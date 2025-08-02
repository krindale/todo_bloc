/// **테마 서비스 - 다크/라이트 모드 상태 관리**
/// 
/// 시스템 테마 감지, 사용자 설정 저장, 테마 변경 이벤트 처리를 담당합니다.
/// 
/// **주요 기능:**
/// - 시스템 테마 자동 감지 및 적용
/// - 사용자 테마 설정 저장/로드
/// - 테마 변경 이벤트 브로드캐스트
/// - 플랫폼별 테마 설정 지원
/// 
/// **패턴:**
/// - Singleton 패턴: 앱 전체에서 단일 인스턴스 사용
/// - Observer 패턴: 테마 변경 시 위젯들에게 알림
/// - Strategy 패턴: 플랫폼별 테마 저장 전략

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 테마 모드 열거형
enum ThemePreference {
  system,  // 시스템 설정 따름
  light,   // 라이트 모드 고정
  dark,    // 다크 모드 고정
}

/// 테마 서비스 클래스
class ThemeService extends ChangeNotifier {
  static ThemeService? _instance;
  static ThemeService get instance {
    _instance ??= ThemeService._internal();
    return _instance!;
  }

  ThemeService._internal() {
    _initialize();
  }

  // 상태 변수들
  ThemePreference _themePreference = ThemePreference.system;
  bool _isDarkMode = false;
  bool _isInitialized = false;

  // SharedPreferences 키
  static const String _themePreferenceKey = 'theme_preference';

  /// 현재 테마 설정
  ThemePreference get themePreference => _themePreference;

  /// 현재 다크 모드 여부
  bool get isDarkMode => _isDarkMode;

  /// 초기화 완료 여부
  bool get isInitialized => _isInitialized;

  /// 서비스 초기화
  Future<void> _initialize() async {
    try {
      // SharedPreferences에서 저장된 설정 로드
      await _loadThemePreference();
      
      // 현재 테마 상태 계산
      _updateCurrentTheme();
      
      _isInitialized = true;
      notifyListeners();
      
      print('ThemeService 초기화 완료 - 설정: $_themePreference, 다크모드: $_isDarkMode');
    } catch (e) {
      print('ThemeService 초기화 실패: $e');
      // 기본값으로 폴백
      _themePreference = ThemePreference.system;
      _updateCurrentTheme();
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// 저장된 테마 설정 로드
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPreference = prefs.getInt(_themePreferenceKey);
      
      if (savedPreference != null && savedPreference < ThemePreference.values.length) {
        _themePreference = ThemePreference.values[savedPreference];
      } else {
        // 저장된 설정이 없으면 시스템 설정 사용
        _themePreference = ThemePreference.system;
      }
    } catch (e) {
      print('테마 설정 로드 실패: $e');
      _themePreference = ThemePreference.system;
    }
  }

  /// 테마 설정 저장
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themePreferenceKey, _themePreference.index);
    } catch (e) {
      print('테마 설정 저장 실패: $e');
    }
  }

  /// 현재 테마 상태 업데이트
  void _updateCurrentTheme() {
    switch (_themePreference) {
      case ThemePreference.system:
        _isDarkMode = _getSystemBrightness() == Brightness.dark;
        break;
      case ThemePreference.light:
        _isDarkMode = false;
        break;
      case ThemePreference.dark:
        _isDarkMode = true;
        break;
    }
  }

  /// 시스템 밝기 설정 가져오기
  Brightness _getSystemBrightness() {
    return SchedulerBinding.instance.platformDispatcher.platformBrightness;
  }

  /// 테마 설정 변경
  Future<void> setThemePreference(ThemePreference preference) async {
    if (_themePreference == preference) return;

    _themePreference = preference;
    _updateCurrentTheme();
    
    // 설정 저장
    await _saveThemePreference();
    
    // 변경 알림
    notifyListeners();
    
    print('테마 설정 변경됨: $preference (다크모드: $_isDarkMode)');
  }

  /// 다크/라이트 모드 토글
  Future<void> toggleTheme() async {
    switch (_themePreference) {
      case ThemePreference.system:
        // 시스템 설정에서 현재와 반대로 설정
        final newPreference = _isDarkMode ? ThemePreference.light : ThemePreference.dark;
        await setThemePreference(newPreference);
        break;
      case ThemePreference.light:
        await setThemePreference(ThemePreference.dark);
        break;
      case ThemePreference.dark:
        await setThemePreference(ThemePreference.light);
        break;
    }
  }

  /// 시스템 테마로 되돌리기
  Future<void> useSystemTheme() async {
    await setThemePreference(ThemePreference.system);
  }

  /// 시스템 테마 변경 감지 및 업데이트
  void onSystemThemeChanged() {
    if (_themePreference == ThemePreference.system) {
      final newIsDarkMode = _getSystemBrightness() == Brightness.dark;
      if (_isDarkMode != newIsDarkMode) {
        _isDarkMode = newIsDarkMode;
        notifyListeners();
        print('시스템 테마 변경 감지됨: 다크모드 $_isDarkMode');
      }
    }
  }

  /// MaterialApp의 ThemeMode 반환
  ThemeMode get themeMode {
    switch (_themePreference) {
      case ThemePreference.system:
        return ThemeMode.system;
      case ThemePreference.light:
        return ThemeMode.light;
      case ThemePreference.dark:
        return ThemeMode.dark;
    }
  }

  /// 디버깅용 상태 정보
  Map<String, dynamic> get debugInfo => {
    'themePreference': _themePreference.toString(),
    'isDarkMode': _isDarkMode,
    'systemBrightness': _getSystemBrightness().toString(),
    'isInitialized': _isInitialized,
  };

  /// 테스트용 인스턴스 리셋 메서드
  static void resetForTesting() {
    _instance?.dispose();
    _instance = null;
  }
}