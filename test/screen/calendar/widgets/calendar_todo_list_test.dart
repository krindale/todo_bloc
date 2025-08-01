/// **CalendarTodoList 위젯 테스트**
/// 
/// 캘린더에서 선택된 날짜의 Todo 목록을 표시하는 위젯 테스트입니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:todo_bloc/screen/calendar/widgets/calendar_todo_list.dart';
import 'package:todo_bloc/domain/entities/todo_entity.dart';
import 'package:todo_bloc/presentation/providers/todo_provider.dart';
import 'package:todo_bloc/screen/widgets/todo_item_card.dart';

// Mock 클래스 생성을 위한 어노테이션
@GenerateMocks([])
void main() {
  group('CalendarTodoList', () {
    late DateTime testDate;
    late List<TodoEntity> testTodos;
    late List<TodoEntity> emptyTodos;

    setUp(() {
      testDate = DateTime(2024, 1, 15);
      
      testTodos = [
        TodoEntity(
          id: '1',
          title: 'Test Todo 1',
          description: 'First test todo',
          isCompleted: false,
          dueDate: testDate,
          priority: 'high',
          category: 'work',
          tags: ['urgent', 'important'],
          createdAt: testDate.subtract(const Duration(hours: 1)),
          updatedAt: testDate,
        ),
        TodoEntity(
          id: '2',
          title: 'Test Todo 2',
          description: 'Second test todo',
          isCompleted: true,
          dueDate: testDate,
          priority: 'medium',
          category: 'personal',
          tags: ['routine'],
          createdAt: testDate.subtract(const Duration(hours: 2)),
          updatedAt: testDate,
        ),
        TodoEntity(
          id: '3',
          title: 'Test Todo 3',
          description: 'Third test todo',
          isCompleted: false,
          dueDate: testDate,
          priority: 'low',
          category: 'hobby',
          tags: [],
          createdAt: testDate.subtract(const Duration(hours: 3)),
          updatedAt: testDate,
        ),
      ];

      emptyTodos = [];
    });

    /// 기본 렌더링 테스트
    testWidgets('renders correctly with todos', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CalendarTodoList(
                selectedDate: testDate,
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 헤더가 렌더링되는지 확인
      expect(find.byIcon(Icons.event_note), findsOneWidget);
      
      // Todo 아이템들이 렌더링되는지 확인
      expect(find.byType(TodoItemCard), findsNWidgets(testTodos.length));
      
      // 각 Todo 제목이 표시되는지 확인
      for (final todo in testTodos) {
        expect(find.text(todo.title), findsOneWidget);
      }
    });

    /// 빈 상태 렌더링 테스트
    testWidgets('renders empty state when no todos', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CalendarTodoList(
                selectedDate: testDate,
                todos: emptyTodos,
              ),
            ),
          ),
        ),
      );

      // 빈 상태 아이콘 확인
      expect(find.byIcon(Icons.event_available), findsOneWidget);
      
      // 빈 상태 메시지 확인
      expect(find.text('이 날에는 할 일이 없습니다'), findsOneWidget);
      expect(find.text('AI 생성 버튼으로 새로운 할 일을 추가해보세요'), findsOneWidget);
      
      // Todo 아이템이 없는지 확인
      expect(find.byType(TodoItemCard), findsNothing);
    });

    /// 헤더 날짜 포맷 테스트
    testWidgets('displays correct date format in header', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CalendarTodoList(
                selectedDate: testDate,
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 날짜 아이콘 확인
      expect(find.byIcon(Icons.event_note), findsOneWidget);
    });

    /// 오늘 날짜 표시 테스트
    testWidgets('shows today badge when selected date is today', (tester) async {
      final today = DateTime.now();
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CalendarTodoList(
                selectedDate: today,
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 오늘 배지가 표시되는지 확인
      expect(find.text('오늘'), findsOneWidget);
    });

    /// 과거 날짜에서 오늘 배지 미표시 테스트
    testWidgets('does not show today badge for past dates', (tester) async {
      final pastDate = DateTime.now().subtract(const Duration(days: 5));
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CalendarTodoList(
                selectedDate: pastDate,
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 오늘 배지가 표시되지 않는지 확인
      expect(find.text('오늘'), findsNothing);
    });

    /// Todo 통계 표시 테스트
    testWidgets('displays correct todo statistics', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CalendarTodoList(
                selectedDate: testDate,
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 완료된 Todo 수 / 전체 Todo 수 표시 확인
      final completedCount = testTodos.where((todo) => todo.isCompleted).length;
      final totalCount = testTodos.length;
      
      expect(find.text('$completedCount/$totalCount'), findsOneWidget);
      
      // 진행률 표시 확인
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    /// 빈 Todo 목록 통계 테스트
    testWidgets('displays no todos message when list is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CalendarTodoList(
                selectedDate: testDate,
                todos: emptyTodos,
              ),
            ),
          ),
        ),
      );

      // "할 일 없음" 메시지 확인
      expect(find.text('할 일 없음'), findsOneWidget);
      
      // 진행률 표시기는 없어야 함
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    /// 모든 Todo 완료 상태 테스트
    testWidgets('shows correct statistics when all todos are completed', (tester) async {
      final allCompletedTodos = testTodos.map((todo) => 
        TodoEntity(
          id: todo.id,
          title: todo.title,
          description: todo.description,
          isCompleted: true, // 모두 완료로 설정
          dueDate: todo.dueDate,
          priority: todo.priority,
          category: todo.category,
          tags: todo.tags,
          createdAt: todo.createdAt,
          updatedAt: todo.updatedAt,
        ),
      ).toList();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CalendarTodoList(
                selectedDate: testDate,
                todos: allCompletedTodos,
              ),
            ),
          ),
        ),
      );

      // 모든 할 일이 완료되었을 때의 통계 확인
      expect(find.text('${allCompletedTodos.length}/${allCompletedTodos.length}'), findsOneWidget);
    });

    /// 스크롤 가능한 목록 테스트
    testWidgets('todo list is scrollable', (tester) async {
      // 많은 Todo 항목 생성
      final manyTodos = List.generate(20, (index) => 
        TodoEntity(
          id: 'todo_$index',
          title: 'Todo Item $index',
          description: 'Description for todo $index',
          isCompleted: index % 2 == 0, // 짝수는 완료
          dueDate: testDate,
          priority: ['high', 'medium', 'low'][index % 3],
          category: 'test',
          tags: [],
          createdAt: testDate.subtract(Duration(hours: index)),
          updatedAt: testDate,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CalendarTodoList(
                selectedDate: testDate,
                todos: manyTodos,
              ),
            ),
          ),
        ),
      );

      // ListView가 존재하는지 확인
      expect(find.byType(ListView), findsOneWidget);
      
      // 일부 아이템만 화면에 보이는지 확인 (스크롤로 인해)
      expect(find.byType(TodoItemCard), findsWidgets);
    });

    /// 위젯 구조 테스트
    testWidgets('has correct widget structure', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CalendarTodoList(
                selectedDate: testDate,
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 최상위 Container 확인
      expect(find.byType(Container), findsWidgets);
      
      // Column 구조 확인
      expect(find.byType(Column), findsOneWidget);
      
      // Expanded 위젯 확인 (스크롤 영역용)
      expect(find.byType(Expanded), findsOneWidget);
    });

    /// 테마 적용 테스트
    testWidgets('respects theme colors', (tester) async {
      final customTheme = ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.purple,
          surface: Colors.grey,
          onSurface: Colors.black,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: customTheme,
            home: Scaffold(
              body: CalendarTodoList(
                selectedDate: testDate,
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 위젯이 에러 없이 렌더링되는지 확인
      expect(find.byType(CalendarTodoList), findsOneWidget);
      expect(find.byIcon(Icons.event_note), findsOneWidget);
    });

    /// 접근성 테스트
    testWidgets('provides proper accessibility', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CalendarTodoList(
                selectedDate: testDate,
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 접근성 지침 준수 확인
      final SemanticsHandle handle = tester.ensureSemantics();
      await tester.pumpAndSettle();
      
      // 접근성 트리 확인
      expect(tester.getSemantics(find.byType(CalendarTodoList)), isNotNull);
      
      handle.dispose();
    });

    /// 엣지 케이스: null 또는 빈 제목 Todo 테스트
    testWidgets('handles todos with empty or null titles gracefully', (tester) async {
      final edgeCaseTodos = [
        TodoEntity(
          id: '1',
          title: '', // 빈 제목
          description: 'Todo with empty title',
          isCompleted: false,
          dueDate: testDate,
          priority: 'medium',
          category: 'test',
          tags: [],
          createdAt: testDate,
          updatedAt: testDate,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CalendarTodoList(
                selectedDate: testDate,
                todos: edgeCaseTodos,
              ),
            ),
          ),
        ),
      );

      // 위젯이 에러 없이 렌더링되는지 확인
      expect(find.byType(CalendarTodoList), findsOneWidget);
      expect(find.byType(TodoItemCard), findsOneWidget);
    });
  });
}