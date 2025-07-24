import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../model/todo_item.dart';

// 3. Task Card Widget
class TaskCard extends StatelessWidget {
  final TodoItem task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onCompleteChanged;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onCompleteChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    switch (task.priority) {
      case 'High':
        priorityColor = Colors.red.shade400;
        break;
      case 'Medium':
        priorityColor = Colors.blue.shade400;
        break;
      default:
        priorityColor = Colors.green.shade400;
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        leading: Container(
          width: 5,
          height: double.infinity,
          color: priorityColor,
        ),
        title: Text(task.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${DateFormat.yMMMd().format(task.dueDate)}'),
            if (task.hasAlarm) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.alarm,
                size: 16,
                color: Colors.orange.shade600,
              ),
              if (task.alarmTime != null) ...[
                const SizedBox(width: 4),
                Text(
                  TimeOfDay.fromDateTime(task.alarmTime!).format(context),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: onCompleteChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: onEdit,
              padding: const EdgeInsets.all(0),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: onDelete,
              padding: const EdgeInsets.all(0),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }
}
