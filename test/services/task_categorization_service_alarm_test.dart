import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/services/task_categorization_service.dart';
import 'package:todo_bloc/model/todo_item.dart';

void main() {
  group('TaskCategorizationService - 알람 정보 보존 테스트', () {
    late TaskCategorizationService service;

    setUp(() {
      service = TaskCategorizationService();
    });

    group('categorizeAndUpdateTask', () {
      test('알람 정보가 있는 TodoItem의 카테고리 분류 시 알람 정보 보존', () {
        // Given
        final originalAlarmTime = DateTime(2025, 1, 15, 14, 30);
        final todoWithAlarm = TodoItem(
          title: 'work meeting preparation',
          priority: 'High',
          dueDate: DateTime(2025, 1, 15),
          hasAlarm: true,
          alarmTime: originalAlarmTime,
          notificationId: 12345,
          firebaseDocId: 'test_doc_id',
        );

        // When
        final categorizedTodo = service.categorizeAndUpdateTask(todoWithAlarm);

        // Then
        expect(categorizedTodo.category, equals('Work')); // 카테고리 분류 확인
        expect(categorizedTodo.hasAlarm, isTrue); // 알람 설정 보존
        expect(categorizedTodo.alarmTime, equals(originalAlarmTime)); // 알람 시간 보존
        expect(categorizedTodo.notificationId, equals(12345)); // 알림 ID 보존
        expect(categorizedTodo.firebaseDocId, equals('test_doc_id')); // Firebase ID 보존
        
        // 기본 필드들도 보존되는지 확인
        expect(categorizedTodo.title, equals(todoWithAlarm.title));
        expect(categorizedTodo.priority, equals(todoWithAlarm.priority));
        expect(categorizedTodo.dueDate, equals(todoWithAlarm.dueDate));
        expect(categorizedTodo.isCompleted, equals(todoWithAlarm.isCompleted));
      });

      test('알람이 없는 TodoItem의 카테고리 분류', () {
        // Given
        final todoWithoutAlarm = TodoItem(
          title: 'personal reading book',
          priority: 'Medium',
          dueDate: DateTime(2025, 1, 15),
          hasAlarm: false,
          alarmTime: null,
          notificationId: null,
        );

        // When
        final categorizedTodo = service.categorizeAndUpdateTask(todoWithoutAlarm);

        // Then
        expect(categorizedTodo.category, equals('Personal')); // 카테고리 분류 확인
        expect(categorizedTodo.hasAlarm, isFalse); // 알람 없음 보존
        expect(categorizedTodo.alarmTime, isNull); // null 값 보존
        expect(categorizedTodo.notificationId, isNull); // null 값 보존
      });

      test('다양한 카테고리와 알람 조합 테스트', () {
        // Given
        final testCases = [
          {
            'title': 'buy groceries',
            'expectedCategory': 'Shopping',
            'hasAlarm': true,
            'alarmTime': DateTime(2025, 1, 15, 10, 0),
          },
          {
            'title': 'doctor appointment',
            'expectedCategory': 'Health',
            'hasAlarm': true,
            'alarmTime': DateTime(2025, 1, 15, 15, 30),
          },
          {
            'title': 'family dinner',
            'expectedCategory': 'Social', // 실제로는 Social로 분류됨
            'hasAlarm': false,
            'alarmTime': null,
          },
        ];

        for (final testCase in testCases) {
          // When
          final todo = TodoItem(
            title: testCase['title'] as String,
            priority: 'Medium',
            dueDate: DateTime(2025, 1, 15),
            hasAlarm: testCase['hasAlarm'] as bool,
            alarmTime: testCase['alarmTime'] as DateTime?,
            notificationId: testCase['hasAlarm'] as bool ? 999 : null,
          );

          final categorizedTodo = service.categorizeAndUpdateTask(todo);

          // Then
          expect(categorizedTodo.category, equals(testCase['expectedCategory']));
          expect(categorizedTodo.hasAlarm, equals(testCase['hasAlarm']));
          expect(categorizedTodo.alarmTime, equals(testCase['alarmTime']));
          
          if (testCase['hasAlarm'] as bool) {
            expect(categorizedTodo.notificationId, equals(999));
          } else {
            expect(categorizedTodo.notificationId, isNull);
          }
        }
      });

      test('완료된 TodoItem의 알람 정보 보존', () {
        // Given
        final completedTodoWithAlarm = TodoItem(
          title: 'completed meeting preparation',
          priority: 'High',
          dueDate: DateTime(2025, 1, 15),
          isCompleted: true, // 완료된 상태
          hasAlarm: true,
          alarmTime: DateTime(2025, 1, 15, 9, 0),
          notificationId: 54321,
        );

        // When
        final categorizedTodo = service.categorizeAndUpdateTask(completedTodoWithAlarm);

        // Then
        expect(categorizedTodo.category, equals('Work'));
        expect(categorizedTodo.isCompleted, isTrue); // 완료 상태 보존
        expect(categorizedTodo.hasAlarm, isTrue); // 알람 정보 보존
        expect(categorizedTodo.alarmTime, equals(DateTime(2025, 1, 15, 9, 0)));
        expect(categorizedTodo.notificationId, equals(54321));
      });

      test('카테고리를 찾을 수 없는 제목의 경우 Personal 카테고리로 분류되고 알람 정보 보존', () {
        // Given
        final unknownCategoryTodo = TodoItem(
          title: 'some random task xyz123',
          priority: 'Low',
          dueDate: DateTime(2025, 1, 15),
          hasAlarm: true,
          alarmTime: DateTime(2025, 1, 15, 20, 0),
          notificationId: 99999,
        );

        // When
        final categorizedTodo = service.categorizeAndUpdateTask(unknownCategoryTodo);

        // Then
        expect(categorizedTodo.category, equals('Personal')); // 기본 카테고리
        expect(categorizedTodo.hasAlarm, isTrue); // 알람 정보 보존
        expect(categorizedTodo.alarmTime, equals(DateTime(2025, 1, 15, 20, 0)));
        expect(categorizedTodo.notificationId, equals(99999));
      });
    });

    group('다른 메서드들의 알람 TodoItem 처리', () {
      test('groupTasksByCategory에서 알람이 있는 TodoItem 그룹핑', () {
        // Given
        final todosWithAlarm = [
          TodoItem(
            title: 'work meeting',
            priority: 'High',
            dueDate: DateTime(2025, 1, 15),
            category: 'Work',
            hasAlarm: true,
            alarmTime: DateTime(2025, 1, 15, 10, 0),
          ),
          TodoItem(
            title: 'personal exercise',
            priority: 'Medium',
            dueDate: DateTime(2025, 1, 15),
            category: 'Personal',
            hasAlarm: true,
            alarmTime: DateTime(2025, 1, 15, 18, 0),
          ),
          TodoItem(
            title: 'shopping groceries',
            priority: 'Low',
            dueDate: DateTime(2025, 1, 15),
            category: 'Shopping',
            hasAlarm: false,
          ),
        ];

        // When
        final groupedTasks = service.groupTasksByCategory(todosWithAlarm);

        // Then
        expect(groupedTasks.keys, containsAll(['Work', 'Personal', 'Shopping']));
        expect(groupedTasks['Work']!.length, equals(1));
        expect(groupedTasks['Personal']!.length, equals(1));
        expect(groupedTasks['Shopping']!.length, equals(1));
        
        // 알람 정보가 보존되는지 확인
        expect(groupedTasks['Work']!.first.hasAlarm, isTrue);
        expect(groupedTasks['Personal']!.first.hasAlarm, isTrue);
        expect(groupedTasks['Shopping']!.first.hasAlarm, isFalse);
      });

      test('getCategoryTaskCounts에서 알람 TodoItem 카운트', () {
        // Given
        final todosWithVariousAlarms = [
          TodoItem(title: 'work task 1', priority: 'High', dueDate: DateTime.now(), category: 'Work', hasAlarm: true),
          TodoItem(title: 'work task 2', priority: 'Medium', dueDate: DateTime.now(), category: 'Work', hasAlarm: false),
          TodoItem(title: 'personal task', priority: 'Low', dueDate: DateTime.now(), category: 'Personal', hasAlarm: true),
        ];

        // When
        final counts = service.getCategoryTaskCounts(todosWithVariousAlarms);

        // Then
        expect(counts['Work'], equals(2));
        expect(counts['Personal'], equals(1));
      });

      test('getCategoryCompletionCounts에서 완료된 알람 TodoItem 카운트', () {
        // Given
        final completedTodosWithAlarms = [
          TodoItem(title: 'completed work', priority: 'High', dueDate: DateTime.now(), category: 'Work', isCompleted: true, hasAlarm: true),
          TodoItem(title: 'incomplete work', priority: 'Medium', dueDate: DateTime.now(), category: 'Work', isCompleted: false, hasAlarm: true),
          TodoItem(title: 'completed personal', priority: 'Low', dueDate: DateTime.now(), category: 'Personal', isCompleted: true, hasAlarm: false),
        ];

        // When
        final completionCounts = service.getCategoryCompletionCounts(completedTodosWithAlarms);

        // Then
        expect(completionCounts['Work'], equals(1)); // 완료된 Work 태스크 1개
        expect(completionCounts['Personal'], equals(1)); // 완료된 Personal 태스크 1개
      });
    });
  });
}