/// **Todo 도메인 레포지토리 인터페이스**
/// 
/// 클린 아키텍처의 도메인 레이어에서 정의하는 추상 레포지토리입니다.
/// 데이터 저장소의 구체적인 구현에 의존하지 않고, 순수한 비즈니스 요구사항만 정의합니다.

import '../entities/todo_entity.dart';

/// Todo 레포지토리 인터페이스
abstract class TodoRepository {
  /// 모든 Todo 항목 조회
  Future<List<TodoEntity>> getAllTodos();

  /// ID로 특정 Todo 항목 조회
  Future<TodoEntity?> getTodoById(String id);

  /// 완료되지 않은 Todo 항목들 조회
  Future<List<TodoEntity>> getIncompleteTodos();

  /// 완료된 Todo 항목들 조회
  Future<List<TodoEntity>> getCompletedTodos();

  /// 카테고리별 Todo 항목들 조회
  Future<List<TodoEntity>> getTodosByCategory(TodoCategory category);

  /// 오늘 마감인 Todo 항목들 조회
  Future<List<TodoEntity>> getTodosDueToday();

  /// 지난 마감일 Todo 항목들 조회
  Future<List<TodoEntity>> getOverdueTodos();

  /// Todo 항목 추가
  Future<String> addTodo(TodoEntity todo);

  /// Todo 항목 수정
  Future<void> updateTodo(TodoEntity todo);

  /// Todo 항목 삭제
  Future<void> deleteTodo(String id);

  /// 여러 Todo 항목 삭제
  Future<void> deleteTodos(List<String> ids);

  /// Todo 완료 상태 토글
  Future<void> toggleTodoCompletion(String id);

  /// 완료된 모든 Todo 항목 삭제
  Future<void> deleteCompletedTodos();

  /// Todo 항목 검색
  Future<List<TodoEntity>> searchTodos(String query);

  /// Todo 항목 실시간 스트림 (선택적)
  Stream<List<TodoEntity>>? getTodosStream();

  /// 통계 정보 조회
  Future<TodoStatistics> getStatistics();
}

/// Todo 통계 정보
class TodoStatistics {
  final int totalCount;
  final int completedCount;
  final int incompleteCount;
  final int overdueCount;
  final int dueTodayCount;
  final Map<TodoCategory, int> categoryCount;
  final Map<TodoPriority, int> priorityCount;

  const TodoStatistics({
    required this.totalCount,
    required this.completedCount,
    required this.incompleteCount,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.categoryCount,
    required this.priorityCount,
  });

  double get completionRate {
    if (totalCount == 0) return 0.0;
    return completedCount / totalCount;
  }

  double get overdueRate {
    if (incompleteCount == 0) return 0.0;
    return overdueCount / incompleteCount;
  }
}