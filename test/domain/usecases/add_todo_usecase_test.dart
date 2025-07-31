import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:todo_bloc/domain/entities/todo_entity.dart';
import 'package:todo_bloc/domain/repositories/todo_repository.dart';
import 'package:todo_bloc/domain/usecases/add_todo_usecase.dart';

@GenerateMocks([TodoRepository])
import 'add_todo_usecase_test.mocks.dart';

void main() {
  group('AddTodoUseCase', () {
    late AddTodoUseCase useCase;
    late MockTodoRepository mockRepository;

    setUp(() {
      mockRepository = MockTodoRepository();
      useCase = AddTodoUseCase(mockRepository);
    });

    test('should add todo successfully', () async {
      // Arrange
      final params = AddTodoParams(
        title: 'Test Todo',
        description: 'Test Description',
        priority: TodoPriority.high,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        category: TodoCategory.work,
      );

      when(mockRepository.addTodo(any)).thenAnswer((_) async => 'test-id');

      // Act
      final result = await useCase.execute(params);

      // Assert
      expect(result, isNotNull);
      expect(result, isA<String>());
      verify(mockRepository.addTodo(any)).called(1);
    });

    test('should throw exception for empty title', () async {
      // Arrange
      final params = AddTodoParams(
        title: '',
        description: 'Test Description',
        priority: TodoPriority.high,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        category: TodoCategory.work,
      );

      // Act & Assert
      expect(
        () => useCase.execute(params),
        throwsA(isA<TodoValidationException>()),
      );
      
      verifyNever(mockRepository.addTodo(any));
    });

    test('should throw exception for past due date', () async {
      // Arrange
      final params = AddTodoParams(
        title: 'Test Todo',
        description: 'Test Description',
        priority: TodoPriority.high,
        dueDate: DateTime.now().subtract(const Duration(days: 1)),
        category: TodoCategory.work,
      );

      // Act & Assert
      expect(
        () => useCase.execute(params),
        throwsA(isA<TodoValidationException>()),
      );

      verifyNever(mockRepository.addTodo(any));
    });

    test('should handle repository error', () async {
      // Arrange
      final params = AddTodoParams(
        title: 'Test Todo',
        description: 'Test Description',
        priority: TodoPriority.high,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        category: TodoCategory.work,
      );

      when(mockRepository.addTodo(any))
          .thenThrow(Exception('Repository error'));

      // Act & Assert
      expect(
        () => useCase.execute(params),
        throwsA(isA<Exception>()),
      );
    });

    test('should trim whitespace from title and description', () async {
      // Arrange
      final params = AddTodoParams(
        title: '  Test Todo  ',
        description: '  Test Description  ',
        priority: TodoPriority.medium,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        category: TodoCategory.personal,
      );

      when(mockRepository.addTodo(any)).thenAnswer((_) async => 'test-id');

      // Act
      await useCase.execute(params);

      // Assert
      verify(mockRepository.addTodo(argThat(predicate<TodoEntity>((todo) =>
          todo.title == 'Test Todo' && todo.description == 'Test Description'))))
          .called(1);
    });

    test('should set creation timestamp', () async {
      // Arrange
      final now = DateTime.now();
      final params = AddTodoParams(
        title: 'Test Todo',
        description: 'Test Description',
        priority: TodoPriority.low,
        dueDate: now.add(const Duration(days: 1)),
        category: TodoCategory.health,
      );

      when(mockRepository.addTodo(any)).thenAnswer((_) async => 'test-id');

      // Act
      await useCase.execute(params);

      // Assert
      verify(mockRepository.addTodo(argThat(predicate<TodoEntity>((todo) {
        final timeDiff = todo.createdAt.difference(now).inSeconds.abs();
        return timeDiff < 5; // Within 5 seconds of now
      })))).called(1);
    });

    test('should generate unique id', () async {
      // Arrange
      final params = AddTodoParams(
        title: 'Test Todo',
        description: 'Test Description',
        priority: TodoPriority.medium,
        dueDate: DateTime.now().add(const Duration(days: 1)),
        category: TodoCategory.work,
      );

      when(mockRepository.addTodo(any)).thenAnswer((_) async => 'test-id');

      // Act
      final id1 = await useCase.execute(params);
      // 작은 지연을 추가해서 다른 timestamp 보장
      await Future.delayed(const Duration(milliseconds: 2));
      final id2 = await useCase.execute(params);

      // Assert
      expect(id1, isNot(equals(id2)));
      expect(id1.length, greaterThan(0));
      expect(id2.length, greaterThan(0));
    });
  });
}