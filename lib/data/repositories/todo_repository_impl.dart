/// **Todo 레포지토리 구현체**
/// 
/// 도메인 레포지토리 인터페이스를 구현하는 구체적인 클래스입니다.
/// 로컬 및 원격 데이터 소스를 조합하여 데이터 관리를 담당합니다.

import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../datasources/todo_remote_datasource.dart';
import '../models/todo_model.dart';

/// Todo 레포지토리 구현체
class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource _localDataSource;
  final TodoRemoteDataSource? _remoteDataSource;
  final bool _useRemoteDataSource;

  TodoRepositoryImpl({
    required TodoLocalDataSource localDataSource,
    TodoRemoteDataSource? remoteDataSource,
    bool useRemoteDataSource = false,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _useRemoteDataSource = useRemoteDataSource && remoteDataSource != null;

  @override
  Future<List<TodoEntity>> getAllTodos() async {
    try {
      // 원격 데이터 소스를 사용하는 경우
      if (_useRemoteDataSource) {
        final models = await _remoteDataSource!.getAllTodos();
        return models.map((model) => model.toEntity()).toList();
      }

      // 로컬 데이터 소스 사용
      final models = await _localDataSource.getAllTodos();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      // 원격에서 실패하면 로컬로 fallback
      if (_useRemoteDataSource) {
        final models = await _localDataSource.getAllTodos();
        return models.map((model) => model.toEntity()).toList();
      }
      rethrow;
    }
  }

  @override
  Future<TodoEntity?> getTodoById(String id) async {
    try {
      if (_useRemoteDataSource) {
        final model = await _remoteDataSource!.getTodoById(id);
        return model?.toEntity();
      }

      final model = await _localDataSource.getTodoById(id);
      return model?.toEntity();
    } catch (e) {
      if (_useRemoteDataSource) {
        final model = await _localDataSource.getTodoById(id);
        return model?.toEntity();
      }
      rethrow;
    }
  }

  @override
  Future<List<TodoEntity>> getIncompleteTodos() async {
    final allTodos = await getAllTodos();
    return allTodos.where((todo) => !todo.isCompleted).toList();
  }

  @override
  Future<List<TodoEntity>> getCompletedTodos() async {
    final allTodos = await getAllTodos();
    return allTodos.where((todo) => todo.isCompleted).toList();
  }

  @override
  Future<List<TodoEntity>> getTodosByCategory(TodoCategory category) async {
    final allTodos = await getAllTodos();
    return allTodos.where((todo) => todo.category == category).toList();
  }

  @override
  Future<List<TodoEntity>> getTodosDueToday() async {
    final allTodos = await getAllTodos();
    return allTodos.where((todo) => todo.isDueToday).toList();
  }

  @override
  Future<List<TodoEntity>> getOverdueTodos() async {
    final allTodos = await getAllTodos();
    return allTodos.where((todo) => todo.isOverdue).toList();
  }

  @override
  Future<String> addTodo(TodoEntity todo) async {
    final model = TodoModel.fromEntity(todo);

    try {
      // 로컬에 먼저 저장
      await _localDataSource.addTodo(model);

      // 원격 데이터 소스가 있으면 동기화
      if (_useRemoteDataSource) {
        await _remoteDataSource!.addTodo(model);
      }

      return todo.id;
    } catch (e) {
      // 원격 저장에 실패해도 로컬은 유지
      if (_useRemoteDataSource) {
        // 백그라운드에서 나중에 동기화하도록 마킹 가능
      }
      return todo.id;
    }
  }

  @override
  Future<void> updateTodo(TodoEntity todo) async {
    final model = TodoModel.fromEntity(todo);

    try {
      // 로컬 업데이트
      await _localDataSource.updateTodo(model);

      // 원격 업데이트
      if (_useRemoteDataSource) {
        await _remoteDataSource!.updateTodo(model);
      }
    } catch (e) {
      // 원격 업데이트 실패 시 로그 기록 또는 재시도 큐에 추가
      if (_useRemoteDataSource) {
        // 백그라운드 동기화 마킹
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      // 로컬 삭제
      await _localDataSource.deleteTodo(id);

      // 원격 삭제
      if (_useRemoteDataSource) {
        await _remoteDataSource!.deleteTodo(id);
      }
    } catch (e) {
      if (_useRemoteDataSource) {
        // 백그라운드 동기화 마킹
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteTodos(List<String> ids) async {
    try {
      // 로컬 일괄 삭제
      await _localDataSource.deleteTodos(ids);

      // 원격 일괄 삭제
      if (_useRemoteDataSource) {
        await _remoteDataSource!.deleteTodos(ids);
      }
    } catch (e) {
      if (_useRemoteDataSource) {
        // 백그라운드 동기화 마킹
      }
      rethrow;
    }
  }

  @override
  Future<void> toggleTodoCompletion(String id) async {
    final todo = await getTodoById(id);
    if (todo == null) return;

    final updatedTodo = todo.isCompleted 
        ? todo.markIncomplete() 
        : todo.markCompleted();
    
    await updateTodo(updatedTodo);
  }

  @override
  Future<void> deleteCompletedTodos() async {
    try {
      await _localDataSource.deleteCompletedTodos();

      if (_useRemoteDataSource) {
        await _remoteDataSource!.deleteCompletedTodos();
      }
    } catch (e) {
      if (_useRemoteDataSource) {
        // 백그라운드 동기화 마킹
      }
      rethrow;
    }
  }

  @override
  Future<List<TodoEntity>> searchTodos(String query) async {
    try {
      List<TodoModel> models;
      
      if (_useRemoteDataSource) {
        models = await _remoteDataSource!.searchTodos(query);
      } else {
        models = await _localDataSource.searchTodos(query);
      }

      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      if (_useRemoteDataSource) {
        final models = await _localDataSource.searchTodos(query);
        return models.map((model) => model.toEntity()).toList();
      }
      rethrow;
    }
  }

  @override
  Stream<List<TodoEntity>>? getTodosStream() {
    // 원격 데이터 소스가 스트림을 지원하는 경우
    if (_useRemoteDataSource) {
      return _remoteDataSource!.getTodosStream()
          .map((models) => models.map((model) => model.toEntity()).toList());
    }

    // 로컬 데이터 소스는 일반적으로 스트림을 지원하지 않음
    return _localDataSource.getTodosStream()
        ?.map((models) => models.map((model) => model.toEntity()).toList());
  }

  @override
  Future<TodoStatistics> getStatistics() async {
    final allTodos = await getAllTodos();
    
    final totalCount = allTodos.length;
    final completedCount = allTodos.where((todo) => todo.isCompleted).length;
    final incompleteCount = totalCount - completedCount;
    final overdueCount = allTodos.where((todo) => todo.isOverdue).length;
    final dueTodayCount = allTodos.where((todo) => todo.isDueToday).length;

    // 카테고리별 카운트
    final categoryCount = <TodoCategory, int>{};
    for (final category in TodoCategory.values) {
      categoryCount[category] = allTodos.where((todo) => todo.category == category).length;
    }

    // 우선순위별 카운트
    final priorityCount = <TodoPriority, int>{};
    for (final priority in TodoPriority.values) {
      priorityCount[priority] = allTodos.where((todo) => todo.priority == priority).length;
    }

    return TodoStatistics(
      totalCount: totalCount,
      completedCount: completedCount,
      incompleteCount: incompleteCount,
      overdueCount: overdueCount,
      dueTodayCount: dueTodayCount,
      categoryCount: categoryCount,
      priorityCount: priorityCount,
    );
  }
}