import 'package:flutter/material.dart';
import '../widgets/task_summary/task_statistics_card.dart';
import '../widgets/task_summary/category_section.dart';
import '../widgets/task_summary/progress_card.dart';
import '../widgets/task_summary/category_chip.dart';

import '../../../model/todo_item.dart';
import '../../../util/todo_database.dart';

/// 작업 요약을 보여주는 화면 위젯
/// 전체 작업 현황, 카테고리 및 진행률을 표시합니다.
class TaskSummaryScreen extends StatefulWidget {
  const TaskSummaryScreen({Key? key}) : super(key: key);

  @override
  _TaskSummaryScreenState createState() => _TaskSummaryScreenState();
}

class _TaskSummaryScreenState extends State<TaskSummaryScreen> {
  
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

  List<TodoItem> _tasks = [];

  int get _totalTasks => _tasks.length;
  int get _completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get _pendingTasks => _tasks.where((task) => !task.isCompleted).length;
  int get _dueTodayTasks => _tasks.where((task) => task.dueDate == DateTime.now()).length;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskStatisticsCard(
            totalTasks: _totalTasks,
            completedTasks: _completedTasks,
            pendingTasks: _pendingTasks,
            dueTodayTasks: _dueTodayTasks,
          ),
          SizedBox(height: 20),
          CategorySection(categories: defaultCategories),
          SizedBox(height: 20),
          ProgressCard(
            totalTasks: _totalTasks,
            completedTasks: _completedTasks,
          ),
        ],
      ),
    );
  }

  void _loadTodos() async {
    final todos = await TodoDatabase.getTodos();
    setState(() {
      _tasks = todos;
    });
  }
}
