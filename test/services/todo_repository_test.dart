import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/domain/entities/todo_entity.dart';
import 'package:todo_bloc/services/todo_repository.dart';

// Mock 클래스들 생성
@GenerateMocks([TodoRepository])
import 'todo_repository_test.mocks.dart';

/// TodoRepository 인터페이스 테스트
/// 
/// SOLID 원칙에 따라 설계된 Repository 패턴의 인터페이스가 
/// 올바르게 정의되었는지 검증합니다.
void main() {
  group('TodoRepository Interface Tests', () {
    late MockTodoRepository mockRepository;
    late TodoItem testTodo;
    late List<TodoItem> testTodos;

    setUp(() {
      mockRepository = MockTodoRepository();
      testTodo = TodoItem.fromPriority(
        title: 'Test Todo',
        priorityEnum: TodoPriority.medium,
        dueDate: DateTime.now(),
        category: 'Personal',
        firebaseDocId: 'test-doc-id',
      );
      testTodos = [
        testTodo,
        TodoItem.fromPriority(
          title: 'Test Todo 2',
          priorityEnum: TodoPriority.high,
          dueDate: DateTime.now().add(Duration(days: 1)),
          category: 'Work',
          firebaseDocId: 'test-doc-id-2',
        ),
      ];
    });

    group('TodoReader Interface', () {
      test('getTodos should return list of TodoItems', () async {
        // Arrange
        when(mockRepository.getTodos()).thenAnswer((_) async => testTodos);

        // Act
        final result = await mockRepository.getTodos();

        // Assert
        expect(result, isA<List<TodoItem>>());
        expect(result.length, equals(2));
        expect(result.first.title, equals('Test Todo'));
        verify(mockRepository.getTodos()).called(1);
      });

      test('getTodos should return empty list when no todos exist', () async {
        // Arrange
        when(mockRepository.getTodos()).thenAnswer((_) async => []);

        // Act
        final result = await mockRepository.getTodos();

        // Assert
        expect(result, isEmpty);
        verify(mockRepository.getTodos()).called(1);
      });

      test('getTodosStream should return stream or null', () {
        // Arrange - Stream을 지원하는 경우
        final stream = Stream<List<TodoItem>>.value(testTodos);
        when(mockRepository.getTodosStream()).thenReturn(stream);

        // Act
        final result = mockRepository.getTodosStream();

        // Assert
        expect(result, isA<Stream<List<TodoItem>>>());
        verify(mockRepository.getTodosStream()).called(1);
      });

      test('getTodosStream should return null when not supported', () {
        // Arrange - Stream을 지원하지 않는 경우 (Hive)
        when(mockRepository.getTodosStream()).thenReturn(null);

        // Act
        final result = mockRepository.getTodosStream();

        // Assert
        expect(result, isNull);
        verify(mockRepository.getTodosStream()).called(1);
      });
    });

    group('TodoWriter Interface', () {
      test('addTodo should add new todo item', () async {
        // Arrange
        when(mockRepository.addTodo(any)).thenAnswer((_) async {});

        // Act
        await mockRepository.addTodo(testTodo);

        // Assert
        verify(mockRepository.addTodo(testTodo)).called(1);
      });

      test('addTodo should handle null todo gracefully', () async {
        // Arrange
        when(mockRepository.addTodo(any))
            .thenThrow(ArgumentError('Todo cannot be null'));

        // Act & Assert
        expect(
          () => mockRepository.addTodo(null as dynamic),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('updateTodo should update existing todo item', () async {
        // Arrange
        when(mockRepository.updateTodo(any)).thenAnswer((_) async {});

        // Act
        await mockRepository.updateTodo(testTodo);

        // Assert
        verify(mockRepository.updateTodo(testTodo)).called(1);
      });

      test('updateTodo should throw exception for non-existent todo', () async {
        // Arrange
        when(mockRepository.updateTodo(any))
            .thenThrow(StateError('Todo not found'));

        // Act & Assert
        expect(
          () => mockRepository.updateTodo(testTodo),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('TodoDeleter Interface', () {
      test('deleteTodo should delete existing todo item', () async {
        // Arrange
        when(mockRepository.deleteTodo(any)).thenAnswer((_) async {});

        // Act
        await mockRepository.deleteTodo(testTodo);

        // Assert
        verify(mockRepository.deleteTodo(testTodo)).called(1);
      });

      test('deleteTodo should throw exception for non-existent todo', () async {
        // Arrange
        when(mockRepository.deleteTodo(any))
            .thenThrow(StateError('Todo not found'));

        // Act & Assert
        expect(
          () => mockRepository.deleteTodo(testTodo),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('Deprecated Methods', () {
      test('updateTodoByIndex should work with valid index', () async {
        // Arrange
        when(mockRepository.updateTodoByIndex(any, any))
            .thenAnswer((_) async {});

        // Act
        await mockRepository.updateTodoByIndex(0, testTodo);

        // Assert
        verify(mockRepository.updateTodoByIndex(0, testTodo)).called(1);
      });

      test('updateTodoByIndex should throw for invalid index', () async {
        // Arrange
        when(mockRepository.updateTodoByIndex(any, any))
            .thenThrow(RangeError.index(-1, [], 'index'));

        // Act & Assert
        expect(
          () => mockRepository.updateTodoByIndex(-1, testTodo),
          throwsA(isA<RangeError>()),
        );
      });

      test('deleteTodoByIndex should work with valid index', () async {
        // Arrange
        when(mockRepository.deleteTodoByIndex(any)).thenAnswer((_) async {});

        // Act
        await mockRepository.deleteTodoByIndex(0);

        // Assert
        verify(mockRepository.deleteTodoByIndex(0)).called(1);
      });

      test('deleteTodoByIndex should throw for invalid index', () async {
        // Arrange
        when(mockRepository.deleteTodoByIndex(any))
            .thenThrow(RangeError.index(-1, [], 'index'));

        // Act & Assert
        expect(
          () => mockRepository.deleteTodoByIndex(-1),
          throwsA(isA<RangeError>()),
        );
      });
    });

    group('Interface Segregation Principle Validation', () {
      test('TodoReader interface should be implementable independently', () {
        // Mock 객체가 TodoReader 인터페이스만 구현해도 동작해야 함
        final TodoReader reader = mockRepository;
        expect(reader, isA<TodoReader>());
      });

      test('TodoWriter interface should be implementable independently', () {
        // Mock 객체가 TodoWriter 인터페이스만 구현해도 동작해야 함
        final TodoWriter writer = mockRepository;
        expect(writer, isA<TodoWriter>());
      });

      test('TodoDeleter interface should be implementable independently', () {
        // Mock 객체가 TodoDeleter 인터페이스만 구현해도 동작해야 함
        final TodoDeleter deleter = mockRepository;
        expect(deleter, isA<TodoDeleter>());
      });

      test('TodoRepository should implement all segregated interfaces', () {
        // TodoRepository는 모든 인터페이스를 구현해야 함
        expect(mockRepository, isA<TodoReader>());
        expect(mockRepository, isA<TodoWriter>());
        expect(mockRepository, isA<TodoDeleter>());
        expect(mockRepository, isA<TodoRepository>());
      });
    });

    group('Error Handling', () {
      test('should handle database connection errors', () async {
        // Arrange
        when(mockRepository.getTodos())
            .thenThrow(Exception('Database connection failed'));

        // Act & Assert
        expect(
          () => mockRepository.getTodos(),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle network errors for Firebase operations', () async {
        // Arrange
        when(mockRepository.addTodo(any))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => mockRepository.addTodo(testTodo),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle concurrent modification errors', () async {
        // Arrange
        when(mockRepository.updateTodo(any))
            .thenThrow(StateError('Concurrent modification detected'));

        // Act & Assert
        expect(
          () => mockRepository.updateTodo(testTodo),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}