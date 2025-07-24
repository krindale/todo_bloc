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
        .orderBy('createdAt', descending: true)
        .get();
    
    final todos = snapshot.docs
        .map((doc) => FirestoreTodoItem.fromFirestore(doc))
        .toList();
    
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
        .orderBy('createdAt', descending: true)
        .get();
    
    final links = snapshot.docs
        .map((doc) => FirestoreSavedLink.fromFirestore(doc))
        .toList();
    
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
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FirestoreTodoItem.fromFirestore(doc))
            .toList());
  }

  Stream<List<SavedLink>> savedLinksStream() {
    if (!isUserSignedIn) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection(FirestoreSavedLink.collectionName)
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FirestoreSavedLink.fromFirestore(doc))
            .toList());
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
}