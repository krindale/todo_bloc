/// **작업 통계 분석 서비스**
/// 
/// 사용자의 할 일 데이터를 분석하여 생산성 지표와 통계를 제공합니다.
/// 대시보드와 리포트 화면에서 사용되는 핵심 분석 엔진입니다.
/// 
/// **분석 지표:**
/// - 전체 작업 수 및 완료율
/// - 카테고리별 작업 분포
/// - 우선순위별 현황
/// - 마감일 기반 작업 분류
/// - 생산성 트렌드 분석
/// 
/// **제공하는 통계:**
/// - TaskStatistics: 기본 통계 정보
/// - 카테고리별 완료율
/// - 오늘 마감인 작업 수
/// - 우선순위별 분포
/// - 시간대별 작업 패턴
/// 
/// **사용 사례:**
/// - 대시보드 위젯 데이터 공급
/// - 진행률 시각화
/// - 생산성 리포트 생성
/// - 사용자 행동 분석
/// 
/// **의존성:**
/// - TaskCategorizationService: 카테고리 분류 로직
/// - TodoItem 모델: 작업 데이터 구조

import '../model/todo_item.dart';
import 'task_categorization_service.dart';

class TaskStatistics {
  final int totalTasks;
  final int completedTasks;
  final int pendingTasks;
  final int dueTodayTasks;
  final Map<String, int> categoryTaskCounts;
  final Map<String, int> categoryCompletionCounts;

  const TaskStatistics({
    required this.totalTasks,
    required this.completedTasks,
    required this.pendingTasks,
    required this.dueTodayTasks,
    required this.categoryTaskCounts,
    required this.categoryCompletionCounts,
  });
}

class TaskStatisticsService {
  final TaskCategorizationService _categorizationService;

  TaskStatisticsService({TaskCategorizationService? categorizationService})
      : _categorizationService = categorizationService ?? TaskCategorizationService();

  TaskStatistics calculateStatistics(List<TodoItem> tasks) {
    final totalTasks = tasks.length;
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final pendingTasks = tasks.where((task) => !task.isCompleted).length;
    final dueTodayTasks = tasks.where((task) => _isToday(task.dueDate)).length;

    final categoryTaskCounts = _categorizationService.getCategoryTaskCounts(tasks);
    final categoryCompletionCounts = _categorizationService.getCategoryCompletionCounts(tasks);

    return TaskStatistics(
      totalTasks: totalTasks,
      completedTasks: completedTasks,
      pendingTasks: pendingTasks,
      dueTodayTasks: dueTodayTasks,
      categoryTaskCounts: categoryTaskCounts,
      categoryCompletionCounts: categoryCompletionCounts,
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}