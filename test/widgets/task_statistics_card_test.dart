import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/widgets/task_summary/task_statistics_card.dart';

void main() {
  group('TaskStatisticsCard', () {
    testWidgets('should display all task statistics', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskStatisticsCard(
              totalTasks: 10,
              completedTasks: 5,
              pendingTasks: 4,
              dueTodayTasks: 1,
              delayedTasks: 2,
              overallProgress: 50.0,
              todayProgress: 100.0,
            ),
          ),
        ),
      );

      expect(find.text('Task Summary'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      
      expect(find.text('Total Tasks'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Due Today'), findsOneWidget);
    });

    testWidgets('should display zero values correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskStatisticsCard(
              totalTasks: 0,
              completedTasks: 0,
              pendingTasks: 0,
              dueTodayTasks: 0,
              delayedTasks: 0,
              overallProgress: 0.0,
              todayProgress: 0.0,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsNWidgets(5));
    });

    testWidgets('should be wrapped in a Card widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TaskStatisticsCard(
              totalTasks: 1,
              completedTasks: 1,
              pendingTasks: 0,
              dueTodayTasks: 0,
              delayedTasks: 0,
              overallProgress: 100.0,
              todayProgress: 0.0,
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
    });
  });
}