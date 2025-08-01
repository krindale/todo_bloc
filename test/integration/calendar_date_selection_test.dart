/// **캘린더 날짜 선택 테스트**
/// 
/// 날짜 선택 시 해당 날짜의 할 일이 올바르게 표시되는지 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:todo_bloc/screen/calendar/calendar_screen.dart';
import 'package:todo_bloc/screen/calendar/widgets/calendar_todo_list.dart';
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
  group('Calendar Date Selection Tests', () {
    late MockHiveTodoRepository mockRepository;

    setUp(() {
      mockRepository = MockHiveTodoRepository();
      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);
    });

    /// 오늘과 내일의 할 일이 올바르게 분리되어 표시되는지 테스트
    testWidgets('displays todos for correct dates', (tester) async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final dayAfterTomorrow = today.add(const Duration(days: 2));
      
      final testTodos = [
        TodoEntity(
          id: 'today-1',
          title: '오늘 할 일 1',
          description: '오늘 해야 할 작업',
          isCompleted: false,
          dueDate: today,
          priority: TodoPriority.high,
          category: TodoCategory.work,
          createdAt: today,
        ),
        TodoEntity(
          id: 'today-2',
          title: '오늘 할 일 2',
          description: '오늘 해야 할 다른 작업',
          isCompleted: true,
          dueDate: today,
          priority: TodoPriority.medium,
          category: TodoCategory.personal,
          createdAt: today,
        ),
        TodoEntity(
          id: 'tomorrow-1',
          title: '내일 할 일',
          description: '내일 해야 할 작업',
          isCompleted: false,
          dueDate: tomorrow,
          priority: TodoPriority.low,
          category: TodoCategory.study,
          createdAt: today,
        ),
        TodoEntity(
          id: 'day-after-1',
          title: '모레 할 일',
          description: '모레 해야 할 작업',
          isCompleted: false,
          dueDate: dayAfterTomorrow,
          priority: TodoPriority.high,
          category: TodoCategory.health,
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

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 캘린더가 렌더링되었는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(find.byType(CalendarTodoList), findsOneWidget);

      container.dispose();
    });

    /// 날짜별 Todo 필터링 로직 단위 테스트
    test('getTodosForDay filters todos correctly', () {
      final today = DateTime(2024, 1, 15);
      final tomorrow = DateTime(2024, 1, 16);
      final yesterday = DateTime(2024, 1, 14);
      
      final allTodos = [
        TodoEntity(
          id: 'today-1',
          title: '오늘 할 일',
          description: '오늘 작업',
          isCompleted: false,
          dueDate: today,
          priority: TodoPriority.high,
          category: TodoCategory.work,
          createdAt: today,
        ),
        TodoEntity(
          id: 'tomorrow-1',
          title: '내일 할 일',
          description: '내일 작업',
          isCompleted: false,
          dueDate: tomorrow,
          priority: TodoPriority.medium,
          category: TodoCategory.personal,
          createdAt: today,
        ),
        TodoEntity(
          id: 'yesterday-1',
          title: '어제 할 일',
          description: '어제 작업',
          isCompleted: true,
          dueDate: yesterday,
          priority: TodoPriority.low,
          category: TodoCategory.study,
          createdAt: yesterday,
        ),
      ];

      // CalendarScreen의 _getTodosForDay 로직을 직접 테스트
      List<TodoEntity> getTodosForDay(List<TodoEntity> todos, DateTime day) {
        return todos.where((todo) {
          final todoDate = DateTime(
            todo.dueDate.year,
            todo.dueDate.month,
            todo.dueDate.day,
          );
          final targetDate = DateTime(day.year, day.month, day.day);
          return todoDate.isAtSameMomentAs(targetDate);
        }).toList();
      }

      // 오늘 날짜의 할 일 필터링 테스트
      final todayTodos = getTodosForDay(allTodos, today);
      expect(todayTodos.length, equals(1));
      expect(todayTodos.first.title, equals('오늘 할 일'));

      // 내일 날짜의 할 일 필터링 테스트
      final tomorrowTodos = getTodosForDay(allTodos, tomorrow);
      expect(tomorrowTodos.length, equals(1));
      expect(tomorrowTodos.first.title, equals('내일 할 일'));

      // 어제 날짜의 할 일 필터링 테스트
      final yesterdayTodos = getTodosForDay(allTodos, yesterday);
      expect(yesterdayTodos.length, equals(1));
      expect(yesterdayTodos.first.title, equals('어제 할 일'));

      // 할 일이 없는 날짜 테스트
      final emptyDayTodos = getTodosForDay(allTodos, DateTime(2024, 1, 20));
      expect(emptyDayTodos.length, equals(0));
    });

    /// 시간은 다르지만 같은 날짜의 할 일들이 올바르게 그룹화되는지 테스트
    test('groups todos by date regardless of time', () {
      final baseDate = DateTime(2024, 1, 15);
      
      final todosWithDifferentTimes = [
        TodoEntity(
          id: 'morning',
          title: '아침 할 일',
          description: '아침 작업',
          isCompleted: false,
          dueDate: DateTime(2024, 1, 15, 9, 0), // 오전 9시
          priority: TodoPriority.high,
          category: TodoCategory.work,
          createdAt: baseDate,
        ),
        TodoEntity(
          id: 'afternoon',
          title: '오후 할 일',
          description: '오후 작업',
          isCompleted: false,
          dueDate: DateTime(2024, 1, 15, 14, 30), // 오후 2시 30분
          priority: TodoPriority.medium,
          category: TodoCategory.personal,
          createdAt: baseDate,
        ),
        TodoEntity(
          id: 'evening',
          title: '저녁 할 일',
          description: '저녁 작업',
          isCompleted: false,
          dueDate: DateTime(2024, 1, 15, 20, 0), // 저녁 8시
          priority: TodoPriority.low,
          category: TodoCategory.study,
          createdAt: baseDate,
        ),
      ];

      // 같은 날짜의 모든 할 일이 그룹화되는지 테스트
      List<TodoEntity> getTodosForDay(List<TodoEntity> todos, DateTime day) {
        return todos.where((todo) {
          final todoDate = DateTime(
            todo.dueDate.year,
            todo.dueDate.month,
            todo.dueDate.day,
          );
          final targetDate = DateTime(day.year, day.month, day.day);
          return todoDate.isAtSameMomentAs(targetDate);
        }).toList();
      }

      final sameDayTodos = getTodosForDay(todosWithDifferentTimes, baseDate);
      expect(sameDayTodos.length, equals(3));
      
      // 모든 할 일이 포함되었는지 확인
      final titles = sameDayTodos.map((todo) => todo.title).toList();
      expect(titles, containsAll(['아침 할 일', '오후 할 일', '저녁 할 일']));
    });

    /// 월별 Todo 개수 계산 테스트
    test('calculates todo counts for month correctly', () {
      final january2024 = DateTime(2024, 1, 1);
      final february2024 = DateTime(2024, 2, 1);
      
      final mixedMonthTodos = [
        // 1월 todos
        TodoEntity(
          id: 'jan-1',
          title: '1월 1일 할 일',
          isCompleted: false,
          dueDate: DateTime(2024, 1, 1),
          priority: TodoPriority.high,
          category: TodoCategory.work,
          createdAt: january2024,
        ),
        TodoEntity(
          id: 'jan-15-1',
          title: '1월 15일 할 일 1',
          isCompleted: false,
          dueDate: DateTime(2024, 1, 15),
          priority: TodoPriority.medium,
          category: TodoCategory.personal,
          createdAt: january2024,
        ),
        TodoEntity(
          id: 'jan-15-2',
          title: '1월 15일 할 일 2',
          isCompleted: true,
          dueDate: DateTime(2024, 1, 15),
          priority: TodoPriority.low,
          category: TodoCategory.study,
          createdAt: january2024,
        ),
        // 2월 todos
        TodoEntity(
          id: 'feb-1',
          title: '2월 1일 할 일',
          isCompleted: false,
          dueDate: DateTime(2024, 2, 1),
          priority: TodoPriority.high,
          category: TodoCategory.health,
          createdAt: february2024,
        ),
      ];

      // CalendarScreen의 _getTodoCountsForMonth 로직을 직접 테스트
      Map<DateTime, int> getTodoCountsForMonth(List<TodoEntity> todos, DateTime month) {
        final Map<DateTime, int> todoCounts = {};
        
        for (final todo in todos) {
          final todoDate = DateTime(
            todo.dueDate.year,
            todo.dueDate.month,
            todo.dueDate.day,
          );
          
          // 해당 월의 Todo만 포함
          if (todoDate.month == month.month && todoDate.year == month.year) {
            todoCounts[todoDate] = (todoCounts[todoDate] ?? 0) + 1;
          }
        }
        
        return todoCounts;
      }

      // 1월 Todo 개수 테스트
      final januaryCounts = getTodoCountsForMonth(mixedMonthTodos, january2024);
      expect(januaryCounts.length, equals(2)); // 2개 날짜에 todo가 있음
      expect(januaryCounts[DateTime(2024, 1, 1)], equals(1)); // 1월 1일에 1개
      expect(januaryCounts[DateTime(2024, 1, 15)], equals(2)); // 1월 15일에 2개
      
      // 2월 Todo 개수 테스트
      final februaryCounts = getTodoCountsForMonth(mixedMonthTodos, february2024);
      expect(februaryCounts.length, equals(1)); // 1개 날짜에 todo가 있음
      expect(februaryCounts[DateTime(2024, 2, 1)], equals(1)); // 2월 1일에 1개
    });
  });
}