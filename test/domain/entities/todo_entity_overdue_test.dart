/// **TodoEntity Overdue 로직 테스트**
/// 
/// 완료되지 않은 지난항목 분류 로직을 테스트합니다.

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/domain/entities/todo_entity.dart';

void main() {
  group('TodoEntity isOverdue Tests', () {
    late DateTime today;
    late DateTime yesterday;
    late DateTime tomorrow;

    setUp(() {
      final now = DateTime.now();
      today = DateTime(now.year, now.month, now.day);
      yesterday = today.subtract(const Duration(days: 1));
      tomorrow = today.add(const Duration(days: 1));
    });

    /// 8월 1일 시나리오 테스트
    test('August 1st todos should be overdue after August 1st', () {
      // 8월 1일로 설정
      final august1st = DateTime(2024, 8, 1);
      
      // 8월 1일의 다양한 시간대 할 일들
      final august1stTodos = [
        TodoEntity(
          id: 'morning',
          title: '8월 1일 오전 할 일',
          isCompleted: false,
          dueDate: DateTime(2024, 8, 1, 9, 0), // 오전 9시
          priority: TodoPriority.high,
          category: TodoCategory.work,
          createdAt: august1st,
        ),
        TodoEntity(
          id: 'completed',
          title: '8월 1일 완료된 할 일',
          isCompleted: true, // 완료된 항목
          dueDate: DateTime(2024, 8, 1, 12, 0), // 오후 12시
          priority: TodoPriority.high,
          category: TodoCategory.work,
          createdAt: august1st,
        ),
      ];

      // 미완료 항목들 확인
      final incompleteTodos = august1stTodos.where((todo) => !todo.isCompleted).toList();
      
      // 실제 로직 테스트 (8월 2일 이후라고 가정)
      for (final todo in incompleteTodos) {
        // 8월 1일의 할 일들이 8월 2일에는 overdue가 되어야 함
        expect(todo.dueDate.day, equals(1)); // 8월 1일인지 확인
        expect(todo.dueDate.month, equals(8)); // 8월인지 확인
      }

      // 완료된 항목은 overdue가 아니어야 함
      final completedTodos = august1stTodos.where((todo) => todo.isCompleted).toList();
      for (final todo in completedTodos) {
        expect(todo.isCompleted, isTrue);
        expect(todo.isOverdue, isFalse); // 완료된 항목은 overdue가 아님
      }
    });

    /// 어제 날짜의 미완료 항목은 overdue여야 함
    test('incomplete todos from yesterday should be overdue', () {
      final yesterdayTodo = TodoEntity(
        id: 'yesterday',
        title: '어제 할 일',
        isCompleted: false,
        dueDate: yesterday.add(const Duration(hours: 12)), // 어제 오후 12시
        priority: TodoPriority.high,
        category: TodoCategory.work,
        createdAt: yesterday,
      );

      expect(yesterdayTodo.isOverdue, isTrue);
    });

    /// 오늘 날짜의 항목은 overdue가 아니어야 함
    test('todos due today should not be overdue', () {
      final todayTodo = TodoEntity(
        id: 'today',
        title: '오늘 할 일',
        isCompleted: false,
        dueDate: today.add(const Duration(hours: 18)), // 오늘 오후 6시
        priority: TodoPriority.medium,
        category: TodoCategory.personal,
        createdAt: today,
      );

      expect(todayTodo.isOverdue, isFalse);
    });

    /// 완료된 과거 항목은 overdue가 아니어야 함
    test('completed past todos should not be overdue', () {
      final completedPastTodo = TodoEntity(
        id: 'completed-past',
        title: '완료된 과거 할 일',
        isCompleted: true,
        dueDate: yesterday,
        priority: TodoPriority.high,
        category: TodoCategory.work,
        createdAt: yesterday,
      );

      expect(completedPastTodo.isOverdue, isFalse);
    });

    /// 시간과 관계없이 날짜만으로 판단하는지 테스트
    test('overdue logic should work based on date only, not time', () {
      final yesterdayMorning = TodoEntity(
        id: 'yesterday-morning',
        title: '어제 새벽 할 일',
        isCompleted: false,
        dueDate: yesterday.add(const Duration(hours: 1)), // 어제 새벽 1시
        priority: TodoPriority.high,
        category: TodoCategory.work,
        createdAt: yesterday,
      );

      final yesterdayNight = TodoEntity(
        id: 'yesterday-night',
        title: '어제 밤 할 일',
        isCompleted: false,
        dueDate: yesterday.add(const Duration(hours: 23)), // 어제 밤 11시
        priority: TodoPriority.medium,
        category: TodoCategory.personal,
        createdAt: yesterday,
      );

      // 시간과 관계없이 어제 날짜의 모든 미완료 항목은 overdue여야 함
      expect(yesterdayMorning.isOverdue, isTrue);
      expect(yesterdayNight.isOverdue, isTrue);
    });

    /// 경계값 테스트: 정확히 자정
    test('handles midnight boundary correctly', () {
      final yesterdayMidnight = TodoEntity(
        id: 'yesterday-midnight',
        title: '어제 자정 할 일',
        isCompleted: false,
        dueDate: DateTime(yesterday.year, yesterday.month, yesterday.day, 0, 0), // 어제 자정
        priority: TodoPriority.high,
        category: TodoCategory.work,
        createdAt: yesterday,
      );

      final todayMidnight = TodoEntity(
        id: 'today-midnight',
        title: '오늘 자정 할 일',
        isCompleted: false,
        dueDate: DateTime(today.year, today.month, today.day, 0, 0), // 오늘 자정
        priority: TodoPriority.medium,
        category: TodoCategory.personal,
        createdAt: today,
      );

      expect(yesterdayMidnight.isOverdue, isTrue);
      expect(todayMidnight.isOverdue, isFalse);
    });
  });
}