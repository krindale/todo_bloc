import 'package:flutter/material.dart';
import 'task_card.dart';
import '../../../model/todo_item.dart';

// 4. Task List Widget
class TaskList extends StatelessWidget {
  final List<TodoItem> tasks;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final Function(int, bool?) onCompleteChanged;

  const TaskList({
    Key? key,
    required this.tasks,
    required this.onEdit,
    required this.onDelete,
    required this.onCompleteChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        return TaskCard(
          task: tasks[index],
          onEdit: () => onEdit(index),
          onDelete: () => onDelete(index),
          onCompleteChanged: (value) => onCompleteChanged(index, value),
        );
      },
    );
  }
}