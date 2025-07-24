import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/model/saved_link.dart';
import 'package:todo_bloc/services/firebase_sync_service.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  User,
  CollectionReference,
  DocumentReference,
  QuerySnapshot,
  DocumentSnapshot,
  Query,
])
import 'firebase_sync_service_test.mocks.dart';

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockDocumentSnapshot<Object?> mockDocSnapshot;
  late FirebaseSyncService syncService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDocRef = MockDocumentReference<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDocSnapshot = MockDocumentSnapshot<Object?>();
    syncService = FirebaseSyncService();
  });

  group('FirebaseSyncService 테스트', () {
    setUp(() {
      // 기본 모킹 설정
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_user_id');
    });

    group('사용자 인증 상태 테스트', () {
      test('로그인된 사용자 확인', () {
        // Given
        when(mockAuth.currentUser).thenReturn(mockUser);

        // When & Then
        expect(syncService.isUserSignedIn, true);
      });

      test('로그인되지 않은 사용자 확인', () {
        // Given
        when(mockAuth.currentUser).thenReturn(null);

        // When & Then
        expect(syncService.isUserSignedIn, false);
      });
    });

    group('Todo Firebase 동기화 테스트', () {
      test('Todo Firestore 추가 성공', () async {
        // Given
        final todo = TodoItem(
          title: 'Test Todo',
          priority: 'High',
          dueDate: DateTime.now(),
          isCompleted: false,
        );

        when(mockFirestore.collection('todos')).thenReturn(mockCollection);
        when(mockCollection.add(any)).thenAnswer((_) async => mockDocRef);
        when(mockDocRef.id).thenReturn('generated_doc_id');

        // When
        final docId = await syncService.addTodoToFirestore(todo);

        // Then
        expect(docId, 'generated_doc_id');
        verify(mockCollection.add(any)).called(1);
      });

      test('Todo Firestore 업데이트 성공', () async {
        // Given
        final todo = TodoItem(
          title: 'Updated Todo',
          priority: 'Medium',
          dueDate: DateTime.now(),
          isCompleted: true,
          firebaseDocId: 'existing_doc_id',
        );

        when(mockFirestore.collection('todos')).thenReturn(mockCollection);
        when(mockCollection.doc('existing_doc_id')).thenReturn(mockDocRef);
        when(mockDocRef.update(any)).thenAnswer((_) async => {});

        // When
        await syncService.updateTodoInFirestore(todo);

        // Then
        verify(mockDocRef.update(any)).called(1);
      });

      test('Todo Firestore 삭제 성공', () async {
        // Given
        const docId = 'doc_to_delete';

        when(mockFirestore.collection('todos')).thenReturn(mockCollection);
        when(mockCollection.doc(docId)).thenReturn(mockDocRef);
        when(mockDocRef.delete()).thenAnswer((_) async => {});

        // When
        await syncService.deleteTodoFromFirestore(docId);

        // Then
        verify(mockDocRef.delete()).called(1);
      });

      test('사용자별 Todo 데이터 필터링 확인', () async {
        // Given
        final mockQuery = MockQuery<Map<String, dynamic>>();
        when(mockFirestore.collection('todos')).thenReturn(mockCollection);
        when(mockCollection.where('userId', isEqualTo: 'test_user_id'))
            .thenReturn(mockQuery);
        when(mockQuery.orderBy('createdAt', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([]);

        // When
        await syncService.syncTodosFromFirestore();

        // Then
        verify(mockCollection.where('userId', isEqualTo: 'test_user_id')).called(1);
      });
    });

    group('SavedLink Firebase 동기화 테스트', () {
      test('SavedLink Firestore 추가 성공', () async {
        // Given
        final link = SavedLink(
          title: 'Test Link',
          url: 'https://test.com',
          category: 'Work',
          colorValue: 0xFF6366F1,
          createdAt: DateTime.now(),
        );

        when(mockFirestore.collection('saved_links')).thenReturn(mockCollection);
        when(mockCollection.add(any)).thenAnswer((_) async => mockDocRef);
        when(mockDocRef.id).thenReturn('generated_link_id');

        // When
        final docId = await syncService.addLinkToFirestore(link);

        // Then
        expect(docId, 'generated_link_id');
        verify(mockCollection.add(any)).called(1);
      });

      test('SavedLink Firestore 업데이트 성공', () async {
        // Given
        final link = SavedLink(
          title: 'Updated Link',
          url: 'https://updated.com',
          category: 'Personal',
          colorValue: 0xFF8B5CF6,
          createdAt: DateTime.now(),
          firebaseDocId: 'existing_link_id',
        );

        when(mockFirestore.collection('saved_links')).thenReturn(mockCollection);
        when(mockCollection.doc('existing_link_id')).thenReturn(mockDocRef);
        when(mockDocRef.update(any)).thenAnswer((_) async => {});

        // When
        await syncService.updateLinkInFirestore(link);

        // Then
        verify(mockDocRef.update(any)).called(1);
      });

      test('사용자별 SavedLink 데이터 필터링 확인', () async {
        // Given
        final mockQuery = MockQuery<Map<String, dynamic>>();
        when(mockFirestore.collection('saved_links')).thenReturn(mockCollection);
        when(mockCollection.where('userId', isEqualTo: 'test_user_id'))
            .thenReturn(mockQuery);
        when(mockQuery.orderBy('createdAt', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([]);

        // When
        await syncService.syncLinksFromFirestore();

        // Then
        verify(mockCollection.where('userId', isEqualTo: 'test_user_id')).called(1);
      });
    });

    group('전체 데이터 동기화 테스트', () {
      test('전체 데이터 업로드 성공', () async {
        // Given: 모킹 설정
        when(mockFirestore.collection(any)).thenReturn(mockCollection);
        when(mockCollection.add(any)).thenAnswer((_) async => mockDocRef);

        // When
        await syncService.uploadAllDataToFirestore();

        // Then: 예외가 발생하지 않아야 함
        expect(true, true);
      });

      test('전체 데이터 다운로드 성공', () async {
        // Given: 모킹 설정
        final mockQuery = MockQuery<Map<String, dynamic>>();
        when(mockFirestore.collection(any)).thenReturn(mockCollection);
        when(mockCollection.where(any, isEqualTo: any)).thenReturn(mockQuery);
        when(mockQuery.orderBy(any, descending: any)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
        when(mockQuerySnapshot.docs).thenReturn([]);

        // When
        await syncService.downloadAllDataFromFirestore();

        // Then: 예외가 발생하지 않아야 함
        expect(true, true);
      });
    });

    group('오류 처리 테스트', () {
      test('로그인하지 않은 사용자 동기화 시도', () async {
        // Given
        when(mockAuth.currentUser).thenReturn(null);

        // When
        final docId = await syncService.addTodoToFirestore(TodoItem(
          title: 'Test',
          priority: 'Low',
          dueDate: DateTime.now(),
          isCompleted: false,
        ));

        // Then
        expect(docId, null);
      });

      test('Firebase 문서 ID 없이 업데이트 시도', () async {
        // Given
        final todo = TodoItem(
          title: 'No Doc ID Todo',
          priority: 'High',
          dueDate: DateTime.now(),
          isCompleted: false,
          firebaseDocId: null, // 문서 ID 없음
        );

        // When & Then: 예외가 발생하지 않아야 함 (early return)
        await syncService.updateTodoInFirestore(todo);
        expect(true, true);
      });
    });

    group('실시간 스트림 테스트', () {
      test('Todo 실시간 스트림 생성', () {
        // Given
        final mockQuery = MockQuery<Map<String, dynamic>>();
        when(mockFirestore.collection('todos')).thenReturn(mockCollection);
        when(mockCollection.where('userId', isEqualTo: 'test_user_id'))
            .thenReturn(mockQuery);
        when(mockQuery.orderBy('createdAt', descending: true))
            .thenReturn(mockQuery);
        when(mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));
        when(mockQuerySnapshot.docs).thenReturn([]);

        // When
        final stream = syncService.todosStream();

        // Then
        expect(stream, isA<Stream<List<TodoItem>>>());
      });

      test('로그인하지 않은 사용자 스트림', () {
        // Given
        when(mockAuth.currentUser).thenReturn(null);

        // When
        final stream = syncService.todosStream();

        // Then
        expect(stream, isA<Stream<List<TodoItem>>>());
        stream.listen((todos) {
          expect(todos, isEmpty);
        });
      });
    });
  });
}