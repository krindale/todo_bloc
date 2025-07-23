import '../model/todo_item.dart';

class TaskStatistics {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int dueTodayTasks;

  const TaskStatistics({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.dueTodayTasks,
  });
}

class TaskStatisticsService {
  TaskStatistics calculateStatistics(List<TodoItem> tasks) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final pendingTasks = tasks.where((task) => !task.isCompleted).length;
    final dueTodayTasks = tasks.where((task) => _isToday(task.dueDate)).length;

    return TaskStatistics(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      dueTodayTasks: dueTodayTasks,
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}