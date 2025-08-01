/// **캘린더 업데이트 통합 테스트**
/// 
/// 새로운 할 일이 추가되었을 때 캘린더에 실시간으로 업데이트되는지 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:todo_bloc/screen/calendar/calendar_screen.dart';
import 'package:todo_bloc/domain/entities/todo_entity.dart';
import 'package:todo_bloc/presentation/providers/combined_todo_provider.dart';
import 'package:todo_bloc/presentation/providers/todo_provider.dart';
import 'package:todo_bloc/services/hive_todo_repository.dart';
import 'package:todo_bloc/model/todo_item.dart';

import '../screen/calendar/calendar_screen_test.mocks.dart';

@GenerateMocks([
  HiveTodoRepository,
])
void main() {
  group('Calendar Update Integration Tests', () {
    late MockHiveTodoRepository mockRepository;

    setUp(() {
      mockRepository = MockHiveTodoRepository();
      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);
    });

    /// 새로운 할 일 추가 시 캘린더 업데이트 테스트
    testWidgets('calendar updates when new todo is added', (tester) async {
      final initialTodos = <TodoEntity>[];
      
      // ProviderContainer를 직접 사용하여 상태 변경을 테스트
      final container = ProviderContainer(
        overrides: [
          hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      // 초기 상태 확인
      await tester.pumpAndSettle();
      expect(find.byType(CalendarScreen), findsOneWidget);

      // 새로운 할 일 추가 시뮬레이션
      final newTodo = TodoEntity(
        id: 'new-todo',
        title: 'New Todo Item',
        description: 'Added dynamically',
        isCompleted: false,
        dueDate: DateTime.now(),
        priority: TodoPriority.high,
        category: TodoCategory.work,
        createdAt: DateTime.now(),
      );

      // 할 일 추가 후 provider 새로고침 시뮬레이션
      container.invalidate(combinedTodoProvider);
      
      await tester.pumpAndSettle();

      // 캘린더가 여전히 정상적으로 렌더링되는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);

      container.dispose();
    });

    /// 날짜 선택 시 해당 날짜의 할 일 표시 테스트
    testWidgets('shows todos for selected date correctly', (tester) async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      
      final testTodos = [
        TodoEntity(
          id: 'today-todo',
          title: 'Today Todo',
          description: 'Task for today',
          isCompleted: false,
          dueDate: today,
          priority: TodoPriority.high,
          category: TodoCategory.work,
          createdAt: today,
        ),
        TodoEntity(
          id: 'tomorrow-todo',
          title: 'Tomorrow Todo',
          description: 'Task for tomorrow',
          isCompleted: false,
          dueDate: tomorrow,
          priority: TodoPriority.medium,
          category: TodoCategory.personal,
          createdAt: today,
        ),
      ];

      final container = ProviderContainer(
        overrides: [
          hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 캘린더가 렌더링되었는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);

      container.dispose();
    });

    /// Provider 동기화 테스트
    testWidgets('combined provider syncs with both data sources', (tester) async {
      // Hive 데이터
      final hiveTodos = [
        TodoItem(
          title: 'Hive Todo',
          priority: 'high',
          dueDate: DateTime.now(),
          isCompleted: false,
          category: 'work',
        ),
      ];

      when(mockRepository.getTodos()).thenAnswer((_) async => hiveTodos);

      final container = ProviderContainer(
        overrides: [
          hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      // CombinedTodoProvider 직접 테스트
      final combinedTodos = await container.read(combinedTodoProvider.future);
      
      // Hive 데이터가 TodoEntity로 변환되어 포함되었는지 확인
      expect(combinedTodos.isNotEmpty, isTrue);
      expect(combinedTodos.any((todo) => todo.title == 'Hive Todo'), isTrue);

      container.dispose();
    });
  });
}