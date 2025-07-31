/// **Todo 상태 모델**
/// 
/// UI에서 사용하는 Todo 관련 상태들을 정의합니다.

import 'package:equatable/equatable.dart';
import '../../domain/entities/todo_entity.dart';

/// Todo UI 상태
enum TodoUIState {
  initial,
  loading,
  loaded,
  error,
}

/// Todo 페이지 상태
class TodoPageState extends Equatable {
  final TodoUIState state;
  final List<TodoEntity> todos;
  final String? errorMessage;
  final bool isLoading;
  final TodoEntity? selectedTodo;

  const TodoPageState({
    this.state = TodoUIState.initial,
    this.todos = const [],
    this.errorMessage,
    this.isLoading = false,
    this.selectedTodo,
  });

  TodoPageState copyWith({
    TodoUIState? state,
    List<TodoEntity>? todos,
    String? errorMessage,
    bool? isLoading,
    TodoEntity? selectedTodo,
  }) {
    return TodoPageState(
      state: state ?? this.state,
      todos: todos ?? this.todos,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
      selectedTodo: selectedTodo ?? this.selectedTodo,
    );
  }

  @override
  List<Object?> get props => [
        state,
        todos,
        errorMessage,
        isLoading,
        selectedTodo,
      ];
}

/// Todo 폼 상태
class TodoFormState extends Equatable {
  final String title;
  final String description;
  final TodoPriority priority;
  final DateTime dueDate;
  final TodoCategory category;
  final DateTime? alarmTime;
  final bool hasAlarm;
  final bool isValid;
  final Map<String, String> errors;

  const TodoFormState({
    this.title = '',
    this.description = '',
    this.priority = TodoPriority.medium,
    required this.dueDate,
    this.category = TodoCategory.personal,
    this.alarmTime,
    this.hasAlarm = false,
    this.isValid = false,
    this.errors = const {},
  });

  TodoFormState copyWith({
    String? title,
    String? description,
    TodoPriority? priority,
    DateTime? dueDate,
    TodoCategory? category,
    DateTime? alarmTime,
    bool? hasAlarm,
    bool? isValid,
    Map<String, String>? errors,
  }) {
    return TodoFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      alarmTime: alarmTime ?? this.alarmTime,
      hasAlarm: hasAlarm ?? this.hasAlarm,
      isValid: isValid ?? this.isValid,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
        title,
        description,
        priority,
        dueDate,
        category,
        alarmTime,
        hasAlarm,
        isValid,
        errors,
      ];
}

/// 필터 상태
class FilterState extends Equatable {
  final TodoFilter filter;
  final TodoCategory? selectedCategory;
  final TodoSortBy sortBy;
  final SortOrder sortOrder;
  final String searchQuery;

  const FilterState({
    this.filter = TodoFilter.all,
    this.selectedCategory,
    this.sortBy = TodoSortBy.dueDate,
    this.sortOrder = SortOrder.ascending,
    this.searchQuery = '',
  });

  FilterState copyWith({
    TodoFilter? filter,
    TodoCategory? selectedCategory,
    TodoSortBy? sortBy,
    SortOrder? sortOrder,
    String? searchQuery,
  }) {
    return FilterState(
      filter: filter ?? this.filter,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        filter,
        selectedCategory,
        sortBy,
        sortOrder,
        searchQuery,
      ];
}

/// 통계 상태
class StatisticsState extends Equatable {
  final int totalTodos;
  final int completedTodos;
  final int incompleteTodos;
  final int overdueTodos;
  final int todayTodos;
  final double completionRate;
  final Map<TodoCategory, int> categoryStats;
  final Map<TodoPriority, int> priorityStats;

  const StatisticsState({
    this.totalTodos = 0,
    this.completedTodos = 0,
    this.incompleteTodos = 0,
    this.overdueTodos = 0,
    this.todayTodos = 0,
    this.completionRate = 0.0,
    this.categoryStats = const {},
    this.priorityStats = const {},
  });

  StatisticsState copyWith({
    int? totalTodos,
    int? completedTodos,
    int? incompleteTodos,
    int? overdueTodos,
    int? todayTodos,
    double? completionRate,
    Map<TodoCategory, int>? categoryStats,
    Map<TodoPriority, int>? priorityStats,
  }) {
    return StatisticsState(
      totalTodos: totalTodos ?? this.totalTodos,
      completedTodos: completedTodos ?? this.completedTodos,
      incompleteTodos: incompleteTodos ?? this.incompleteTodos,
      overdueTodos: overdueTodos ?? this.overdueTodos,
      todayTodos: todayTodos ?? this.todayTodos,
      completionRate: completionRate ?? this.completionRate,
      categoryStats: categoryStats ?? this.categoryStats,
      priorityStats: priorityStats ?? this.priorityStats,
    );
  }

  @override
  List<Object?> get props => [
        totalTodos,
        completedTodos,
        incompleteTodos,
        overdueTodos,
        todayTodos,
        completionRate,
        categoryStats,
        priorityStats,
      ];
}