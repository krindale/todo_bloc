/// **Combined Todo Provider**
/// 
/// Riverpod와 Hive 데이터를 결합하여 캘린더에서 사용할 수 있는 통합 Todo 데이터를 제공합니다.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/todo_entity.dart';
import '../../model/todo_item.dart';
import '../../services/hive_todo_repository.dart';
import 'todo_provider.dart';

/// Hive Todo Repository Provider
final hiveTodoRepositoryProvider = Provider<HiveTodoRepository>((ref) {
  return HiveTodoRepository();
});

/// Hive Todo 데이터 Provider (실시간 업데이트 지원)
final hiveTodoListProvider = FutureProvider.autoDispose<List<TodoItem>>((ref) async {
  final repository = ref.watch(hiveTodoRepositoryProvider);
  return await repository.getTodos();
});

/// Combined Todo Provider - Riverpod와 Hive 데이터를 결합 (실시간 업데이트 지원)
final combinedTodoProvider = FutureProvider.autoDispose<List<TodoEntity>>((ref) async {
  // 두 provider를 모두 watch하여 자동 새로고침 보장
  final riverpodTodosAsync = ref.watch(todoListProvider);
  final hiveTodosAsync = ref.watch(hiveTodoListProvider);
  
  // 두 데이터가 모두 로드될 때까지 대기
  final riverpodTodos = await riverpodTodosAsync.when(
    data: (data) => Future.value(data),
    loading: () => Future.value(<TodoEntity>[]),
    error: (error, stack) {
      // 에러 발생 시 빈 리스트 반환하여 앱이 계속 동작하도록 함
      return Future.value(<TodoEntity>[]);
    },
  );
  
  final hiveTodos = await hiveTodosAsync.when(
    data: (data) => Future.value(data),
    loading: () => Future.value(<TodoItem>[]),
    error: (error, stack) {
      // 에러 발생 시 빈 리스트 반환하여 앱이 계속 동작하도록 함
      return Future.value(<TodoItem>[]);
    },
  );
  
  // Hive TodoItem을 TodoEntity로 변환
  final convertedHiveTodos = hiveTodos.map((hiveItem) => TodoEntity(
    id: hiveItem.firebaseDocId ?? '${hiveItem.title}_${hiveItem.dueDate.millisecondsSinceEpoch}', // 더 고유한 ID 생성
    title: hiveItem.title,
    description: '', // TodoItem에는 description 필드가 없음
    isCompleted: hiveItem.isCompleted,
    dueDate: hiveItem.dueDate,
    priority: _convertPriorityToEnum(hiveItem.priority),
    category: _convertCategoryToEnum(hiveItem.category),
    createdAt: DateTime.now(), // TodoItem에는 createdAt 필드가 없으므로 현재 시간 사용
  )).toList();
  
  // 두 데이터를 결합하고 중복 제거
  final allTodos = <TodoEntity>[...riverpodTodos, ...convertedHiveTodos];
  
  // ID 기준으로 중복 제거 (같은 할 일이 양쪽에 있을 수 있음)
  final uniqueTodos = <String, TodoEntity>{};
  for (final todo in allTodos) {
    uniqueTodos[todo.id] = todo;
  }
  
  return uniqueTodos.values.toList();
});

/// Priority를 TodoPriority enum으로 변환하는 헬퍼 함수
TodoPriority _convertPriorityToEnum(String? hivePriority) {
  switch (hivePriority?.toLowerCase()) {
    case 'high':
    case '높음':
      return TodoPriority.high;
    case 'medium':
    case '보통':
      return TodoPriority.medium;
    case 'low':
    case '낮음':
      return TodoPriority.low;
    default:
      return TodoPriority.medium;
  }
}

/// Category를 TodoCategory enum으로 변환하는 헬퍼 함수
TodoCategory _convertCategoryToEnum(String? hiveCategory) {
  switch (hiveCategory?.toLowerCase()) {
    case 'work':
    case '업무':
    case '일':
      return TodoCategory.work;
    case 'personal':
    case '개인':
    case '사적':
      return TodoCategory.personal;
    case 'health':
    case '건강':
    case '운동':
      return TodoCategory.health;
    case 'study':
    case '공부':
    case '학습':
      return TodoCategory.study;
    case 'lifestyle':
    case '생활':
    case '라이프스타일':
      return TodoCategory.lifestyle;
    case 'finance':
    case '재정':
    case '돈':
      return TodoCategory.finance;
    default:
      return TodoCategory.personal;
  }
}