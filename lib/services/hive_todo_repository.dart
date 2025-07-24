import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../model/todo_item.dart';
import '../util/todo_database.dart';
import 'todo_repository.dart';

class HiveTodoRepository implements TodoRepository {
  // Firebase-only 플랫폼 여부 확인
  bool _shouldUseFirebaseOnly() {
    return kIsWeb || Platform.isMacOS || Platform.isWindows;
  }

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
    if (_shouldUseFirebaseOnly()) {
      // Firebase-only 플랫폼에서는 TodoItem으로 업데이트
      await TodoDatabase.updateTodo(0, updatedTodo); // index는 무시됨
    } else {
      await TodoDatabase.updateTodo(index, updatedTodo);
    }
  }

  @override
  Future<void> deleteTodo(int index) async {
    if (_shouldUseFirebaseOnly()) {
      // Firebase-only 플랫폼에서는 인덱스 기반 삭제 지원하지 않음 
      throw Exception('Index-based deletion not supported on this platform');
    } else {
      await TodoDatabase.deleteTodo(index);
    }
  }

  // Firebase-only 플랫폼용 삭제 메서드 추가
  Future<void> deleteTodoByItem(TodoItem todo) async {
    await TodoDatabase.deleteTodoByItem(todo);
  }
}