/// **Hive 기반 로컬 데이터 소스**
/// 
/// TodoLocalDataSource 인터페이스의 Hive 구현체입니다.
/// 로컬 데이터베이스에 Todo 데이터를 저장하고 관리합니다.

import 'package:hive_flutter/hive_flutter.dart';
import '../../core/utils/app_logger.dart';
import '../models/todo_model.dart';
import 'todo_local_datasource.dart';

class TodoHiveDataSource implements TodoLocalDataSource {
  static const String _boxName = 'todos';
  Box<TodoModel>? _box;

  @override
  Future<void> initialize() async {
    try {
      if (_box == null || !_box!.isOpen) {
        _box = await Hive.openBox<TodoModel>(_boxName);
        AppLogger.info('Hive TodoDataSource initialized', tag: 'DataSource');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to initialize Hive TodoDataSource',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<TodoModel>> getAllTodos() async {
    try {
      await _ensureInitialized();
      final todos = _box!.values.toList();
      AppLogger.debug('Retrieved ${todos.length} todos from Hive', tag: 'DataSource');
      return todos;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get all todos from Hive',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<TodoModel?> getTodoById(String id) async {
    try {
      await _ensureInitialized();
      final todo = _box!.get(id);
      if (todo != null) {
        AppLogger.debug('Retrieved todo with id: $id from Hive', tag: 'DataSource');
      } else {
        AppLogger.debug('Todo with id: $id not found in Hive', tag: 'DataSource');
      }
      return todo;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get todo by id: $id from Hive',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  @override
  Future<void> addTodo(TodoModel todo) async {
    try {
      await _ensureInitialized();
      await _box!.put(todo.id, todo);
      AppLogger.info('Added todo with id: ${todo.id} to Hive', tag: 'DataSource');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to add todo with id: ${todo.id} to Hive',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    try {
      await _ensureInitialized();
      if (_box!.containsKey(todo.id)) {
        await _box!.put(todo.id, todo);
        AppLogger.info('Updated todo with id: ${todo.id} in Hive', tag: 'DataSource');
      } else {
        throw Exception('Todo with id ${todo.id} not found');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to update todo with id: ${todo.id} in Hive',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      await _ensureInitialized();
      if (_box!.containsKey(id)) {
        await _box!.delete(id);
        AppLogger.info('Deleted todo with id: $id from Hive', tag: 'DataSource');
      } else {
        AppLogger.warning('Attempted to delete non-existent todo with id: $id', tag: 'DataSource');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to delete todo with id: $id from Hive',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<List<TodoModel>> getTodosByCategory(String category) async {
    try {
      await _ensureInitialized();
      final todos = _box!.values
          .where((todo) => todo.category == category)
          .toList();
      AppLogger.debug('Retrieved ${todos.length} todos for category: $category from Hive', tag: 'DataSource');
      return todos;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get todos by category: $category from Hive',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<List<TodoModel>> getCompletedTodos() async {
    try {
      await _ensureInitialized();
      final todos = _box!.values
          .where((todo) => todo.isCompleted)
          .toList();
      AppLogger.debug('Retrieved ${todos.length} completed todos from Hive', tag: 'DataSource');
      return todos;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get completed todos from Hive',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<List<TodoModel>> getIncompleteTodos() async {
    try {
      await _ensureInitialized();
      final todos = _box!.values
          .where((todo) => !todo.isCompleted)
          .toList();
      AppLogger.debug('Retrieved ${todos.length} incomplete todos from Hive', tag: 'DataSource');
      return todos;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to get incomplete todos from Hive',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<void> clearAllTodos() async {
    try {
      await _ensureInitialized();
      await _box!.clear();
      AppLogger.info('Cleared all todos from Hive', tag: 'DataSource');
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to clear all todos from Hive',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Stream<List<TodoModel>> watchAllTodos() {
    return Stream.fromFuture(_ensureInitialized()).asyncExpand((_) {
      return _box!.watch().map((_) => _box!.values.toList());
    });
  }

  @override
  Future<void> dispose() async {
    try {
      if (_box != null && _box!.isOpen) {
        await _box!.close();
        AppLogger.info('Hive TodoDataSource disposed', tag: 'DataSource');
      }
    } catch (e, stackTrace) {
      AppLogger.error(
        'Failed to dispose Hive TodoDataSource',
        tag: 'DataSource',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Box가 초기화되었는지 확인하고 필요시 초기화
  Future<void> _ensureInitialized() async {
    if (_box == null || !_box!.isOpen) {
      await initialize();
    }
  }
}