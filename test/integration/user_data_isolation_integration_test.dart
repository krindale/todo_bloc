import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/model/todo_item_adapter.dart';
import 'package:todo_bloc/model/saved_link.dart';
import 'package:todo_bloc/util/todo_database.dart';
import 'package:todo_bloc/services/saved_link_repository.dart';
import 'package:todo_bloc/screen/todo_screen.dart';
import 'package:todo_bloc/screen/saved_links_screen.dart';
import 'package:todo_bloc/screen/tabbar/task_tabbar_screen.dart';

@GenerateMocks([FirebaseAuth, User])
import 'user_data_isolation_integration_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser1;
  late MockUser mockUser2;

  setUpAll(() async {
    // 테스트 환경에서는 메모리에서 Hive 초기화
    Hive.init('./test_hive');
    Hive.registerAdapter(TodoItemCompatibleAdapter());
    Hive.registerAdapter(SavedLinkAdapter());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser1 = MockUser();
    mockUser2 = MockUser();
  });

  group('사용자 데이터 격리 통합 테스트', () {
    testWidgets('완전한 사용자 전환 시나리오 테스트', (WidgetTester tester) async {
      // Given: 첫 번째 사용자 로그인
      when(mockUser1.uid).thenReturn('integration_user_1');
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser1);

      // 첫 번째 사용자 데이터 생성
      final user1Todo = TodoItem(
        title: 'User 1 Todo',
        priority: 'High',
        dueDate: DateTime.now(),
        isCompleted: false,
      );
      await TodoDatabase.addTodo(user1Todo);

      final user1Repository = SavedLinkRepository();
      await user1Repository.init();
      final user1Link = SavedLink(
        title: 'User 1 Link',
        url: 'https://user1.com',
        category: 'Work',
        colorValue: 0xFF6366F1,
        createdAt: DateTime.now(),
      );
      await user1Repository.addLink(user1Link);

      // 첫 번째 사용자 데이터 확인
      final user1Todos = await TodoDatabase.getTodos();
      final user1Links = await user1Repository.getAllLinks();
      expect(user1Todos.length, 1);
      expect(user1Links.length, 1);
      expect(user1Todos.first.title, 'User 1 Todo');
      expect(user1Links.first.title, 'User 1 Link');

      // When: 첫 번째 사용자 로그아웃 (데이터 완전 삭제)
      await TodoDatabase.clearUserData();
      await user1Repository.clearUserData();

      // 두 번째 사용자 로그인
      when(mockUser2.uid).thenReturn('integration_user_2');
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser2);

      // 두 번째 사용자 데이터 생성
      final user2Todo = TodoItem(
        title: 'User 2 Todo',
        priority: 'Medium',
        dueDate: DateTime.now(),
        isCompleted: true,
      );
      await TodoDatabase.addTodo(user2Todo);

      final user2Repository = SavedLinkRepository();
      await user2Repository.init();
      final user2Link = SavedLink(
        title: 'User 2 Link',
        url: 'https://user2.com',
        category: 'Personal',
        colorValue: 0xFF8B5CF6,
        createdAt: DateTime.now(),
      );
      await user2Repository.addLink(user2Link);

      // Then: 두 번째 사용자는 첫 번째 사용자 데이터에 접근할 수 없어야 함
      final user2Todos = await TodoDatabase.getTodos();
      final user2Links = await user2Repository.getAllLinks();
      expect(user2Todos.length, 1);
      expect(user2Links.length, 1);
      expect(user2Todos.first.title, 'User 2 Todo');
      expect(user2Links.first.title, 'User 2 Link');

      // 첫 번째 사용자로 다시 전환
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser1);
      final backToUser1Todos = await TodoDatabase.getTodos();
      expect(backToUser1Todos.length, 0); // 로그아웃 시 삭제되었으므로
    });

    testWidgets('UI 레벨 사용자 전환 테스트', (WidgetTester tester) async {
      // Given: 첫 번째 사용자로 앱 시작
      when(mockUser1.uid).thenReturn('ui_user_1');
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser1);

      await tester.pumpWidget(
        MaterialApp(
          home: TaskTabbarScreen(),
          routes: {
            '/login': (context) => Scaffold(body: Text('Login Screen')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // TodoScreen에서 할 일 추가
      await tester.enterText(find.byType(TextFormField).first, 'UI User 1 Todo');
      await tester.tap(find.text('추가'));
      await tester.pumpAndSettle();

      // SavedLinks 탭으로 이동하여 링크 추가 시뮬레이션
      await tester.tap(find.text('Saved Links'));
      await tester.pumpAndSettle();

      // When: 로그아웃 (사용자 전환 시뮬레이션)
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('로그아웃'));
      await tester.pumpAndSettle();

      // Then: 로그인 화면으로 이동되어야 함
      expect(find.text('Login Screen'), findsOneWidget);

      // 두 번째 사용자 로그인 시뮬레이션
      when(mockUser2.uid).thenReturn('ui_user_2');
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser2);

      // 다시 메인 화면으로 이동
      await tester.pumpWidget(
        MaterialApp(
          home: TaskTabbarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // 두 번째 사용자는 빈 상태에서 시작해야 함
      expect(find.text('UI User 1 Todo'), findsNothing);
    });

    testWidgets('동시 사용자 데이터 생성 및 격리 테스트', (WidgetTester tester) async {
      // Given: 여러 사용자 시뮬레이션
      final users = [
        {'id': 'concurrent_user_1', 'mock': MockUser()},
        {'id': 'concurrent_user_2', 'mock': MockUser()},
        {'id': 'concurrent_user_3', 'mock': MockUser()},
      ];

      final userTasks = <String, List<TodoItem>>{};
      final userLinks = <String, List<SavedLink>>{};

      // When: 각 사용자별로 데이터 생성
      for (final user in users) {
        final userId = user['id'] as String;
        final userMock = user['mock'] as MockUser;
        
        when(userMock.uid).thenReturn(userId);
        when(mockFirebaseAuth.currentUser).thenReturn(userMock);

        // 사용자별 고유 할 일 생성
        final todo = TodoItem(
          title: 'Todo for $userId',
          priority: 'High',
          dueDate: DateTime.now(),
          isCompleted: false,
        );
        await TodoDatabase.addTodo(todo);
        userTasks[userId] = await TodoDatabase.getTodos();

        // 사용자별 고유 링크 생성
        final repository = SavedLinkRepository();
        await repository.init();
        final link = SavedLink(
          title: 'Link for $userId',
          url: 'https://$userId.com',
          category: 'Work',
          colorValue: 0xFF6366F1,
          createdAt: DateTime.now(),
        );
        await repository.addLink(link);
        userLinks[userId] = await repository.getAllLinks();
      }

      // Then: 각 사용자의 데이터가 독립적으로 관리되어야 함
      for (final user in users) {
        final userId = user['id'] as String;
        
        expect(userTasks[userId]?.length, 1);
        expect(userLinks[userId]?.length, 1);
        expect(userTasks[userId]?.first.title, 'Todo for $userId');
        expect(userLinks[userId]?.first.title, 'Link for $userId');
        
        // 다른 사용자의 데이터와 중복되지 않는지 확인
        for (final otherUser in users) {
          final otherUserId = otherUser['id'] as String;
          if (userId != otherUserId) {
            expect(userTasks[userId]?.first.title, 
                   isNot(equals('Todo for $otherUserId')));
            expect(userLinks[userId]?.first.title, 
                   isNot(equals('Link for $otherUserId')));
          }
        }
      }
    });

    testWidgets('사용자 데이터 CRUD 완전성 테스트', (WidgetTester tester) async {
      // Given: 테스트 사용자
      when(mockUser1.uid).thenReturn('crud_integration_user');
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser1);

      // Create - 데이터 생성
      final originalTodo = TodoItem(
        title: 'CRUD Integration Todo',
        priority: 'High',
        dueDate: DateTime.now(),
        isCompleted: false,
        firebaseDocId: 'test_doc_id',
      );
      await TodoDatabase.addTodo(originalTodo);

      final repository = SavedLinkRepository();
      await repository.init();
      final originalLink = SavedLink(
        title: 'CRUD Integration Link',
        url: 'https://crud.com',
        category: 'Work',
        colorValue: 0xFF6366F1,
        createdAt: DateTime.now(),
        firebaseDocId: 'test_link_doc_id',
      );
      await repository.addLink(originalLink);

      // Read - 데이터 읽기
      var todos = await TodoDatabase.getTodos();
      var links = await repository.getAllLinks();
      expect(todos.length, 1);
      expect(links.length, 1);

      // Update - 데이터 수정
      final updatedTodo = TodoItem(
        title: 'Updated CRUD Todo',
        priority: 'Medium',
        dueDate: DateTime.now(),
        isCompleted: true,
        firebaseDocId: 'test_doc_id',
      );
      await TodoDatabase.updateTodo(0, updatedTodo);

      final updatedLink = SavedLink(
        title: 'Updated CRUD Link',
        url: 'https://updated-crud.com',
        category: 'Personal',
        colorValue: 0xFF8B5CF6,
        createdAt: DateTime.now(),
        firebaseDocId: 'test_link_doc_id',
      );
      await repository.updateLink(0, updatedLink);

      // 수정 확인
      todos = await TodoDatabase.getTodos();
      links = await repository.getAllLinks();
      expect(todos.first.title, 'Updated CRUD Todo');
      expect(todos.first.isCompleted, true);
      expect(links.first.title, 'Updated CRUD Link');
      expect(links.first.category, 'Personal');

      // Delete - 데이터 삭제
      await TodoDatabase.deleteTodo(0);
      await repository.deleteLink(links.first);

      // 삭제 확인
      todos = await TodoDatabase.getTodos();
      links = await repository.getAllLinks();
      expect(todos.length, 0);
      expect(links.length, 0);
    });

    testWidgets('대용량 데이터 처리 및 성능 테스트', (WidgetTester tester) async {
      // Given: 성능 테스트 사용자
      when(mockUser1.uid).thenReturn('performance_user');
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser1);

      final repository = SavedLinkRepository();
      await repository.init();

      // When: 대량의 데이터 생성
      const itemCount = 100;
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < itemCount; i++) {
        final todo = TodoItem(
          title: 'Performance Todo $i',
          priority: i % 3 == 0 ? 'High' : i % 3 == 1 ? 'Medium' : 'Low',
          dueDate: DateTime.now().add(Duration(days: i)),
          isCompleted: i % 4 == 0,
        );
        await TodoDatabase.addTodo(todo);

        final link = SavedLink(
          title: 'Performance Link $i',
          url: 'https://performance$i.com',
          category: i % 2 == 0 ? 'Work' : 'Personal',
          colorValue: 0xFF6366F1,
          createdAt: DateTime.now().subtract(Duration(minutes: i)),
        );
        await repository.addLink(link);
      }

      stopwatch.stop();

      // Then: 성능 및 정확성 검증
      final todos = await TodoDatabase.getTodos();
      final links = await repository.getAllLinks();
      
      expect(todos.length, itemCount);
      expect(links.length, itemCount);
      expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // 10초 이내

      // 데이터 무결성 검증
      for (int i = 0; i < 10; i++) { // 샘플 검증
        expect(todos.any((todo) => todo.title == 'Performance Todo $i'), true);
        expect(links.any((link) => link.title == 'Performance Link $i'), true);
      }
    });
  });

  tearDown(() async {
    // 각 테스트 후 정리
    try {
      await TodoDatabase.clearUserData();
      final repository = SavedLinkRepository();
      await repository.clearUserData();
    } catch (e) {
      // 테스트 환경에서는 예외 무시
    }
  });

  tearDownAll(() async {
    await Hive.close();
  });
}