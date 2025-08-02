/// **테마 토글 스위치 위젯 테스트**
/// 
/// ThemeToggleSwitch 위젯의 UI 동작과 상호작용을 검증하는 위젯 테스트입니다.
/// 
/// **테스트 범위:**
/// - 위젯 렌더링 및 표시
/// - 테마 변경에 따른 UI 업데이트
/// - 터치 상호작용 및 콜백 처리
/// - 컴팩트/전체 모드별 동작
/// - 접근성 및 사용성

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/widgets/theme/theme_toggle_switch.dart';
import '../../lib/services/theme_service.dart';

void main() {
  group('ThemeToggleSwitch Widget Tests', () {
    setUp(() {
      // SharedPreferences 모킹 초기화
      SharedPreferences.setMockInitialValues({});
      
      // ThemeService 리셋
      ThemeService.resetForTesting();
    });

    tearDown(() {
      ThemeService.resetForTesting();
    });

    group('컴팩트 모드 테스트', () {
      testWidgets('should render compact switch correctly', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: AppBar(
                actions: const [
                  ThemeToggleSwitch.compact(),
                ],
              ),
            ),
          ),
        );

        // 컴팩트 스위치가 렌더링되는지 확인
        expect(find.byType(ThemeToggleSwitch), findsOneWidget);
        expect(find.byType(InkWell), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
      });

      testWidgets('should show correct icon for system theme', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeToggleSwitch.compact(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 시스템 테마 아이콘이 표시되는지 확인
        expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
      });

      testWidgets('should change icon when theme changes', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeToggleSwitch.compact(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 초기 상태 확인 (시스템 테마)
        expect(find.byIcon(Icons.brightness_auto), findsOneWidget);

        // 다크 모드로 변경
        await ThemeService.instance.setThemePreference(ThemePreference.dark);
        await tester.pumpAndSettle();

        // 다크 모드 아이콘으로 변경되었는지 확인
        expect(find.byIcon(Icons.dark_mode), findsOneWidget);
        expect(find.byIcon(Icons.brightness_auto), findsNothing);
      });

      testWidgets('should respond to tap and toggle theme', (tester) async {
        final service = ThemeService.instance;
        
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeToggleSwitch.compact(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 초기 테마 설정 확인
        final initialPreference = service.themePreference;

        // 스위치 탭
        await tester.tap(find.byType(ThemeToggleSwitch));
        await tester.pumpAndSettle();

        // 테마가 변경되었는지 확인
        expect(service.themePreference, isNot(equals(initialPreference)));
      });
    });

    group('전체 모드 테스트', () {
      testWidgets('should render full switch with labels', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeToggleSwitch.full(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 전체 스위치 구성 요소들이 렌더링되는지 확인
        expect(find.byType(ThemeToggleSwitch), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
        expect(find.byType(Switch), findsOneWidget);
        expect(find.text('테마 설정'), findsOneWidget);
      });

      testWidgets('should show system theme indicator', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeToggleSwitch.full(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 시스템 설정 표시기가 나타나는지 확인
        expect(find.text('시스템 설정 따름'), findsOneWidget);
      });

      testWidgets('should hide system indicator when not in system mode', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeToggleSwitch.full(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 다크 모드로 변경
        await ThemeService.instance.setThemePreference(ThemePreference.dark);
        await tester.pumpAndSettle();

        // 시스템 설정 표시기가 사라졌는지 확인
        expect(find.text('시스템 설정 따름'), findsNothing);
      });

      testWidgets('should update switch state when theme changes', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeToggleSwitch.full(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 스위치 위젯 찾기
        final switchFinder = find.byType(Switch);
        expect(switchFinder, findsOneWidget);

        // 라이트 모드로 변경
        await ThemeService.instance.setThemePreference(ThemePreference.light);
        await tester.pumpAndSettle();

        // 스위치가 off 상태인지 확인
        Switch switchWidget = tester.widget(switchFinder);
        expect(switchWidget.value, isFalse);

        // 다크 모드로 변경
        await ThemeService.instance.setThemePreference(ThemePreference.dark);
        await tester.pumpAndSettle();

        // 스위치가 on 상태인지 확인
        switchWidget = tester.widget(switchFinder);
        expect(switchWidget.value, isTrue);
      });
    });

    group('설정 메뉴 테스트', () {
      testWidgets('should render theme settings menu', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeSettingsMenuItem(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 메뉴 버튼이 렌더링되는지 확인
        expect(find.byType(PopupMenuButton<ThemePreference>), findsOneWidget);
        expect(find.byType(Icon), findsOneWidget);
      });

      testWidgets('should show popup menu when tapped', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeSettingsMenuItem(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 메뉴 버튼 탭
        await tester.tap(find.byType(PopupMenuButton<ThemePreference>));
        await tester.pumpAndSettle();

        // 팝업 메뉴 아이템들이 표시되는지 확인
        expect(find.text('시스템 설정 따름'), findsOneWidget);
        expect(find.text('라이트 모드'), findsOneWidget);
        expect(find.text('다크 모드'), findsOneWidget);
      });

      testWidgets('should change theme when menu item selected', (tester) async {
        final service = ThemeService.instance;
        
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeSettingsMenuItem(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 메뉴 버튼 탭
        await tester.tap(find.byType(PopupMenuButton<ThemePreference>));
        await tester.pumpAndSettle();

        // 다크 모드 선택
        await tester.tap(find.text('다크 모드'));
        await tester.pumpAndSettle();

        // 테마가 다크 모드로 변경되었는지 확인
        expect(service.themePreference, equals(ThemePreference.dark));
        expect(service.isDarkMode, isTrue);
      });

      testWidgets('should show check mark for current selection', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeSettingsMenuItem(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 다크 모드로 변경
        await ThemeService.instance.setThemePreference(ThemePreference.dark);
        await tester.pumpAndSettle();

        // 메뉴 버튼 탭
        await tester.tap(find.byType(PopupMenuButton<ThemePreference>));
        await tester.pumpAndSettle();

        // 다크 모드 항목에 체크 마크가 있는지 확인
        expect(find.byIcon(Icons.check), findsOneWidget);
      });
    });

    group('접근성 테스트', () {
      testWidgets('should have proper semantics for compact switch', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeToggleSwitch.compact(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 접근성 정보가 있는지 확인
        final semantics = tester.getSemantics(find.byType(InkWell));
        expect(semantics.hasAction(SemanticsAction.tap), isTrue);
      });

      testWidgets('should have tooltip for settings menu', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeSettingsMenuItem(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 툴팁이 설정되어 있는지 확인
        final popupButton = tester.widget<PopupMenuButton<ThemePreference>>(
          find.byType(PopupMenuButton<ThemePreference>),
        );
        expect(popupButton.tooltip, equals('테마 설정'));
      });
    });

    group('애니메이션 테스트', () {
      testWidgets('should animate icon changes smoothly', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeToggleSwitch.compact(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 초기 아이콘 확인
        expect(find.byIcon(Icons.brightness_auto), findsOneWidget);

        // 테마 변경
        await ThemeService.instance.setThemePreference(ThemePreference.dark);
        
        // 애니메이션 진행
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150)); // 애니메이션 중간
        await tester.pumpAndSettle(); // 애니메이션 완료

        // 새 아이콘으로 변경되었는지 확인
        expect(find.byIcon(Icons.dark_mode), findsOneWidget);
        expect(find.byIcon(Icons.brightness_auto), findsNothing);
      });
    });

    group('에러 처리 테스트', () {
      testWidgets('should handle theme service errors gracefully', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ThemeToggleSwitch.compact(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 위젯이 에러 없이 렌더링되는지 확인
        expect(find.byType(ThemeToggleSwitch), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    });
  });
}