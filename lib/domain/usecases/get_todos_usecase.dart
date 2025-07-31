/// **Todo 조회 Use Case**
/// 
/// Todo 항목들을 조회하고 필터링하는 비즈니스 로직을 담당합니다.

import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

/// Todo 조회 Use Case
class GetTodosUseCase {
  final TodoRepository _repository;

  const GetTodosUseCase(this._repository);

  /// 모든 Todo 조회
  Future<List<TodoEntity>> execute([GetTodosParams? params]) async {
    List<TodoEntity> todos;

    // 파라미터에 따른 조회 방식 결정
    if (params == null) {
      todos = await _repository.getAllTodos();
    } else {
      todos = await _getTodosByFilter(params);
    }

    // 정렬 적용
    if (params?.sortBy != null) {
      todos = _sortTodos(todos, params!.sortBy!, params.sortOrder);
    }

    // 제한 적용
    if (params?.limit != null && params!.limit! > 0) {
      todos = todos.take(params.limit!).toList();
    }

    return todos;
  }

  Future<List<TodoEntity>> _getTodosByFilter(GetTodosParams params) async {
    switch (params.filter) {
      case TodoFilter.all:
        return await _repository.getAllTodos();
      case TodoFilter.incomplete:
        return await _repository.getIncompleteTodos();
      case TodoFilter.completed:
        return await _repository.getCompletedTodos();
      case TodoFilter.dueToday:
        return await _repository.getTodosDueToday();
      case TodoFilter.overdue:
        return await _repository.getOverdueTodos();
      case TodoFilter.byCategory:
        if (params.category == null) {
          throw ArgumentError('카테고리 필터에는 카테고리가 필요합니다.');
        }
        return await _repository.getTodosByCategory(params.category!);
    }
  }

  List<TodoEntity> _sortTodos(
    List<TodoEntity> todos,
    TodoSortBy sortBy,
    SortOrder sortOrder,
  ) {
    todos.sort((a, b) {
      int comparison;

      switch (sortBy) {
        case TodoSortBy.dueDate:
          comparison = a.dueDate.compareTo(b.dueDate);
          break;
        case TodoSortBy.priority:
          comparison = _comparePriority(a.priority, b.priority);
          break;
        case TodoSortBy.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case TodoSortBy.title:
          comparison = a.title.compareTo(b.title);
          break;
        case TodoSortBy.category:
          comparison = a.category.displayName.compareTo(b.category.displayName);
          break;
        case TodoSortBy.completionStatus:
          comparison = a.isCompleted == b.isCompleted
              ? 0
              : a.isCompleted
                  ? 1
                  : -1;
          break;
      }

      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return todos;
  }

  int _comparePriority(TodoPriority a, TodoPriority b) {
    const priorityOrder = {
      TodoPriority.high: 3,
      TodoPriority.medium: 2,
      TodoPriority.low: 1,
    };

    return priorityOrder[a]!.compareTo(priorityOrder[b]!);
  }
}

/// Todo 조회 파라미터
class GetTodosParams {
  final TodoFilter filter;
  final TodoCategory? category;
  final TodoSortBy? sortBy;
  final SortOrder sortOrder;
  final int? limit;

  const GetTodosParams({
    this.filter = TodoFilter.all,
    this.category,
    this.sortBy,
    this.sortOrder = SortOrder.ascending,
    this.limit,
  });
}

/// Todo 필터 타입
enum TodoFilter {
  all,
  incomplete,
  completed,
  dueToday,
  overdue,
  byCategory,
}

/// Todo 정렬 기준
enum TodoSortBy {
  dueDate,
  priority,
  createdAt,
  title,
  category,
  completionStatus,
}

/// 정렬 순서
enum SortOrder {
  ascending,
  descending,
}