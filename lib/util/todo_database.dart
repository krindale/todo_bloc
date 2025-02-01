import 'package:hive/hive.dart';
import '../model/todo_item.dart';

class TodoDatabase {
  static const String _boxName = "todoBox";

  static Future<Box<TodoItem>> getBox() async {
    return await Hive.openBox<TodoItem>(_boxName);
  }

  // ✅ 모든 할 일 가져오기 (Read All)
  static Future<List<TodoItem>> getTodos() async {
    final box = await Hive.openBox<TodoItem>(_boxName); // ✅ 비동기 처리
    return box.values.toList();
  }

  // ✅ 새로운 할 일 추가
  static Future<void> addTodo(TodoItem todo) async {
    final box = await Hive.openBox<TodoItem>(_boxName);
    await box.add(todo);
  }

  // ✅ 특정 할 일 업데이트
  static Future<void> updateTodo(int index, TodoItem updatedTodo) async {
    final box = await Hive.openBox<TodoItem>(_boxName);
    await box.putAt(index, updatedTodo);
  }

  // ✅ 특정 할 일 삭제
  static Future<void> deleteTodo(int index) async {
    final box = await Hive.openBox<TodoItem>(_boxName);
    await box.deleteAt(index);
  }
}
