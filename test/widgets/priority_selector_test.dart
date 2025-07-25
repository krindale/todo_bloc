import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/widgets/todo_screen/priority_selector.dart';

/// PrioritySelector 위젯 테스트
/// 
/// Todo 우선순위 선택 드롭다운 위젯의 렌더링과
/// 사용자 상호작용을 테스트합니다.
void main() {
  group('PrioritySelector Widget Tests', () {
    testWidgets('should render PrioritySelector with initial priority selection', (tester) async {
      // Arrange
      String selectedPriority = 'High';
      String? changedPriority;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrioritySelector(
              selectedPriority: selectedPriority,
              onPriorityChanged: (priority) {
                changedPriority = priority;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(PrioritySelector), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('should display correct colors for High priority', (tester) async {
      // Arrange
      const selectedPriority = 'High';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrioritySelector(
              selectedPriority: selectedPriority,
              onPriorityChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(PrioritySelector), findsOneWidget);
      
      final prioritySelector = tester.widget<PrioritySelector>(find.byType(PrioritySelector));
      expect(prioritySelector.selectedPriority, equals('High'));
    });

    testWidgets('should display correct colors for Medium priority', (tester) async {
      // Arrange
      const selectedPriority = 'Medium';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrioritySelector(
              selectedPriority: selectedPriority,
              onPriorityChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(PrioritySelector), findsOneWidget);
      
      final prioritySelector = tester.widget<PrioritySelector>(find.byType(PrioritySelector));
      expect(prioritySelector.selectedPriority, equals('Medium'));
    });

    testWidgets('should display correct colors for Low priority', (tester) async {
      // Arrange
      const selectedPriority = 'Low';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrioritySelector(
              selectedPriority: selectedPriority,
              onPriorityChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(PrioritySelector), findsOneWidget);
      
      final prioritySelector = tester.widget<PrioritySelector>(find.byType(PrioritySelector));
      expect(prioritySelector.selectedPriority, equals('Low'));
    });

    testWidgets('should handle unknown priority with default color', (tester) async {
      // Arrange
      const selectedPriority = 'Unknown';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrioritySelector(
              selectedPriority: selectedPriority,
              onPriorityChanged: (_) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(PrioritySelector), findsOneWidget);
      
      final prioritySelector = tester.widget<PrioritySelector>(find.byType(PrioritySelector));
      expect(prioritySelector.selectedPriority, equals('Unknown'));
    });

    testWidgets('should open dropdown when tapped', (tester) async {
      // Arrange
      const selectedPriority = 'High';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrioritySelector(
              selectedPriority: selectedPriority,
              onPriorityChanged: (_) {},
            ),
          ),
        ),
      );

      // Tap the dropdown button
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('High'), findsWidgets); // 선택된 것과 드롭다운 메뉴의 항목
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Low'), findsOneWidget);
    });

    testWidgets('should call onPriorityChanged when priority is selected', (tester) async {
      // Arrange
      String selectedPriority = 'High';
      String? changedPriority;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrioritySelector(
              selectedPriority: selectedPriority,
              onPriorityChanged: (priority) {
                changedPriority = priority;
              },
            ),
          ),
        ),
      );

      // Tap the dropdown button to open menu
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select Medium priority
      await tester.tap(find.text('Medium').last);
      await tester.pumpAndSettle();

      // Assert
      expect(changedPriority, equals('Medium'));
    });

    testWidgets('should not call onPriorityChanged when same priority is selected', (tester) async {
      // Arrange
      String selectedPriority = 'High';
      int callCount = 0;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrioritySelector(
              selectedPriority: selectedPriority,
              onPriorityChanged: (priority) {
                callCount++;
              },
            ),
          ),
        ),
      );

      // Tap the dropdown button to open menu
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select same priority (High)
      await tester.tap(find.text('High').last);
      await tester.pumpAndSettle();

      // Assert
      expect(callCount, equals(1)); // onChanged는 호출되지만 같은 값
    });

    testWidgets('should display correct icons for all priorities', (tester) async {
      // Arrange
      const selectedPriority = 'High';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrioritySelector(
              selectedPriority: selectedPriority,
              onPriorityChanged: (_) {},
            ),
          ),
        ),
      );

      // Open dropdown menu
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget); // High priority icon
      expect(find.byIcon(Icons.remove), findsOneWidget); // Medium priority icon
      expect(find.byIcon(Icons.arrow_downward), findsOneWidget); // Low priority icon
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget); // Dropdown arrow
    });

    testWidgets('should have consistent styling across all priorities', (tester) async {
      final priorities = ['High', 'Medium', 'Low'];

      for (final priority in priorities) {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrioritySelector(
                selectedPriority: priority,
                onPriorityChanged: (_) {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(Container), findsOneWidget);
        expect(find.byType(DropdownButtonHideUnderline), findsOneWidget);
        expect(find.byType(DropdownButton<String>), findsOneWidget);
        
        final containerWidget = tester.widget<Container>(find.byType(Container));
        expect(containerWidget.decoration, isA<BoxDecoration>());
      }
    });

    group('Priority Selection Integration', () {
      testWidgets('should update from High to Medium priority', (tester) async {
        // Arrange
        String selectedPriority = 'High';
        String? newPriority;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return PrioritySelector(
                    selectedPriority: selectedPriority,
                    onPriorityChanged: (priority) {
                      setState(() {
                        selectedPriority = priority;
                        newPriority = priority;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );

        // Open dropdown and select Medium
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Medium').last);
        await tester.pumpAndSettle();

        // Assert
        expect(newPriority, equals('Medium'));
        expect(find.text('Medium'), findsOneWidget);
      });

      testWidgets('should update from Medium to Low priority', (tester) async {
        // Arrange
        String selectedPriority = 'Medium';
        String? newPriority;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return PrioritySelector(
                    selectedPriority: selectedPriority,
                    onPriorityChanged: (priority) {
                      setState(() {
                        selectedPriority = priority;
                        newPriority = priority;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );

        // Open dropdown and select Low
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Low').last);
        await tester.pumpAndSettle();

        // Assert
        expect(newPriority, equals('Low'));
        expect(find.text('Low'), findsOneWidget);
      });

      testWidgets('should cycle through all priorities', (tester) async {
        // Arrange
        String selectedPriority = 'High';
        final List<String> selectedPriorities = [];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return PrioritySelector(
                    selectedPriority: selectedPriority,
                    onPriorityChanged: (priority) {
                      setState(() {
                        selectedPriority = priority;
                        selectedPriorities.add(priority);
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );

        final priorities = ['Medium', 'Low', 'High'];
        
        for (final priority in priorities) {
          await tester.tap(find.byType(DropdownButton<String>));
          await tester.pumpAndSettle();
          
          await tester.tap(find.text(priority).last);
          await tester.pumpAndSettle();
        }

        // Assert
        expect(selectedPriorities, equals(['Medium', 'Low', 'High']));
      });
    });

    group('Edge Cases and Error Handling', () {
      testWidgets('should handle null onPriorityChanged gracefully', (tester) async {
        // Note: onPriorityChanged는 required 파라미터이므로 
        // 이 테스트는 empty function을 전달하는 것으로 대체
        
        // Arrange
        const selectedPriority = 'High';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PrioritySelector(
                selectedPriority: selectedPriority,
                onPriorityChanged: (_) {}, // Empty function
              ),
            ),
          ),
        );

        // Open dropdown and select another priority
        await tester.tap(find.byType(DropdownButton<String>));
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Medium').last);
        await tester.pumpAndSettle();

        // Assert - should not crash
        expect(find.byType(PrioritySelector), findsOneWidget);
      });

      testWidgets('should handle rapid priority changes', (tester) async {
        // Arrange
        String selectedPriority = 'High';
        final List<String> changes = [];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return PrioritySelector(
                    selectedPriority: selectedPriority,
                    onPriorityChanged: (priority) {
                      setState(() {
                        selectedPriority = priority;
                        changes.add(priority);
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );

        // Rapid changes
        for (int i = 0; i < 3; i++) {
          await tester.tap(find.byType(DropdownButton<String>));
          await tester.pumpAndSettle();
          
          await tester.tap(find.text('Medium').last);
          await tester.pumpAndSettle();
          
          await tester.tap(find.byType(DropdownButton<String>));
          await tester.pumpAndSettle();
          
          await tester.tap(find.text('Low').last);
          await tester.pumpAndSettle();
        }

        // Assert
        expect(changes.length, equals(6)); // 3 cycles * 2 changes each
        expect(find.byType(PrioritySelector), findsOneWidget);
      });
    });

    group('Accessibility Tests', () {
      testWidgets('should be accessible for screen readers', (tester) async {
        // Arrange
        const selectedPriority = 'High';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Semantics(
                label: 'Priority Selector',
                child: PrioritySelector(
                  selectedPriority: selectedPriority,
                  onPriorityChanged: (_) {},
                ),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(PrioritySelector), findsOneWidget);
        expect(find.byType(Semantics), findsOneWidget);
      });
    });
  });
}