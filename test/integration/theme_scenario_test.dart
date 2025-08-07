/// **테마 전환 시나리오 통합 테스트**
/// 
/// 실제 사용자 시나리오를 기반으로 한 테마 전환 동작을 검증하는 E2E 스타일 테스트입니다.
/// 
/// **테스트 시나리오:**
/// - 신규 사용자 첫 실행 시나리오
/// - 기존 사용자 재방문 시나리오
/// - 테마 전환 사용자 경험 시나리오
/// - 시스템 테마 변경 반응 시나리오
/// - 에러 복구 시나리오

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/main.dart';
import '../../lib/services/theme_service.dart';
import '../../lib/theme/app_theme.dart';
import '../../lib/widgets/theme/theme_toggle_switch.dart';
import '../../lib/screen/main_tab_screen.dart';

void main() {
  group('Theme Scenario Tests', () {
    setUp(() {
      // SharedPreferences 모킹 초기화
      SharedPreferences.setMockInitialValues({});
      
      // ThemeService 리셋
      ThemeService.resetForTesting();
    });

    tearDown(() {
      ThemeService.resetForTesting();
    });

    group('신규 사용자 시나리오', () {
      testWidgets('신규 사용자가 앱을 처음 실행할 때 시스템 테마가 적용되어야 함', (tester) async {
        // Given: 신규 사용자 (저장된 설정 없음)
        // When: 앱 실행
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Then: 시스템 테마가 기본으로 설정됨
        final service = ThemeService.instance;
        expect(service.themePreference, equals(ThemePreference.system));
        expect(service.isInitialized, isTrue);

        // 토글 스위치에 시스템 아이콘이 표시됨
        expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
      });

      testWidgets('신규 사용자가 다크모드로 첫 전환을 수행하는 시나리오', (tester) async {
        // Given: 신규 사용자가 앱을 실행
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;
        final initialPreference = service.themePreference;
        
        // When: 사용자가 토글 스위치를 탭하여 테마 변경
        await tester.tap(find.byType(ThemeToggleSwitch));
        await tester.pumpAndSettle();

        // Then: 테마가 변경되고 UI가 업데이트됨
        expect(service.themePreference, isNot(equals(initialPreference)));
        
        // 시각적 변화 확인 (아이콘 변경)
        if (service.isDarkMode) {
          expect(find.byIcon(Icons.dark_mode), findsOneWidget);
        } else {
          expect(find.byIcon(Icons.light_mode), findsOneWidget);
        }

        // 설정이 저장되었는지 확인
        final prefs = await SharedPreferences.getInstance();
        final savedPreference = prefs.getInt('theme_preference');
        expect(savedPreference, equals(service.themePreference.index));
      });
    });

    group('기존 사용자 시나리오', () {
      testWidgets('다크모드를 사용하던 사용자가 앱을 재실행하는 시나리오', (tester) async {
        // Given: 이전에 다크모드를 설정한 사용자
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('theme_preference', ThemePreference.dark.index);

        // When: 앱 재실행
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Then: 이전 설정(다크모드)이 복원됨
        final service = ThemeService.instance;
        expect(service.themePreference, equals(ThemePreference.dark));
        expect(service.isDarkMode, isTrue);

        // UI가 다크모드로 렌더링됨
        expect(find.byIcon(Icons.dark_mode), findsOneWidget);
        
        // MaterialApp이 다크 테마 모드로 설정됨
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.themeMode, equals(ThemeMode.dark));
      });

      testWidgets('라이트모드 사용자가 시스템 모드로 변경하는 시나리오', (tester) async {
        // Given: 라이트모드를 사용하던 사용자
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('theme_preference', ThemePreference.light.index);
        
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;
        expect(service.themePreference, equals(ThemePreference.light));

        // When: 시스템 설정으로 되돌리기
        await service.useSystemTheme();
        await tester.pumpAndSettle();

        // Then: 시스템 테마로 변경됨
        expect(service.themePreference, equals(ThemePreference.system));
        expect(find.byIcon(Icons.brightness_auto), findsOneWidget);

        // MaterialApp이 시스템 테마 모드로 설정됨
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.themeMode, equals(ThemeMode.system));
      });
    });

    group('연속적인 테마 전환 시나리오', () {
      testWidgets('사용자가 여러 번 연속으로 테마를 전환하는 시나리오', (tester) async {
        // Given: 앱이 실행된 상태
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;
        final changeSequence = <ThemePreference>[];

        service.addListener(() {
          changeSequence.add(service.themePreference);
        });

        // When: 사용자가 여러 번 토글
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.byType(ThemeToggleSwitch));
          await tester.pumpAndSettle();
        }

        // Then: 모든 변경이 정상적으로 처리됨
        expect(changeSequence.length, equals(5));
        expect(tester.takeException(), isNull);
        
        // 마지막 설정이 저장되었는지 확인
        final prefs = await SharedPreferences.getInstance();
        final savedPreference = prefs.getInt('theme_preference');
        expect(savedPreference, equals(service.themePreference.index));
      });

      testWidgets('테마 전환 중 앱이 다시 시작되는 시나리오', (tester) async {
        // Given: 앱이 실행되고 테마가 변경됨
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ThemeToggleSwitch));
        await tester.pumpAndSettle();

        final firstService = ThemeService.instance;
        final savedPreference = firstService.themePreference;

        // When: 앱 재시작 시뮬레이션
        ThemeService.resetForTesting();
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Then: 변경된 설정이 유지됨
        final newService = ThemeService.instance;
        expect(newService.themePreference, equals(savedPreference));
      });
    });

    group('시스템 테마 상호작용 시나리오', () {
      testWidgets('시스템 모드에서 시스템 테마가 변경되는 시나리오', (tester) async {
        // Given: 시스템 모드로 설정된 앱
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;
        await service.setThemePreference(ThemePreference.system);
        await tester.pumpAndSettle();

        expect(service.themePreference, equals(ThemePreference.system));
        final initialIsDark = service.isDarkMode;

        // When: 시스템 테마 변경 시뮬레이션
        service.onSystemThemeChanged();
        await tester.pumpAndSettle();

        // Then: 시스템 모드 설정이 유지됨
        expect(service.themePreference, equals(ThemePreference.system));
        // 시스템 아이콘이 계속 표시됨
        expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
      });

      testWidgets('수동 모드에서 시스템 테마 변경이 무시되는 시나리오', (tester) async {
        // Given: 수동으로 다크모드 설정
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;
        await service.setThemePreference(ThemePreference.dark);
        await tester.pumpAndSettle();

        expect(service.themePreference, equals(ThemePreference.dark));
        expect(service.isDarkMode, isTrue);

        // When: 시스템 테마 변경 시뮬레이션
        service.onSystemThemeChanged();
        await tester.pumpAndSettle();

        // Then: 수동 설정이 유지됨
        expect(service.themePreference, equals(ThemePreference.dark));
        expect(service.isDarkMode, isTrue);
        expect(find.byIcon(Icons.dark_mode), findsOneWidget);
      });
    });

    group('사용자 경험 시나리오', () {
      testWidgets('테마 전환 시 부드러운 애니메이션이 동작하는 시나리오', (tester) async {
        // Given: 앱이 실행된 상태
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // When: 테마 전환
        await tester.tap(find.byType(ThemeToggleSwitch));
        
        // 애니메이션 중간 상태 확인
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 150));

        // Then: 애니메이션이 에러 없이 진행됨
        expect(tester.takeException(), isNull);
        
        // 애니메이션 완료
        await tester.pumpAndSettle();
        
        // 최종 상태가 올바르게 적용됨
        final service = ThemeService.instance;
        expect(service.isInitialized, isTrue);
      });

      testWidgets('다중 탭 환경에서 테마 전환이 모든 탭에 적용되는 시나리오', (tester) async {
        // Given: 메인 탭 화면이 표시된 상태
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // 탭바가 있는지 확인
        expect(find.byType(TabBar), findsOneWidget);
        expect(find.byType(TabBarView), findsOneWidget);

        final service = ThemeService.instance;

        // When: 테마 전환
        await service.setThemePreference(ThemePreference.dark);
        await tester.pumpAndSettle();

        // Then: 모든 탭에 다크 테마가 적용됨
        final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
        expect(materialApp.themeMode, equals(ThemeMode.dark));

        // 각 탭으로 이동하면서 테마 일관성 확인
        final tabCount = 4; // Task, Calendar, Summary, Links
        for (int i = 0; i < tabCount; i++) {
          await tester.tap(find.byType(Tab).at(i));
          await tester.pumpAndSettle();
          
          // 에러 없이 탭 전환이 되는지 확인
          expect(tester.takeException(), isNull);
        }
      });
    });

    group('에러 복구 시나리오', () {
      testWidgets('잘못된 설정 데이터에서 복구되는 시나리오', (tester) async {
        // Given: 손상된 설정 데이터
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('theme_preference', 999); // 유효하지 않은 값

        // When: 앱 실행
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        // Then: 기본값으로 복구됨
        final service = ThemeService.instance;
        expect(service.themePreference, equals(ThemePreference.system));
        expect(service.isInitialized, isTrue);
        expect(tester.takeException(), isNull);

        // 정상적으로 테마 전환이 가능함
        await tester.tap(find.byType(ThemeToggleSwitch));
        await tester.pumpAndSettle();

        expect(service.themePreference, isNot(equals(ThemePreference.system)));
      });

      testWidgets('SharedPreferences 오류 상황에서의 복구 시나리오', (tester) async {
        // Given: 앱이 정상 실행된 상태
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;

        // When: 여러 번 테마 변경 (일부는 실패할 수 있음)
        for (int i = 0; i < 3; i++) {
          try {
            await service.setThemePreference(
              i % 2 == 0 ? ThemePreference.dark : ThemePreference.light
            );
            await tester.pumpAndSettle();
          } catch (e) {
            // 에러가 발생해도 앱이 계속 동작해야 함
          }
        }

        // Then: 앱이 계속 정상 동작함
        expect(service.isInitialized, isTrue);
        expect(tester.takeException(), isNull);

        // 토글 스위치가 여전히 작동함
        await tester.tap(find.byType(ThemeToggleSwitch));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    });

    group('성능 및 메모리 시나리오', () {
      testWidgets('장시간 사용 중 테마 전환 성능이 유지되는 시나리오', (tester) async {
        // Given: 앱이 실행된 상태
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;
        final stopwatch = Stopwatch()..start();

        // When: 100회 테마 전환 (성능 테스트)
        for (int i = 0; i < 100; i++) {
          await service.setThemePreference(
            i % 3 == 0 ? ThemePreference.system :
            i % 3 == 1 ? ThemePreference.light : ThemePreference.dark
          );
          
          if (i % 10 == 0) {
            await tester.pump(); // 주기적으로 UI 업데이트
          }
        }

        stopwatch.stop();
        await tester.pumpAndSettle();

        // Then: 성능이 합리적인 범위 내에 있음
        expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // 10초 이내
        expect(service.isInitialized, isTrue);
        expect(tester.takeException(), isNull);
      });

      testWidgets('메모리 누수 없이 테마 변경이 처리되는 시나리오', (tester) async {
        // Given: 앱이 실행된 상태
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();

        final service = ThemeService.instance;
        var listenerCallCount = 0;

        // 리스너 추가
        void testListener() {
          listenerCallCount++;
        }

        service.addListener(testListener);

        // When: 여러 번 테마 변경
        for (int i = 0; i < 5; i++) {
          await service.toggleTheme();
          await tester.pumpAndSettle();
        }

        // Then: 리스너가 올바른 횟수만큼 호출됨
        expect(listenerCallCount, equals(5));

        // 리스너 제거 후 더 이상 호출되지 않음
        service.removeListener(testListener);
        await service.toggleTheme();
        await tester.pumpAndSettle();

        expect(listenerCallCount, equals(5)); // 변화 없음
      });
    });
  });
}