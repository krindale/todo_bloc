import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_bloc/model/saved_link.dart';
import 'package:todo_bloc/services/saved_link_repository.dart';

@GenerateMocks([FirebaseAuth, User])
import 'saved_link_repository_user_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;
  late SavedLinkRepository repository;

  setUpAll() async {
    await Hive.initFlutter();
    Hive.registerAdapter(SavedLinkAdapter());
  }

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    repository = SavedLinkRepository();
  });

  group('SavedLinkRepository 사용자별 데이터 분리 테스트', () {
    testWidgets('사용자별 SavedLink 데이터 격리 테스트', (WidgetTester tester) async {
      // Given: 첫 번째 사용자
      const userId1 = 'saved_link_user_1';
      when(mockUser.uid).thenReturn(userId1);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      await repository.init();

      final link1 = SavedLink(
        title: 'User 1 Link',
        url: 'https://user1.com',
        category: 'Work',
        colorValue: 0xFF6366F1,
        createdAt: DateTime.now(),
      );

      // When: 첫 번째 사용자 링크 추가
      await repository.addLink(link1);
      final user1Links = repository.getAllLinks();

      // Given: 두 번째 사용자로 전환
      const userId2 = 'saved_link_user_2';
      final mockUser2 = MockUser();
      when(mockUser2.uid).thenReturn(userId2);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser2);

      final repository2 = SavedLinkRepository();
      await repository2.init();

      // When: 두 번째 사용자 데이터 조회
      final user2Links = repository2.getAllLinks();

      // Then: 두 사용자의 데이터가 완전히 분리되어야 함
      expect(user1Links.length, 1);
      expect(user2Links.length, 0);
      expect(user1Links.first.title, 'User 1 Link');
    });

    testWidgets('SavedLink 사용자 데이터 완전 삭제 테스트', (WidgetTester tester) async {
      // Given: 사용자 데이터 존재
      const userId = 'saved_link_delete_user';
      when(mockUser.uid).thenReturn(userId);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      await repository.init();

      final link = SavedLink(
        title: 'Delete Test Link',
        url: 'https://delete.com',
        category: 'Personal',
        colorValue: 0xFF8B5CF6,
        createdAt: DateTime.now(),
      );

      await repository.addLink(link);
      expect(repository.getAllLinks().length, 1);

      // When: 사용자 데이터 완전 삭제
      await repository.clearUserData();

      // Then: 데이터가 완전히 삭제되어야 함
      final newRepository = SavedLinkRepository();
      await newRepository.init();
      expect(newRepository.getAllLinks().length, 0);
    });

    testWidgets('SavedLink CRUD 작업 사용자별 분리 테스트', (WidgetTester tester) async {
      // Given: 사용자 설정
      const userId = 'saved_link_crud_user';
      when(mockUser.uid).thenReturn(userId);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      await repository.init();

      final link = SavedLink(
        title: 'CRUD Test Link',
        url: 'https://crud.com',
        category: 'Shopping',
        colorValue: 0xFFEC4899,
        createdAt: DateTime.now(),
        firebaseDocId: 'test_link_doc_id',
      );

      // Create
      await repository.addLink(link);
      var links = repository.getAllLinks();
      expect(links.length, 1);
      expect(links.first.title, 'CRUD Test Link');

      // Update
      final updatedLink = SavedLink(
        title: 'Updated Link',
        url: 'https://updated.com',
        category: 'Health',
        colorValue: 0xFF10B981,
        createdAt: DateTime.now(),
        firebaseDocId: 'test_link_doc_id',
      );
      await repository.updateLink(0, updatedLink);
      links = repository.getAllLinks();
      expect(links.first.title, 'Updated Link');
      expect(links.first.category, 'Health');

      // Delete
      await repository.deleteLink(links.first);
      links = repository.getAllLinks();
      expect(links.length, 0);
    });

    testWidgets('동시 다중 사용자 데이터 처리 테스트', (WidgetTester tester) async {
      // Given: 다수의 사용자 시뮬레이션
      final userIds = ['user_A', 'user_B', 'user_C'];
      final repositories = <SavedLinkRepository>[];

      for (int i = 0; i < userIds.length; i++) {
        final mockUserForTest = MockUser();
        when(mockUserForTest.uid).thenReturn(userIds[i]);
        when(mockFirebaseAuth.currentUser).thenReturn(mockUserForTest);

        final repo = SavedLinkRepository();
        await repo.init();

        final link = SavedLink(
          title: 'Link for ${userIds[i]}',
          url: 'https://${userIds[i]}.com',
          category: 'Work',
          colorValue: 0xFF6366F1,
          createdAt: DateTime.now(),
        );

        await repo.addLink(link);
        repositories.add(repo);
      }

      // Then: 각 사용자의 데이터가 독립적으로 관리되어야 함
      for (int i = 0; i < repositories.length; i++) {
        final links = repositories[i].getAllLinks();
        expect(links.length, 1);
        expect(links.first.title, 'Link for ${userIds[i]}');
      }
    });
  });

  tearDown(() async {
    try {
      await repository.clearUserData();
    } catch (e) {
      // 테스트 환경에서는 예외 무시
    }
  });

  tearDownAll(() async {
    await Hive.close();
  });
}