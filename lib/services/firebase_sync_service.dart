import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/todo_item.dart';
import '../model/saved_link.dart';
import '../model/firestore_todo_item.dart';
import '../model/firestore_saved_link.dart';
import '../util/todo_database.dart';
import 'saved_link_repository.dart';

class FirebaseSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  bool get isUserSignedIn => _auth.currentUser != null;

  // Todo 동기화
  Future<void> syncTodosToFirestore() async {
    if (!isUserSignedIn) return;
    
    final todos = await TodoDatabase.getTodos();
    final batch = _firestore.batch();
    
    for (final todo in todos) {
      final docRef = _firestore
          .collection(FirestoreTodoItem.collectionName)
          .doc();
      
      batch.set(docRef, FirestoreTodoItem.toFirestore(todo, _userId!));
    }
    
    await batch.commit();
  }

  Future<void> syncTodosFromFirestore() async {
    if (!isUserSignedIn) return;
    
    final snapshot = await _firestore
        .collection(FirestoreTodoItem.collectionName)
        .where('userId', isEqualTo: _userId)
        .get();
    
    final todos = snapshot.docs
        .map((doc) => FirestoreTodoItem.fromFirestore(doc))
        .toList();
    
    // 클라이언트 사이드에서 정렬
    todos.sort((a, b) => b.dueDate.compareTo(a.dueDate));
    
    // 로컬 DB 초기화 후 Firestore 데이터로 대체
    await TodoDatabase.clearAll();
    for (final todo in todos) {
      await TodoDatabase.addTodo(todo);
    }
  }

  // SavedLink 동기화
  Future<void> syncLinksToFirestore() async {
    if (!isUserSignedIn) return;
    
    final repository = SavedLinkRepository();
    final links = await repository.getAllLinks();
    final batch = _firestore.batch();
    
    for (final link in links) {
      final docRef = _firestore
          .collection(FirestoreSavedLink.collectionName)
          .doc();
      
      batch.set(docRef, FirestoreSavedLink.toFirestore(link, _userId!));
    }
    
    await batch.commit();
  }

  Future<void> syncLinksFromFirestore() async {
    if (!isUserSignedIn) return;
    
    final snapshot = await _firestore
        .collection(FirestoreSavedLink.collectionName)
        .where('userId', isEqualTo: _userId)
        .get();
    
    final links = snapshot.docs
        .map((doc) => FirestoreSavedLink.fromFirestore(doc))
        .toList();
    
    // 클라이언트 사이드에서 정렬
    links.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    // 로컬 DB 초기화 후 Firestore 데이터로 대체
    final repository = SavedLinkRepository();
    await repository.clear();
    for (final link in links) {
      await repository.addLink(link);
    }
  }

  // 전체 동기화 (로컬 → Firebase)
  Future<void> uploadAllDataToFirestore() async {
    if (!isUserSignedIn) {
      throw Exception('User must be signed in to sync data');
    }
    
    await Future.wait([
      syncTodosToFirestore(),
      syncLinksToFirestore(),
    ]);
  }

  // 전체 동기화 (Firebase → 로컬)
  Future<void> downloadAllDataFromFirestore() async {
    if (!isUserSignedIn) {
      throw Exception('User must be signed in to sync data');
    }
    
    await Future.wait([
      syncTodosFromFirestore(),
      syncLinksFromFirestore(),
    ]);
  }

  // 실시간 리스너 설정
  Stream<List<TodoItem>> todosStream() {
    if (!isUserSignedIn) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(FirestoreTodoItem.collectionName)
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
          final todos = snapshot.docs
              .map((doc) => FirestoreTodoItem.fromFirestore(doc))
              .toList();
          // 클라이언트 사이드에서 정렬
          todos.sort((a, b) => b.dueDate.compareTo(a.dueDate));
          return todos;
        });
  }

  Stream<List<SavedLink>> savedLinksStream() {
    if (!isUserSignedIn) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(FirestoreSavedLink.collectionName)
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) {
          final links = snapshot.docs
              .map((doc) => FirestoreSavedLink.fromFirestore(doc))
              .toList();
          // 클라이언트 사이드에서 정렬
          links.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return links;
        });
  }

  // 중복 제거 함수
  Future<void> removeDuplicateTodos() async {
    if (!isUserSignedIn) return;
    
    final snapshot = await _firestore
        .collection(FirestoreTodoItem.collectionName)
        .where('userId', isEqualTo: _userId)
        .get();
    
    // 제목과 생성일 기준으로 중복 찾기
    Map<String, List<DocumentSnapshot>> duplicateMap = {};
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final title = data['title'] as String;
      final dueDate = data['dueDate'] as Timestamp;
      final key = '$title-${dueDate.millisecondsSinceEpoch}';
      
      if (duplicateMap[key] == null) {
        duplicateMap[key] = [];
      }
      duplicateMap[key]!.add(doc);
    }
    
    // 중복된 항목들 삭제 (첫 번째 것만 남기고 나머지 삭제)
    final batch = _firestore.batch();
    int deletedCount = 0;
    
    for (var entry in duplicateMap.entries) {
      if (entry.value.length > 1) {
        // 첫 번째 제외하고 나머지 삭제
        for (int i = 1; i < entry.value.length; i++) {
          batch.delete(entry.value[i].reference);
          deletedCount++;
        }
      }
    }
    
    if (deletedCount > 0) {
      await batch.commit();
      print('$deletedCount개의 중복 Todo 항목이 삭제되었습니다.');
    }
  }

  // Todo 개별 CRUD 작업
  Future<String?> addTodoToFirestore(TodoItem todo) async {
    if (!isUserSignedIn) return null;
    
    final docRef = await _firestore
        .collection(FirestoreTodoItem.collectionName)
        .add(FirestoreTodoItem.toFirestore(todo, _userId!));
    
    return docRef.id;
  }

  Future<void> updateTodoInFirestore(TodoItem todo) async {
    if (!isUserSignedIn || todo.firebaseDocId == null) return;
    
    await _firestore
        .collection(FirestoreTodoItem.collectionName)
        .doc(todo.firebaseDocId)
        .update(FirestoreTodoItem.updateFirestore(todo));
  }

  Future<void> deleteTodoFromFirestore(String docId) async {
    if (!isUserSignedIn) return;
    
    await _firestore
        .collection(FirestoreTodoItem.collectionName)
        .doc(docId)
        .delete();
  }

  // SavedLink 중복 제거 함수
  Future<void> removeDuplicateSavedLinks() async {
    if (!isUserSignedIn) return;
    
    final snapshot = await _firestore
        .collection(FirestoreSavedLink.collectionName)
        .where('userId', isEqualTo: _userId)
        .get();
    
    // URL과 생성일 기준으로 중복 찾기
    Map<String, List<DocumentSnapshot>> duplicateMap = {};
    
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final url = data['url'] as String;
      final createdAt = data['createdAt'] as Timestamp;
      final key = '$url-${createdAt.millisecondsSinceEpoch}';
      
      if (duplicateMap[key] == null) {
        duplicateMap[key] = [];
      }
      duplicateMap[key]!.add(doc);
    }
    
    // 중복된 항목들 삭제 (첫 번째 것만 남기고 나머지 삭제)
    final batch = _firestore.batch();
    int deletedCount = 0;
    
    for (var entry in duplicateMap.entries) {
      if (entry.value.length > 1) {
        // 첫 번째 제외하고 나머지 삭제
        for (int i = 1; i < entry.value.length; i++) {
          batch.delete(entry.value[i].reference);
          deletedCount++;
        }
      }
    }
    
    if (deletedCount > 0) {
      await batch.commit();
      print('$deletedCount개의 중복 SavedLink 항목이 삭제되었습니다.');
    }
  }

  // SavedLink 개별 CRUD 작업
  Future<String?> addLinkToFirestore(SavedLink link) async {
    if (!isUserSignedIn) return null;
    
    final docRef = await _firestore
        .collection(FirestoreSavedLink.collectionName)
        .add(FirestoreSavedLink.toFirestore(link, _userId!));
    
    return docRef.id;
  }

  Future<void> updateLinkInFirestore(SavedLink link) async {
    if (!isUserSignedIn || link.firebaseDocId == null) return;
    
    await _firestore
        .collection(FirestoreSavedLink.collectionName)
        .doc(link.firebaseDocId)
        .update(FirestoreSavedLink.updateFirestore(link));
  }

  Future<void> deleteLinkFromFirestore(String docId) async {
    if (!isUserSignedIn) return;
    
    await _firestore
        .collection(FirestoreSavedLink.collectionName)
        .doc(docId)
        .delete();
  }

  // 전체 중복 데이터 정리 함수
  Future<void> cleanupDuplicateData() async {
    if (!isUserSignedIn) return;
    
    print('Firebase 중복 데이터 정리 시작...');
    
    try {
      await Future.wait([
        removeDuplicateTodos(),
        removeDuplicateSavedLinks(),
      ]);
      
      print('Firebase 중복 데이터 정리 완료');
    } catch (e) {
      print('중복 데이터 정리 중 오류 발생: $e');
    }
  }
}