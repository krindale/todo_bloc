import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/data/category_data.dart';
import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/screen/task_summary_screen.dart';
import 'package:todo_bloc/services/task_statistics_service.dart';
import '../services/mock_todo_repository.dart';

void main() {
  group('TaskSummaryScreen', () {
    late MockTodoRepository mockRepository;
    late TaskStatisticsService statisticsService;
    late CategoryProvider categoryProvider;

    setUp(() {
      mockRepository = MockTodoRepository();
      statisticsService = TaskStatisticsService();
      categoryProvider = CategoryProvider();
    });

    testWidgets('should display loading indicator initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskSummaryScreen(
              todoRepository: mockRepository,
              statisticsService: statisticsService,
              categoryProvider: categoryProvider,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display task statistics after loading', (tester) async {
      final today = DateTime.now();
      mockRepository.addMockTodo(
        TodoItem(
          title: 'Test Task',
          priority: 'High',
          dueDate: today,
          isCompleted: false,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskSummaryScreen(
              todoRepository: mockRepository,
              statisticsService: statisticsService,
              categoryProvider: categoryProvider,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Task Summary'), findsOneWidget);
      expect(find.text('1'), findsAtLeastNWidgets(1));
    });

    testWidgets('should display categories section', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskSummaryScreen(
              todoRepository: mockRepository,
              statisticsService: statisticsService,
              categoryProvider: categoryProvider,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Personal'), findsOneWidget);
    });

    testWidgets('should handle repository errors gracefully', (tester) async {
      mockRepository.shouldThrowError = true;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskSummaryScreen(
              todoRepository: mockRepository,
              statisticsService: statisticsService,
              categoryProvider: categoryProvider,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

  });
}