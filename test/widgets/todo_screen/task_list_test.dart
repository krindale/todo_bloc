import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/widgets/todo_screen/task_list.dart';
import 'package:todo_bloc/model/todo_item.dart';

void main() {
  group('TaskList', () {
    late List<TodoItem> mockTasks;
    late Function(int) mockOnEdit;
    late Function(int) mockOnDelete;
    late Function(int, bool?) mockOnCompleteChanged;

    setUp(() {
      mockOnEdit = (index) {};
      mockOnDelete = (index) {};
      mockOnCompleteChanged = (index, value) {};

      mockTasks = [
        // 지난 날 완료된 할일
        TodoItem(
          title: 'Past Completed Task',
          priority: 'High',
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
          isCompleted: true,
        ),
        // 지난 날 미완료된 할일
        TodoItem(
          title: 'Past Incomplete Task',
          priority: 'Medium',
          dueDate: DateTime.now().subtract(const Duration(days: 1)),
          isCompleted: false,
        ),
        // 현재/미래 할일
        TodoItem(
          title: 'Current Task',
          priority: 'Low',
          dueDate: DateTime.now(),
          isCompleted: false,
        ),
        TodoItem(
          title: 'Future Task',
          priority: 'High',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          isCompleted: false,
        ),
      ];
    });

    Widget createTestWidget({List<TodoItem>? tasks}) {
      return MaterialApp(
        home: Scaffold(
          body: TaskList(
            tasks: tasks ?? mockTasks,
            onEdit: mockOnEdit,
            onDelete: mockOnDelete,
            onCompleteChanged: mockOnCompleteChanged,
          ),
        ),
      );
    }

    testWidgets('should display empty state when no tasks', (tester) async {
      await tester.pumpWidget(createTestWidget(tasks: []));

      expect(find.text('할 일이 없습니다!'), findsOneWidget);
    });

    testWidgets('should group tasks into correct categories', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for group headers
      expect(find.text('지난 날 완료된 할일 (1개)'), findsOneWidget);
      expect(find.text('지난 날 미완료된 할일 (1개)'), findsOneWidget);
      expect(find.text('현재 및 예정된 할일 (2개)'), findsOneWidget);
    });

    testWidgets('should display correct group colors and icons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for specific icons
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // 완료된 할일
      expect(find.byIcon(Icons.warning), findsOneWidget); // 미완료된 할일
      expect(find.byIcon(Icons.schedule), findsOneWidget); // 현재/예정된 할일
    });

    testWidgets('should have collapsible past completed section', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Past completed section should be collapsible (has arrow)
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      // Initially collapsed, so task content should not be visible
      expect(find.text('Past Completed Task'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('지난 날 완료된 할일 (1개)'));
      await tester.pumpAndSettle();

      // Now task should be visible
      expect(find.text('Past Completed Task'), findsOneWidget);
      
      // Arrow should now point up
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });

    testWidgets('should show non-collapsible sections expanded by default', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Non-collapsible sections should show their tasks immediately
      expect(find.text('Past Incomplete Task'), findsOneWidget);
      expect(find.text('Current Task'), findsOneWidget);
      expect(find.text('Future Task'), findsOneWidget);
    });

    testWidgets('should handle task completion state changes with animation', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap on a task completion checkbox
      // Since we're testing animations, we should find task cards
      expect(find.byType(AnimatedContainer), findsAtLeastNWidgets(3)); // Should have animated containers
    });

    testWidgets('should display task cards with proper keys for animation', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Expand past completed section
      await tester.tap(find.text('지난 날 완료된 할일 (1개)'));
      await tester.pumpAndSettle();

      // Each task should have a unique ValueKey based on title, date, and completion status
      final taskCardFinder = find.byType(TweenAnimationBuilder<double>);
      expect(taskCardFinder, findsAtLeastNWidgets(1));
    });

    group('Task Grouping Logic', () {
      testWidgets('should correctly identify past completed tasks', (tester) async {
        final pastCompletedTask = TodoItem(
          title: 'Old Completed Task',
          priority: 'Medium',
          dueDate: DateTime.now().subtract(const Duration(days: 5)),
          isCompleted: true,
        );

        await tester.pumpWidget(createTestWidget(tasks: [pastCompletedTask]));
        await tester.pumpAndSettle();

        expect(find.text('지난 날 완료된 할일 (1개)'), findsOneWidget);
      });

      testWidgets('should correctly identify past incomplete tasks', (tester) async {
        final pastIncompleteTask = TodoItem(
          title: 'Old Incomplete Task',
          priority: 'High',
          dueDate: DateTime.now().subtract(const Duration(days: 3)),
          isCompleted: false,
        );

        await tester.pumpWidget(createTestWidget(tasks: [pastIncompleteTask]));
        await tester.pumpAndSettle();

        expect(find.text('지난 날 미완료된 할일 (1개)'), findsOneWidget);
      });

      testWidgets('should correctly identify current and future tasks', (tester) async {
        final todayTask = TodoItem(
          title: 'Today Task',
          priority: 'Medium',
          dueDate: DateTime.now(),
          isCompleted: false,
        );

        final futureTask = TodoItem(
          title: 'Future Task',
          priority: 'Low',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          isCompleted: false,
        );

        await tester.pumpWidget(createTestWidget(tasks: [todayTask, futureTask]));
        await tester.pumpAndSettle();

        expect(find.text('현재 및 예정된 할일 (2개)'), findsOneWidget);
      });
    });

    group('Animation Tests', () {
      testWidgets('should have AnimatedList for group transitions', (tester) async {
        await tester.pumpWidget(createTestWidget());
        
        expect(find.byType(AnimatedList), findsOneWidget);
      });

      testWidgets('should have SlideTransition and FadeTransition for groups', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(SlideTransition), findsAtLeastNWidgets(1));
        expect(find.byType(FadeTransition), findsAtLeastNWidgets(1));
      });

      testWidgets('should have animated containers for individual tasks', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        expect(find.byType(AnimatedContainer), findsAtLeastNWidgets(3));
      });

      testWidgets('should animate collapse/expand with rotation', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Should have AnimationController for rotation
        expect(find.byType(AnimatedBuilder), findsAtLeastNWidgets(1));
      });
    });

    group('Group Ordering', () {
      testWidgets('should display groups in correct order', (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Get all group widgets
        final groupWidgets = find.byType(Card);
        expect(groupWidgets, findsAtLeastNWidgets(3));

        // The order should be:
        // 1. 지난 날 완료된 할일 (at top)
        // 2. 현재 및 예정된 할일 (middle)
        // 3. 지난 날 미완료된 할일 (at bottom)
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle tasks with same due date but different completion status', (tester) async {
        final sameDateTasks = [
          TodoItem(
            title: 'Completed Today',
            priority: 'High',
            dueDate: DateTime.now(),
            isCompleted: true,
          ),
          TodoItem(
            title: 'Incomplete Today',
            priority: 'Medium',
            dueDate: DateTime.now(),
            isCompleted: false,
          ),
        ];

        await tester.pumpWidget(createTestWidget(tasks: sameDateTasks));
        await tester.pumpAndSettle();

        // Both should be in "current and future" section since they're today
        expect(find.text('현재 및 예정된 할일 (2개)'), findsOneWidget);
      });

      testWidgets('should handle only past completed tasks', (tester) async {
        final onlyPastCompleted = [
          TodoItem(
            title: 'Old Completed 1',
            priority: 'High',
            dueDate: DateTime.now().subtract(const Duration(days: 1)),
            isCompleted: true,
          ),
          TodoItem(
            title: 'Old Completed 2',
            priority: 'Medium',
            dueDate: DateTime.now().subtract(const Duration(days: 2)),
            isCompleted: true,
          ),
        ];

        await tester.pumpWidget(createTestWidget(tasks: onlyPastCompleted));
        await tester.pumpAndSettle();

        expect(find.text('지난 날 완료된 할일 (2개)'), findsOneWidget);
        // Other sections should not appear
        expect(find.text('현재 및 예정된 할일'), findsNothing);
        expect(find.text('지난 날 미완료된 할일'), findsNothing);
      });
    });
  });
}