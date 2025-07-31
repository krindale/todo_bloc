import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../model/todo_item.dart';
import 'repository_provider.dart';

part 'todo_provider.g.dart';

/// Todo list provider
/// 
/// 모든 Todo 항목을 관리하는 AsyncNotifier입니다.
/// CRUD 작업을 통해 상태를 업데이트합니다.
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<TodoItem>> build() async {
    final repository = ref.watch(todoRepositoryProvider);
    return await repository.getTodos();
  }

  /// Todo 항목 추가
  Future<void> addTodo(TodoItem todo) async {
    final repository = ref.read(todoRepositoryProvider);
    await repository.addTodo(todo);
    
    // 상태 새로고침
    ref.invalidateSelf();
  }

  /// Todo 항목 업데이트
  Future<void> updateTodo(TodoItem todo) async {
    final repository = ref.read(todoRepositoryProvider);
    await repository.updateTodo(todo);
    
    // 상태 새로고침
    ref.invalidateSelf();
  }

  /// Todo 항목 삭제
  Future<void> deleteTodo(TodoItem todo) async {
    final repository = ref.read(todoRepositoryProvider);
    await repository.deleteTodo(todo);
    
    // 상태 새로고침
    ref.invalidateSelf();
  }

  /// Todo 완료 상태 토글
  Future<void> toggleTodoCompletion(int index) async {
    final currentState = await future;
    if (index >= 0 && index < currentState.length) {
      final todo = currentState[index];
      final updatedTodo = TodoItem(
        title: todo.title,
        content: todo.content,
        dueDate: todo.dueDate,
        priority: todo.priority,
        isCompleted: !todo.isCompleted,
        firebaseDocId: todo.firebaseDocId,
      );
      await updateTodo(updatedTodo);
    }
  }
}

/// 완료된 Todo 항목만 필터링하는 provider
@riverpod
Future<List<TodoItem>> completedTodos(CompletedTodosRef ref) async {
  final todos = await ref.watch(todoListProvider.future);
  return todos.where((todo) => todo.isCompleted).toList();
}

/// 미완료된 Todo 항목만 필터링하는 provider
@riverpod
Future<List<TodoItem>> incompleteTodos(IncompleteTodosRef ref) async {
  final todos = await ref.watch(todoListProvider.future);
  return todos.where((todo) => !todo.isCompleted).toList();
}

/// 우선순위별 Todo 항목 필터링 provider
@riverpod
Future<List<TodoItem>> todosByPriority(TodosByPriorityRef ref, Priority priority) async {
  final todos = await ref.watch(todoListProvider.future);
  return todos.where((todo) => todo.priority == priority).toList();
}