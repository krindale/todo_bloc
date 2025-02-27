import 'package:flutter/material.dart';
import 'task_info_item.dart';

/// 작업 통계를 보여주는 카드 위젯
class TaskStatisticsCard extends StatelessWidget {
  const TaskStatisticsCard({Key? key}) : super(key: key);

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
              children: const [
                TaskInfoItem(value: '32', label: 'Total Tasks', color: Colors.blue),
                TaskInfoItem(value: '18', label: 'Completed', color: Colors.green),
                TaskInfoItem(value: '8', label: 'Pending', color: Colors.purple),
                TaskInfoItem(value: '6', label: 'Due Today', color: Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 