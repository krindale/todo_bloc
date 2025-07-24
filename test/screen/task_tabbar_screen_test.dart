import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_bloc/screen/tabbar/task_tabbar_screen.dart';

@GenerateMocks([FirebaseAuth, User])
import 'task_tabbar_screen_test.mocks.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUser = MockUser();
    when(mockUser.uid).thenReturn('test_user_tabbar');
    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
  });

  group('TaskTabbarScreen UI 테스트', () {
    testWidgets('기본 탭바 구조 테스트', (WidgetTester tester) async {
      // Given & When: TaskTabbarScreen 렌더링
      await tester.pumpWidget(
        MaterialApp(
          home: TaskTabbarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Then: 기본 UI 요소들이 표시되어야 함
      expect(find.text('Task Manager'), findsOneWidget);
      expect(find.text('Task List'), findsOneWidget);
      expect(find.text('Task Summary'), findsOneWidget);
      expect(find.text('Saved Links'), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('네비게이션 백버튼 제거 확인', (WidgetTester tester) async {
      // Given & When: TaskTabbarScreen 렌더링
      await tester.pumpWidget(
        MaterialApp(
          home: TaskTabbarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Then: AppBar에 백버튼이 없어야 함
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.automaticallyImplyLeading, false);
      expect(find.byType(BackButton), findsNothing);
    });

    testWidgets('팝업 메뉴 구조 테스트', (WidgetTester tester) async {
      // Given: TaskTabbarScreen 렌더링
      await tester.pumpWidget(
        MaterialApp(
          home: TaskTabbarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When: 팝업 메뉴 버튼 탭
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Then: 로그아웃 메뉴만 표시되어야 함 (업로드/다운로드 제거됨)
      expect(find.text('로그아웃'), findsOneWidget);
      expect(find.text('데이터 업로드'), findsNothing);
      expect(find.text('데이터 다운로드'), findsNothing);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('탭 전환 기능 테스트', (WidgetTester tester) async {
      // Given: TaskTabbarScreen 렌더링
      await tester.pumpWidget(
        MaterialApp(
          home: TaskTabbarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When: Task Summary 탭 선택
      await tester.tap(find.text('Task Summary'));
      await tester.pumpAndSettle();

      // Then: Task Summary 화면으로 전환되어야 함
      expect(find.text('Task Summary'), findsOneWidget);

      // When: Saved Links 탭 선택
      await tester.tap(find.text('Saved Links'));
      await tester.pumpAndSettle();

      // Then: Saved Links 화면으로 전환되어야 함
      expect(find.text('Saved Links'), findsOneWidget);

      // When: Task List 탭으로 다시 전환
      await tester.tap(find.text('Task List'));
      await tester.pumpAndSettle();

      // Then: Task List 화면으로 전환되어야 함
      expect(find.text('Task List'), findsOneWidget);
    });

    testWidgets('로그아웃 다이얼로그 없이 직접 처리 테스트', (WidgetTester tester) async {
      // Given: TaskTabbarScreen 렌더링
      await tester.pumpWidget(
        MaterialApp(
          home: TaskTabbarScreen(),
          routes: {
            '/login': (context) => Scaffold(body: Text('Login Screen')),
          },
        ),
      );
      await tester.pumpAndSettle();

      // When: 팝업 메뉴에서 로그아웃 선택
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('로그아웃'));
      await tester.pumpAndSettle();

      // Then: 로그인 화면으로 이동해야 함
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('TabBar와 TabBarView 연동 테스트', (WidgetTester tester) async {
      // Given: TaskTabbarScreen 렌더링
      await tester.pumpWidget(
        MaterialApp(
          home: TaskTabbarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When & Then: TabBar와 TabBarView가 올바르게 연동되어야 함
      expect(find.byType(DefaultTabController), findsOneWidget);
      
      final defaultTabController = tester.widget<DefaultTabController>(
        find.byType(DefaultTabController)
      );
      expect(defaultTabController.length, 3);

      // 각 탭의 내용이 올바르게 표시되는지 확인
      final tabBar = tester.widget<TabBar>(find.byType(TabBar));
      expect(tabBar.tabs.length, 3);
    });

    testWidgets('AppBar 액션 버튼 레이아웃 테스트', (WidgetTester tester) async {
      // Given: TaskTabbarScreen 렌더링
      await tester.pumpWidget(
        MaterialApp(
          home: TaskTabbarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When & Then: AppBar에 PopupMenuButton만 있어야 함
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions?.length, 1);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('팝업 메뉴 아이콘 및 텍스트 확인', (WidgetTester tester) async {
      // Given: TaskTabbarScreen 렌더링
      await tester.pumpWidget(
        MaterialApp(
          home: TaskTabbarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When: 팝업 메뉴 열기
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Then: 로그아웃 메뉴 아이템의 구조 확인
      expect(find.byIcon(Icons.logout), findsOneWidget);
      expect(find.text('로그아웃'), findsOneWidget);
      expect(find.byType(Row), findsWidgets); // PopupMenuItem 내부의 Row
    });

    testWidgets('탭 순서 및 내용 확인', (WidgetTester tester) async {
      // Given: TaskTabbarScreen 렌더링
      await tester.pumpWidget(
        MaterialApp(
          home: TaskTabbarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When & Then: 탭의 순서가 올바른지 확인
      final tabTexts = ['Task List', 'Task Summary', 'Saved Links'];
      for (int i = 0; i < tabTexts.length; i++) {
        expect(find.text(tabTexts[i]), findsOneWidget);
      }

      // TabBarView의 children 확인
      expect(find.byType(TabBarView), findsOneWidget);
    });

    testWidgets('반응형 레이아웃 테스트', (WidgetTester tester) async {
      // Given: 다양한 화면 크기로 테스트
      await tester.binding.setSurfaceSize(Size(800, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          home: TaskTabbarScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // When & Then: 큰 화면에서도 레이아웃이 올바르게 표시되어야 함
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(TabBar), findsOneWidget);

      // 화면 크기 복원
      await tester.binding.setSurfaceSize(null);
    });
  });

  tearDown(() {
    // 각 테스트 후 정리 작업
  });
}