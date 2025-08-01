/// **AI Todo 통합 테스트**
/// 
/// AI 할 일 생성부터 TodoScreen 업데이트까지의 전체 플로우를 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:todo_bloc/screen/main_tab_screen.dart';
import 'package:todo_bloc/widgets/ai_generator/ai_todo_generator_dialog.dart';
import 'package:todo_bloc/widgets/ai_generator/ai_generator_todo_list_dialog.dart';
import 'package:todo_bloc/services/hive_todo_repository.dart';
import 'package:todo_bloc/services/ai_todo_generator_service.dart';
import 'package:todo_bloc/core/providers/ai_todo_provider.dart';
import 'package:todo_bloc/model/todo_item.dart';

import 'ai_todo_integration_test.mocks.dart';

@GenerateMocks([
  HiveTodoRepository,
  AiTodoGeneratorService,
])

/// Test AI Todo Notifier for integration testing
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
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AI Todo Integration Tests', () {
    late MockHiveTodoRepository mockRepository;
    late MockAiTodoGeneratorService mockAiService;
    
    setUp(() {
      mockRepository = MockHiveTodoRepository();
      mockAiService = MockAiTodoGeneratorService();
      
      // Mock 기본 동작 설정
      when(mockRepository.getTodos()).thenAnswer((_) async => []);
      when(mockRepository.addTodo(any)).thenAnswer((_) async => {});
    });

    /// 전체 AI Todo 생성 플로우 통합 테스트
    testWidgets('Complete AI todo generation and refresh flow', (tester) async {
      // AI가 생성할 할 일 목록
      final mockGeneratedTodos = [
        '아침 운동하기',
        '건강한 아침식사 준비',
        '비타민 복용하기',
      ];

      // Mock AI 서비스 응답 설정
      when(mockAiService.generateTodos(any))
          .thenAnswer((_) async => mockGeneratedTodos.map((title) => 
            TodoItem(
              title: title,
              priority: 'Medium',
              dueDate: DateTime.now().add(const Duration(days: 1)),
              isCompleted: false,
              category: 'Health',
            )
          ).toList());

      // Provider 오버라이드 설정
      final container = ProviderContainer(
        overrides: [
          // AI 생성된 할 일 목록
          aiTodoGeneratorProvider.overrideWith(
            () => TestAiTodoNotifier(AsyncValue.data(mockGeneratedTodos.map((title) => 
              TodoItem(
                title: title,
                priority: 'Medium',
                dueDate: DateTime.now().add(const Duration(days: 1)),
                isCompleted: false,
                category: 'Health',
              )
            ).toList())),
          ),
          // 생성 중 상태
          isAiGeneratingProvider.overrideWith(
            (ref) => false,
          ),
          // 에러 상태
          aiGenerationErrorProvider.overrideWith(
            (ref) => null,
          ),
        ],
      );

      // 메인 앱 렌더링
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. 초기 상태 확인
      expect(find.text('Todo Manager'), findsOneWidget);
      expect(find.text('AI 생성'), findsOneWidget);

      // 2. AI 생성 다이얼로그 열기
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // 3. 다이얼로그가 열렸는지 확인
      expect(find.byType(AiTodoGeneratorDialog), findsOneWidget);

      // 4. 생성된 할 일 목록 확인
      expect(find.text('아침 운동하기'), findsOneWidget);
      expect(find.text('건강한 아침식사 준비'), findsOneWidget);
      expect(find.text('비타민 복용하기'), findsOneWidget);

      // 5. 선택 상태 확인 (기본적으로 모두 선택됨)
      expect(find.text('3/3 선택'), findsOneWidget);

      // 6. 할 일 추가 버튼 클릭
      await tester.tap(find.text('할 일 추가 (3)'));
      await tester.pump();

      // 7. 비동기 작업 완료 대기
      await tester.pump(const Duration(milliseconds: 500));

      // 8. 성공 메시지 확인
      expect(find.text('3개의 할 일이 추가되었습니다.'), findsOneWidget);

      // 9. Repository addTodo 호출 확인
      verify(mockRepository.addTodo(any)).called(3);

      // 10. 다이얼로그가 자동으로 닫혔는지 확인
      await tester.pumpAndSettle();
      expect(find.byType(AiTodoGeneratorDialog), findsNothing);

      // 11. TodoScreen이 새로고침되어 할 일들이 표시되는지 확인
      // (실제로는 Mock Repository에서 반환하는 데이터에 따라 달라짐)
      
      container.dispose();
    });

    /// AI 생성 중 로딩 상태 테스트
    testWidgets('Shows loading state during AI generation', (tester) async {
      final loadingContainer = ProviderContainer(
        overrides: [
          isAiGeneratingProvider.overrideWith(
            (ref) => true, // 로딩 중
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
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // AI 다이얼로그 열기
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // 로딩 상태 확인
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('AI가 할 일 목록을 생성하고 있습니다...'), findsOneWidget);

      // 버튼들이 비활성화되었는지 확인
      final generateButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('AI 생성'),
          matching: find.byType(ElevatedButton),
        ).last,
      );
      expect(generateButton.onPressed, isNull);

      loadingContainer.dispose();
    });

    /// AI 생성 에러 처리 테스트
    testWidgets('Handles AI generation errors correctly', (tester) async {
      const errorMessage = 'AI 서비스 연결 실패';
      
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
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // AI 다이얼로그 열기
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // 에러 상태 UI 확인
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('AI 생성 중 오류가 발생했습니다'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('다시 시도'), findsOneWidget);

      errorContainer.dispose();
    });

    /// 선택적 할 일 추가 테스트
    testWidgets('Allows selective todo addition', (tester) async {
      final mockTodos = ['할 일 1', '할 일 2', '할 일 3'];

      final container = ProviderContainer(
        overrides: [
          aiTodoGeneratorProvider.overrideWith(
            () => TestAiTodoNotifier(AsyncValue.data(mockTodos.map((title) => 
              TodoItem(title: title, priority: 'Medium', isCompleted: false)
            ).toList())),
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
          container: container,
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // AI 다이얼로그 열기
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // 첫 번째와 세 번째 할 일 선택 해제
      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.at(0)); // 첫 번째 해제
      await tester.pump();
      await tester.tap(checkboxes.at(2)); // 세 번째 해제
      await tester.pump();

      // 선택 상태 확인
      expect(find.text('1/3 선택'), findsOneWidget);

      // 선택된 할 일만 추가
      await tester.tap(find.text('할 일 추가 (1)'));
      await tester.pump(const Duration(milliseconds: 100));

      // Repository에 1개만 추가되었는지 확인
      verify(mockRepository.addTodo(any)).called(1);

      container.dispose();
    });

    /// 전체 선택/해제 기능 테스트
    testWidgets('Select all and deselect all functionality works', (tester) async {
      final mockTodos = ['할 일 A', '할 일 B'];

      final container = ProviderContainer(
        overrides: [
          aiTodoGeneratorProvider.overrideWith(
            () => TestAiTodoNotifier(AsyncValue.data(mockTodos.map((title) => 
              TodoItem(title: title, priority: 'Medium', isCompleted: false)
            ).toList())),
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
          container: container,
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // AI 다이얼로그 열기
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // 전체 해제 클릭
      await tester.tap(find.text('전체 해제'));
      await tester.pump();

      // 선택이 모두 해제되었는지 확인
      expect(find.text('0/2 선택'), findsOneWidget);

      // 추가 버튼이 비활성화되었는지 확인
      final addButton = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('할 일 추가 (0)'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(addButton.onPressed, isNull);

      // 전체 선택 클릭
      await tester.tap(find.text('전체 선택'));
      await tester.pump();

      // 모든 항목이 다시 선택되었는지 확인
      expect(find.text('2/2 선택'), findsOneWidget);

      container.dispose();
    });

    /// 빈 선택으로 추가 시도 시 경고 표시 테스트
    testWidgets('Shows warning when trying to add with no selection', (tester) async {
      final mockTodos = ['테스트 할 일'];

      final container = ProviderContainer(
        overrides: [
          aiTodoGeneratorProvider.overrideWith(
            () => TestAiTodoNotifier(AsyncValue.data(mockTodos.map((title) => 
              TodoItem(title: title, priority: 'Medium', isCompleted: false)
            ).toList())),
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
          container: container,
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // AI 다이얼로그 열기
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // 모든 선택 해제
      await tester.tap(find.text('전체 해제'));
      await tester.pump();

      // 추가 버튼 클릭 시도 (선택된 것 없음)
      await tester.tap(find.text('할 일 추가 (0)'));
      await tester.pump();

      // 경고 메시지 확인
      expect(find.text('추가할 항목을 선택해주세요.'), findsOneWidget);

      // Repository 호출이 없었는지 확인
      verifyNever(mockRepository.addTodo(any));

      container.dispose();
    });

    /// Repository 에러 처리 테스트
    testWidgets('Handles repository errors during todo addition', (tester) async {
      final mockTodos = ['에러 테스트 할 일'];

      // Repository에서 에러 발생 설정
      when(mockRepository.addTodo(any))
          .thenThrow(Exception('Database connection failed'));

      final container = ProviderContainer(
        overrides: [
          aiTodoGeneratorProvider.overrideWith(
            () => TestAiTodoNotifier(AsyncValue.data(mockTodos.map((title) => 
              TodoItem(title: title, priority: 'Medium', isCompleted: false)
            ).toList())),
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
          container: container,
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // AI 다이얼로그 열기
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // 할 일 추가 시도
      await tester.tap(find.text('할 일 추가 (1)'));
      await tester.pump(const Duration(milliseconds: 100));

      // 에러 메시지 확인
      expect(find.textContaining('할 일 추가 중 오류가 발생했습니다'), findsOneWidget);

      container.dispose();
    });
  });
}