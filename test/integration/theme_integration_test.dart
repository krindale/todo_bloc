/// **메인 앱 테마 통합 테스트**
/// 
/// 전체 앱에서 테마 시스템이 올바르게 작동하는지 검증하는 통합 테스트입니다.
/// 
/// **테스트 범위:**
/// - 앱 시작 시 테마 초기화
/// - 테마 전환 시 전체 UI 업데이트
/// - 시스템 테마 변경 감지
/// - 테마 설정 영속성
/// - 컴포넌트별 테마 적용

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/main.dart';
import '../../lib/services/theme_service.dart';
import '../../lib/theme/app_theme.dart';
import '../../lib/widgets/theme/theme_toggle_switch.dart';

void main() {
  group('Theme Integration Tests', () {
    setUp(() {
      // SharedPreferences 모킹 초기화
      SharedPreferences.setMockInitialValues({});
      
      // ThemeService 리셋
      ThemeService.resetForTesting();
    });

    tearDown(() {
      ThemeService.resetForTesting();
    });

    group('앱 초기화 테마 테스트', () {
      testWidgets('should start with system theme by default', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 앱이 시스템 테마로 시작하는지 확인
        final service = ThemeService.instance;
        expect(service.themePreference, equals(ThemePreference.system));
        expect(service.isInitialized, isTrue);
      });

      testWidgets('should load saved theme preference on startup', (tester) async {
        // 다크 모드를 미리 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('theme_preference', ThemePreference.dark.index);

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 저장된 다크 모드 설정이 로드되었는지 확인
        final service = ThemeService.instance;
        expect(service.themePreference, equals(ThemePreference.dark));
        expect(service.isDarkMode, isTrue);
      });

      testWidgets('should apply correct theme to MaterialApp', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // MaterialApp에 올바른 테마가 적용되었는지 확인
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.theme, equals(AppTheme.lightTheme));
        expect(materialApp.darkTheme, equals(AppTheme.darkTheme));
        expect(materialApp.themeMode, equals(ThemeMode.system));
      });
    });

    group('테마 전환 통합 테스트', () {
      testWidgets('should update entire app when theme changes', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 초기 테마 확인
        final service = ThemeService.instance;
        expect(service.themePreference, equals(ThemePreference.system));

        // 다크 모드로 변경
        await service.setThemePreference(ThemePreference.dark);
        await tester.pumpAndSettle();

        // MaterialApp의 테마 모드가 업데이트되었는지 확인
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.themeMode, equals(ThemeMode.dark));

        // 라이트 모드로 변경
        await service.setThemePreference(ThemePreference.light);
        await tester.pumpAndSettle();

        final updatedMaterialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(updatedMaterialApp.themeMode, equals(ThemeMode.light));
      });

      testWidgets('should persist theme changes across app restarts', (tester) async {
        // 첫 번째 앱 인스턴스
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 다크 모드로 변경
        final service = ThemeService.instance;
        await service.setThemePreference(ThemePreference.dark);
        await tester.pumpAndSettle();

        expect(service.themePreference, equals(ThemePreference.dark));

        // 앱 재시작 시뮬레이션
        ThemeService.resetForTesting();
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 설정이 유지되었는지 확인
        final newService = ThemeService.instance;
        expect(newService.themePreference, equals(ThemePreference.dark));
        expect(newService.isDarkMode, isTrue);
      });
    });

    group('UI 컴포넌트 테마 적용 테스트', () {
      testWidgets('should apply theme to navigation components', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // AppBar가 올바른 테마로 렌더링되는지 확인
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, equals(AppTheme.lightTheme.appBarTheme.backgroundColor));
        expect(appBar.foregroundColor, equals(AppTheme.lightTheme.appBarTheme.foregroundColor));

        // 다크 모드로 전환
        await ThemeService.instance.setThemePreference(ThemePreference.dark);
        await tester.pumpAndSettle();

        // AppBar 테마가 업데이트되었는지 확인
        final darkAppBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(darkAppBar.backgroundColor, equals(AppTheme.darkTheme.appBarTheme.backgroundColor));
        expect(darkAppBar.foregroundColor, equals(AppTheme.darkTheme.appBarTheme.foregroundColor));
      });

      testWidgets('should apply theme to toggle switch component', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 토글 스위치가 존재하는지 확인
        expect(find.byType(ThemeToggleSwitch), findsOneWidget);

        // 초기 상태에서 시스템 아이콘이 표시되는지 확인
        expect(find.byIcon(Icons.brightness_auto), findsOneWidget);

        // 토글 스위치 탭하여 테마 변경
        await tester.tap(find.byType(ThemeToggleSwitch));
        await tester.pumpAndSettle();

        // 아이콘이 변경되었는지 확인
        final service = ThemeService.instance;
        if (service.isDarkMode) {
          expect(find.byIcon(Icons.dark_mode), findsOneWidget);
        } else {
          expect(find.byIcon(Icons.light_mode), findsOneWidget);
        }
      });

      testWidgets('should apply theme to text components', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 텍스트 컴포넌트가 올바른 테마를 사용하는지 확인
        final context = tester.element(find.byType(MaterialApp));
        final lightTextTheme = Theme.of(context).textTheme;
        expect(lightTextTheme, equals(AppTheme.lightTheme.textTheme));

        // 다크 모드로 전환
        await ThemeService.instance.setThemePreference(ThemePreference.dark);
        await tester.pumpAndSettle();

        final darkTextTheme = Theme.of(context).textTheme;
        expect(darkTextTheme, equals(AppTheme.darkTheme.textTheme));
      });
    });

    group('시스템 테마 감지 테스트', () {
      testWidgets('should respond to system theme changes', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;
        
        // 시스템 모드로 설정
        await service.setThemePreference(ThemePreference.system);
        await tester.pumpAndSettle();

        expect(service.themePreference, equals(ThemePreference.system));

        // 시스템 테마 변경 시뮬레이션
        service.onSystemThemeChanged();
        await tester.pumpAndSettle();

        // 시스템 모드에서는 테마 설정이 그대로 유지되어야 함
        expect(service.themePreference, equals(ThemePreference.system));
      });

      testWidgets('should not respond to system changes when in manual mode', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;
        
        // 수동으로 다크 모드 설정
        await service.setThemePreference(ThemePreference.dark);
        await tester.pumpAndSettle();

        expect(service.themePreference, equals(ThemePreference.dark));
        expect(service.isDarkMode, isTrue);

        // 시스템 테마 변경 시뮬레이션
        service.onSystemThemeChanged();
        await tester.pumpAndSettle();

        // 수동 모드에서는 시스템 변경에 영향받지 않아야 함
        expect(service.themePreference, equals(ThemePreference.dark));
        expect(service.isDarkMode, isTrue);
      });
    });

    group('성능 및 안정성 테스트', () {
      testWidgets('should handle rapid theme changes without errors', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;

        // 빠른 테마 변경 시뮬레이션
        for (int i = 0; i < 10; i++) {
          await service.setThemePreference(ThemePreference.light);
          await tester.pump();
          
          await service.setThemePreference(ThemePreference.dark);
          await tester.pump();
          
          await service.setThemePreference(ThemePreference.system);
          await tester.pump();
        }

        await tester.pumpAndSettle();

        // 에러가 발생하지 않았는지 확인
        expect(tester.takeException(), isNull);
        expect(service.isInitialized, isTrue);
      });

      testWidgets('should maintain consistent state during theme changes', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;
        var notificationCount = 0;
        
        service.addListener(() {
          notificationCount++;
        });

        // 여러 테마 변경 수행
        await service.setThemePreference(ThemePreference.dark);
        await service.setThemePreference(ThemePreference.light);
        await service.setThemePreference(ThemePreference.system);

        await tester.pumpAndSettle();

        // 적절한 수의 알림이 발생했는지 확인
        expect(notificationCount, equals(3));
        expect(service.themePreference, equals(ThemePreference.system));
      });

      testWidgets('should handle invalid theme data gracefully', (tester) async {
        // 잘못된 테마 데이터로 SharedPreferences 설정
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('theme_preference', 999);

        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 앱이 에러 없이 시작되고 기본값으로 fallback 되었는지 확인
        expect(tester.takeException(), isNull);
        
        final service = ThemeService.instance;
        expect(service.themePreference, equals(ThemePreference.system));
        expect(service.isInitialized, isTrue);
      });
    });

    group('메모리 및 리소스 관리 테스트', () {
      testWidgets('should properly dispose resources on app termination', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;
        expect(service.isInitialized, isTrue);

        // 앱 종료 시뮬레이션
        ThemeService.resetForTesting();

        // 리소스가 정리되었는지 확인
        expect(ThemeService.instance, isNot(same(service)));
      });

      testWidgets('should not leak listeners on widget rebuild', (tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;

        // 위젯 리빌드 시뮬레이션 (여러 번)
        for (int i = 0; i < 5; i++) {
          await tester.pumpWidget(const MyApp());
          await tester.pumpAndSettle();
        }

        // 테마 변경 후 정상적으로 동작하는지 확인
        await service.setThemePreference(ThemePreference.dark);
        await tester.pumpAndSettle();

        expect(service.themePreference, equals(ThemePreference.dark));
        expect(tester.takeException(), isNull);
      });
    });
  });
}