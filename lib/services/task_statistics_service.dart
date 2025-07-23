import '../model/todo_item.dart';
import 'task_categorization_service.dart';

class TaskStatistics {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int dueTodayTasks;
  final Map<String, int> categoryTaskCounts;
  final Map<String, int> categoryCompletionCounts;

  const TaskStatistics({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.dueTodayTasks,
    required this.categoryTaskCounts,
    required this.categoryCompletionCounts,
  });
}

class TaskStatisticsService {
  final TaskCategorizationService _categorizationService;

  TaskStatisticsService({TaskCategorizationService? categorizationService})
      : _categorizationService = categorizationService ?? TaskCategorizationService();

  TaskStatistics calculateStatistics(List<TodoItem> tasks) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final pendingTasks = tasks.where((task) => !task.isCompleted).length;
    final dueTodayTasks = tasks.where((task) => _isToday(task.dueDate)).length;

    final categoryTaskCounts = _categorizationService.getCategoryTaskCounts(tasks);
    final categoryCompletionCounts = _categorizationService.getCategoryCompletionCounts(tasks);

    return TaskStatistics(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      dueTodayTasks: dueTodayTasks,
      categoryTaskCounts: categoryTaskCounts,
      categoryCompletionCounts: categoryCompletionCounts,
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}