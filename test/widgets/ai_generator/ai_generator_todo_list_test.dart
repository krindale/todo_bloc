import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/widgets/ai_generator/ai_generator_todo_list.dart';
import 'package:todo_bloc/model/todo_item.dart';

void main() {
  group('AiGeneratorTodoList', () {
    late List<TodoItem> testTodos;
    late Set<int> selectedTodos;
    late List<int> toggledIndices;
    late List<bool> toggledValues;
    late bool saveCalled;
    late bool resetCalled;

    setUp(() {
      testTodos = [
        TodoItem(
          title: '운동하기',
          category: '건강',
          priority: '높음',
          createdAt: DateTime.now(),
        ),
        TodoItem(
          title: '책 읽기',
          category: '자기계발',
          priority: '보통',
          createdAt: DateTime.now(),
        ),
        TodoItem(
          title: '프로젝트 완료',
          category: '업무',
          priority: '높음',
          createdAt: DateTime.now(),
        ),
      ];
      selectedTodos = {0, 2}; // 첫 번째와 세 번째 선택
      toggledIndices = [];
      toggledValues = [];
      saveCalled = false;
      resetCalled = false;
    });

    Widget createWidget() {
      return MaterialApp(
        home: Scaffold(
          body: AiGeneratorTodoList(
            todos: testTodos,
            selectedTodos: selectedTodos,
            onTodoToggle: (index, value) {
              toggledIndices.add(index);
              toggledValues.add(value);
            },
            onSave: () {
              saveCalled = true;
            },
            onReset: () {
              resetCalled = true;
            },
          ),
        ),
      );
    }

    testWidgets('should display todo list header correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidget());

      // Assert
      expect(find.text('생성된 할 일 목록'), findsOneWidget);
      expect(find.text('2/3 선택됨'), findsOneWidget);
      expect(find.byIcon(Icons.checklist), findsOneWidget);
    });

    testWidgets('should display all todo items', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidget());

      // Assert
      expect(find.text('운동하기'), findsOneWidget);
      expect(find.text('책 읽기'), findsOneWidget);
      expect(find.text('프로젝트 완료'), findsOneWidget);
    });

    testWidgets('should display todo categories and priorities', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidget());

      // Assert
      expect(find.text('건강'), findsOneWidget);
      expect(find.text('자기계발'), findsOneWidget);
      expect(find.text('업무'), findsOneWidget);
      expect(find.text('높음'), findsNWidgets(2));
      expect(find.text('보통'), findsOneWidget);
    });

    testWidgets('should show correct selection states', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidget());

      // Assert
      final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
      expect(checkboxes.elementAt(0).value, isTrue); // 첫 번째 선택됨
      expect(checkboxes.elementAt(1).value, isFalse); // 두 번째 선택 안됨
      expect(checkboxes.elementAt(2).value, isTrue); // 세 번째 선택됨
    });

    testWidgets('should call onTodoToggle when checkbox is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidget());

      // Act
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      // Assert
      expect(toggledIndices, contains(0));
      expect(toggledValues, contains(false)); // 선택된 상태에서 해제
    });

    testWidgets('should call onTodoToggle when InkWell is tapped', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidget());

      // Act
      await tester.tap(find.byType(InkWell).first);
      await tester.pump();

      // Assert
      expect(toggledIndices, contains(0));
      expect(toggledValues, contains(false)); // 선택된 상태에서 해제
    });

    testWidgets('should display save button with correct text', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidget());

      // Assert
      expect(find.text('선택된 할 일 저장 (2개)'), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('should call onSave when save button is pressed', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidget());

      // Act
      await tester.tap(find.text('선택된 할 일 저장 (2개)'));
      await tester.pump();

      // Assert
      expect(saveCalled, isTrue);
    });

    testWidgets('should disable save button when no todos selected', (tester) async {
      // Arrange
      selectedTodos.clear();
      await tester.pumpWidget(createWidget());

      // Act & Assert
      final saveButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, '선택된 할 일 저장 (0개)'),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('should call onReset when reset button is pressed', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidget());

      // Act
      await tester.tap(find.text('다시 생성하기'));
      await tester.pump();

      // Assert
      expect(resetCalled, isTrue);
    });

    testWidgets('should display reset button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidget());

      // Assert
      expect(find.text('다시 생성하기'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should handle empty todo list', (tester) async {
      // Arrange
      testTodos.clear();
      selectedTodos.clear();
      await tester.pumpWidget(createWidget());

      // Assert
      expect(find.text('0/0 선택됨'), findsOneWidget);
      expect(find.text('선택된 할 일 저장 (0개)'), findsOneWidget);
    });

    testWidgets('should display default category when category is null', (tester) async {
      // Arrange
      testTodos.clear();
      testTodos.add(TodoItem(
        title: '카테고리 없는 할 일',
        priority: '보통',
        createdAt: DateTime.now(),
      ));
      selectedTodos.clear();
      await tester.pumpWidget(createWidget());

      // Assert
      expect(find.text('일반'), findsOneWidget);
    });

    testWidgets('should show visual selection feedback', (tester) async {
      // Arrange
      await tester.pumpWidget(createWidget());

      // Act
      final firstContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );

      // Assert - 선택된 항목은 파란색 배경
      final decoration = firstContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.blue[50]));
      expect(decoration.border?.top.color, equals(Colors.blue[300]));
    });

    testWidgets('should handle long todo titles with ellipsis', (tester) async {
      // Arrange
      testTodos.clear();
      testTodos.add(TodoItem(
        title: '매우 긴 할 일 제목입니다. 이 제목은 두 줄을 넘어서 표시될 정도로 길어서 ellipsis 처리가 되어야 합니다.',
        category: '테스트',
        priority: '높음',
        createdAt: DateTime.now(),
      ));
      selectedTodos.clear();
      await tester.pumpWidget(createWidget());

      // Assert
      final textWidget = tester.widget<Text>(
        find.text('매우 긴 할 일 제목입니다. 이 제목은 두 줄을 넘어서 표시될 정도로 길어서 ellipsis 처리가 되어야 합니다.'),
      );
      expect(textWidget.maxLines, equals(2));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });

    testWidgets('should show proper spacing and padding', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createWidget());

      // Assert
      expect(find.byType(Padding), findsWidgets);
      expect(find.byType(SizedBox), findsWidgets);
    });
  });
}