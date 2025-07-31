/// **Todo 추가 Use Case**
/// 
/// 새로운 Todo 항목을 추가하는 비즈니스 로직을 담당합니다.
/// 클린 아키텍처의 Use Case 레이어에서 비즈니스 규칙을 적용합니다.

import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

/// Todo 추가 Use Case
class AddTodoUseCase {
  final TodoRepository _repository;

  const AddTodoUseCase(this._repository);

  /// Todo 추가 실행
  /// 
  /// 비즈니스 규칙:
  /// 1. 제목은 필수이며 공백일 수 없음
  /// 2. 마감일은 과거일 수 없음 (오늘은 가능)
  /// 3. 알람 시간은 마감일 이후일 수 없음
  Future<String> execute(AddTodoParams params) async {
    // 비즈니스 규칙 검증
    _validateParams(params);

    // ID 생성 (UUID)
    final id = _generateId();

    // 엔터티 생성
    final todo = TodoEntity(
      id: id,
      title: params.title.trim(),
      description: params.description?.trim() ?? '',
      priority: params.priority,
      dueDate: params.dueDate,
      category: params.category,
      createdAt: DateTime.now(),
      alarmTime: params.alarmTime,
      hasAlarm: params.alarmTime != null,
    );

    // 레포지토리를 통해 저장
    await _repository.addTodo(todo);
    
    return id;
  }

  void _validateParams(AddTodoParams params) {
    // 제목 검증
    if (params.title.trim().isEmpty) {
      throw TodoValidationException('제목은 필수입니다.');
    }

    if (params.title.trim().length > 255) {
      throw TodoValidationException('제목은 255자 이하여야 합니다.');
    }

    // 마감일 검증
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final dueDateStart = DateTime(
      params.dueDate.year,
      params.dueDate.month,
      params.dueDate.day,
    );

    if (dueDateStart.isBefore(todayStart)) {
      throw TodoValidationException('마감일은 오늘 이후로 설정해야 합니다.');
    }

    // 알람 시간 검증
    if (params.alarmTime != null) {
      if (params.alarmTime!.isAfter(params.dueDate)) {
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

  String _generateId() {
    // 간단한 UUID 생성 (실제로는 uuid 패키지 사용 권장)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'todo_${timestamp}_$random';
  }
}

/// Todo 추가 파라미터
class AddTodoParams {
  final String title;
  final String? description;
  final TodoPriority priority;
  final DateTime dueDate;
  final TodoCategory category;
  final DateTime? alarmTime;

  const AddTodoParams({
    required this.title,
    this.description,
    required this.priority,
    required this.dueDate,
    required this.category,
    this.alarmTime,
  });
}

/// Todo 검증 예외
class TodoValidationException implements Exception {
  final String message;
  const TodoValidationException(this.message);

  @override
  String toString() => 'TodoValidationException: $message';
}