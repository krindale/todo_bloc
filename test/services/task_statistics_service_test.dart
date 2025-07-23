import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/services/task_statistics_service.dart';
import 'package:todo_bloc/services/task_categorization_service.dart';

void main() {
  group('TaskStatisticsService', () {
    late TaskStatisticsService service;

    setUp(() {
      service = TaskStatisticsService(
        categorizationService: TaskCategorizationService(),
      );
    });

    test('should calculate statistics for empty list', () {
      final tasks = <TodoItem>[];
      
      final result = service.calculateStatistics(tasks);
      
      expect(result.totalTasks, 0);
      expect(result.completedTasks, 0);
      expect(result.pendingTasks, 0);
      expect(result.dueTodayTasks, 0);
      expect(result.categoryTaskCounts, <String, int>{});
      expect(result.categoryCompletionCounts, <String, int>{});
    });

    test('should calculate statistics correctly', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      
      final tasks = [
        TodoItem(
          title: 'Task 1',
          priority: 'High',
          dueDate: today,
          isCompleted: true,
        ),
        TodoItem(
          title: 'Task 2',
          priority: 'Medium',
          dueDate: today,
          isCompleted: false,
        ),
        TodoItem(
          title: 'Task 3',
          priority: 'Low',
          dueDate: yesterday,
          isCompleted: false,
        ),
      ];
      
      final result = service.calculateStatistics(tasks);
      
      expect(result.totalTasks, 3);
      expect(result.completedTasks, 1);
      expect(result.pendingTasks, 2);
      expect(result.dueTodayTasks, 2);
    });

    test('should handle tasks with different dates', () {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));
      
      final tasks = [
        TodoItem(
          title: 'Task 1',
          priority: 'High',
          dueDate: tomorrow,
          isCompleted: false,
        ),
      ];
      
      final result = service.calculateStatistics(tasks);
      
      expect(result.totalTasks, 1);
      expect(result.completedTasks, 0);
      expect(result.pendingTasks, 1);
      expect(result.dueTodayTasks, 0);
    });
  });
}