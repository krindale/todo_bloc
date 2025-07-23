import '../model/todo_item.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> getTodos();
  Future<void> addTodo(TodoItem todo);
  Future<void> updateTodo(int index, TodoItem updatedTodo);
  Future<void> deleteTodo(int index);
}