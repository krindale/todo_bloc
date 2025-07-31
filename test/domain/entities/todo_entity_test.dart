import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/domain/entities/todo_entity.dart';

void main() {
  group('TodoEntity', () {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    final testTodo = TodoEntity(
      id: 'test-1',
      title: 'Test Todo',
      description: 'Test Description',
      priority: TodoPriority.high,
      dueDate: tomorrow,
      category: TodoCategory.work,
      isCompleted: false,
      createdAt: now,
    );

    test('should create a todo entity with correct values', () {
      expect(testTodo.id, equals('test-1'));
      expect(testTodo.title, equals('Test Todo'));
      expect(testTodo.description, equals('Test Description'));
      expect(testTodo.priority, equals(TodoPriority.high));
      expect(testTodo.dueDate, equals(tomorrow));
      expect(testTodo.category, equals(TodoCategory.work));
      expect(testTodo.isCompleted, isFalse);
      expect(testTodo.createdAt, equals(now));
    });

    test('should mark todo as completed', () {
      final completedTodo = testTodo.markCompleted();
      
      expect(completedTodo.isCompleted, isTrue);
      expect(completedTodo.completedAt, isNotNull);
      expect(completedTodo.id, equals(testTodo.id));
      expect(completedTodo.title, equals(testTodo.title));
    });

    test('should not change if already completed', () {
      final alreadyCompleted = testTodo.copyWith(
        isCompleted: true, 
        completedAt: now,
      );
      final result = alreadyCompleted.markCompleted();
      
      expect(result.completedAt, equals(now));
      expect(result, equals(alreadyCompleted));
    });

    test('should set alarm correctly', () {
      final alarmTime = tomorrow.subtract(const Duration(hours: 1));
      final todoWithAlarm = testTodo.setAlarm(alarmTime);
      
      expect(todoWithAlarm.alarmTime, equals(alarmTime));
      expect(todoWithAlarm.hasAlarm, isTrue);
    });

    test('should detect overdue todo', () {
      final overdueTodo = testTodo.copyWith(
        dueDate: now.subtract(const Duration(days: 1)),
      );
      
      expect(overdueTodo.isOverdue, isTrue);
      expect(testTodo.isOverdue, isFalse);
    });

    test('should detect today todo', () {
      final todayTodo = testTodo.copyWith(
        dueDate: DateTime(now.year, now.month, now.day, 23, 59),
      );
      
      expect(todayTodo.isDueToday, isTrue);
      expect(testTodo.isDueToday, isFalse);
    });

    test('should calculate remaining days correctly', () {
      final in3Days = now.add(const Duration(days: 3));
      final futureTodo = testTodo.copyWith(dueDate: in3Days);
      
      expect(futureTodo.remainingDays, equals(3));
      expect(testTodo.remainingDays, equals(1));
    });

    test('should validate correctly', () {
      final validTodo = testTodo;
      final invalidTodo = testTodo.copyWith(title: '');
      
      expect(validTodo.isValid, isTrue);
      expect(invalidTodo.isValid, isFalse);
    });

    test('should detect high priority', () {
      final highPriorityTodo = testTodo.copyWith(priority: TodoPriority.high);
      final lowPriorityTodo = testTodo.copyWith(priority: TodoPriority.low);
      
      expect(highPriorityTodo.isHighPriority, isTrue);
      expect(lowPriorityTodo.isHighPriority, isFalse);
    });

    test('should support equality comparison', () {
      final sameTodo = TodoEntity(
        id: 'test-1',
        title: 'Test Todo',
        description: 'Test Description',
        priority: TodoPriority.high,
        dueDate: tomorrow,
        category: TodoCategory.work,
        isCompleted: false,
        createdAt: now,
      );
      
      final differentTodo = testTodo.copyWith(title: 'Different Title');
      
      expect(testTodo, equals(sameTodo));
      expect(testTodo, isNot(equals(differentTodo)));
    });

    test('should have consistent hashCode', () {
      final sameTodo = TodoEntity(
        id: 'test-1',
        title: 'Test Todo',
        description: 'Test Description',
        priority: TodoPriority.high,
        dueDate: tomorrow,
        category: TodoCategory.work,
        isCompleted: false,
        createdAt: now,
      );
      
      expect(testTodo.hashCode, equals(sameTodo.hashCode));
    });
  });
}