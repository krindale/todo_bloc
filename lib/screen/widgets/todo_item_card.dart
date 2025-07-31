/// **Todo 항목 카드 위젯**
/// 
/// 개별 Todo 항목을 표시하는 카드 위젯입니다.

import 'package:flutter/material.dart';
import '../../domain/entities/todo_entity.dart';
import '../../core/utils/date_formatter.dart';

class TodoItemCard extends StatelessWidget {
  final TodoEntity todo;
  final VoidCallback onToggleComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool showDate;

  const TodoItemCard({
    super.key,
    required this.todo,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggleComplete(),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted 
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty)
              Text(
                todo.description,
                style: TextStyle(
                  decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                  color: todo.isCompleted 
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.4)
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (showDate)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 12,
                      color: _getDueDateColor(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.formatShortMonthDayWeekday(todo.dueDate),
                      style: TextStyle(
                        fontSize: 11,
                        color: _getDueDateColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriorityIndicator(context),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                    break;
                  case 'delete':
                    onDelete();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('편집'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('삭제', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 우선순위 표시기
  Widget _buildPriorityIndicator(BuildContext context) {
    Color priorityColor;
    switch (todo.priority) {
      case TodoPriority.high:
        priorityColor = Colors.red;
        break;
      case TodoPriority.medium:
        priorityColor = Colors.orange;
        break;
      case TodoPriority.low:
        priorityColor = Colors.green;
        break;
    }

    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: priorityColor,
        shape: BoxShape.circle,
      ),
    );
  }

  /// 마감일 색상 결정
  Color _getDueDateColor(BuildContext context) {
    if (todo.isCompleted) {
      return Theme.of(context).colorScheme.onSurface.withOpacity(0.4);
    }

    if (todo.isOverdue) {
      return Colors.red;
    }

    if (todo.isDueToday) {
      return Colors.orange;
    }

    return Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
  }
}