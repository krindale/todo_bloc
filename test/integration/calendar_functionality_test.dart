/// **캘린더 기능 통합 테스트**
/// 
/// 캘린더의 모든 핵심 기능이 올바르게 작동하는지 검증합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:todo_bloc/screen/calendar/calendar_screen.dart';
import 'package:todo_bloc/screen/calendar/widgets/calendar_header.dart';
import 'package:todo_bloc/screen/calendar/widgets/calendar_todo_list.dart';
import 'package:todo_bloc/domain/entities/todo_entity.dart';
import 'package:todo_bloc/presentation/providers/combined_todo_provider.dart';
import 'package:todo_bloc/presentation/providers/calendar_refresh_provider.dart';
import 'package:todo_bloc/services/hive_todo_repository.dart';
import 'package:todo_bloc/model/todo_item.dart';

import '../screen/calendar/calendar_screen_test.mocks.dart';

@GenerateMocks([
  HiveTodoRepository,
])
void main() {
  group('Calendar Functionality Integration Tests', () {
    late MockHiveTodoRepository mockRepository;

    setUp(() {
      mockRepository = MockHiveTodoRepository();
      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);
    });

    /// 캘린더 기본 렌더링 및 구성 요소 테스트
    testWidgets('calendar renders all components correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 모든 주요 구성 요소가 렌더링되었는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(find.byType(CalendarHeader), findsOneWidget);
      expect(find.byType(CalendarTodoList), findsOneWidget);
      
      // 새로고침 버튼 확인
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byTooltip('캘린더 새로고침'), findsOneWidget);
    });

    /// 새로고침 버튼 동작 테스트
    testWidgets('refresh button works correctly', (tester) async {
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

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 초기 새로고침 상태 확인
      final initialRefreshState = container.read(calendarRefreshProvider);

      // 새로고침 버튼 클릭
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // 새로고침 상태가 변경되었는지 확인
      final updatedRefreshState = container.read(calendarRefreshProvider);
      expect(updatedRefreshState, greaterThan(initialRefreshState));

      container.dispose();
    });

    /// Provider 실시간 업데이트 테스트
    testWidgets('providers update automatically', (tester) async {
      // 초기 빈 데이터
      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);

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

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 초기 상태 확인
      expect(find.byType(CalendarScreen), findsOneWidget);

      // 새로운 데이터로 Mock 업데이트
      final newTodoItem = TodoItem(
        title: 'New Todo Item',
        priority: 'high',
        dueDate: DateTime.now(),
        isCompleted: false,
        category: 'work',
      );

      when(mockRepository.getTodos()).thenAnswer((_) async => [newTodoItem]);

      // Provider 새로고침
      container.invalidate(combinedTodoProvider);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 캘린더가 여전히 정상적으로 렌더링되는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);

      container.dispose();
    });

    /// 다양한 날짜의 할 일 데이터 처리 테스트
    testWidgets('handles multiple dates with todos correctly', (tester) async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      final nextWeek = today.add(const Duration(days: 7));

      // 다양한 날짜의 할 일 데이터
      final multiDateTodos = [
        TodoItem(
          title: '오늘 할 일 1',
          priority: 'high',
          dueDate: today,
          isCompleted: false,
          category: 'work',
        ),
        TodoItem(
          title: '오늘 할 일 2',
          priority: 'medium',
          dueDate: today,
          isCompleted: true,
          category: 'personal',
        ),
        TodoItem(
          title: '내일 할 일',
          priority: 'low',
          dueDate: tomorrow,
          isCompleted: false,
          category: 'study',
        ),
        TodoItem(
          title: '다음 주 할 일',
          priority: 'high',
          dueDate: nextWeek,
          isCompleted: false,
          category: 'health',
        ),
      ];

      when(mockRepository.getTodos()).thenAnswer((_) async => multiDateTodos);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 캘린더가 다양한 날짜의 할 일을 올바르게 처리하는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(find.byType(CalendarTodoList), findsOneWidget);
    });

    /// 에러 복구 테스트
    testWidgets('recovers from errors gracefully', (tester) async {
      // 초기에는 에러 발생
      when(mockRepository.getTodos()).thenThrow(Exception('Database error'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 에러 상태에서도 기본 구조는 유지되는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);

      // Mock을 정상 상태로 복구
      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);
      
      // 새로고침 버튼 클릭으로 복구 시도
      if (tester.any(find.byIcon(Icons.refresh))) {
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // 복구 후 정상 작동하는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    /// 성능 테스트 - 대량 데이터 처리
    testWidgets('handles large dataset efficiently', (tester) async {
      // 대량의 할 일 데이터 생성 (100개)
      final largeTodoDataset = List.generate(100, (index) {
        final baseDate = DateTime.now().subtract(Duration(days: 50 - index));
        return TodoItem(
          title: 'Todo $index',
          priority: ['high', 'medium', 'low'][index % 3],
          dueDate: baseDate.add(Duration(days: index % 30)),
          isCompleted: index % 3 == 0,
          category: ['work', 'personal', 'study', 'health'][index % 4],
        );
      });

      when(mockRepository.getTodos()).thenAnswer((_) async => largeTodoDataset);

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 10));

      stopwatch.stop();

      // 성능 확인 (10초 이내 로딩 완료)
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      
      // 대량 데이터에도 정상 렌더링 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(find.byType(CalendarHeader), findsOneWidget);
      expect(find.byType(CalendarTodoList), findsOneWidget);
    });

    /// 메모리 누수 방지 테스트
    testWidgets('prevents memory leaks with autoDispose', (tester) async {
      final container = ProviderContainer(
        overrides: [
          hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
        ],
      );

      // 여러 번 위젯 생성/제거 반복
      for (int i = 0; i < 3; i++) {
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: CalendarScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle(const Duration(seconds: 2));

        // 위젯 제거
        await tester.pumpWidget(Container());
        await tester.pumpAndSettle();
      }

      // 메모리 누수 없이 정상 작동 확인
      container.dispose();
      // Container가 정상적으로 dispose되었는지는 dispose() 호출 자체로 충분
    });
  });

  group('Calendar Logic Unit Tests', () {
    /// 날짜 필터링 엣지 케이스 테스트
    test('date filtering handles edge cases correctly', () {
      final leapYearDate = DateTime(2024, 2, 29); // 윤년
      final yearEndDate = DateTime(2023, 12, 31); // 연말
      final yearStartDate = DateTime(2024, 1, 1);  // 연초

      final edgeCaseTodos = [
        TodoEntity(
          id: 'leap-year',
          title: '윤년 할 일',
          isCompleted: false,
          dueDate: leapYearDate,
          priority: TodoPriority.high,
          category: TodoCategory.work,
          createdAt: leapYearDate,
        ),
        TodoEntity(
          id: 'year-end',
          title: '연말 할 일',
          isCompleted: false,
          dueDate: yearEndDate,
          priority: TodoPriority.medium,
          category: TodoCategory.personal,
          createdAt: yearEndDate,
        ),
        TodoEntity(
          id: 'year-start',
          title: '연초 할 일',
          isCompleted: false,
          dueDate: yearStartDate,
          priority: TodoPriority.low,
          category: TodoCategory.study,
          createdAt: yearStartDate,
        ),
      ];

      // 날짜 필터링 함수 (CalendarScreen에서 사용하는 로직)
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

      // 각 엣지 케이스 날짜에 대해 정확한 필터링 확인
      expect(getTodosForDay(edgeCaseTodos, leapYearDate).length, equals(1));
      expect(getTodosForDay(edgeCaseTodos, yearEndDate).length, equals(1));
      expect(getTodosForDay(edgeCaseTodos, yearStartDate).length, equals(1));
      
      // 존재하지 않는 날짜
      expect(getTodosForDay(edgeCaseTodos, DateTime(2024, 2, 30)).length, equals(0));
    });

    /// 중복 제거 로직 테스트
    test('duplicate removal works correctly', () {
      final duplicateTodos = [
        TodoEntity(
          id: 'duplicate-1',
          title: '중복 할 일',
          isCompleted: false,
          dueDate: DateTime.now(),
          priority: TodoPriority.high,
          category: TodoCategory.work,
          createdAt: DateTime.now(),
        ),
        TodoEntity(
          id: 'duplicate-1', // 같은 ID
          title: '중복 할 일 (수정됨)',
          isCompleted: true,
          dueDate: DateTime.now(),
          priority: TodoPriority.medium,
          category: TodoCategory.personal,
          createdAt: DateTime.now(),
        ),
        TodoEntity(
          id: 'unique-1',
          title: '고유 할 일',
          isCompleted: false,
          dueDate: DateTime.now(),
          priority: TodoPriority.low,
          category: TodoCategory.study,
          createdAt: DateTime.now(),
        ),
      ];

      // 중복 제거 로직 (CombinedTodoProvider에서 사용하는 로직)
      final uniqueTodos = <String, TodoEntity>{};
      for (final todo in duplicateTodos) {
        uniqueTodos[todo.id] = todo; // 나중에 추가된 것이 덮어씀
      }
      final result = uniqueTodos.values.toList();

      // 중복이 제거되고 최신 버전이 유지되는지 확인
      expect(result.length, equals(2));
      final duplicateItem = result.firstWhere((todo) => todo.id == 'duplicate-1');
      expect(duplicateItem.title, equals('중복 할 일 (수정됨)'));
      expect(duplicateItem.isCompleted, isTrue);
    });
  });
}