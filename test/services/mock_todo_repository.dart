import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/services/todo_repository.dart';

class MockTodoRepository implements TodoRepository {
  final List<TodoItem> _todos = [];
  bool shouldThrowError = false;

  @override
  Future<List<TodoItem>> getTodos() async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    return List.from(_todos);
  }

  @override
  Future<void> addTodo(TodoItem todo) async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    _todos.add(todo);
  }

  @override
  Future<void> updateTodo(TodoItem todo) async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    // Find todo by firebaseDocId or other unique identifier
    final index = _todos.indexWhere((t) => t.firebaseDocId == todo.firebaseDocId);
    if (index != -1) {
      _todos[index] = todo;
    }
  }

  @override
  Future<void> updateTodoByIndex(int index, TodoItem updatedTodo) async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    if (index >= 0 && index < _todos.length) {
      _todos[index] = updatedTodo;
    }
  }

  @override
  Future<void> deleteTodo(TodoItem todo) async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    // Find todo by firebaseDocId or other unique identifier
    _todos.removeWhere((t) => t.firebaseDocId == todo.firebaseDocId);
  }

  @override
  Future<void> deleteTodoByIndex(int index) async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    if (index >= 0 && index < _todos.length) {
      _todos.removeAt(index);
    }
  }

  @override
  Stream<List<TodoItem>>? getTodosStream() {
    // Mock implementation returns null as streams are not supported in mock
    return null;
  }

  void addMockTodo(TodoItem todo) {
    _todos.add(todo);
  }

  void clear() {
    _todos.clear();
  }
}

// 테스트용 main 함수
void main() {
  // Mock 클래스이므로 별도의 테스트는 없음
  // 실제 테스트는 이 Mock을 사용하는 다른 테스트 파일들에서 수행됨
}