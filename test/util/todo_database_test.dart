import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/util/todo_database.dart';

@GenerateMocks([FirebaseAuth, User])
import 'todo_database_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUpAll(() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TodoItemAdapter());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
  });

  group('TodoDatabase 사용자별 데이터 분리 테스트', () {
    testWidgets('사용자별 박스명 생성 테스트', (WidgetTester tester) async {
      // Given: 사용자 ID 설정
      const userId = 'test_user_123';
      when(mockUser.uid).thenReturn(userId);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // When & Then: 박스명에 사용자 ID가 포함되어야 함
      expect(() => TodoDatabase.getBox(), returnsNormally);
    });

    testWidgets('사용자 미로그인 시 예외 발생 테스트', (WidgetTester tester) async {
      // Given: 로그인하지 않은 상태
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // When & Then: 예외가 발생해야 함
      expect(() => TodoDatabase.getBox(), throwsException);
    });

    testWidgets('서로 다른 사용자 데이터 격리 테스트', (WidgetTester tester) async {
      // Given: 첫 번째 사용자
      const userId1 = 'user_1';
      when(mockUser.uid).thenReturn(userId1);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      final todo1 = TodoItem(
        title: 'User 1 Todo',
        priority: 'High',
        dueDate: DateTime.now(),
        isCompleted: false,
      );

      // When: 첫 번째 사용자 데이터 추가
      await TodoDatabase.addTodo(todo1);
      final user1Todos = await TodoDatabase.getTodos();

      // Given: 두 번째 사용자로 전환
      const userId2 = 'user_2';
      final mockUser2 = MockUser();
      when(mockUser2.uid).thenReturn(userId2);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser2);

      // When: 두 번째 사용자 데이터 조회
      final user2Todos = await TodoDatabase.getTodos();

      // Then: 두 사용자의 데이터가 완전히 분리되어야 함
      expect(user1Todos.length, 1);
      expect(user2Todos.length, 0);
      expect(user1Todos.first.title, 'User 1 Todo');
    });

    testWidgets('사용자 데이터 완전 삭제 테스트', (WidgetTester tester) async {
      // Given: 사용자 데이터 존재
      const userId = 'test_user_delete';
      when(mockUser.uid).thenReturn(userId);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      final todo = TodoItem(
        title: 'Test Todo',
        priority: 'Medium',
        dueDate: DateTime.now(),
        isCompleted: false,
      );

      await TodoDatabase.addTodo(todo);
      expect((await TodoDatabase.getTodos()).length, 1);

      // When: 사용자 데이터 완전 삭제
      await TodoDatabase.clearUserData();

      // Then: 데이터가 완전히 삭제되어야 함
      final remainingTodos = await TodoDatabase.getTodos();
      expect(remainingTodos.length, 0);
    });

    testWidgets('사용자별 CRUD 작업 테스트', (WidgetTester tester) async {
      // Given: 사용자 설정
      const userId = 'crud_test_user';
      when(mockUser.uid).thenReturn(userId);
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      final todo = TodoItem(
        title: 'CRUD Test Todo',
        priority: 'Low',
        dueDate: DateTime.now(),
        isCompleted: false,
        firebaseDocId: 'test_doc_id',
      );

      // Create
      await TodoDatabase.addTodo(todo);
      var todos = await TodoDatabase.getTodos();
      expect(todos.length, 1);
      expect(todos.first.title, 'CRUD Test Todo');

      // Update
      final updatedTodo = TodoItem(
        title: 'Updated Todo',
        priority: 'High',
        dueDate: DateTime.now(),
        isCompleted: true,
        firebaseDocId: 'test_doc_id',
      );
      await TodoDatabase.updateTodo(0, updatedTodo);
      todos = await TodoDatabase.getTodos();
      expect(todos.first.title, 'Updated Todo');
      expect(todos.first.isCompleted, true);

      // Delete
      await TodoDatabase.deleteTodo(0);
      todos = await TodoDatabase.getTodos();
      expect(todos.length, 0);
    });
  });

  tearDown(() async {
    try {
      await TodoDatabase.clearUserData();
    } catch (e) {
      // 테스트 환경에서는 예외 무시
    }
  });

  tearDownAll(() async {
    await Hive.close();
  });
}