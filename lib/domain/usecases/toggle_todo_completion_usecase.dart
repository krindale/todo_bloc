/// **Todo 완료 상태 토글 Use Case**
/// 
/// Todo 항목의 완료 상태를 변경하는 비즈니스 로직을 담당합니다.

import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';
import 'update_todo_usecase.dart'; // TodoNotFoundException 재사용

/// Todo 완료 상태 토글 Use Case
class ToggleTodoCompletionUseCase {
  final TodoRepository _repository;

  const ToggleTodoCompletionUseCase(this._repository);

  /// 완료 상태 토글 실행
  Future<TodoEntity> execute(String id) async {
    // 기존 Todo 조회
    final existingTodo = await _repository.getTodoById(id);
    if (existingTodo == null) {
      throw TodoNotFoundException('ID $id에 해당하는 Todo를 찾을 수 없습니다.');
    }

    // 완료 상태 토글
    final updatedTodo = existingTodo.isCompleted
        ? existingTodo.markIncomplete()
        : existingTodo.markCompleted();

    // 레포지토리를 통해 업데이트
    await _repository.updateTodo(updatedTodo);

    return updatedTodo;
  }

  /// 특정 완료 상태로 설정
  Future<TodoEntity> setCompletionStatus(String id, bool isCompleted) async {
    // 기존 Todo 조회
    final existingTodo = await _repository.getTodoById(id);
    if (existingTodo == null) {
      throw TodoNotFoundException('ID $id에 해당하는 Todo를 찾을 수 없습니다.');
    }

    // 이미 같은 상태인 경우 그대로 반환
    if (existingTodo.isCompleted == isCompleted) {
      return existingTodo;
    }

    // 완료 상태 변경
    final updatedTodo = isCompleted
        ? existingTodo.markCompleted()
        : existingTodo.markIncomplete();

    // 레포지토리를 통해 업데이트
    await _repository.updateTodo(updatedTodo);

    return updatedTodo;
  }
}