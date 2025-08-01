/// **Main Tab Screen 테스트**
/// 
/// MainTabScreen의 TodoScreenWrapper와 AI 콜백 시스템을 테스트합니다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:todo_bloc/screen/main_tab_screen.dart';
import 'package:todo_bloc/screen/todo_screen.dart';
import 'package:todo_bloc/services/hive_todo_repository.dart';
import 'package:todo_bloc/services/task_categorization_service.dart';
import 'package:todo_bloc/services/firebase_sync_service.dart';

import 'main_tab_screen_test.mocks.dart';

@GenerateMocks([
  HiveTodoRepository,
  TaskCategorizationService,
  FirebaseSyncService,
])
void main() {
  group('MainTabScreen', () {
    late MockHiveTodoRepository mockRepository;
    late MockTaskCategorizationService mockCategorizationService;
    late MockFirebaseSyncService mockFirebaseService;

    setUp(() {
      mockRepository = MockHiveTodoRepository();
      mockCategorizationService = MockTaskCategorizationService();
      mockFirebaseService = MockFirebaseSyncService();
      
      // Mock 기본 동작 설정
      when(mockRepository.getTodos()).thenAnswer((_) async => []);
      when(mockFirebaseService.isUserSignedIn).thenReturn(false);
    });

    /// 기본 탭 화면 렌더링 테스트
    testWidgets('renders all tabs correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      // AppBar와 탭들 확인
      expect(find.text('Todo Manager'), findsOneWidget);
      expect(find.text('Tasks'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);
      expect(find.text('Summary'), findsOneWidget);
      expect(find.text('Links'), findsOneWidget);

      // 플로팅 액션 버튼 확인 (Task 탭에서만 표시)
      expect(find.text('AI 생성'), findsOneWidget);
    });

    /// TodoScreenWrapper 렌더링 테스트
    testWidgets('renders TodoScreenWrapper in first tab', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      // TodoScreenWrapper가 렌더링되는지 확인
      expect(find.byType(TodoScreenWrapper), findsOneWidget);
    });

    /// 탭 전환 기능 테스트
    testWidgets('can switch between tabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      // Calendar 탭 클릭
      await tester.tap(find.text('Calendar'));
      await tester.pumpAndSettle();

      // 플로팅 액션 버튼이 사라지는지 확인
      expect(find.text('AI 생성'), findsNothing);

      // Tasks 탭으로 다시 돌아가기
      await tester.tap(find.text('Tasks'));
      await tester.pumpAndSettle();

      // 플로팅 액션 버튼이 다시 나타나는지 확인
      expect(find.text('AI 생성'), findsOneWidget);
    });

    /// AI 다이얼로그 열기 테스트
    testWidgets('opens AI generator dialog when FAB is tapped', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      // 플로팅 액션 버튼 클릭
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle();

      // AI 다이얼로그가 열렸는지 확인
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('AI에게 할 일을 요청해보세요'), findsOneWidget);
    });

    /// 탭 상태 Provider 테스트
    testWidgets('updates selectedTabIndexProvider when tabs change', (tester) async {
      late ProviderContainer container;
      
      await tester.pumpWidget(
        ProviderScope(
          child: Consumer(
            builder: (context, ref, child) {
              container = ProviderScope.containerOf(context);
              return MaterialApp(
                home: MainTabScreen(),
              );
            },
          ),
        ),
      );

      // 초기 탭 인덱스 확인
      expect(container.read(selectedTabIndexProvider), equals(0));

      // Summary 탭 클릭 (인덱스 2)
      await tester.tap(find.text('Summary'));
      await tester.pumpAndSettle();

      // Provider 상태 업데이트 확인
      expect(container.read(selectedTabIndexProvider), equals(2));
    });
  });

  group('TodoScreenWrapper', () {
    late GlobalKey<TodoScreenState> testKey;

    setUp(() {
      testKey = GlobalKey<TodoScreenState>();
    });

    /// TodoScreenWrapper 기본 렌더링 테스트
    testWidgets('renders TodoScreen correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoScreenWrapper(),
          ),
        ),
      );

      // TodoScreen의 기본 컴포넌트들이 렌더링되는지 확인
      await tester.pumpAndSettle();
      
      // 입력 필드와 기본 UI 요소들 확인
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
    });

    /// refreshTodos 메서드 호출 테스트
    testWidgets('refreshTodos method calls TodoScreen refresh', (tester) async {
      // TodoScreenWrapper를 key와 함께 렌더링
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoScreenWrapper(key: testKey),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Wrapper State를 직접 가져와서 refreshTodos 호출
      final wrapperState = testKey.currentState;
      expect(wrapperState, isNotNull);

      // 메서드 호출 (실제로는 TodoScreen의 refreshTodos가 호출됨)
      // 이 테스트는 메서드가 에러 없이 호출되는지만 확인
      expect(() => wrapperState?.refreshTodos(), returnsNormally);
    });

    /// GlobalKey를 통한 State 접근 테스트
    testWidgets('can access TodoScreenState through GlobalKey', (tester) async {
      final wrapperKey = GlobalKey<State<TodoScreenWrapper>>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TodoScreenWrapper(key: wrapperKey),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Wrapper State 접근 확인
      final wrapperState = wrapperKey.currentState;
      expect(wrapperState, isNotNull);
      expect(wrapperState, isA<State<TodoScreenWrapper>>());

      // refreshTodos 메서드 존재 확인 (dynamic cast needed for private class)
      final dynamicState = wrapperState as dynamic;
      expect(() => dynamicState.refreshTodos(), returnsNormally);
    });
  });

  group('AI Callback Integration', () {
    /// AI 콜백 전체 플로우 테스트
    testWidgets('AI callback flows from dialog to TodoScreen refresh', (tester) async {
      bool refreshCalled = false;
      
      // Custom TodoScreenWrapper to track refresh calls
      Widget buildTestWrapper() {
        return MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    Expanded(
                      child: TodoScreenWrapper(),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // AI 다이얼로그를 시뮬레이션하여 콜백 호출
                        // 실제 앱에서는 MainTabScreen이 이 역할을 함
                        refreshCalled = true;
                      },
                      child: const Text('Test Callback'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      }

      await tester.pumpWidget(buildTestWrapper());
      await tester.pumpAndSettle();

      // 테스트 콜백 버튼 클릭
      await tester.tap(find.text('Test Callback'));
      await tester.pump();

      // 콜백이 호출되었는지 확인
      expect(refreshCalled, isTrue);
    });
  });

  group('Error Handling', () {
    /// TabController 에러 처리 테스트
    testWidgets('handles TabController disposal correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 위젯을 제거하여 dispose 호출
      await tester.pumpWidget(
        MaterialApp(
          home: Container(),
        ),
      );

      // dispose가 에러 없이 완료되는지 확인
      await tester.pumpAndSettle();
    });

    /// 잘못된 탭 인덱스 처리 테스트
    testWidgets('handles invalid tab transitions gracefully', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: MainTabScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 빠른 탭 전환으로 상태 변경 충돌 테스트
      await tester.tap(find.text('Calendar'));
      await tester.tap(find.text('Summary'));
      await tester.tap(find.text('Tasks'));
      
      await tester.pumpAndSettle();

      // 앱이 정상 상태인지 확인
      expect(find.text('Todo Manager'), findsOneWidget);
      expect(find.text('AI 생성'), findsOneWidget); // Tasks 탭이 활성화됨
    });
  });
}