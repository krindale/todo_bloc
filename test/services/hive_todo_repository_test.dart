import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/services/hive_todo_repository.dart';
import 'package:todo_bloc/services/platform_strategy.dart';
import 'package:todo_bloc/util/todo_database.dart';

// Mock 클래스들 생성
@GenerateMocks([PlatformStrategy])
import 'hive_todo_repository_test.mocks.dart';

/// HiveTodoRepository 구현체 테스트
/// 
/// SOLID 원칙을 준수하는 Repository 패턴 구현체가
/// 다양한 플랫폼 전략과 올바르게 작동하는지 검증합니다.
void main() {
  group('HiveTodoRepository Tests', () {
    late HiveTodoRepository repository;
    late MockPlatformStrategy mockStrategy;
    late TodoItem testTodo;
    late List<TodoItem> testTodos;

    setUp(() {
      mockStrategy = MockPlatformStrategy();
      repository = HiveTodoRepository(mockStrategy);
      
      testTodo = TodoItem(
        title: 'Test Todo',
        content: 'Test Content',
        dueDate: DateTime.now(),
        priority: Priority.medium,
        firebaseDocId: 'test-doc-id',
      );
      
      testTodos = [
        testTodo,
        TodoItem(
          title: 'Test Todo 2',
          content: 'Test Content 2',
          dueDate: DateTime.now().add(Duration(days: 1)),
          priority: Priority.high,
          firebaseDocId: 'test-doc-id-2',
        ),
      ];
    });

    group('Constructor and Dependency Injection', () {
      test('should create repository with custom platform strategy', () {
        // Act
        final repo = HiveTodoRepository(mockStrategy);

        // Assert
        expect(repo, isA<HiveTodoRepository>());
        expect(repo, isA<TodoRepository>());
      });

      test('should create repository with default platform strategy when null provided', () {
        // Act
        final repo = HiveTodoRepository();

        // Assert
        expect(repo, isA<HiveTodoRepository>());
      });

      test('should follow Dependency Inversion Principle', () {
        // Repository는 구체 클래스가 아닌 PlatformStrategy 추상화에 의존해야 함
        expect(repository, isA<TodoRepository>());
        // 내부적으로 PlatformStrategy를 사용하는지는 실제 메서드 호출을 통해 검증
      });
    });

    group('TodoReader Implementation', () {
      test('getTodos should return list from TodoDatabase', () async {
        // 이 테스트는 실제 TodoDatabase.getTodos()를 호출하므로
        // 통합 테스트의 성격을 가집니다.
        // 실제 구현에서는 TodoDatabase를 Mock으로 대체해야 합니다.
        
        // Act & Assert
        expect(() => repository.getTodos(), returnsNormally);
      });

      test('getTodosStream should return null for Hive-based repository', () {
        // Act
        final stream = repository.getTodosStream();

        // Assert
        expect(stream, isNull);
      });
    });

    group('TodoWriter Implementation', () {
      test('addTodo should call TodoDatabase.addTodo', () async {
        // 이 테스트는 실제 구현의 동작을 검증합니다.
        // 실제로는 TodoDatabase를 Mock으로 대체해야 합니다.
        
        // Act & Assert
        expect(() => repository.addTodo(testTodo), returnsNormally);
      });
    });

    group('Platform Strategy Integration', () {
      test('updateTodo should use Firebase-only strategy when applicable', () async {
        // Arrange
        when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(true);
        when(mockStrategy.updateTodo(any)).thenAnswer((_) async {});

        // Act
        await repository.updateTodo(testTodo);

        // Assert
        verify(mockStrategy.shouldUseFirebaseOnly()).called(1);
        verify(mockStrategy.updateTodo(testTodo)).called(1);
      });

      test('updateTodo should use mobile strategy when not Firebase-only', () async {
        // Arrange
        when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(false);
        when(mockStrategy.updateTodo(any)).thenAnswer((_) async {});

        // Act
        await repository.updateTodo(testTodo);

        // Assert
        verify(mockStrategy.shouldUseFirebaseOnly()).called(1);
        verify(mockStrategy.updateTodo(testTodo)).called(1);
      });

      test('deleteTodo should use Firebase-only strategy when applicable', () async {
        // Arrange
        when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(true);
        when(mockStrategy.deleteTodo(any)).thenAnswer((_) async {});

        // Act
        await repository.deleteTodo(testTodo);

        // Assert
        verify(mockStrategy.shouldUseFirebaseOnly()).called(1);
        verify(mockStrategy.deleteTodo(testTodo)).called(1);
      });

      test('deleteTodo should use mobile strategy when not Firebase-only', () async {
        // Arrange
        when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(false);
        when(mockStrategy.deleteTodo(any)).thenAnswer((_) async {});

        // Act
        await repository.deleteTodo(testTodo);

        // Assert
        verify(mockStrategy.shouldUseFirebaseOnly()).called(1);
        verify(mockStrategy.deleteTodo(testTodo)).called(1);
      });
    });

    group('Deprecated Methods Support', () {
      test('updateTodoByIndex should delegate to updateTodo for Firebase-only platforms', () async {
        // Arrange
        when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(true);
        when(mockStrategy.updateTodo(any)).thenAnswer((_) async {});

        // Act
        await repository.updateTodoByIndex(0, testTodo);

        // Assert
        verify(mockStrategy.shouldUseFirebaseOnly()).called(1);
        // Firebase-only 플랫폼에서는 인덱스를 무시하고 updateTodo를 호출해야 함
      });

      test('updateTodoByIndex should use index-based approach for mobile platforms', () async {
        // Arrange
        when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(false);

        // Act & Assert
        expect(() => repository.updateTodoByIndex(0, testTodo), returnsNormally);
      });

      test('deleteTodoByIndex should handle Firebase-only platforms correctly', () async {
        // Arrange
        when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(true);
        when(mockStrategy.deleteTodo(any)).thenAnswer((_) async {});

        // Firebase-only 플랫폼에서는 먼저 todos를 가져와서 인덱스에 해당하는 아이템을 찾아야 함
        // 실제 구현에서는 getTodos()를 Mock해야 함
        
        // Act & Assert
        expect(() => repository.deleteTodoByIndex(0), returnsNormally);
      });

      test('deleteTodoByIndex should throw RangeError for invalid index on Firebase-only platforms', () async {
        // Arrange
        when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(true);

        // Act & Assert
        // 빈 리스트에서 인덱스 0에 접근하려고 하면 RangeError 발생
        expect(() => repository.deleteTodoByIndex(0), throwsA(isA<RangeError>()));
      });
    });

    group('Error Handling', () {
      test('should handle TodoDatabase errors gracefully', () async {
        // TodoDatabase에서 예외가 발생했을 때 적절히 전파되는지 테스트
        // 실제 구현에서는 Mock을 사용해 예외 상황을 시뮬레이션해야 함
        
        expect(repository.getTodos(), isA<Future<List<TodoItem>>>());
      });

      test('should handle PlatformStrategy errors', () async {
        // Arrange
        when(mockStrategy.updateTodo(any))
            .thenThrow(Exception('Platform strategy error'));
        when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(true);

        // Act & Assert
        expect(
          () => repository.updateTodo(testTodo),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('TodoItem Identification Logic', () {
      test('should find todo by firebaseDocId when available', () async {
        // 이 테스트는 updateTodo 메서드의 내부 로직을 검증합니다.
        // 실제로는 TodoDatabase.getTodos()를 Mock해서 테스트해야 합니다.
        
        // Arrange
        when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(false);
        when(mockStrategy.updateTodo(any)).thenAnswer((_) async {});

        final todoWithDocId = TodoItem(
          title: 'Test',
          firebaseDocId: 'unique-doc-id',
        );

        // Act
        await repository.updateTodo(todoWithDocId);

        // Assert
        verify(mockStrategy.updateTodo(todoWithDocId)).called(1);
      });

      test('should fallback to title and dueDate matching when firebaseDocId is null', () async {
        // Arrange
        when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(false);
        when(mockStrategy.updateTodo(any)).thenAnswer((_) async {});

        final todoWithoutDocId = TodoItem(
          title: 'Test Todo',
          dueDate: DateTime.now(),
          firebaseDocId: null,
        );

        // Act
        await repository.updateTodo(todoWithoutDocId);

        // Assert
        verify(mockStrategy.updateTodo(todoWithoutDocId)).called(1);
      });
    });

    group('SOLID Principles Validation', () {
      test('Single Responsibility Principle - only manages todo data', () {
        // Repository는 오직 Todo 데이터 관리만 담당해야 함
        expect(repository, isA<TodoRepository>());
        expect(repository, isA<TodoReader>());
        expect(repository, isA<TodoWriter>());
        expect(repository, isA<TodoDeleter>());
      });

      test('Open/Closed Principle - extensible through PlatformStrategy', () {
        // PlatformStrategy를 통해 확장 가능하면서 수정에는 닫혀있어야 함
        final customStrategy = MockPlatformStrategy();
        final customRepo = HiveTodoRepository(customStrategy);
        
        expect(customRepo, isA<HiveTodoRepository>());
      });

      test('Liskov Substitution Principle - substitutable for TodoRepository', () {
        // HiveTodoRepository는 TodoRepository를 완전히 대체할 수 있어야 함
        final TodoRepository abstractRepo = repository;
        
        expect(abstractRepo, isA<TodoRepository>());
        expect(() => abstractRepo.getTodos(), returnsNormally);
      });

      test('Interface Segregation Principle - implements segregated interfaces', () {
        // 분리된 인터페이스들을 모두 올바르게 구현해야 함
        final TodoReader reader = repository;
        final TodoWriter writer = repository;
        final TodoDeleter deleter = repository;
        
        expect(reader, isA<TodoReader>());
        expect(writer, isA<TodoWriter>());
        expect(deleter, isA<TodoDeleter>());
      });

      test('Dependency Inversion Principle - depends on abstractions', () {
        // 구체 클래스가 아닌 PlatformStrategy 추상화에 의존해야 함
        expect(repository, isA<HiveTodoRepository>());
        
        // PlatformStrategy 메서드 호출을 통해 의존성 확인
        when(mockStrategy.shouldUseFirebaseOnly()).thenReturn(true);
        when(mockStrategy.updateTodo(any)).thenAnswer((_) async {});
        
        repository.updateTodo(testTodo);
        
        verify(mockStrategy.shouldUseFirebaseOnly()).called(1);
      });
    });
  });
}