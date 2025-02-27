import 'package:flutter/material.dart';

/// 작업 진행률을 표시하는 카드 위젯
class ProgressCard extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;

  const ProgressCard({
    Key? key,
    required this.totalTasks,
    required this.completedTasks,
  }) : super(key: key);

  double get progressPercentage => 
      totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Progress', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Center(
              child: Column(
                children: [
                  Text(
                    '${progressPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '$completedTasks of $totalTasks completed',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 