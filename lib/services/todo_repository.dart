import '../model/todo_item.dart';

/// Todo 데이터에 대한 읽기 작업을 담당하는 인터페이스
/// 
/// Interface Segregation Principle을 적용하여 읽기 전용 작업을 분리했습니다.
/// 클라이언트가 읽기 작업만 필요한 경우 이 인터페이스만 의존할 수 있습니다.
abstract class TodoReader {
  /// 모든 Todo 항목을 비동기적으로 반환합니다.
  /// 
  /// Returns:
  ///   저장된 모든 [TodoItem] 목록
  Future<List<TodoItem>> getTodos();

  /// Todo 항목의 실시간 스트림을 반환합니다 (선택적).
  /// 
  /// Firebase 같은 실시간 데이터베이스에서는 스트림을 제공하지만,
  /// Hive 같은 로컬 저장소에서는 null을 반환할 수 있습니다.
  /// 
  /// Returns:
  ///   [TodoItem] 목록의 스트림 또는 null (지원하지 않는 경우)
  Stream<List<TodoItem>>? getTodosStream();
}

/// Todo 데이터에 대한 쓰기 작업을 담당하는 인터페이스
/// 
/// Interface Segregation Principle을 적용하여 쓰기 작업을 분리했습니다.
abstract class TodoWriter {
  /// 새로운 Todo 항목을 추가합니다.
  /// 
  /// Parameters:
  ///   [todo] - 추가할 Todo 항목
  /// 
  /// Throws:
  ///   데이터베이스 저장 실패 시 예외 발생
  Future<void> addTodo(TodoItem todo);

  /// 기존 Todo 항목을 업데이트합니다.
  /// 
  /// TodoItem의 고유 식별자(firebaseDocId 또는 다른 키)를 통해 
  /// 업데이트할 항목을 찾아서 수정합니다.
  /// 
  /// Parameters:
  ///   [todo] - 업데이트할 Todo 항목 (고유 식별자 포함)
  /// 
  /// Throws:
  ///   해당 항목을 찾을 수 없거나 업데이트 실패 시 예외 발생
  Future<void> updateTodo(TodoItem todo);
}

/// Todo 데이터에 대한 삭제 작업을 담당하는 인터페이스
/// 
/// Interface Segregation Principle을 적용하여 삭제 작업을 분리했습니다.
abstract class TodoDeleter {
  /// Todo 항목을 삭제합니다.
  /// 
  /// TodoItem의 고유 식별자를 통해 삭제할 항목을 찾아서 제거합니다.
  /// 
  /// Parameters:
  ///   [todo] - 삭제할 Todo 항목 (고유 식별자 포함)
  /// 
  /// Throws:
  ///   해당 항목을 찾을 수 없거나 삭제 실패 시 예외 발생
  Future<void> deleteTodo(TodoItem todo);
}

/// Todo 데이터 저장소에 대한 통합 인터페이스
/// 
/// 읽기, 쓰기, 삭제 작업을 모두 제공하는 완전한 Repository 패턴 구현입니다.
/// 기존 코드와의 호환성을 위해 deprecated된 인덱스 기반 메서드도 포함합니다.
/// 
/// SOLID 원칙 적용:
/// - SRP: 각 작업별로 인터페이스 분리
/// - ISP: 클라이언트가 필요한 인터페이스만 의존 가능
/// - DIP: 추상화에 의존하여 구체 구현체와 분리
abstract class TodoRepository implements TodoReader, TodoWriter, TodoDeleter {
  /// [Deprecated] 인덱스를 사용한 Todo 업데이트 (레거시 호환성용)
  /// 
  /// 새 코드에서는 [updateTodo] 메서드를 사용하세요.
  /// 플랫폼에 따라 인덱스 기반 접근이 지원되지 않을 수 있습니다.
  /// 
  /// Parameters:
  ///   [index] - 업데이트할 항목의 인덱스
  ///   [updatedTodo] - 업데이트할 데이터
  @Deprecated('Use updateTodo(TodoItem) instead. Index-based operations may not be supported on all platforms.')
  Future<void> updateTodoByIndex(int index, TodoItem updatedTodo);

  /// [Deprecated] 인덱스를 사용한 Todo 삭제 (레거시 호환성용)
  /// 
  /// 새 코드에서는 [deleteTodo] 메서드를 사용하세요.
  /// 플랫폼에 따라 인덱스 기반 접근이 지원되지 않을 수 있습니다.
  /// 
  /// Parameters:
  ///   [index] - 삭제할 항목의 인덱스
  @Deprecated('Use deleteTodo(TodoItem) instead. Index-based operations may not be supported on all platforms.')
  Future<void> deleteTodoByIndex(int index);
}