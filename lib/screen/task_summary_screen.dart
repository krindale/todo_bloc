/// **작업 통계 및 요약 화면**
/// 
/// 사용자의 할 일 현황을 시각적으로 분석하고 보여주는 대시보드 화면입니다.
/// 생산성 지표, 카테고리별 분포, 진행률 등을 한눈에 확인할 수 있습니다.
/// 
/// **주요 기능:**
/// - 전체 작업 통계 (완료율, 진행 상황)
/// - 카테고리별 작업 분포 시각화
/// - 우선순위별 작업 현황
/// - 마감일 임박 작업 알림
/// - 생산성 트렌드 분석
/// 
/// **UI 구성 요소:**
/// - TaskStatisticsCard: 핵심 통계 지표
/// - ProgressCard: 진행률 시각화
/// - CategorySection: 카테고리별 분류
/// - CategorizedTaskSection: 상세 작업 목록
/// 
/// **데이터 소스:**
/// - TaskStatisticsService: 통계 계산
/// - TaskCategorizationService: 카테고리 분석
/// - Repository 패턴: 데이터 추상화
/// 
/// **반응형 설계:**
/// - 모바일/데스크톱 최적화 레이아웃
/// - 다양한 화면 크기 지원

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
import '../services/firebase_sync_service.dart';
import '../services/platform_strategy.dart';
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
  late final FirebaseSyncService _firebaseService;
  late final PlatformStrategy _platformStrategy;

  TaskStatistics? _statistics;
  Map<String, List<TodoItem>> _categorizedTasks = {};

  bool get _shouldUseFirebaseOnly => _platformStrategy.shouldUseFirebaseOnly();

  @override
  void initState() {
    super.initState();
    _todoRepository = widget.todoRepository ?? HiveTodoRepository();
    _categorizationService = widget.categorizationService ?? TaskCategorizationService();
    _statisticsService = widget.statisticsService ?? TaskStatisticsService(
      categorizationService: _categorizationService,
    );
    _categoryProvider = widget.categoryProvider ?? CategoryProvider();
    _firebaseService = FirebaseSyncService();
    _platformStrategy = PlatformStrategyFactory.create();
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
    if (_shouldUseFirebaseOnly) {
      return _buildWithFirebaseStream();
    } else {
      return _buildWithLocalData();
    }
  }

  Widget _buildWithFirebaseStream() {
    return StreamBuilder<List<TodoItem>>(
      stream: _firebaseService.todosStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }
        
        final todos = snapshot.data ?? [];
        final statistics = _statisticsService.calculateStatistics(todos);
        final categorizedTasks = _categorizationService.groupTasksByCategory(todos);
        
        return _buildContent(statistics, categorizedTasks);
      },
    );
  }

  Widget _buildWithLocalData() {
    if (_statistics == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadTodos,
      child: _buildContent(_statistics!, _categorizedTasks),
    );
  }

  Widget _buildContent(TaskStatistics statistics, Map<String, List<TodoItem>> categorizedTasks) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskStatisticsCard(
            totalTasks: statistics.totalTasks,
            completedTasks: statistics.completedTasks,
            pendingTasks: statistics.pendingTasks,
            dueTodayTasks: statistics.dueTodayTasks,
            delayedTasks: statistics.delayedTasks,
            overallProgress: statistics.overallProgress,
            todayProgress: statistics.todayProgress,
          ),
          const SizedBox(height: 20),
          CategorySection(categories: _categoryProvider.getCategories()),
          const SizedBox(height: 20),
          ProgressCard(
            categoryTaskCounts: statistics.categoryTaskCounts,
            categoryCompletionCounts: statistics.categoryCompletionCounts,
            categories: _categoryProvider.getCategories(),
          ),
          const SizedBox(height: 20),
          CategorizedTaskSection(
            categorizedTasks: categorizedTasks,
            categoryTaskCounts: statistics.categoryTaskCounts,
            categoryCompletionCounts: statistics.categoryCompletionCounts,
          ),
        ],
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
