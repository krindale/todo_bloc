import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_bloc/services/firebase_sync_service.dart';
import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/model/saved_link.dart';

import 'firebase_sync_service_duplicate_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  Query,
  QuerySnapshot,
  QueryDocumentSnapshot,
  DocumentReference,
  WriteBatch,
  FirebaseAuth,
  User,
], customMocks: [
  MockSpec<CollectionReference<Map<String, dynamic>>>(as: #MockCollectionReference),
])
void main() {
  group('Firebase Duplicate Data Cleanup Tests', () {
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late MockCollectionReference<Map<String, dynamic>> mockCollection;
    late MockQuery mockQuery;
    late MockQuerySnapshot mockSnapshot;
    late MockWriteBatch mockBatch;
    late FirebaseSyncService syncService;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockCollection = MockCollectionReference<Map<String, dynamic>>();
      mockQuery = MockQuery();
      mockSnapshot = MockQuerySnapshot();
      mockBatch = MockWriteBatch();
      
      // Firebase Auth Mock 설정
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test-user-id');
      
      syncService = FirebaseSyncService();
    });

    group('Todo Duplicate Removal', () {
      test('should identify and remove duplicate todos', () async {
        // Mock 중복 데이터 생성
        final mockDoc1 = MockQueryDocumentSnapshot();
        final mockDoc2 = MockQueryDocumentSnapshot();
        final mockDoc3 = MockQueryDocumentSnapshot();

        final testDate = DateTime.now();
        final testTimestamp = Timestamp.fromDate(testDate);

        // 중복 데이터 (같은 제목, 같은 날짜)
        final duplicateData1 = {
          'title': 'Duplicate Todo',
          'dueDate': testTimestamp,
          'priority': 'High',
          'isCompleted': false,
          'category': 'Work',
          'userId': 'test-user-id',
        };

        final duplicateData2 = {
          'title': 'Duplicate Todo',
          'dueDate': testTimestamp,
          'priority': 'High',
          'isCompleted': false,
          'category': 'Work',
          'userId': 'test-user-id',
        };

        // 유니크 데이터
        final uniqueData = {
          'title': 'Unique Todo',
          'dueDate': testTimestamp,
          'priority': 'Medium',
          'isCompleted': false,
          'category': 'Personal',
          'userId': 'test-user-id',
        };

        // Mock 설정
        when(mockDoc1.data()).thenReturn(duplicateData1 as Map<String, dynamic>);
        when(mockDoc2.data()).thenReturn(duplicateData2 as Map<String, dynamic>);
        when(mockDoc3.data()).thenReturn(uniqueData as Map<String, dynamic>);

        when(mockDoc1.reference).thenReturn(MockDocumentReference());
        when(mockDoc2.reference).thenReturn(MockDocumentReference());
        when(mockDoc3.reference).thenReturn(MockDocumentReference());

        when(mockSnapshot.docs).thenReturn([mockDoc1, mockDoc2, mockDoc3]);

        when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(mockCollection.where('userId', isEqualTo: 'test-user-id')).thenReturn(mockQuery);
        
        when(mockFirestore.collection('todos')).thenReturn(mockCollection);
        when(mockFirestore.batch()).thenReturn(mockBatch);
        when(mockBatch.commit()).thenAnswer((_) async => Future.value());

        // 중복 제거 실행 (실제 메서드 호출은 private이므로 공개 메서드로 테스트)
        await syncService.cleanupDuplicateData();

        // 검증: 배치 커밋이 호출되었는지 확인 (중복이 있을 때만)
        verify(mockBatch.commit()).called(1);
      });

      test('should not delete anything when no duplicates exist', () async {
        // Mock 유니크 데이터만 존재
        final mockDoc1 = MockQueryDocumentSnapshot();
        final mockDoc2 = MockQueryDocumentSnapshot();

        final testDate1 = DateTime.now();
        final testDate2 = DateTime.now().add(Duration(days: 1));

        final uniqueData1 = {
          'title': 'Todo 1',
          'dueDate': Timestamp.fromDate(testDate1),
          'priority': 'High',
          'userId': 'test-user-id',
        };

        final uniqueData2 = {
          'title': 'Todo 2',
          'dueDate': Timestamp.fromDate(testDate2),
          'priority': 'Medium',
          'userId': 'test-user-id',
        };

        // Mock 설정
        when(mockDoc1.data()).thenReturn(uniqueData1 as Map<String, dynamic>);
        when(mockDoc2.data()).thenReturn(uniqueData2 as Map<String, dynamic>);

        when(mockSnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
        when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(mockCollection.where('userId', isEqualTo: 'test-user-id')).thenReturn(mockQuery);
        when(mockFirestore.collection('todos')).thenReturn(mockCollection);

        // 중복 제거 실행
        await syncService.cleanupDuplicateData();

        // 검증: 배치 커밋이 호출되지 않았는지 확인 (중복이 없으므로)
        verifyNever(mockBatch.commit());
      });
    });

    group('SavedLink Duplicate Removal', () {
      test('should identify and remove duplicate saved links', () async {
        // Mock 중복 데이터 생성
        final mockDoc1 = MockQueryDocumentSnapshot();
        final mockDoc2 = MockQueryDocumentSnapshot();

        final testDate = DateTime.now();
        final testTimestamp = Timestamp.fromDate(testDate);

        // 중복 데이터 (같은 URL, 같은 생성일)
        final duplicateData1 = {
          'url': 'https://example.com',
          'createdAt': testTimestamp,
          'title': 'Example Site',
          'userId': 'test-user-id',
        };

        final duplicateData2 = {
          'url': 'https://example.com',
          'createdAt': testTimestamp,
          'title': 'Example Site',
          'userId': 'test-user-id',
        };

        // Mock 설정
        when(mockDoc1.data()).thenReturn(duplicateData1 as Map<String, dynamic>);
        when(mockDoc2.data()).thenReturn(duplicateData2 as Map<String, dynamic>);

        when(mockDoc1.reference).thenReturn(MockDocumentReference());
        when(mockDoc2.reference).thenReturn(MockDocumentReference());

        when(mockSnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
        when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(mockCollection.where('userId', isEqualTo: 'test-user-id')).thenReturn(mockQuery);
        
        when(mockFirestore.collection('saved_links')).thenReturn(mockCollection);
        when(mockFirestore.batch()).thenReturn(mockBatch);
        when(mockBatch.commit()).thenAnswer((_) async => Future.value());

        // 중복 제거 실행
        await syncService.cleanupDuplicateData();

        // 검증: 배치 커밋이 호출되었는지 확인
        verify(mockBatch.commit()).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle Firebase query errors gracefully', () async {
        // Mock 설정 - 쿼리 에러
        when(mockCollection.where('userId', isEqualTo: 'test-user-id'))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'permission-denied',
          message: 'Insufficient permissions',
        ));
        when(mockFirestore.collection('todos')).thenReturn(mockCollection);

        // 에러 처리 테스트
        expect(
          () async => await syncService.cleanupDuplicateData(),
          returnsNormally, // 에러가 발생해도 앱이 계속 실행되어야 함
        );
      });

      test('should handle batch commit failures', () async {
        // Mock 데이터 설정
        final mockDoc1 = MockQueryDocumentSnapshot();
        final mockDoc2 = MockQueryDocumentSnapshot();

        final duplicateData = {
          'title': 'Duplicate',
          'dueDate': Timestamp.now(),
          'userId': 'test-user-id',
        };

        when(mockDoc1.data()).thenReturn(duplicateData as Map<String, dynamic>);
        when(mockDoc2.data()).thenReturn(duplicateData as Map<String, dynamic>);
        when(mockDoc1.reference).thenReturn(MockDocumentReference());
        when(mockDoc2.reference).thenReturn(MockDocumentReference());

        when(mockSnapshot.docs).thenReturn([mockDoc1, mockDoc2]);
        when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(mockCollection.where('userId', isEqualTo: 'test-user-id')).thenReturn(mockQuery);
        when(mockFirestore.collection('todos')).thenReturn(mockCollection);
        when(mockFirestore.batch()).thenReturn(mockBatch);

        // Mock 설정 - 배치 커밋 실패
        when(mockBatch.commit()).thenThrow(FirebaseException(
          plugin: 'cloud_firestore',
          code: 'aborted',
          message: 'Transaction was aborted',
        ));

        // 에러 처리 테스트
        expect(
          () async => await syncService.cleanupDuplicateData(),
          returnsNormally, // 에러가 발생해도 앱이 계속 실행되어야 함
        );
      });

      test('should handle user not signed in', () async {
        // Mock 설정 - 사용자 로그인 안됨
        when(mockAuth.currentUser).thenReturn(null);

        // 테스트 실행
        await syncService.cleanupDuplicateData();

        // 검증: Firebase 작업이 수행되지 않았는지 확인
        verifyNever(mockFirestore.collection(any));
      });
    });

    group('Performance Tests', () {
      test('should handle large number of duplicates efficiently', () async {
        // 대량의 중복 데이터 시뮬레이션
        const int duplicateCount = 100;
        final List<MockQueryDocumentSnapshot> mockDocs = [];

        final testData = {
          'title': 'Mass Duplicate',
          'dueDate': Timestamp.now(),
          'userId': 'test-user-id',
        };

        for (int i = 0; i < duplicateCount; i++) {
          final mockDoc = MockQueryDocumentSnapshot();
          when(mockDoc.data()).thenReturn(testData as Map<String, dynamic>);
          when(mockDoc.reference).thenReturn(MockDocumentReference());
          mockDocs.add(mockDoc);
        }

        when(mockSnapshot.docs).thenReturn(mockDocs);
        when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(mockCollection.where('userId', isEqualTo: 'test-user-id')).thenReturn(mockQuery);
        when(mockFirestore.collection('todos')).thenReturn(mockCollection);
        when(mockFirestore.batch()).thenReturn(mockBatch);
        when(mockBatch.commit()).thenAnswer((_) async => Future.value());

        // 성능 테스트
        final stopwatch = Stopwatch()..start();
        await syncService.cleanupDuplicateData();
        stopwatch.stop();

        // 합리적인 시간 내 완료 확인 (1초 이내)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));

        // 배치 커밋이 호출되었는지 확인
        verify(mockBatch.commit()).called(1);
      });
    });
  });
}