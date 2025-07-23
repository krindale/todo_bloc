import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/model/todo_item.dart';
import 'package:todo_bloc/services/task_categorization_service.dart';

void main() {
  group('TaskCategorizationService', () {
    late TaskCategorizationService service;

    setUp(() {
      service = TaskCategorizationService();
    });

    group('categorizeTask', () {
      test('should categorize work-related tasks correctly', () {
        expect(service.categorizeTask('Meeting with client'), 'Work');
        expect(service.categorizeTask('Prepare presentation for team'), 'Work');
        expect(service.categorizeTask('회의 준비하기'), 'Work');
        expect(service.categorizeTask('프로젝트 마감일 확인'), 'Work');
      });

      test('should categorize shopping tasks correctly', () {
        expect(service.categorizeTask('Buy groceries'), 'Shopping');
        expect(service.categorizeTask('Purchase new clothes'), 'Shopping');
        expect(service.categorizeTask('마트에서 장보기'), 'Shopping');
        expect(service.categorizeTask('온라인 쇼핑몰에서 신발 주문'), 'Shopping');
      });

      test('should categorize health tasks correctly', () {
        expect(service.categorizeTask('Doctor appointment'), 'Health');
        expect(service.categorizeTask('Go to gym'), 'Health');
        expect(service.categorizeTask('병원 검진 받기'), 'Health');
        expect(service.categorizeTask('헬스장에서 운동하기'), 'Health');
      });

      test('should categorize personal tasks correctly', () {
        expect(service.categorizeTask('Read a book'), 'Personal');
        expect(service.categorizeTask('Watch movie'), 'Personal');
        expect(service.categorizeTask('독서하기'), 'Personal');
        expect(service.categorizeTask('개인 시간 갖기'), 'Personal');
      });

      test('should return Personal for unrecognized tasks', () {
        expect(service.categorizeTask('Random activity'), 'Personal');
        expect(service.categorizeTask('Something unknown'), 'Personal');
        expect(service.categorizeTask(''), 'Personal');
      });

      test('should handle mixed language tasks', () {
        expect(service.categorizeTask('Meeting with 고객'), 'Work');
        expect(service.categorizeTask('Buy 옷 for party'), 'Shopping');
      });

      test('should prioritize exact word matches', () {
        expect(service.categorizeTask('work on project'), 'Work');
        expect(service.categorizeTask('workout at gym'), 'Health');
      });
    });

    group('categorizeAndUpdateTask', () {
      test('should update task with category', () {
        final task = TodoItem(
          title: 'Meeting with team',
          priority: 'High',
          dueDate: DateTime.now(),
          isCompleted: false,
        );

        final categorizedTask = service.categorizeAndUpdateTask(task);

        expect(categorizedTask.title, 'Meeting with team');
        expect(categorizedTask.category, 'Work');
        expect(categorizedTask.priority, 'High');
        expect(categorizedTask.isCompleted, false);
      });
    });

    group('groupTasksByCategory', () {
      test('should group tasks by category correctly', () {
        final tasks = [
          TodoItem(
            title: 'Team meeting',
            priority: 'High',
            dueDate: DateTime.now(),
            isCompleted: false,
            category: 'Work',
          ),
          TodoItem(
            title: 'Buy groceries',
            priority: 'Medium',
            dueDate: DateTime.now(),
            isCompleted: true,
            category: 'Shopping',
          ),
          TodoItem(
            title: 'Project review',
            priority: 'High',
            dueDate: DateTime.now(),
            isCompleted: false,
            category: 'Work',
          ),
        ];

        final grouped = service.groupTasksByCategory(tasks);

        expect(grouped.keys, containsAll(['Work', 'Shopping']));
        expect(grouped['Work']!.length, 2);
        expect(grouped['Shopping']!.length, 1);
        expect(grouped['Work']![0].title, 'Team meeting');
        expect(grouped['Work']![1].title, 'Project review');
        expect(grouped['Shopping']![0].title, 'Buy groceries');
      });

      test('should auto-categorize tasks without category', () {
        final tasks = [
          TodoItem(
            title: 'Doctor appointment',
            priority: 'High',
            dueDate: DateTime.now(),
            isCompleted: false,
          ),
        ];

        final grouped = service.groupTasksByCategory(tasks);

        expect(grouped.keys, contains('Health'));
        expect(grouped['Health']!.length, 1);
      });
    });

    group('getCategoryTaskCounts', () {
      test('should count tasks by category', () {
        final tasks = [
          TodoItem(
            title: 'Meeting',
            priority: 'High',
            dueDate: DateTime.now(),
            isCompleted: false,
            category: 'Work',
          ),
          TodoItem(
            title: 'Shopping',
            priority: 'Medium',
            dueDate: DateTime.now(),
            isCompleted: true,
            category: 'Shopping',
          ),
          TodoItem(
            title: 'Another meeting',
            priority: 'Low',
            dueDate: DateTime.now(),
            isCompleted: false,
            category: 'Work',
          ),
        ];

        final counts = service.getCategoryTaskCounts(tasks);

        expect(counts['Work'], 2);
        expect(counts['Shopping'], 1);
      });
    });

    group('getCategoryCompletionCounts', () {
      test('should count completed tasks by category', () {
        final tasks = [
          TodoItem(
            title: 'Meeting',
            priority: 'High',
            dueDate: DateTime.now(),
            isCompleted: true,
            category: 'Work',
          ),
          TodoItem(
            title: 'Shopping',
            priority: 'Medium',
            dueDate: DateTime.now(),
            isCompleted: true,
            category: 'Shopping',
          ),
          TodoItem(
            title: 'Another meeting',
            priority: 'Low',
            dueDate: DateTime.now(),
            isCompleted: false,
            category: 'Work',
          ),
        ];

        final counts = service.getCategoryCompletionCounts(tasks);

        expect(counts['Work'], 1);
        expect(counts['Shopping'], 1);
        expect(counts.containsKey('Personal'), false);
      });
    });
  });
}