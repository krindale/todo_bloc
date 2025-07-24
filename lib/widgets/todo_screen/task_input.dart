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
  final String selectedPriority;
  final Function(String) onPriorityChanged;
  final TimeOfDay? alarmTime;
  final VoidCallback onPickAlarmTime;
  final VoidCallback onClearAlarm;
  final bool hasAlarm;

  TaskInput({
    Key? key,
    required this.taskController,
    required this.selectedPriority,
    required this.selectedDate,
    required this.onPickDate,
    required this.onAddOrUpdateTask,
    required this.onCancelEditing,
    required this.isEditing,
    required this.onPriorityChanged,
    this.alarmTime,
    required this.onPickAlarmTime,
    required this.onClearAlarm,
    required this.hasAlarm,
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: PrioritySelector(
                    selectedPriority: selectedPriority,
                    onPriorityChanged: onPriorityChanged,
                  ),
                ),
                const SizedBox(width: 8),
                // 알람 버튼
                Container(
                  height: 36, // 우선순위 버튼보다 작게 조정
                  decoration: BoxDecoration(
                    color: hasAlarm
                        ? Colors.orange.shade100
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasAlarm ? Colors.orange : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          onPressed: onPickAlarmTime,
                          icon: Icon(
                            Icons.alarm,
                            size: 18,
                            color: hasAlarm
                                ? Colors.orange.shade700
                                : Colors.grey.shade600,
                          ),
                          tooltip: '알람 설정',
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      if (hasAlarm) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Text(
                            alarmTime != null ? alarmTime!.format(context) : '',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 28,
                          height: 36,
                          child: IconButton(
                            onPressed: onClearAlarm,
                            icon: Icon(
                              Icons.clear,
                              size: 14,
                              color: Colors.orange.shade700,
                            ),
                            tooltip: '알람 해제',
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isEditing) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onCancelEditing,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 8.0),
                    ),
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
                        ? 'Due Date (Today)'
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
