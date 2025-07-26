import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/widgets/task_summary/categorized_task_section.dart';
import 'package:todo_bloc/model/todo_item.dart';

void main() {
  group('CategorizedTaskSection', () {
    late Map<String, List<TodoItem>> mockCategorizedTasks;
    late Map<String, int> mockCategoryTaskCounts;
    late Map<String, int> mockCategoryCompletionCounts;

    setUp(() {
      mockCategorizedTasks = {
        'Work': [
          TodoItem(
            title: 'Work Task 1',
            priority: 'High',
            dueDate: DateTime(2025, 3, 15),
            isCompleted: true,
          ),
          TodoItem(
            title: 'Work Task 2',
            priority: 'Medium',
            dueDate: DateTime(2025, 3, 16),
            isCompleted: false,
            hasAlarm: true,
            alarmTime: DateTime(2025, 3, 16, 9, 30),
          ),
        ],
        'Personal': [
          TodoItem(
            title: 'Personal Task 1',
            priority: 'Low',
            dueDate: DateTime(2025, 3, 17),
            isCompleted: false,
          ),
        ],
      };

      mockCategoryTaskCounts = {
        'Work': 2,
        'Personal': 1,
      };

      mockCategoryCompletionCounts = {
        'Work': 1,
        'Personal': 0,
      };
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: CategorizedTaskSection(
            categorizedTasks: mockCategorizedTasks,
            categoryTaskCounts: mockCategoryTaskCounts,
            categoryCompletionCounts: mockCategoryCompletionCounts,
          ),
        ),
      );
    }

    testWidgets('should display section title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Tasks by Category'), findsOneWidget);
    });

    testWidgets('should display category cards', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
    });

    testWidgets('should display category completion stats', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Work category: 1/2 tasks completed (50%)
      expect(find.text('1/2 tasks completed (50%)'), findsOneWidget);
      // Personal category: 0/1 tasks completed (0%)
      expect(find.text('0/1 tasks completed (0%)'), findsOneWidget);
    });

    testWidgets('should display task count badges', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('2'), findsOneWidget); // Work category count
      expect(find.text('1'), findsOneWidget); // Personal category count
    });

    testWidgets('should show task items when category is expanded', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand Work category
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      expect(find.text('Work Task 1'), findsOneWidget);
      expect(find.text('Work Task 2'), findsOneWidget);
    });

    testWidgets('should display task with completion status', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand Work category
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      // Completed task should have check_circle icon
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      // Incomplete task should have radio_button_unchecked icon
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('should display priority and due date in MM/DD format', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand Work category
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      expect(find.text('Priority: High • Due: 03/15'), findsOneWidget);
      expect(find.text('Priority: Medium • Due: 03/16'), findsOneWidget);
    });

    testWidgets('should display alarm information on separate line when hasAlarm is true', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand Work category
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      // Check for alarm icon
      expect(find.byIcon(Icons.alarm), findsOneWidget);
      
      // Check for alarm text (should show date and time)
      expect(find.textContaining('Alarm: 03/16'), findsOneWidget);
      expect(find.textContaining('at 9:30'), findsOneWidget);
    });

    testWidgets('should not display alarm info when hasAlarm is false', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand Personal category (has no alarm)
      await tester.tap(find.text('Personal'));
      await tester.pumpAndSettle();

      // Should not find alarm icon for non-alarm tasks
      final alarmIcons = find.byIcon(Icons.alarm);
      expect(alarmIcons, findsNothing);
    });

    testWidgets('should display priority badges with correct colors', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Expand Work category
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      expect(find.text('High'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
    });

    testWidgets('should handle empty categories', (tester) async {
      final emptyWidget = MaterialApp(
        home: Scaffold(
          body: CategorizedTaskSection(
            categorizedTasks: {},
            categoryTaskCounts: {},
            categoryCompletionCounts: {},
          ),
        ),
      );

      await tester.pumpWidget(emptyWidget);

      // Should not display the section when empty
      expect(find.text('Tasks by Category'), findsNothing);
    });

    testWidgets('should display "No tasks in this category" for empty category', (tester) async {
      final emptyCategory = {
        'Empty': <TodoItem>[],
      };
      
      final emptyTaskCounts = {'Empty': 0};
      final emptyCompletionCounts = {'Empty': 0};

      final widget = MaterialApp(
        home: Scaffold(
          body: CategorizedTaskSection(
            categorizedTasks: emptyCategory,
            categoryTaskCounts: emptyTaskCounts,
            categoryCompletionCounts: emptyCompletionCounts,
          ),
        ),
      );

      await tester.pumpWidget(widget);

      // Expand empty category
      await tester.tap(find.text('Empty'));
      await tester.pumpAndSettle();

      expect(find.text('No tasks in this category'), findsOneWidget);
    });

    testWidgets('should show "... and X more tasks" when more than 5 tasks', (tester) async {
      // Create category with 7 tasks
      final manyTasks = List.generate(7, (index) => TodoItem(
        title: 'Task ${index + 1}',
        priority: 'Medium',
        dueDate: DateTime.now(),
        isCompleted: false,
      ));

      final widget = MaterialApp(
        home: Scaffold(
          body: CategorizedTaskSection(
            categorizedTasks: {'Many': manyTasks},
            categoryTaskCounts: {'Many': 7},
            categoryCompletionCounts: {'Many': 0},
          ),
        ),
      );

      await tester.pumpWidget(widget);

      // Expand category
      await tester.tap(find.text('Many'));
      await tester.pumpAndSettle();

      expect(find.text('... and 2 more tasks'), findsOneWidget);
    });

    group('Date formatting', () {
      testWidgets('should format date as MM/DD', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Expand Work category
        await tester.tap(find.text('Work'));
        await tester.pumpAndSettle();

        // March 15, 2025 should be formatted as 03/15
        expect(find.textContaining('03/15'), findsOneWidget);
        // March 16, 2025 should be formatted as 03/16
        expect(find.textContaining('03/16'), findsOneWidget);
      });

      testWidgets('should pad single digit months and days with zero', (tester) async {
        final singleDigitDateTask = TodoItem(
          title: 'Single Digit Date Task',
          priority: 'Medium',
          dueDate: DateTime(2025, 1, 5), // January 5th
          isCompleted: false,
        );

        final widget = MaterialApp(
          home: Scaffold(
            body: CategorizedTaskSection(
              categorizedTasks: {'Test': [singleDigitDateTask]},
              categoryTaskCounts: {'Test': 1},
              categoryCompletionCounts: {'Test': 0},
            ),
          ),
        );

        await tester.pumpWidget(widget);

        // Expand category
        await tester.tap(find.text('Test'));
        await tester.pumpAndSettle();

        // January 5, 2025 should be formatted as 01/05
        expect(find.textContaining('01/05'), findsOneWidget);
      });
    });
  });
}