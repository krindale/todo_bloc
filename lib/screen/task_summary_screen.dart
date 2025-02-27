import 'package:flutter/material.dart';
import '../widgets/task_summary/task_statistics_card.dart';
import '../widgets/task_summary/category_section.dart';
import '../widgets/task_summary/progress_card.dart';
import '../widgets/task_summary/category_chip.dart';

/// 작업 요약을 보여주는 화면 위젯
/// 전체 작업 현황, 카테고리 및 진행률을 표시합니다.
class TaskSummaryScreen extends StatelessWidget {
  const TaskSummaryScreen({Key? key}) : super(key: key);

  static const List<CategoryData> defaultCategories = [
    CategoryData(label: 'Work', color: Colors.purple),
    CategoryData(label: 'Personal', color: Colors.grey),
    CategoryData(label: 'Shopping', color: Colors.blueGrey),
    CategoryData(label: 'Health', color: Colors.green),
    CategoryData(label: 'Finance', color: Colors.blue),
    CategoryData(label: 'Travel', color: Colors.orange),
    CategoryData(label: 'Family', color: Colors.brown),
    CategoryData(label: 'Social', color: Colors.cyan),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          TaskStatisticsCard(
            totalTasks: 32,
            completedTasks: 18,
            pendingTasks: 8,
            dueTodayTasks: 6,
          ),
          SizedBox(height: 20),
          CategorySection(categories: defaultCategories),
          SizedBox(height: 20),
          ProgressCard(
            totalTasks: 18,
            completedTasks: 14,
          ),
        ],
      ),
    );
  }
}
