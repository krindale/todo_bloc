import 'package:flutter/material.dart';
import 'task_info_item.dart';

/// 작업 통계를 보여주는 카드 위젯
class TaskStatisticsCard extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int dueTodayTasks;

  const TaskStatisticsCard({
    Key? key,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.dueTodayTasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Task Summary', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TaskInfoItem(value: totalTasks.toString(), label: 'Total Tasks', color: Colors.blue),
                TaskInfoItem(value: completedTasks.toString(), label: 'Completed', color: Colors.green),
                TaskInfoItem(value: pendingTasks.toString(), label: 'Pending', color: Colors.purple),
                TaskInfoItem(value: dueTodayTasks.toString(), label: 'Due Today', color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 