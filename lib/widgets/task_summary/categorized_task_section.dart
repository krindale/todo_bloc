import 'package:flutter/material.dart';
import '../../model/todo_item.dart';
import '../../data/category_data.dart';

class CategorizedTaskSection extends StatelessWidget {
  final Map<String, List<TodoItem>> categorizedTasks;
  final Map<String, int> categoryTaskCounts;
  final Map<String, int> categoryCompletionCounts;

  const CategorizedTaskSection({
    Key? key,
    required this.categorizedTasks,
    required this.categoryTaskCounts,
    required this.categoryCompletionCounts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (categorizedTasks.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No tasks available',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tasks by Category',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...categorizedTasks.entries.map((entry) {
          final category = entry.key;
          final tasks = entry.value;
          final totalCount = categoryTaskCounts[category] ?? 0;
          final completedCount = categoryCompletionCounts[category] ?? 0;
          final completionRate = totalCount > 0 ? (completedCount / totalCount * 100).round() : 0;
          
          return _buildCategoryCard(
            context,
            category,
            tasks,
            totalCount,
            completedCount,
            completionRate,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String category,
    List<TodoItem> tasks,
    int totalCount,
    int completedCount,
    int completionRate,
  ) {
    final categoryColor = _getCategoryColor(category);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: categoryColor,
            shape: BoxShape.circle,
          ),
        ),
        title: Text(
          category,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$completedCount/$totalCount tasks completed ($completionRate%)',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$totalCount',
            style: TextStyle(
              color: categoryColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          if (tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No tasks in this category'),
            )
          else
            ...tasks.take(5).map((task) => _buildTaskItem(context, task, categoryColor)),
          if (tasks.length > 5)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '... and ${tasks.length - 5} more tasks',
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(BuildContext context, TodoItem task, Color categoryColor) {
    return ListTile(
      dense: true,
      leading: Icon(
        task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        color: task.isCompleted ? Colors.green : Colors.grey,
        size: 20,
      ),
      title: Text(
        task.title,
        style: TextStyle(
          fontSize: 14,
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? Colors.grey : null,
        ),
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Priority: ${task.priority} • Due: ${_formatDate(task.dueDate)}',
            style: const TextStyle(fontSize: 12),
          ),
          if (task.hasAlarm) ...[
            const SizedBox(width: 8),
            Icon(
              Icons.alarm,
              size: 14,
              color: Colors.orange.shade600,
            ),
            if (task.alarmTime != null) ...[
              const SizedBox(width: 4),
              Text(
                TimeOfDay.fromDateTime(task.alarmTime!).format(context),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.orange.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: _getPriorityColor(task.priority).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          task.priority,
          style: TextStyle(
            color: _getPriorityColor(task.priority),
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final categoryData = CategoryProvider.defaultCategories
        .firstWhere((c) => c.label == category, orElse: () => const CategoryData(label: '', color: Colors.grey));
    return categoryData.color;
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade400;
      case 'medium':
        return Colors.blue.shade400;
      case 'low':
        return Colors.green.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {    
      return 'Yesterday';
    } else if (difference > 1) {
      return 'In $difference days';
    } else {
      return '${-difference} days ago';
    }
  }
}