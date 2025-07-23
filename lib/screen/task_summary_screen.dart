import 'package:flutter/material.dart';
import '../widgets/task_summary/task_statistics_card.dart';
import '../widgets/task_summary/category_section.dart';
import '../widgets/task_summary/progress_card.dart';
import '../model/todo_item.dart';
import '../services/todo_repository.dart';
import '../services/hive_todo_repository.dart';
import '../services/task_statistics_service.dart';
import '../data/category_data.dart';

/// 작업 요약을 보여주는 화면 위젯
/// 전체 작업 현황, 카테고리 및 진행률을 표시합니다.
class TaskSummaryScreen extends StatefulWidget {
  final TodoRepository? todoRepository;
  final TaskStatisticsService? statisticsService;
  final CategoryProvider? categoryProvider;

  const TaskSummaryScreen({
    Key? key,
    this.todoRepository,
    this.statisticsService,
    this.categoryProvider,
  }) : super(key: key);

  @override
  _TaskSummaryScreenState createState() => _TaskSummaryScreenState();
}

class _TaskSummaryScreenState extends State<TaskSummaryScreen> {
  late final TodoRepository _todoRepository;
  late final TaskStatisticsService _statisticsService;
  late final CategoryProvider _categoryProvider;

  TaskStatistics? _statistics;

  @override
  void initState() {
    super.initState();
    _todoRepository = widget.todoRepository ?? HiveTodoRepository();
    _statisticsService = widget.statisticsService ?? TaskStatisticsService();
    _categoryProvider = widget.categoryProvider ?? CategoryProvider();
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    if (_statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskStatisticsCard(
            totalTasks: _statistics!.totalTasks,
            completedTasks: _statistics!.completedTasks,
            pendingTasks: _statistics!.pendingTasks,
            dueTodayTasks: _statistics!.dueTodayTasks,
          ),
          const SizedBox(height: 20),
          CategorySection(categories: _categoryProvider.getCategories()),
          const SizedBox(height: 20),
          ProgressCard(
            totalTasks: _statistics!.totalTasks,
            completedTasks: _statistics!.completedTasks,
          ),
        ],
      ),
    );
  }

  Future<void> _loadTodos() async {
    try {
      final todos = await _todoRepository.getTodos();
      final statistics = _statisticsService.calculateStatistics(todos);
      
      setState(() {
        _statistics = statistics;
      });
    } catch (e) {
      // 에러 처리
      debugPrint('Error loading todos: $e');
    }
  }
}
