import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/model/todo_item.dart';

void main() {
  group('TodoItem 모델 테스트', () {
    test('TodoItem 생성 테스트', () {
      // Given
      final now = DateTime.now();
      
      // When
      final todo = TodoItem(
        title: 'Test Todo',
        priority: 'High',
        dueDate: now,
        isCompleted: false,
        category: 'Work',
        firebaseDocId: 'test_doc_id',
      );

      // Then
      expect(todo.title, 'Test Todo');
      expect(todo.priority, 'High');
      expect(todo.dueDate, now);
      expect(todo.isCompleted, false);
      expect(todo.category, 'Work');
      expect(todo.firebaseDocId, 'test_doc_id');
    });

    test('TodoItem 기본값 테스트', () {
      // Given & When
      final todo = TodoItem(
        title: 'Simple Todo',
        priority: 'Medium',
        dueDate: DateTime.now(),
        isCompleted: false,
      );

      // Then
      expect(todo.title, 'Simple Todo');
      expect(todo.priority, 'Medium');
      expect(todo.isCompleted, false);
      expect(todo.category, isNull);
      expect(todo.firebaseDocId, isNull);
    });

    test('TodoItem 완료 상태 변경 테스트', () {
      // Given
      final todo = TodoItem(
        title: 'Todo to Complete',
        priority: 'Low',
        dueDate: DateTime.now(),
        isCompleted: false,
      );

      // When
      final completedTodo = TodoItem(
        title: todo.title,
        priority: todo.priority,
        dueDate: todo.dueDate,
        isCompleted: true,
        category: todo.category,
        firebaseDocId: todo.firebaseDocId,
      );

      // Then
      expect(todo.isCompleted, false);
      expect(completedTodo.isCompleted, true);
      expect(completedTodo.title, todo.title);
    });

    test('TodoItem 우선순위 유효성 테스트', () {
      // Given
      final validPriorities = ['High', 'Medium', 'Low'];

      // When & Then
      for (final priority in validPriorities) {
        final todo = TodoItem(
          title: 'Priority Test',
          priority: priority,
          dueDate: DateTime.now(),
          isCompleted: false,
        );
        expect(todo.priority, priority);
      }
    });

    test('TodoItem 날짜 비교 테스트', () {
      // Given
      final today = DateTime.now();
      final tomorrow = today.add(Duration(days: 1));
      final yesterday = today.subtract(Duration(days: 1));

      final todoToday = TodoItem(
        title: 'Today Todo',
        priority: 'High',
        dueDate: today,
        isCompleted: false,
      );

      final todoTomorrow = TodoItem(
        title: 'Tomorrow Todo',
        priority: 'Medium',
        dueDate: tomorrow,
        isCompleted: false,
      );

      final todoYesterday = TodoItem(
        title: 'Yesterday Todo',
        priority: 'Low',
        dueDate: yesterday,
        isCompleted: false,
      );

      // Then
      expect(todoToday.dueDate.day, today.day);
      expect(todoTomorrow.dueDate.isAfter(today), true);
      expect(todoYesterday.dueDate.isBefore(today), true);
    });
  });
}