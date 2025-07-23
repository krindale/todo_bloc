import '../model/todo_item.dart';
import '../util/todo_database.dart';
import 'todo_repository.dart';

class HiveTodoRepository implements TodoRepository {
  @override
  Future<List<TodoItem>> getTodos() async {
    return await TodoDatabase.getTodos();
  }

  @override
  Future<void> addTodo(TodoItem todo) async {
    await TodoDatabase.addTodo(todo);
  }

  @override
  Future<void> updateTodo(int index, TodoItem updatedTodo) async {
    await TodoDatabase.updateTodo(index, updatedTodo);
  }

  @override
  Future<void> deleteTodo(int index) async {
    await TodoDatabase.deleteTodo(index);
  }
}