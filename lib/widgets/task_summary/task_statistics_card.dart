import 'package:flutter/material.dart';
import 'task_info_item.dart';
import '../common/ring_chart.dart';

/// 작업 통계를 보여주는 카드 위젯
class TaskStatisticsCard extends StatelessWidget {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int dueTodayTasks;
  final int delayedTasks;
  final double overallProgress;
  final double todayProgress;

  const TaskStatisticsCard({
    Key? key,
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.dueTodayTasks,
    required this.delayedTasks,
    required this.overallProgress,
    required this.todayProgress,
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
                TaskInfoItem(value: delayedTasks.toString(), label: 'Delayed', color: Colors.orange),
              ],
            ),
            SizedBox(height: 32),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildProgressRingChart(
                  'Overall Progress',
                  overallProgress / 100,
                  Colors.blue,
                ),
                _buildProgressRingChart(
                  'Today\'s Progress',
                  todayProgress / 100,
                  Colors.green,
                ),
              ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRingChart(String title, double progress, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        RingChart(
          progress: progress,
          color: color,
          size: 100.0,
          strokeWidth: 8.0,
          centerWidget: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 