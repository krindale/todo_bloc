/// **Todo 삭제 Use Case**
/// 
/// Todo 항목을 삭제하는 비즈니스 로직을 담당합니다.

import '../repositories/todo_repository.dart';
import 'update_todo_usecase.dart'; // TodoNotFoundException 재사용

/// Todo 삭제 Use Case
class DeleteTodoUseCase {
  final TodoRepository _repository;

  const DeleteTodoUseCase(this._repository);

  /// 단일 Todo 삭제
  Future<void> execute(String id) async {
    // Todo 존재 여부 확인
    final existingTodo = await _repository.getTodoById(id);
    if (existingTodo == null) {
      throw TodoNotFoundException('ID $id에 해당하는 Todo를 찾을 수 없습니다.');
    }

    // 삭제 실행
    await _repository.deleteTodo(id);
  }

  /// 여러 Todo 삭제
  Future<void> executeMultiple(List<String> ids) async {
    if (ids.isEmpty) {
      throw ArgumentError('삭제할 Todo ID 목록이 비어있습니다.');
    }

    // 각 Todo 존재 여부 확인
    for (final id in ids) {
      final existingTodo = await _repository.getTodoById(id);
      if (existingTodo == null) {
        throw TodoNotFoundException('ID $id에 해당하는 Todo를 찾을 수 없습니다.');
      }
    }

    // 일괄 삭제 실행
    await _repository.deleteTodos(ids);
  }

  /// 완료된 모든 Todo 삭제
  Future<int> executeCompleted() async {
    final completedTodos = await _repository.getCompletedTodos();
    
    if (completedTodos.isEmpty) {
      return 0;
    }

    await _repository.deleteCompletedTodos();
    return completedTodos.length;
  }
}