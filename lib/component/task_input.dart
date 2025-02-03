import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'priority_selector.dart';

// 2. Task Input Widget
class TaskInput extends StatelessWidget {
  final TextEditingController taskController;
  final DateTime? selectedDate;
  final VoidCallback onPickDate;
  final VoidCallback onAddOrUpdateTask;
  final VoidCallback onCancelEditing;
  final bool isEditing;
  String selectedPriority;

  TaskInput({
    Key? key,
    required this.taskController,
    required this.selectedPriority,
    required this.selectedDate,
    required this.onPickDate,
    required this.onAddOrUpdateTask,
    required this.onCancelEditing,
    required this.isEditing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: 'Task Description',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: PrioritySelector(
                    selectedPriority: selectedPriority,
                    onPriorityChanged: (priority) {
                      // Handle priority change in parent widget
                      selectedPriority = priority;
                    },
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onCancelEditing,
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(selectedDate == null
                        ? 'Due Date'
                        : DateFormat.yMMMd().format(selectedDate!)),
                    onPressed: onPickDate,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAddOrUpdateTask,
                    child: Text(isEditing ? 'Update Task' : '+ Add Task'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}