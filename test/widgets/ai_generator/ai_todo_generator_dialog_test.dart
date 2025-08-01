/// **AI Todo Generator Dialog 테스트**
/// 
/// AiTodoGeneratorDialog의 콜백 전파 시스템과 상태 관리를 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:todo_bloc/widgets/ai_generator/ai_todo_generator_dialog.dart';
import 'package:todo_bloc/core/providers/ai_todo_provider.dart';
import 'package:todo_bloc/services/ai_todo_generator_service.dart';
import 'package:todo_bloc/model/todo_item.dart';

import 'ai_todo_generator_dialog_test.mocks.dart';

@GenerateMocks([AiTodoGeneratorService])
void main() {
  group('AiTodoGeneratorDialog', () {
    late MockAiTodoGeneratorService mockAiService;
    late ProviderContainer container;
    
    setUp(() {
      mockAiService = MockAiTodoGeneratorService();
      
      // Mock Provider 설정
      container = ProviderContainer(
        overrides: [
          aiTodoGeneratorProvider.overrideWith(
            () => TestAiTodoNotifier(const AsyncValue.data(null)),
          ),
          isAiGeneratingProvider.overrideWith(
            (ref) => false,
          ),
          aiGenerationErrorProvider.overrideWith(
            (ref) => null,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    /// 기본 다이얼로그 렌더링 테스트
    testWidgets('renders dialog with all components', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AiTodoGeneratorDialog(),
          ),
        ),
      );

      // 다이얼로그 컴포넌트들 확인
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('AI 생성'), findsAtLeastNWidgets(1)); // 버튼에도 있음
      expect(find.text('닫기'), findsOneWidget);
      
      // 빈 상태 메시지 확인
      expect(find.text('AI에게 할 일을 요청해보세요'), findsOneWidget);
      expect(find.textContaining('예: "내일 프레젠테이션'), findsAtLeastNWidgets(1));
    });

    /// 콜백 전파 테스트
    testWidgets('propagates onTodosAdded callback to child components', (tester) async {
      bool callbackTriggered = false;

      // 생성된 할 일이 있는 상태로 설정
      final testTodos = [
        TodoItem(title: '테스트 할 일 1', priority: 'Medium', isCompleted: false, dueDate: DateTime.now()),
        TodoItem(title: '테스트 할 일 2', priority: 'Medium', isCompleted: false, dueDate: DateTime.now()),
      ];
      
      final containerWithData = ProviderContainer(
        overrides: [
          aiTodoGeneratorProvider.overrideWith(
            () => TestAiTodoNotifier(AsyncValue.data(testTodos)),
          ),
          isAiGeneratingProvider.overrideWith(
            (ref) => false,
          ),
          aiGenerationErrorProvider.overrideWith(
            (ref) => null,
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: containerWithData,
          child: MaterialApp(
            home: AiTodoGeneratorDialog(
              onTodosAdded: () {
                callbackTriggered = true;
              },
            ),
          ),
        ),
      );

      // AiGeneratorTodoList가 렌더링되었는지 확인 (TodoItem.title로 표시됨)
      expect(find.text('테스트 할 일 1'), findsOneWidget);
      expect(find.text('테스트 할 일 2'), findsOneWidget);

      // 할 일 추가 버튼 클릭
      await tester.tap(find.text('할 일 추가 (2)'));
      await tester.pump();
      
      // 비동기 작업 완료 대기
      await tester.pump(const Duration(milliseconds: 100));

      // 콜백이 호출되었는지 확인
      expect(callbackTriggered, isTrue);
      
      containerWithData.dispose();
    });

    /// 로딩 상태 표시 테스트
    testWidgets('shows loading state correctly', (tester) async {
      final loadingContainer = ProviderContainer(
        overrides: [
          isAiGeneratingProvider.overrideWith(
            (ref) => true,
          ),
          aiTodoGeneratorProvider.overrideWith(
            () => TestAiTodoNotifier(const AsyncValue.loading()),
          ),
          aiGenerationErrorProvider.overrideWith(
            (ref) => null,
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: loadingContainer,
          child: const MaterialApp(
            home: AiTodoGeneratorDialog(),
          ),
        ),
      );

      // 로딩 상태 확인
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('AI가 할 일 목록을 생성하고 있습니다...'), findsOneWidget);
      expect(find.text('잠시만 기다려주세요'), findsOneWidget);

      loadingContainer.dispose();
    });

    /// 에러 상태 표시 테스트
    testWidgets('shows error state correctly', (tester) async {
      const errorMessage = '네트워크 연결 오류';
      
      final errorContainer = ProviderContainer(
        overrides: [
          isAiGeneratingProvider.overrideWith(
            (ref) => false,
          ),
          aiTodoGeneratorProvider.overrideWith(
            () => TestAiTodoNotifier(AsyncValue.error(errorMessage, StackTrace.current)),
          ),
          aiGenerationErrorProvider.overrideWith(
            (ref) => errorMessage,
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: errorContainer,
          child: const MaterialApp(
            home: AiTodoGeneratorDialog(),
          ),
        ),
      );

      // 에러 상태 확인
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('AI 생성 중 오류가 발생했습니다'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);

      errorContainer.dispose();
    });

    /// 텍스트 입력 및 생성 버튼 테스트
    testWidgets('handles text input and generate button', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AiTodoGeneratorDialog(),
          ),
        ),
      );

      // 텍스트 필드 찾기
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // 텍스트 입력
      await tester.enterText(textField, '운동 계획 세우기');
      await tester.pump();

      // AI 생성 버튼 클릭
      await tester.tap(find.text('AI 생성').last); // 하단 버튼
      await tester.pump();

      // 버튼이 비활성화되는지 확인하기 위해 상태 변경 시뮬레이션
      // (실제 AI 호출은 Mock으로 대체되어야 함)
    });

    /// 빈 입력으로 생성 시도 시 경고 테스트
    testWidgets('shows warning for empty input', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AiTodoGeneratorDialog(),
          ),
        ),
      );

      // 빈 입력으로 AI 생성 버튼 클릭
      await tester.tap(find.text('AI 생성').last);
      await tester.pump();

      // 경고 스낵바 확인
      expect(find.text('요청 내용을 입력해주세요.'), findsOneWidget);
    });

    /// 다이얼로그 닫기 기능 테스트
    testWidgets('can close dialog with close button', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const AiTodoGeneratorDialog(),
                    ),
                    child: const Text('Open Dialog'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      // 다이얼로그 열기
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // 다이얼로그가 열렸는지 확인
      expect(find.byType(AiTodoGeneratorDialog), findsOneWidget);

      // 닫기 버튼 클릭
      await tester.tap(find.text('닫기'));
      await tester.pumpAndSettle();

      // 다이얼로그가 닫혔는지 확인
      expect(find.byType(AiTodoGeneratorDialog), findsNothing);
    });

    /// 다시 시도 버튼 기능 테스트
    testWidgets('retry button clears error state', (tester) async {
      const errorMessage = '테스트 에러';
      bool retryCallbackCalled = false;
      
      final errorContainer = ProviderContainer(
        overrides: [
          isAiGeneratingProvider.overrideWith(
            (ref) => false,
          ),
          aiTodoGeneratorProvider.overrideWith(
            () => TestAiTodoNotifier(const AsyncValue.data(null)),
          ),
          aiGenerationErrorProvider.overrideWith(
            (ref) => errorMessage,
          ),
          // Mock notifier for retry action
          aiTodoGeneratorProvider.overrideWith(
            () => TestAiTodoNotifier(AsyncValue.error(errorMessage, StackTrace.current), onClearGenerated: () => retryCallbackCalled = true),
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: errorContainer,
          child: const MaterialApp(
            home: AiTodoGeneratorDialog(),
          ),
        ),
      );

      // 다시 시도 버튼 클릭
      await tester.tap(find.text('다시 시도'));
      await tester.pump();

      // 재시도 액션이 호출되었는지 확인
      expect(retryCallbackCalled, isTrue);

      errorContainer.dispose();
    });

    /// 포커스 자동 설정 테스트
    testWidgets('automatically focuses text field when opened', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: AiTodoGeneratorDialog(),
          ),
        ),
      );

      // 위젯이 빌드될 때까지 대기
      await tester.pumpAndSettle();

      // 텍스트 필드가 포커스를 받았는지 확인
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.focusNode?.hasFocus, isTrue);
    });
  });
}

/// Test AI Todo Notifier for testing
class TestAiTodoNotifier extends AiTodoGenerator {
  final AsyncValue<List<TodoItem>?> _initialState;
  final VoidCallback? onClearGenerated;
  
  TestAiTodoNotifier(this._initialState, {this.onClearGenerated});

  @override
  AsyncValue<List<TodoItem>?> build() => _initialState;

  @override
  void clearGeneratedTodos() {
    state = const AsyncValue.data(null);
    if (onClearGenerated != null) {
      onClearGenerated!();
    }
  }

  @override
  Future<void> generateTodos(String prompt) async {
    state = const AsyncValue.loading();
    // Mock implementation - will be controlled by test setup
  }
}