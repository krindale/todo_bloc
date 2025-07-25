import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/widgets/todo_screen/task_input.dart';

/// TaskInput 위젯 테스트
/// 
/// Todo 작업 입력 폼 위젯의 렌더링과
/// 사용자 상호작용을 테스트합니다.
void main() {
  group('TaskInput Widget Tests', () {
    late TextEditingController taskController;

    setUp(() {
      taskController = TextEditingController();
    });

    tearDown(() {
      taskController.dispose();
    });

    testWidgets('should render TaskInput with all required fields', (tester) async {
      // Arrange
      DateTime selectedDate = DateTime.now();
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskInput(
              taskController: taskController,
              selectedPriority: 'Medium',
              selectedDate: selectedDate,
              onPickDate: () {},
              onAddOrUpdateTask: () {},
              onCancelEditing: () {},
              isEditing: false,
              onPriorityChanged: (_) {},
              onPickAlarmTime: () {},
              onClearAlarm: () {},
              hasAlarm: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(TaskInput), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Task Description'), findsOneWidget);
    });

    testWidgets('should display Add Task button when not editing', (tester) async {
      // Arrange
      DateTime selectedDate = DateTime.now();
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskInput(
              taskController: taskController,
              selectedPriority: 'High',
              selectedDate: selectedDate,
              onPickDate: () {},
              onAddOrUpdateTask: () {},
              onCancelEditing: () {},
              isEditing: false,
              onPriorityChanged: (_) {},
              onPickAlarmTime: () {},
              onClearAlarm: () {},
              hasAlarm: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('+ Add Task'), findsOneWidget);
      expect(find.text('Update Task'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('should display Update Task button and Cancel when editing', (tester) async {
      // Arrange
      DateTime selectedDate = DateTime.now();
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskInput(
              taskController: taskController,
              selectedPriority: 'Low',
              selectedDate: selectedDate,
              onPickDate: () {},
              onAddOrUpdateTask: () {},
              onCancelEditing: () {},
              isEditing: true,
              onPriorityChanged: (_) {},
              onPickAlarmTime: () {},
              onClearAlarm: () {},
              hasAlarm: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Update Task'), findsOneWidget);
      expect(find.text('+ Add Task'), findsNothing);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should display selected date correctly', (tester) async {
      // Arrange
      DateTime selectedDate = DateTime(2024, 12, 25);
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskInput(
              taskController: taskController,
              selectedPriority: 'Medium',
              selectedDate: selectedDate,
              onPickDate: () {},
              onAddOrUpdateTask: () {},
              onCancelEditing: () {},
              isEditing: false,
              onPriorityChanged: (_) {},
              onPickAlarmTime: () {},
              onClearAlarm: () {},
              hasAlarm: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.textContaining('Dec'), findsOneWidget);
      expect(find.textContaining('25'), findsOneWidget);
    });

    testWidgets('should display default date text when no date selected', (tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskInput(
              taskController: taskController,
              selectedPriority: 'Medium',
              selectedDate: null,
              onPickDate: () {},
              onAddOrUpdateTask: () {},
              onCancelEditing: () {},
              isEditing: false,
              onPriorityChanged: (_) {},
              onPickAlarmTime: () {},
              onClearAlarm: () {},
              hasAlarm: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Due Date (Today)'), findsOneWidget);
    });

    testWidgets('should call onPickDate when date button is tapped', (tester) async {
      // Arrange
      bool datePickerCalled = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskInput(
              taskController: taskController,
              selectedPriority: 'Medium',
              selectedDate: null,
              onPickDate: () {
                datePickerCalled = true;
              },
              onAddOrUpdateTask: () {},
              onCancelEditing: () {},
              isEditing: false,
              onPriorityChanged: (_) {},
              onPickAlarmTime: () {},
              onClearAlarm: () {},
              hasAlarm: false,
            ),
          ),
        ),
      );

      // Tap the date picker button
      await tester.tap(find.byIcon(Icons.date_range));
      await tester.pump();

      // Assert
      expect(datePickerCalled, isTrue);
    });

    testWidgets('should call onAddOrUpdateTask when task button is tapped', (tester) async {
      // Arrange
      bool addTaskCalled = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskInput(
              taskController: taskController,
              selectedPriority: 'Medium',
              selectedDate: null,
              onPickDate: () {},
              onAddOrUpdateTask: () {
                addTaskCalled = true;
              },
              onCancelEditing: () {},
              isEditing: false,
              onPriorityChanged: (_) {},
              onPickAlarmTime: () {},
              onClearAlarm: () {},
              hasAlarm: false,
            ),
          ),
        ),
      );

      // Tap the add task button
      await tester.tap(find.text('+ Add Task'));
      await tester.pump();

      // Assert
      expect(addTaskCalled, isTrue);
    });

    testWidgets('should call onCancelEditing when cancel button is tapped', (tester) async {
      // Arrange
      bool cancelCalled = false;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskInput(
              taskController: taskController,
              selectedPriority: 'Medium',
              selectedDate: null,
              onPickDate: () {},
              onAddOrUpdateTask: () {},
              onCancelEditing: () {
                cancelCalled = true;
              },
              isEditing: true,
              onPriorityChanged: (_) {},
              onPickAlarmTime: () {},
              onClearAlarm: () {},
              hasAlarm: false,
            ),
          ),
        ),
      );

      // Tap the cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      // Assert
      expect(cancelCalled, isTrue);
    });

    group('Alarm Feature Tests', () {
      testWidgets('should display alarm button without alarm time when hasAlarm is false', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskInput(
                taskController: taskController,
                selectedPriority: 'Medium',
                selectedDate: null,
                onPickDate: () {},
                onAddOrUpdateTask: () {},
                onCancelEditing: () {},
                isEditing: false,
                onPriorityChanged: (_) {},
                onPickAlarmTime: () {},
                onClearAlarm: () {},
                hasAlarm: false,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.alarm), findsOneWidget);
        expect(find.byIcon(Icons.clear), findsNothing);
      });

      testWidgets('should display alarm time and clear button when hasAlarm is true', (tester) async {
        // Arrange
        const alarmTime = TimeOfDay(hour: 14, minute: 30);
        
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskInput(
                taskController: taskController,
                selectedPriority: 'Medium',
                selectedDate: null,
                onPickDate: () {},
                onAddOrUpdateTask: () {},
                onCancelEditing: () {},
                isEditing: false,
                onPriorityChanged: (_) {},
                alarmTime: alarmTime,
                onPickAlarmTime: () {},
                onClearAlarm: () {},
                hasAlarm: true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.alarm), findsOneWidget);
        expect(find.byIcon(Icons.clear), findsOneWidget);
        expect(find.text('2:30 PM'), findsOneWidget);
      });

      testWidgets('should call onPickAlarmTime when alarm button is tapped', (tester) async {
        // Arrange
        bool alarmPickerCalled = false;
        
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskInput(
                taskController: taskController,
                selectedPriority: 'Medium',
                selectedDate: null,
                onPickDate: () {},
                onAddOrUpdateTask: () {},
                onCancelEditing: () {},
                isEditing: false,
                onPriorityChanged: (_) {},
                onPickAlarmTime: () {
                  alarmPickerCalled = true;
                },
                onClearAlarm: () {},
                hasAlarm: false,
              ),
            ),
          ),
        );

        // Tap the alarm button
        await tester.tap(find.byIcon(Icons.alarm));
        await tester.pump();

        // Assert
        expect(alarmPickerCalled, isTrue);
      });

      testWidgets('should call onClearAlarm when clear alarm button is tapped', (tester) async {
        // Arrange
        bool clearAlarmCalled = false;
        const alarmTime = TimeOfDay(hour: 10, minute: 15);
        
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskInput(
                taskController: taskController,
                selectedPriority: 'Medium',
                selectedDate: null,
                onPickDate: () {},
                onAddOrUpdateTask: () {},
                onCancelEditing: () {},
                isEditing: false,
                onPriorityChanged: (_) {},
                alarmTime: alarmTime,
                onPickAlarmTime: () {},
                onClearAlarm: () {
                  clearAlarmCalled = true;
                },
                hasAlarm: true,
              ),
            ),
          ),
        );

        // Tap the clear alarm button
        await tester.tap(find.byIcon(Icons.clear));
        await tester.pump();

        // Assert
        expect(clearAlarmCalled, isTrue);
      });

      testWidgets('should display different alarm button styling when alarm is set', (tester) async {
        // Test without alarm
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskInput(
                taskController: taskController,
                selectedPriority: 'Medium',
                selectedDate: null,
                onPickDate: () {},
                onAddOrUpdateTask: () {},
                onCancelEditing: () {},
                isEditing: false,
                onPriorityChanged: (_) {},
                onPickAlarmTime: () {},
                onClearAlarm: () {},
                hasAlarm: false,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.alarm), findsOneWidget);

        // Test with alarm
        const alarmTime = TimeOfDay(hour: 9, minute: 0);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskInput(
                taskController: taskController,
                selectedPriority: 'Medium',
                selectedDate: null,
                onPickDate: () {},
                onAddOrUpdateTask: () {},
                onCancelEditing: () {},
                isEditing: false,
                onPriorityChanged: (_) {},
                alarmTime: alarmTime,
                onPickAlarmTime: () {},
                onClearAlarm: () {},
                hasAlarm: true,
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.alarm), findsOneWidget);
        expect(find.byIcon(Icons.clear), findsOneWidget);
      });
    });

    group('Text Input Tests', () {
      testWidgets('should accept text input in task description field', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskInput(
                taskController: taskController,
                selectedPriority: 'Medium',
                selectedDate: null,
                onPickDate: () {},
                onAddOrUpdateTask: () {},
                onCancelEditing: () {},
                isEditing: false,
                onPriorityChanged: (_) {},
                onPickAlarmTime: () {},
                onClearAlarm: () {},
                hasAlarm: false,
              ),
            ),
          ),
        );

        // Enter text in the task description field
        await tester.enterText(find.byType(TextField), 'Test task description');
        await tester.pump();

        // Assert
        expect(taskController.text, equals('Test task description'));
        expect(find.text('Test task description'), findsOneWidget);
      });

      testWidgets('should display existing text in task controller', (tester) async {
        // Arrange
        taskController.text = 'Existing task';
        
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskInput(
                taskController: taskController,
                selectedPriority: 'Medium',
                selectedDate: null,
                onPickDate: () {},
                onAddOrUpdateTask: () {},
                onCancelEditing: () {},
                isEditing: false,
                onPriorityChanged: (_) {},
                onPickAlarmTime: () {},
                onClearAlarm: () {},
                hasAlarm: false,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Existing task'), findsOneWidget);
      });
    });

    group('Priority Integration Tests', () {
      testWidgets('should call onPriorityChanged when priority is changed', (tester) async {
        // Arrange
        String? changedPriority;
        
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskInput(
                taskController: taskController,
                selectedPriority: 'High',
                selectedDate: null,
                onPickDate: () {},
                onAddOrUpdateTask: () {},
                onCancelEditing: () {},
                isEditing: false,
                onPriorityChanged: (priority) {
                  changedPriority = priority;
                },
                onPickAlarmTime: () {},
                onClearAlarm: () {},
                hasAlarm: false,
              ),
            ),
          ),
        );

        // Change priority through PrioritySelector
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Medium').last);
        await tester.pumpAndSettle();

        // Assert
        expect(changedPriority, equals('Medium'));
      });
    });

    group('Edge Cases and Error Handling', () {
      testWidgets('should handle empty task controller', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskInput(
                taskController: taskController,
                selectedPriority: 'Medium',
                selectedDate: null,
                onPickDate: () {},
                onAddOrUpdateTask: () {},
                onCancelEditing: () {},
                isEditing: false,
                onPriorityChanged: (_) {},
                onPickAlarmTime: () {},
                onClearAlarm: () {},
                hasAlarm: false,
              ),
            ),
          ),
        );

        // Assert - should not crash with empty controller
        expect(find.byType(TaskInput), findsOneWidget);
        expect(taskController.text, isEmpty);
      });

      testWidgets('should handle null alarmTime when hasAlarm is true', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskInput(
                taskController: taskController,
                selectedPriority: 'Medium',
                selectedDate: null,
                onPickDate: () {},
                onAddOrUpdateTask: () {},
                onCancelEditing: () {},
                isEditing: false,
                onPriorityChanged: (_) {},
                alarmTime: null, // null but hasAlarm is true
                onPickAlarmTime: () {},
                onClearAlarm: () {},
                hasAlarm: true,
              ),
            ),
          ),
        );

        // Assert - should not crash and should show empty time
        expect(find.byType(TaskInput), findsOneWidget);
        expect(find.byIcon(Icons.alarm), findsOneWidget);
        expect(find.byIcon(Icons.clear), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should have proper tooltips for alarm buttons', (tester) async {
        // Arrange
        const alarmTime = TimeOfDay(hour: 12, minute: 0);
        
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TaskInput(
                taskController: taskController,
                selectedPriority: 'Medium',
                selectedDate: null,
                onPickDate: () {},
                onAddOrUpdateTask: () {},
                onCancelEditing: () {},
                isEditing: false,
                onPriorityChanged: (_) {},
                alarmTime: alarmTime,
                onPickAlarmTime: () {},
                onClearAlarm: () {},
                hasAlarm: true,
              ),
            ),
          ),
        );

        // Find IconButtons by tooltip property
        final alarmButton = find.byWidgetPredicate((widget) => 
          widget is IconButton && widget.tooltip == '알람 설정');
        final clearButton = find.byWidgetPredicate((widget) => 
          widget is IconButton && widget.tooltip == '알람 해제');

        // Assert
        expect(alarmButton, findsOneWidget);
        expect(clearButton, findsOneWidget);
      });
    });
  });
}