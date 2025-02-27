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
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Container(
          width: 5,
          height: double.infinity,
          color: priorityColor,
        ),
        title: Text(
            task.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${DateFormat.yMMMd().format(task.dueDate)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: onCompleteChanged,
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}