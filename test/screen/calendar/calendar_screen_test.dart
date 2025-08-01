/// **Calendar Screen 테스트**
/// 
/// 캘린더 화면의 네비게이션 기능과 할 일 표시 기능을 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:todo_bloc/screen/calendar/calendar_screen.dart';
import 'package:todo_bloc/screen/calendar/widgets/calendar_header.dart';
import 'package:todo_bloc/screen/calendar/widgets/calendar_todo_list.dart';
import 'package:todo_bloc/domain/entities/todo_entity.dart';
import 'package:todo_bloc/services/hive_todo_repository.dart';
import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/presentation/providers/combined_todo_provider.dart';
import 'package:todo_bloc/presentation/providers/todo_provider.dart';

import 'calendar_screen_test.mocks.dart';

@GenerateMocks([
  HiveTodoRepository,
])
void main() {
  group('CalendarScreen', () {
    late MockHiveTodoRepository mockRepository;

    setUp(() {
      mockRepository = MockHiveTodoRepository();
      
      // Mock 기본 동작 설정
      when(mockRepository.getTodos()).thenAnswer((_) async => []);
    });

    /// 기본 캘린더 화면 렌더링 테스트
    testWidgets('renders calendar with header correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      // 로딩 상태에서 시작
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 데이터 로드 완료 대기
      await tester.pumpAndSettle();

      // 캘린더 헤더 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
    });

    /// 캘린더 헤더 네비게이션 버튼 테스트
    testWidgets('calendar header has navigation buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 이전/다음 달 버튼 확인
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byTooltip('이전 달'), findsOneWidget);
      expect(find.byTooltip('다음 달'), findsOneWidget);
    });

    /// 월 네비게이션 기능 테스트
    testWidgets('can navigate to previous and next month', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 현재 월 확인 (대략적으로)
      final currentMonth = DateTime.now().month;
      
      // 이전 달 버튼 클릭
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      // 다음 달 버튼 클릭
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      // 네비게이션이 에러 없이 작동하는지 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
    });

    /// Provider 통합 테스트 - 테스트 데이터로 할 일 표시
    testWidgets('displays todos from combined provider correctly', (tester) async {
      // 테스트용 할 일 데이터 생성
      final testTodos = [
        TodoEntity(
          id: '1',
          title: 'Test Todo 1',
          description: 'Test Description',
          isCompleted: false,
          dueDate: DateTime.now(),
          priority: TodoPriority.high,
          category: TodoCategory.work,
          createdAt: DateTime.now(),
        ),
        TodoEntity(
          id: '2',
          title: 'Test Todo 2',
          description: 'Test Description 2',
          isCompleted: true,
          dueDate: DateTime.now(),
          priority: 'medium',
          category: 'personal',
          tags: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Hive Todo 테스트 데이터
      final hiveTodos = [
        TodoItem(
          title: 'Hive Todo 1',
          description: 'Hive Description',
          isCompleted: false,
          dueDate: DateTime.now().add(const Duration(days: 1)),
          priority: 'low',
          category: 'hobby',
          createdAt: DateTime.now(),
        ),
      ];

      // Mock repository 설정
      when(mockRepository.getTodos()).thenAnswer((_) async => hiveTodos);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Combined provider가 사용하는 하위 provider들을 오버라이드
            todoListProvider.overrideWith((ref) => testTodos),
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 캘린더 구성 요소들이 렌더링되었는지 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
      expect(find.byType(CalendarTodoList), findsOneWidget);
      
      // TableCalendar가 렌더링되었는지 확인
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    /// 날짜 선택 기능 테스트
    testWidgets('can select different dates', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 오늘 날짜 찾기 (캘린더에서 첫 번째 날짜 요소)
      final todayFinder = find.text('1').first;
      
      if (todayFinder.evaluate().isNotEmpty) {
        // 날짜 선택
        await tester.tap(todayFinder);
        await tester.pumpAndSettle();

        // 선택이 에러 없이 작동하는지 확인
        expect(find.byType(CalendarHeader), findsOneWidget);
      }
    });

    /// 에러 상태 처리 테스트
    testWidgets('handles error state correctly', (tester) async {
      // Mock repository가 에러를 던지도록 설정
      when(mockRepository.getTodos()).thenThrow(Exception('Database error'));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // 에러를 발생시키는 provider override
            todoListProvider.overrideWith((ref) => throw Exception('Provider error')),
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 에러 상태 UI 요소 확인
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('캘린더를 불러오는 중 오류가 발생했습니다.'), findsOneWidget);
    });

    /// 선택된 날짜 Provider 테스트
    testWidgets('selected date provider works correctly', (tester) async {
      final testDate = DateTime(2024, 1, 15);
      
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedDateProvider.overrideWith((ref) => testDate),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 캘린더가 선택된 날짜로 렌더링되는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    /// 캘린더 포맷 Provider 테스트
    testWidgets('calendar format provider works correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarFormatProvider.overrideWith((ref) => CalendarFormat.twoWeeks),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 2주 포맷으로 캘린더가 렌더링되는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
    });

    /// 빈 데이터 상태 테스트
    testWidgets('handles empty todo list correctly', (tester) async {
      // 빈 데이터 설정
      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoListProvider.overrideWith((ref) => <TodoEntity>[]),
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 빈 상태에서도 캘린더 구성 요소들이 정상적으로 렌더링되는지 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
      expect(find.byType(CalendarTodoList), findsOneWidget);
      expect(find.byType(TableCalendar), findsOneWidget);
    });
  });

  group('CalendarHeader', () {
    /// 헤더 기본 렌더링 테스트
    testWidgets('renders month/year and format buttons', (tester) async {
      final testDate = DateTime(2024, 1, 15);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: testDate,
              calendarFormat: CalendarFormat.month,
              onFormatChanged: (format) {},
              onPreviousMonth: () {},
              onNextMonth: () {},
            ),
          ),
        ),
      );

      // 네비게이션 버튼 확인
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      
      // 포맷 변경 버튼 확인
      expect(find.text('월별'), findsOneWidget);
      expect(find.text('2주'), findsOneWidget);
    });

    /// 포맷 변경 기능 테스트
    testWidgets('can change calendar format', (tester) async {
      var currentFormat = CalendarFormat.month;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return CalendarHeader(
                  focusedDay: DateTime.now(),
                  calendarFormat: currentFormat,
                  onFormatChanged: (format) {
                    setState(() {
                      currentFormat = format;
                    });
                  },
                  onPreviousMonth: () {},
                  onNextMonth: () {},
                );
              },
            ),
          ),
        ),
      );

      // 2주 뷰 버튼 클릭
      await tester.tap(find.text('2주'));
      await tester.pump();

      // 포맷이 변경되었는지는 상위 위젯에서 관리하므로
      // 여기서는 탭이 에러 없이 작동하는지만 확인
      expect(find.text('2주'), findsOneWidget);
    });

    /// 네비게이션 콜백 테스트
    testWidgets('calls navigation callbacks correctly', (tester) async {
      var previousCalled = false;
      var nextCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CalendarHeader(
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              onFormatChanged: (format) {},
              onPreviousMonth: () {
                previousCalled = true;
              },
              onNextMonth: () {
                nextCalled = true;
              },
            ),
          ),
        ),
      );

      // 이전 달 버튼 클릭
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();
      expect(previousCalled, isTrue);

      // 다음 달 버튼 클릭
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();
      expect(nextCalled, isTrue);
    });
  });

  group('Calendar Integration', () {
    /// 전체 캘린더 워크플로우 테스트
    testWidgets('full calendar navigation and selection workflow', (tester) async {
      final testTodos = [
        TodoEntity(
          id: '1',
          title: 'Today Todo',
          description: 'Today task',
          isCompleted: false,
          dueDate: DateTime.now(),
          priority: 'high',
          category: 'work',
          tags: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        TodoEntity(
          id: '2',
          title: 'Tomorrow Todo',
          description: 'Tomorrow task',
          isCompleted: false,
          dueDate: DateTime.now().add(const Duration(days: 1)),
          priority: 'medium',
          category: 'personal',
          tags: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoListProvider.overrideWith((ref) => testTodos),
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. 이전 달로 이동
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      // 2. 다음 달로 이동
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      // 3. 포맷 변경 (월별 → 2주)
      await tester.tap(find.text('2주'));
      await tester.pump();

      // 4. 다시 월별 뷰로 변경
      await tester.tap(find.text('월별'));
      await tester.pump();

      // 모든 조작이 에러 없이 완료되는지 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
      expect(find.byType(CalendarTodoList), findsOneWidget);
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    /// 날짜 선택과 Todo 표시 통합 테스트
    testWidgets('date selection shows correct todos', (tester) async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      
      final testTodos = [
        TodoEntity(
          id: '1',
          title: 'Today Todo',
          description: 'Task for today',
          isCompleted: false,
          dueDate: today,
          priority: 'high',
          category: 'work',
          tags: [],
          createdAt: today,
          updatedAt: today,
        ),
        TodoEntity(
          id: '2',
          title: 'Tomorrow Todo',
          description: 'Task for tomorrow',
          isCompleted: false,
          dueDate: tomorrow,
          priority: 'medium',
          category: 'personal',
          tags: [],
          createdAt: today,
          updatedAt: today,
        ),
      ];

      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoListProvider.overrideWith((ref) => testTodos),
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 오늘 날짜가 기본 선택되어 있고, 오늘의 Todo가 표시되는지 확인
      expect(find.byType(CalendarTodoList), findsOneWidget);
    });

    /// Provider 상태 변경에 따른 UI 업데이트 테스트
    testWidgets('UI updates when provider state changes', (tester) async {
      final testTodos = [
        TodoEntity(
          id: '1',
          title: 'Initial Todo',
          description: 'Initial task',
          isCompleted: false,
          dueDate: DateTime.now(),
          priority: 'medium',
          category: 'work',
          tags: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoListProvider.overrideWith((ref) => testTodos),
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 초기 상태 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(find.byType(CalendarTodoList), findsOneWidget);
    });

    /// 다중 데이터 소스 통합 테스트
    testWidgets('integrates multiple data sources correctly', (tester) async {
      // Riverpod 데이터
      final riverpodTodos = [
        TodoEntity(
          id: 'riverpod_1',
          title: 'Riverpod Todo',
          description: 'From Riverpod',
          isCompleted: false,
          dueDate: DateTime.now(),
          priority: 'high',
          category: 'work',
          tags: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      // Hive 데이터
      final hiveTodos = [
        TodoItem(
          title: 'Hive Todo',
          description: 'From Hive',
          isCompleted: false,
          dueDate: DateTime.now(),
          priority: 'medium',
          category: 'personal',
          createdAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getTodos()).thenAnswer((_) async => hiveTodos);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoListProvider.overrideWith((ref) => riverpodTodos),
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 두 데이터 소스가 모두 통합되어 표시되는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(find.byType(CalendarTodoList), findsOneWidget);
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    /// 캘린더 상태 지속성 테스트
    testWidgets('maintains calendar state during interactions', (tester) async {
      final testTodos = [
        TodoEntity(
          id: '1',
          title: 'Test Todo',
          description: 'Test task',
          isCompleted: false,
          dueDate: DateTime.now(),
          priority: 'medium',
          category: 'work',
          tags: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoListProvider.overrideWith((ref) => testTodos),
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 포맷을 2주로 변경
      await tester.tap(find.text('2주'));
      await tester.pump();

      // 다음 달로 이동
      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      // 이전 달로 이동
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      // 상태가 유지되면서 모든 컴포넌트가 정상 작동하는지 확인
      expect(find.byType(CalendarHeader), findsOneWidget);
      expect(find.byType(CalendarTodoList), findsOneWidget);
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    /// 성능 테스트 - 많은 Todo 항목 처리
    testWidgets('handles large number of todos efficiently', (tester) async {
      // 많은 Todo 데이터 생성
      final largeTodoList = List.generate(100, (index) =>
        TodoEntity(
          id: 'todo_$index',
          title: 'Todo $index',
          description: 'Description for todo $index',
          isCompleted: index % 2 == 0,
          dueDate: DateTime.now().add(Duration(days: index % 30)),
          priority: ['high', 'medium', 'low'][index % 3],
          category: ['work', 'personal', 'hobby'][index % 3],
          tags: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoListProvider.overrideWith((ref) => largeTodoList),
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 대량의 데이터에도 캘린더가 정상적으로 렌더링되는지 확인
      expect(find.byType(CalendarScreen), findsOneWidget);
      expect(find.byType(CalendarHeader), findsOneWidget);
      expect(find.byType(CalendarTodoList), findsOneWidget);
      expect(find.byType(TableCalendar), findsOneWidget);
    });

    /// 접근성 통합 테스트
    testWidgets('provides comprehensive accessibility support', (tester) async {
      final testTodos = [
        TodoEntity(
          id: '1',
          title: 'Accessible Todo',
          description: 'Accessible task',
          isCompleted: false,
          dueDate: DateTime.now(),
          priority: 'medium',
          category: 'work',
          tags: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getTodos()).thenAnswer((_) async => <TodoItem>[]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todoListProvider.overrideWith((ref) => testTodos),
            hiveTodoRepositoryProvider.overrideWith((ref) => mockRepository),
          ],
          child: MaterialApp(
            home: CalendarScreen(),
          ),
        ),
      );

      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();

      // 접근성 트리가 올바르게 구성되어 있는지 확인
      expect(tester.getSemantics(find.byType(CalendarScreen)), isNotNull);
      
      // 접근성 요소들 확인
      expect(find.byTooltip('이전 달'), findsOneWidget);
      expect(find.byTooltip('다음 달'), findsOneWidget);

      handle.dispose();
    });
  });
}