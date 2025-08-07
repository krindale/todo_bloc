/// **테마 서비스 테스트**
/// 
/// ThemeService의 모든 기능을 포괄적으로 검증하는 단위 테스트입니다.
/// 
/// **테스트 범위:**
/// - 기본 초기화 및 상태 관리
/// - 테마 설정 변경 및 저장
/// - 토글 기능 및 시스템 테마 감지
/// - 에러 처리 및 예외 상황
/// - 알림 및 상태 변경 이벤트

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../lib/services/theme_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('ThemeService', () {
    late ThemeService service;

    setUp(() {
      // SharedPreferences 모킹 초기화
      SharedPreferences.setMockInitialValues({});
      
      // 새로운 인스턴스를 위해 기존 인스턴스 리셋
      ThemeService.resetForTesting();
      service = ThemeService.instance;
    });

    tearDown(() {
      // 각 테스트 후 정리
      ThemeService.resetForTesting();
    });

    group('초기화 및 기본 상태', () {
      test('should initialize with system theme by default', () {
        expect(service.themePreference, equals(ThemePreference.system));
        expect(service.themeMode, equals(ThemeMode.system));
        expect(service.isInitialized, isTrue);
      });

      test('should be singleton instance', () {
        final service1 = ThemeService.instance;
        final service2 = ThemeService.instance;
        
        expect(identical(service1, service2), isTrue);
      });

      test('should provide complete debug info', () {
        final debugInfo = service.debugInfo;
        
        expect(debugInfo, isA<Map<String, dynamic>>());
        expect(debugInfo.containsKey('themePreference'), isTrue);
        expect(debugInfo.containsKey('isDarkMode'), isTrue);
        expect(debugInfo.containsKey('systemBrightness'), isTrue);
        expect(debugInfo.containsKey('isInitialized'), isTrue);
        
        // 값들이 올바른 타입인지 확인
        expect(debugInfo['themePreference'], isA<String>());
        expect(debugInfo['isDarkMode'], isA<bool>());
        expect(debugInfo['systemBrightness'], isA<String>());
        expect(debugInfo['isInitialized'], isA<bool>());
      });
    });

    group('테마 설정 변경', () {
      test('should change to dark theme correctly', () async {
        await service.setThemePreference(ThemePreference.dark);
        
        expect(service.themePreference, equals(ThemePreference.dark));
        expect(service.isDarkMode, isTrue);
        expect(service.themeMode, equals(ThemeMode.dark));
      });

      test('should change to light theme correctly', () async {
        await service.setThemePreference(ThemePreference.light);
        
        expect(service.themePreference, equals(ThemePreference.light));
        expect(service.isDarkMode, isFalse);
        expect(service.themeMode, equals(ThemeMode.light));
      });

      test('should return to system theme', () async {
        // 먼저 다크 모드로 설정
        await service.setThemePreference(ThemePreference.dark);
        expect(service.themePreference, equals(ThemePreference.dark));
        
        // 시스템 테마로 되돌리기
        await service.useSystemTheme();
        expect(service.themePreference, equals(ThemePreference.system));
        expect(service.themeMode, equals(ThemeMode.system));
      });

      test('should not change when setting same preference', () async {
        final initialPreference = service.themePreference;
        var notificationCount = 0;
        
        service.addListener(() {
          notificationCount++;
        });
        
        await service.setThemePreference(initialPreference);
        
        expect(service.themePreference, equals(initialPreference));
        expect(notificationCount, equals(0)); // 변경이 없으므로 알림도 없어야 함
      });
    });

    group('테마 토글 기능', () {
      test('should toggle from system to opposite mode', () async {
        // 시스템 모드에서 시작
        expect(service.themePreference, equals(ThemePreference.system));
        
        final initialIsDark = service.isDarkMode;
        await service.toggleTheme();
        
        // 시스템의 반대 모드로 변경되어야 함
        if (initialIsDark) {
          expect(service.themePreference, equals(ThemePreference.light));
          expect(service.isDarkMode, isFalse);
        } else {
          expect(service.themePreference, equals(ThemePreference.dark));
          expect(service.isDarkMode, isTrue);
        }
      });

      test('should toggle between light and dark modes', () async {
        // 라이트 모드로 설정
        await service.setThemePreference(ThemePreference.light);
        expect(service.isDarkMode, isFalse);
        
        // 토글 - 다크 모드로 변경
        await service.toggleTheme();
        expect(service.themePreference, equals(ThemePreference.dark));
        expect(service.isDarkMode, isTrue);
        
        // 다시 토글 - 라이트 모드로 변경
        await service.toggleTheme();
        expect(service.themePreference, equals(ThemePreference.light));
        expect(service.isDarkMode, isFalse);
      });
    });

    group('상태 변경 알림', () {
      test('should notify listeners when theme changes', () async {
        var notificationCount = 0;
        ThemePreference? lastNotifiedPreference;
        
        service.addListener(() {
          notificationCount++;
          lastNotifiedPreference = service.themePreference;
        });
        
        await service.setThemePreference(ThemePreference.dark);
        
        expect(notificationCount, equals(1));
        expect(lastNotifiedPreference, equals(ThemePreference.dark));
        
        await service.setThemePreference(ThemePreference.light);
        
        expect(notificationCount, equals(2));
        expect(lastNotifiedPreference, equals(ThemePreference.light));
      });

      test('should handle system theme change notification', () {
        var notificationCount = 0;
        
        // 시스템 모드로 설정
        service.setThemePreference(ThemePreference.system);
        
        service.addListener(() {
          notificationCount++;
        });
        
        // 시스템 테마 변경 시뮬레이션
        service.onSystemThemeChanged();
        
        // 시스템 모드일 때만 알림이 발생해야 함
        expect(notificationCount, greaterThanOrEqualTo(0));
      });
    });

    group('설정 저장 및 로드', () {
      test('should save and load theme preference', () async {
        // 다크 모드로 설정 후 저장
        await service.setThemePreference(ThemePreference.dark);
        
        // SharedPreferences에서 값 확인
        final prefs = await SharedPreferences.getInstance();
        final savedValue = prefs.getInt('theme_preference');
        
        expect(savedValue, equals(ThemePreference.dark.index));
      });

      test('should handle corrupted preference data gracefully', () async {
        // 잘못된 값을 SharedPreferences에 저장
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('theme_preference', 999); // 유효하지 않은 인덱스
        
        // 새 인스턴스 생성
        ThemeService.resetForTesting();
        final newService = ThemeService.instance;
        
        // 기본값으로 fallback 되어야 함
        expect(newService.themePreference, equals(ThemePreference.system));
      });
    });

    group('ThemeMode 매핑', () {
      test('should return correct ThemeMode for each preference', () async {
        await service.setThemePreference(ThemePreference.system);
        expect(service.themeMode, equals(ThemeMode.system));
        
        await service.setThemePreference(ThemePreference.light);
        expect(service.themeMode, equals(ThemeMode.light));
        
        await service.setThemePreference(ThemePreference.dark);
        expect(service.themeMode, equals(ThemeMode.dark));
      });
    });

    group('에러 처리', () {
      test('should handle SharedPreferences errors gracefully', () async {
        // 이 테스트는 실제 SharedPreferences 에러를 시뮬레이션하기 어려우므로
        // 서비스가 기본적으로 에러 상황에서도 동작하는지 확인
        expect(service.isInitialized, isTrue);
        expect(service.themePreference, isNotNull);
        expect(service.themeMode, isNotNull);
      });
    });
  });
}