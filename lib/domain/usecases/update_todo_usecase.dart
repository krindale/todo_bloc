/// **Todo 수정 Use Case**
/// 
/// Todo 항목을 수정하는 비즈니스 로직을 담당합니다.

import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';
import 'add_todo_usecase.dart'; // TodoValidationException 재사용

/// Todo 수정 Use Case
class UpdateTodoUseCase {
  final TodoRepository _repository;

  const UpdateTodoUseCase(this._repository);

  /// Todo 수정 실행
  Future<void> execute(UpdateTodoParams params) async {
    // 기존 Todo 조회
    final existingTodo = await _repository.getTodoById(params.id);
    if (existingTodo == null) {
      throw TodoNotFoundException('ID ${params.id}에 해당하는 Todo를 찾을 수 없습니다.');
    }

    // 비즈니스 규칙 검증
    _validateParams(params);

    // 수정된 엔터티 생성
    final updatedTodo = existingTodo.copyWith(
      title: params.title?.trim(),
      description: params.description?.trim(),
      priority: params.priority,
      dueDate: params.dueDate,
      category: params.category,
      alarmTime: params.alarmTime,
      hasAlarm: params.alarmTime != null,
    );

    // 레포지토리를 통해 업데이트
    await _repository.updateTodo(updatedTodo);
  }

  void _validateParams(UpdateTodoParams params) {
    // 제목 검증
    if (params.title != null) {
      if (params.title!.trim().isEmpty) {
        throw TodoValidationException('제목은 필수입니다.');
      }

      if (params.title!.trim().length > 255) {
        throw TodoValidationException('제목은 255자 이하여야 합니다.');
      }
    }

    // 마감일 검증
    if (params.dueDate != null) {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final dueDateStart = DateTime(
        params.dueDate!.year,
        params.dueDate!.month,
        params.dueDate!.day,
      );

      if (dueDateStart.isBefore(todayStart)) {
        throw TodoValidationException('마감일은 오늘 이후로 설정해야 합니다.');
      }
    }

    // 알람 시간 검증
    if (params.alarmTime != null && params.dueDate != null) {
      if (params.alarmTime!.isAfter(params.dueDate!)) {
        throw TodoValidationException('알람 시간은 마감일 이전이어야 합니다.');
      }

      if (params.alarmTime!.isBefore(DateTime.now())) {
        throw TodoValidationException('알람 시간은 현재 시간 이후여야 합니다.');
      }
    }

    // 설명 길이 검증
    if (params.description != null && params.description!.length > 1000) {
      throw TodoValidationException('설명은 1000자 이하여야 합니다.');
    }
  }
}

/// Todo 수정 파라미터
class UpdateTodoParams {
  final String id;
  final String? title;
  final String? description;
  final TodoPriority? priority;
  final DateTime? dueDate;
  final TodoCategory? category;
  final DateTime? alarmTime;

  const UpdateTodoParams({
    required this.id,
    this.title,
    this.description,
    this.priority,
    this.dueDate,
    this.category,
    this.alarmTime,
  });
}

/// Todo 찾을 수 없음 예외
class TodoNotFoundException implements Exception {
  final String message;
  const TodoNotFoundException(this.message);

  @override
  String toString() => 'TodoNotFoundException: $message';
}