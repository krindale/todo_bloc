import 'package:flutter/material.dart';
import '../widgets/task_summary/task_statistics_card.dart';
import '../widgets/task_summary/category_section.dart';
import '../widgets/task_summary/progress_card.dart';
import '../widgets/task_summary/categorized_task_section.dart';
import '../model/todo_item.dart';
import '../services/todo_repository.dart';
import '../services/hive_todo_repository.dart';
import '../services/task_statistics_service.dart';
import '../services/task_categorization_service.dart';
import '../data/category_data.dart';

/// 작업 요약을 보여주는 화면 위젯
/// 전체 작업 현황, 카테고리 및 진행률을 표시합니다.
class TaskSummaryScreen extends StatefulWidget {
  final TodoRepository? todoRepository;
  final TaskStatisticsService? statisticsService;
  final CategoryProvider? categoryProvider;
  final TaskCategorizationService? categorizationService;

  const TaskSummaryScreen({
    Key? key,
    this.todoRepository,
    this.statisticsService,
    this.categoryProvider,
    this.categorizationService,
  }) : super(key: key);

  @override
  _TaskSummaryScreenState createState() => _TaskSummaryScreenState();
}

class _TaskSummaryScreenState extends State<TaskSummaryScreen> {
  late final TodoRepository _todoRepository;
  late final TaskStatisticsService _statisticsService;
  late final CategoryProvider _categoryProvider;
  late final TaskCategorizationService _categorizationService;

  TaskStatistics? _statistics;
  Map<String, List<TodoItem>> _categorizedTasks = {};

  @override
  void initState() {
    super.initState();
    _todoRepository = widget.todoRepository ?? HiveTodoRepository();
    _categorizationService = widget.categorizationService ?? TaskCategorizationService();
    _statisticsService = widget.statisticsService ?? TaskStatisticsService(
      categorizationService: _categorizationService,
    );
    _categoryProvider = widget.categoryProvider ?? CategoryProvider();
    _loadTodos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 화면이 다시 보여질 때마다 데이터 새로고침
    _loadTodos();
  }

  @override
  Widget build(BuildContext context) {
    if (_statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadTodos,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
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
            const SizedBox(height: 20),
            CategorizedTaskSection(
              categorizedTasks: _categorizedTasks,
              categoryTaskCounts: _statistics!.categoryTaskCounts,
              categoryCompletionCounts: _statistics!.categoryCompletionCounts,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadTodos() async {
    try {
      final todos = await _todoRepository.getTodos();
      final statistics = _statisticsService.calculateStatistics(todos);
      final categorizedTasks = _categorizationService.groupTasksByCategory(todos);
      
      setState(() {
        _statistics = statistics;
        _categorizedTasks = categorizedTasks;
      });
    } catch (e) {
      // 에러 처리
      debugPrint('Error loading todos: $e');
    }
  }
}
