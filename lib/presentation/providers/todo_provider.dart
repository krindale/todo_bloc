/// **Todo Riverpod Provider**
/// 
/// 클린 아키텍처를 적용한 Todo 상태 관리 Provider입니다.
/// Use Case를 통해 비즈니스 로직을 수행하고 UI 상태를 관리합니다.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/todo_entity.dart';
import '../../domain/usecases/add_todo_usecase.dart';
import '../../domain/usecases/get_todos_usecase.dart';
import '../../domain/usecases/update_todo_usecase.dart';
import '../../domain/usecases/delete_todo_usecase.dart';
import '../../domain/usecases/toggle_todo_completion_usecase.dart';
import '../states/todo_state.dart';
import 'dependency_injection_provider.dart';

part 'todo_provider.g.dart';

/// Todo 리스트 Provider
@riverpod
class TodoList extends _$TodoList {
  @override
  FutureOr<List<TodoEntity>> build() async {
    final getTodosUseCase = ref.read(getTodosUseCaseProvider);
    return await getTodosUseCase.execute();
  }

  /// Todo 추가
  Future<void> addTodo({
    required String title,
    String? description,
    required TodoPriority priority,
    required DateTime dueDate,
    required TodoCategory category,
    DateTime? alarmTime,
  }) async {
    final addTodoUseCase = ref.read(addTodoUseCaseProvider);
    
    try {
      await addTodoUseCase.execute(AddTodoParams(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        category: category,
        alarmTime: alarmTime,
      ));
      
      // 상태 새로고침
      ref.invalidateSelf();
    } catch (e) {
      // 에러 처리는 별도 provider에서 관리
      ref.read(todoErrorProvider.notifier).setError(e.toString());
      rethrow;
    }
  }

  /// Todo 수정
  Future<void> updateTodo({
    required String id,
    String? title,
    String? description,
    TodoPriority? priority,
    DateTime? dueDate,
    TodoCategory? category,
    DateTime? alarmTime,
  }) async {
    final updateTodoUseCase = ref.read(updateTodoUseCaseProvider);
    
    try {
      await updateTodoUseCase.execute(UpdateTodoParams(
        id: id,
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        category: category,
        alarmTime: alarmTime,
      ));
      
      ref.invalidateSelf();
    } catch (e) {
      ref.read(todoErrorProvider.notifier).setError(e.toString());
      rethrow;
    }
  }

  /// Todo 삭제
  Future<void> deleteTodo(String id) async {
    final deleteTodoUseCase = ref.read(deleteTodoUseCaseProvider);
    
    try {
      await deleteTodoUseCase.execute(id);
      ref.invalidateSelf();
    } catch (e) {
      ref.read(todoErrorProvider.notifier).setError(e.toString());
      rethrow;
    }
  }

  /// Todo 완료 상태 토글
  Future<void> toggleCompletion(String id) async {
    final toggleUseCase = ref.read(toggleTodoCompletionUseCaseProvider);
    
    try {
      await toggleUseCase.execute(id);
      ref.invalidateSelf();
    } catch (e) {
      ref.read(todoErrorProvider.notifier).setError(e.toString());
      rethrow;
    }
  }

  /// 필터링된 Todo 리스트 조회
  Future<void> loadTodosWithFilter(GetTodosParams params) async {
    final getTodosUseCase = ref.read(getTodosUseCaseProvider);
    
    try {
      final todos = await getTodosUseCase.execute(params);
      state = AsyncData(todos);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

/// 현재 선택된 Todo Provider
@riverpod
class SelectedTodo extends _$SelectedTodo {
  @override
  TodoEntity? build() => null;

  void selectTodo(TodoEntity? todo) {
    state = todo;
  }

  void clearSelection() {
    state = null;
  }
}

/// Todo 필터 Provider
@riverpod
class TodoFilter extends _$TodoFilter {
  @override
  GetTodosParams build() => const GetTodosParams();

  void setFilter({
    TodoFilter? filter,
    TodoCategory? category,
    TodoSortBy? sortBy,
    SortOrder? sortOrder,
  }) {
    state = GetTodosParams(
      filter: filter ?? state.filter,
      category: category ?? state.category,
      sortBy: sortBy ?? state.sortBy,
      sortOrder: sortOrder ?? state.sortOrder,
    );
    
    // 필터 변경 시 Todo 리스트 새로고침
    ref.read(todoListProvider.notifier).loadTodosWithFilter(state);
  }
}

/// Todo 에러 상태 Provider
@riverpod
class TodoError extends _$TodoError {
  @override
  String? build() => null;

  void setError(String error) {
    state = error;
  }

  void clearError() {
    state = null;
  }
}

/// Todo 로딩 상태 Provider
@riverpod
class TodoLoading extends _$TodoLoading {
  @override
  bool build() => false;

  void setLoading(bool loading) {
    state = loading;
  }
}

/// 완료되지 않은 Todo Provider
@riverpod
Future<List<TodoEntity>> incompleteTodos(IncompleteTodosRef ref) async {
  final todos = await ref.watch(todoListProvider.future);
  return todos.where((todo) => !todo.isCompleted).toList();
}

/// 완료된 Todo Provider
@riverpod
Future<List<TodoEntity>> completedTodos(CompletedTodosRef ref) async {
  final todos = await ref.watch(todoListProvider.future);
  return todos.where((todo) => todo.isCompleted).toList();
}

/// 오늘 마감인 Todo Provider
@riverpod
Future<List<TodoEntity>> todayTodos(TodayTodosRef ref) async {
  final todos = await ref.watch(todoListProvider.future);
  return todos.where((todo) => todo.isDueToday).toList();
}

/// 지연된 Todo Provider
@riverpod
Future<List<TodoEntity>> overdueTodos(OverdueTodosRef ref) async {
  final todos = await ref.watch(todoListProvider.future);
  return todos.where((todo) => todo.isOverdue).toList();
}

/// Todo 통계 Provider
@riverpod
Future<TodoStatistics> todoStatistics(TodoStatisticsRef ref) async {
  final repository = ref.read(todoRepositoryProvider);
  return await repository.getStatistics();
}