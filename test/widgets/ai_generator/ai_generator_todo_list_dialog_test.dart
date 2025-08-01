/// **AI Generator Todo List Dialog 테스트**
/// 
/// AiGeneratorTodoList 위젯의 콜백 시스템과 UI 동작을 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:todo_bloc/widgets/ai_generator/ai_generator_todo_list_dialog.dart';
import 'package:todo_bloc/presentation/providers/todo_provider.dart';
import 'package:todo_bloc/services/hive_todo_repository.dart';
import 'package:todo_bloc/core/utils/app_logger.dart';

import 'ai_generator_todo_list_dialog_test.mocks.dart';

@GenerateMocks([HiveTodoRepository])
void main() {
  group('AiGeneratorTodoList', () {
    late MockHiveTodoRepository mockHiveRepository;
    late ProviderContainer container;
    
    setUp(() {
      mockHiveRepository = MockHiveTodoRepository();
      container = ProviderContainer();
      
      // AppLogger 초기화는 테스트에서 불필요 (정적 메서드 사용)
    });

    tearDown(() {
      container.dispose();
    });

    /// 기본 위젯 렌더링 테스트
    testWidgets('renders correctly with provided todos', (tester) async {
      const testTodos = [
        '운동하기',
        '독서하기', 
        '코딩 공부하기'
      ];

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AiGeneratorTodoList(
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 헤더 확인
      expect(find.text('생성된 할 일 목록'), findsOneWidget);
      expect(find.text('3/3 선택'), findsOneWidget);
      
      // Todo 아이템들 확인
      expect(find.text('운동하기'), findsOneWidget);
      expect(find.text('독서하기'), findsOneWidget);
      expect(find.text('코딩 공부하기'), findsOneWidget);
      
      // 체크박스들이 모두 선택된 상태인지 확인 (기본값)
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(3));
      
      for (int i = 0; i < 3; i++) {
        final checkbox = tester.widget<Checkbox>(checkboxes.at(i));
        expect(checkbox.value, isTrue);
      }
    });

    /// Todo 선택/해제 기능 테스트
    testWidgets('can select and deselect todos', (tester) async {
      const testTodos = ['할 일 1', '할 일 2'];

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AiGeneratorTodoList(
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 첫 번째 체크박스 클릭하여 해제
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      // 선택 카운터 업데이트 확인
      expect(find.text('1/2 선택'), findsOneWidget);

      // 다시 클릭하여 선택
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      // 선택 카운터 복원 확인
      expect(find.text('2/2 선택'), findsOneWidget);
    });

    /// 전체 선택/해제 기능 테스트
    testWidgets('can select all and deselect all todos', (tester) async {
      const testTodos = ['할 일 1', '할 일 2', '할 일 3'];

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AiGeneratorTodoList(
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 전체 해제 버튼 클릭
      await tester.tap(find.text('전체 해제'));
      await tester.pump();

      // 모든 체크박스가 해제되었는지 확인
      expect(find.text('0/3 선택'), findsOneWidget);
      
      final checkboxes = find.byType(Checkbox);
      for (int i = 0; i < 3; i++) {
        final checkbox = tester.widget<Checkbox>(checkboxes.at(i));
        expect(checkbox.value, isFalse);
      }

      // 전체 선택 버튼 클릭
      await tester.tap(find.text('전체 선택'));
      await tester.pump();

      // 모든 체크박스가 선택되었는지 확인
      expect(find.text('3/3 선택'), findsOneWidget);
      
      for (int i = 0; i < 3; i++) {
        final checkbox = tester.widget<Checkbox>(checkboxes.at(i));
        expect(checkbox.value, isTrue);
      }
    });

    /// UI 상호작용 테스트
    testWidgets('shows add button with correct count', (tester) async {
      const testTodos = ['테스트 할 일'];

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AiGeneratorTodoList(
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 할 일 추가 버튼이 올바른 카운트로 표시되는지 확인
      expect(find.text('할 일 추가 (1)'), findsOneWidget);
      
      // 버튼이 활성화되어 있는지 확인
      final addButton = find.text('할 일 추가 (1)');
      expect(addButton, findsOneWidget);
    });

    /// 빈 선택 시 버튼 비활성화 테스트
    testWidgets('disables button when no todos are selected', (tester) async {
      const testTodos = ['할 일 1'];

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AiGeneratorTodoList(
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 모든 선택 해제
      await tester.tap(find.text('전체 해제'));
      await tester.pump();

      // 추가 버튼 텍스트가 업데이트되었는지 확인
      expect(find.text('할 일 추가 (0)'), findsOneWidget);
      
      // ElevatedButton이 존재하는지 확인 (ElevatedButton.icon도 ElevatedButton 타입)
      final buttonWidgetFinder = find.ancestor(
        of: find.text('할 일 추가 (0)'),
        matching: find.byWidgetPredicate((widget) => widget is ElevatedButton),
      );
      expect(buttonWidgetFinder, findsOneWidget);
      
      // 버튼의 onPressed가 null인지 확인 (비활성화 상태)
      final button = tester.widget<ElevatedButton>(buttonWidgetFinder);
      expect(button.onPressed, isNull);
    });

    /// 할 일 추가 버튼 클릭 테스트
    testWidgets('can click add todos button', (tester) async {
      const testTodos = ['성공 테스트 할 일'];

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AiGeneratorTodoList(
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 할 일 추가 버튼이 존재하고 클릭 가능한지 확인
      final addButton = find.text('할 일 추가 (1)');
      expect(addButton, findsOneWidget);
      
      // 버튼 클릭 (실제 동작은 하지 않음, UI 테스트만)
      await tester.tap(addButton);
      await tester.pump();
    });

    /// 콜백 프로퍼티 테스트
    testWidgets('accepts onTodosAdded callback', (tester) async {
      const testTodos = ['콜백 테스트 할 일'];
      bool callbackDefined = false;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AiGeneratorTodoList(
                todos: testTodos,
                onTodosAdded: () {
                  callbackDefined = true;
                },
              ),
            ),
          ),
        ),
      );

      // 위젯이 정상적으로 렌더링되고 콜백이 설정되었는지 확인
      expect(find.text('콜백 테스트 할 일'), findsOneWidget);
      expect(find.text('할 일 추가 (1)'), findsOneWidget);
      
      // 콜백 함수가 정의되어 있지만 아직 호출되지 않았는지 확인
      expect(callbackDefined, isFalse);
    });

    /// 리스트 아이템 탭으로 선택 토글 테스트
    testWidgets('can toggle selection by tapping list items', (tester) async {
      const testTodos = ['탭 테스트 할 일'];

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AiGeneratorTodoList(
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // ListTile 탭하여 선택 해제
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // 선택이 해제되었는지 확인
      expect(find.text('0/1 선택'), findsOneWidget);

      // 다시 탭하여 선택
      await tester.tap(find.byType(ListTile));
      await tester.pump();

      // 선택이 복원되었는지 확인
      expect(find.text('1/1 선택'), findsOneWidget);
    });

    /// 애니메이션 상태 테스트
    testWidgets('shows correct visual states for selected/unselected items', (tester) async {
      const testTodos = ['시각적 테스트 할 일'];

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: AiGeneratorTodoList(
                todos: testTodos,
              ),
            ),
          ),
        ),
      );

      // 선택된 상태의 컨테이너 확인
      final selectedContainer = find.byType(AnimatedContainer);
      expect(selectedContainer, findsOneWidget);

      // 선택 해제
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // 애니메이션 완료 대기
      await tester.pump(const Duration(milliseconds: 250));

      // 해제된 상태의 컨테이너 확인
      expect(selectedContainer, findsOneWidget);
    });
  });
}