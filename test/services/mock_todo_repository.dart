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
  Future<void> updateTodo(int index, TodoItem updatedTodo) async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    if (index >= 0 && index < _todos.length) {
      _todos[index] = updatedTodo;
    }
  }

  @override
  Future<void> deleteTodo(int index) async {
    if (shouldThrowError) {
      throw Exception('Database error');
    }
    if (index >= 0 && index < _todos.length) {
      _todos.removeAt(index);
    }
  }

  void addMockTodo(TodoItem todo) {
    _todos.add(todo);
  }

  void clear() {
    _todos.clear();
  }
}