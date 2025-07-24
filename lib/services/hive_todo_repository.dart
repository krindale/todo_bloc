import '../model/todo_item.dart';
import '../util/todo_database.dart';
import 'todo_repository.dart';
import 'platform_strategy.dart';

/// Hive 로컬 데이터베이스를 기반으로 한 Todo Repository 구현체
/// 
/// 이 클래스는 SOLID 원칙을 준수하여 설계되었습니다:
/// - **SRP**: Todo 데이터 관리 책임만 담당
/// - **OCP**: PlatformStrategy를 통해 확장 가능
/// - **LSP**: TodoRepository 인터페이스를 완전히 구현
/// - **ISP**: 분리된 인터페이스들을 모두 구현
/// - **DIP**: PlatformStrategy 추상화에 의존
/// 
/// 플랫폼별 특성:
/// - **모바일**: Hive 로컬 저장소 + Firebase 백업
/// - **데스크톱/웹**: Firebase 중심 + Hive 캐시
/// 
/// Example:
/// ```dart
/// // 기본 전략으로 생성
/// final repository = HiveTodoRepository();
/// 
/// // 커스텀 전략으로 생성 (테스트용)
/// final testRepository = HiveTodoRepository(MockPlatformStrategy());
/// 
/// // 사용
/// await repository.addTodo(newTodo);
/// final todos = await repository.getTodos();
/// ```
class HiveTodoRepository implements TodoRepository {
  /// 플랫폼별 Todo 처리 전략
  final PlatformStrategy _platformStrategy;

  /// HiveTodoRepository 생성자
  /// 
  /// Dependency Inversion Principle을 적용하여 구체 클래스가 아닌 
  /// 추상화(PlatformStrategy)에 의존합니다.
  /// 
  /// Parameters:
  ///   [platformStrategy] - 플랫폼 전략 (null이면 자동 감지)
  /// 
  /// Example:
  /// ```dart
  /// // 자동 플랫폼 감지
  /// final repo = HiveTodoRepository();
  /// 
  /// // 테스트용 커스텀 전략
  /// final testRepo = HiveTodoRepository(MockStrategy());
  /// ```
  HiveTodoRepository([PlatformStrategy? platformStrategy])
      : _platformStrategy = platformStrategy ?? PlatformStrategyFactory.create();

  /// 모든 Todo 항목을 조회합니다.
  /// 
  /// Hive 로컬 데이터베이스에서 저장된 모든 Todo 항목을 반환합니다.
  /// 플랫폼에 관계없이 동일한 방식으로 작동합니다.
  /// 
  /// Returns:
  ///   저장된 모든 [TodoItem] 목록
  /// 
  /// Throws:
  ///   데이터베이스 접근 실패 시 예외 발생
  @override
  Future<List<TodoItem>> getTodos() async {
    return await TodoDatabase.getTodos();
  }

  /// Todo 항목의 실시간 스트림을 반환합니다.
  /// 
  /// Hive는 기본적으로 실시간 스트림을 지원하지 않으므로 null을 반환합니다.
  /// Firebase 기반 Repository에서는 실시간 스트림을 제공할 수 있습니다.
  /// 
  /// Returns:
  ///   null - Hive는 실시간 스트림을 지원하지 않음
  @override
  Stream<List<TodoItem>>? getTodosStream() {
    // Hive는 실시간 스트림을 지원하지 않음
    return null;
  }

  /// 새로운 Todo 항목을 추가합니다.
  /// 
  /// 모든 플랫폼에서 동일하게 작동하며, TodoDatabase를 통해 
  /// Hive 로컬 저장소에 데이터를 저장합니다.
  /// 
  /// Parameters:
  ///   [todo] - 추가할 Todo 항목
  /// 
  /// Throws:
  ///   데이터베이스 저장 실패 시 예외 발생
  @override
  Future<void> addTodo(TodoItem todo) async {
    await TodoDatabase.addTodo(todo);
  }

  /// Todo 항목을 업데이트합니다.
  /// 
  /// 플랫폼별 전략에 따라 다르게 처리됩니다:
  /// - **Firebase 전용 플랫폼**: 문서 ID 기반 업데이트
  /// - **모바일 플랫폼**: 인덱스 검색 후 업데이트
  /// 
  /// Parameters:
  ///   [todo] - 업데이트할 Todo 항목 (식별자 포함)
  /// 
  /// Throws:
  ///   - 해당 항목을 찾을 수 없는 경우
  ///   - 데이터베이스 업데이트 실패 시
  @override
  Future<void> updateTodo(TodoItem todo) async {
    await _platformStrategy.updateTodo(todo);
    if (_platformStrategy.shouldUseFirebaseOnly()) {
      // Firebase-only 플랫폼: 문서 ID 기반 업데이트
      await TodoDatabase.updateTodo(0, todo);
    } else {
      // 모바일 플랫폼: 인덱스를 찾아서 업데이트
      final todos = await getTodos();
      final index = todos.indexWhere((t) => 
        t.firebaseDocId == todo.firebaseDocId || 
        (t.title == todo.title && t.dueDate == todo.dueDate));
      if (index != -1) {
        await TodoDatabase.updateTodo(index, todo);
      }
    }
  }

  /// Todo 항목을 삭제합니다.
  /// 
  /// 플랫폼별 전략에 따라 다르게 처리됩니다:
  /// - **Firebase 전용 플랫폼**: TodoItem 기반 직접 삭제
  /// - **모바일 플랫폼**: 인덱스 검색 후 삭제
  /// 
  /// Parameters:
  ///   [todo] - 삭제할 Todo 항목 (식별자 포함)
  /// 
  /// Throws:
  ///   - 해당 항목을 찾을 수 없는 경우
  ///   - 데이터베이스 삭제 실패 시
  @override
  Future<void> deleteTodo(TodoItem todo) async {
    await _platformStrategy.deleteTodo(todo);
    if (_platformStrategy.shouldUseFirebaseOnly()) {
      // Firebase-only 플랫폼: TodoItem 기반 직접 삭제
      await TodoDatabase.deleteTodoByItem(todo);
    } else {
      // 모바일 플랫폼: 인덱스를 찾아서 삭제
      final todos = await getTodos();
      final index = todos.indexWhere((t) => 
        t.firebaseDocId == todo.firebaseDocId || 
        (t.title == todo.title && t.dueDate == todo.dueDate));
      if (index != -1) {
        await TodoDatabase.deleteTodo(index);
      }
    }
  }

  /// ==================== DEPRECATED METHODS ====================
  /// 
  /// 아래 메서드들은 기존 코드와의 호환성을 위해 유지되지만
  /// 새로운 코드에서는 사용하지 않는 것을 권장합니다.
  /// 
  /// Liskov Substitution Principle을 준수하기 위해 예외를 던지지 않고
  /// 적절한 대체 구현을 제공합니다.

  /// [Deprecated] 인덱스를 사용한 Todo 업데이트
  /// 
  /// 이 메서드는 레거시 호환성을 위해 제공됩니다.
  /// 새 코드에서는 [updateTodo] 메서드를 사용하세요.
  /// 
  /// 플랫폼별 처리:
  /// - **Firebase 전용**: 인덱스를 무시하고 TodoItem 기반으로 처리
  /// - **모바일**: 기존 인덱스 기반 처리 유지
  /// 
  /// Parameters:
  ///   [index] - 업데이트할 항목의 인덱스 (Firebase 전용 플랫폼에서는 무시됨)
  ///   [updatedTodo] - 업데이트할 데이터
  @override
  @Deprecated('Use updateTodo(TodoItem) instead. Index-based operations may not be supported on all platforms.')
  Future<void> updateTodoByIndex(int index, TodoItem updatedTodo) async {
    if (_platformStrategy.shouldUseFirebaseOnly()) {
      // Firebase-only 플랫폼: 인덱스 무시하고 아이템 기반으로 처리
      await updateTodo(updatedTodo);
    } else {
      // 모바일 플랫폼: 기존 인덱스 기반 처리 유지
      await TodoDatabase.updateTodo(index, updatedTodo);
    }
  }

  /// [Deprecated] 인덱스를 사용한 Todo 삭제
  /// 
  /// 이 메서드는 레거시 호환성을 위해 제공됩니다.
  /// 새 코드에서는 [deleteTodo] 메서드를 사용하세요.
  /// 
  /// 플랫폼별 처리:
  /// - **Firebase 전용**: 인덱스를 TodoItem으로 변환 후 처리
  /// - **모바일**: 기존 인덱스 기반 처리 유지
  /// 
  /// Parameters:
  ///   [index] - 삭제할 항목의 인덱스
  /// 
  /// Throws:
  ///   [index]가 범위를 벗어난 경우 (Firebase 전용 플랫폼에서만)
  @override
  @Deprecated('Use deleteTodo(TodoItem) instead. Index-based operations may not be supported on all platforms.')
  Future<void> deleteTodoByIndex(int index) async {
    if (_platformStrategy.shouldUseFirebaseOnly()) {
      // Firebase-only 플랫폼: 인덱스를 TodoItem으로 변환 후 처리
      final todos = await getTodos();
      if (index >= 0 && index < todos.length) {
        await deleteTodo(todos[index]);
      } else {
        throw RangeError.index(index, todos, 'index', 'Invalid index for todo deletion');
      }
    } else {
      // 모바일 플랫폼: 기존 인덱스 기반 처리 유지
      await TodoDatabase.deleteTodo(index);
    }
  }
}
}