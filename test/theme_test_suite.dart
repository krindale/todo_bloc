/// **다크모드 테마 시스템 테스트 스위트**
/// 
/// 전체 테마 시스템의 모든 테스트를 실행하는 통합 테스트 스위트입니다.
/// 
/// **실행 방법:**
/// ```bash
/// flutter test test/theme_test_suite.dart
/// ```
/// 
/// **테스트 구성:**
/// - 단위 테스트: ThemeService, AppTheme
/// - 위젯 테스트: ThemeToggleSwitch 
/// - 통합 테스트: 전체 앱 테마 통합
/// - 시나리오 테스트: 사용자 시나리오 기반

import 'package:flutter_test/flutter_test.dart';

// 단위 테스트
import 'services/theme_service_test.dart' as theme_service_tests;
import 'theme/app_theme_test.dart' as app_theme_tests;

// 위젯 테스트  
import 'widgets/theme/theme_toggle_switch_test.dart' as theme_toggle_tests;

// 통합 테스트
import 'integration/theme_integration_test.dart' as theme_integration_tests;
import 'integration/theme_scenario_test.dart' as theme_scenario_tests;

void main() {
  group('🌙 다크모드 테마 시스템 전체 테스트 스위트', () {
    
    group('📦 단위 테스트 (Unit Tests)', () {
      group('ThemeService Tests', theme_service_tests.main);
      group('AppTheme Tests', app_theme_tests.main);
    });

    group('🎨 위젯 테스트 (Widget Tests)', () {
      group('ThemeToggleSwitch Tests', theme_toggle_tests.main);
    });

    group('🔗 통합 테스트 (Integration Tests)', () {
      group('Theme Integration Tests', theme_integration_tests.main);
    });

    group('🎭 시나리오 테스트 (Scenario Tests)', () {
      group('Theme Scenario Tests', theme_scenario_tests.main);
    });
  });
}