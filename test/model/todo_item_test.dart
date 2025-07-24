import 'package:flutter/material.dart';
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

    // 알람 관련 테스트 추가
    group('알람 기능 테스트', () {
      test('알람이 설정된 TodoItem 생성 테스트', () {
        // Given
        final dueDate = DateTime(2025, 1, 15, 9, 0);
        final alarmTime = DateTime(2025, 1, 15, 14, 30);
        
        // When
        final todoWithAlarm = TodoItem(
          title: 'Alarm Todo',
          priority: 'High',
          dueDate: dueDate,
          hasAlarm: true,
          alarmTime: alarmTime,
          notificationId: 12345,
        );

        // Then
        expect(todoWithAlarm.hasAlarm, isTrue);
        expect(todoWithAlarm.alarmTime, equals(alarmTime));
        expect(todoWithAlarm.notificationId, equals(12345));
      });

      test('알람이 없는 TodoItem 기본값 테스트', () {
        // Given & When
        final todoWithoutAlarm = TodoItem(
          title: 'No Alarm Todo',
          priority: 'Medium',
          dueDate: DateTime.now(),
        );

        // Then
        expect(todoWithoutAlarm.hasAlarm, isFalse);
        expect(todoWithoutAlarm.alarmTime, isNull);
        expect(todoWithoutAlarm.notificationId, isNull);
      });

      test('effectiveAlarmTime 계산 테스트', () {
        // Given
        final dueDate = DateTime(2025, 1, 15, 9, 0);
        final alarmTime = DateTime(2024, 12, 31, 14, 30); // 날짜는 무시, 시간만 사용
        
        final todoWithAlarm = TodoItem(
          title: 'Effective Alarm Test',
          priority: 'Medium',
          dueDate: dueDate,
          hasAlarm: true,
          alarmTime: alarmTime,
        );

        // When
        final effectiveTime = todoWithAlarm.effectiveAlarmTime;

        // Then
        expect(effectiveTime, isNotNull);
        expect(effectiveTime!.year, equals(2025));
        expect(effectiveTime.month, equals(1));
        expect(effectiveTime.day, equals(15));
        expect(effectiveTime.hour, equals(14));
        expect(effectiveTime.minute, equals(30));
      });

      test('hasAlarm이 false일 때 effectiveAlarmTime은 null 반환', () {
        // Given
        final todoWithoutAlarm = TodoItem(
          title: 'No Alarm Test',
          priority: 'Low',
          dueDate: DateTime.now(),
          hasAlarm: false,
          alarmTime: DateTime.now().add(Duration(hours: 1)),
        );

        // When & Then
        expect(todoWithoutAlarm.effectiveAlarmTime, isNull);
      });

      test('setAlarmTimeOfDay 메서드 테스트', () {
        // Given
        final dueDate = DateTime(2025, 1, 15, 9, 0);
        final todo = TodoItem(
          title: 'Alarm Time Test',
          priority: 'Medium',
          dueDate: dueDate,
        );
        const timeOfDay = TimeOfDay(hour: 16, minute: 45);

        // When
        todo.setAlarmTimeOfDay(timeOfDay);

        // Then
        expect(todo.hasAlarm, isTrue);
        expect(todo.alarmTime, isNotNull);
        expect(todo.alarmTime!.hour, equals(16));
        expect(todo.alarmTime!.minute, equals(45));
        expect(todo.alarmTime!.year, equals(2025));
        expect(todo.alarmTime!.month, equals(1));
        expect(todo.alarmTime!.day, equals(15));
      });

      test('clearAlarm 메서드 테스트', () {
        // Given
        final todoWithAlarm = TodoItem(
          title: 'Clear Alarm Test',
          priority: 'High',
          dueDate: DateTime.now(),
          hasAlarm: true,
          alarmTime: DateTime.now().add(Duration(hours: 1)),
          notificationId: 12345,
        );

        // When
        todoWithAlarm.clearAlarm();

        // Then
        expect(todoWithAlarm.hasAlarm, isFalse);
        expect(todoWithAlarm.alarmTime, isNull);
      });

      test('updateDueDateAndAlarm 메서드 테스트', () {
        // Given
        final originalDate = DateTime(2025, 1, 1, 9, 0);
        final newDate = DateTime(2025, 1, 15, 10, 0);
        final originalAlarmTime = DateTime(2025, 1, 1, 14, 30);
        
        final todo = TodoItem(
          title: 'Update Date Test',
          priority: 'Medium',
          dueDate: originalDate,
          hasAlarm: true,
          alarmTime: originalAlarmTime,
        );

        // When
        todo.updateDueDateAndAlarm(newDate);

        // Then
        expect(todo.dueDate, equals(newDate));
        expect(todo.hasAlarm, isTrue);
        expect(todo.alarmTime, isNotNull);
        expect(todo.alarmTime!.year, equals(2025));
        expect(todo.alarmTime!.month, equals(1));
        expect(todo.alarmTime!.day, equals(15)); // 새로운 날짜
        expect(todo.alarmTime!.hour, equals(14)); // 기존 시간 유지
        expect(todo.alarmTime!.minute, equals(30)); // 기존 분 유지
      });
    });
  });
}