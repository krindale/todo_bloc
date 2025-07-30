/// **플랫폼 정보 및 기본 추상화**
///
/// 앱이 실행되는 플랫폼의 특성을 파악하고,
/// 플랫폼별 다른 동작이 필요한 부분을 추상화합니다.

import 'dart:io';
import 'package:flutter/foundation.dart';

/// **플랫폼 타입 정의**
enum PlatformType {
  mobile,
  desktop,
  web,
}

/// **운영체제 타입 정의**
enum OSType {
  android,
  ios,
  windows,
  macos,
  linux,
  web,
  unknown,
}

/// **플랫폼 정보 클래스**
class PlatformInfo {
  PlatformInfo._();
  
  /// 현재 플랫폼 타입
  static PlatformType get platformType {
    if (kIsWeb) return PlatformType.web;
    if (Platform.isAndroid || Platform.isIOS) return PlatformType.mobile;
    return PlatformType.desktop;
  }
  
  /// 현재 운영체제 타입
  static OSType get osType {
    if (kIsWeb) return OSType.web;
    if (Platform.isAndroid) return OSType.android;
    if (Platform.isIOS) return OSType.ios;
    if (Platform.isWindows) return OSType.windows;
    if (Platform.isMacOS) return OSType.macos;
    if (Platform.isLinux) return OSType.linux;
    return OSType.unknown;
  }
  
  /// 모바일 플랫폼 여부
  static bool get isMobile => platformType == PlatformType.mobile;
  
  /// 데스크톱 플랫폼 여부
  static bool get isDesktop => platformType == PlatformType.desktop;
  
  /// 웹 플랫폼 여부
  static bool get isWeb => platformType == PlatformType.web;
  
  /// Android 플랫폼 여부
  static bool get isAndroid => osType == OSType.android;
  
  /// iOS 플랫폼 여부
  static bool get isIOS => osType == OSType.ios;
  
  /// Windows 플랫폼 여부
  static bool get isWindows => osType == OSType.windows;
  
  /// macOS 플랫폼 여부
  static bool get isMacOS => osType == OSType.macos;
  
  /// Linux 플랫폼 여부
  static bool get isLinux => osType == OSType.linux;
  
  /// Apple 플랫폼 여부 (iOS, macOS)
  static bool get isApple => isIOS || isMacOS;
  
  /// 시스템 트레이 지원 여부
  static bool get supportsSystemTray => isDesktop;
  
  /// 윈도우 관리 지원 여부
  static bool get supportsWindowManagement => isDesktop;
  
  /// 파일 시스템 접근 지원 여부
  static bool get supportsFileSystem => !isWeb;
  
  /// 푸시 알림 지원 여부
  static bool get supportsPushNotifications => isMobile;
  
  /// 로컬 알림 지원 여부
  static bool get supportsLocalNotifications => !isWeb;
  
  /// 백그라운드 실행 지원 여부
  static bool get supportsBackgroundExecution => !isWeb;
  
  /// 플랫폼별 기본 폰트 패밀리
  static String get defaultFontFamily {
    switch (osType) {
      case OSType.ios:
      case OSType.macos:
        return 'SF Pro Display';
      case OSType.android:
        return 'Roboto';
      case OSType.windows:
        return 'Segoe UI';
      case OSType.linux:
        return 'Ubuntu';
      case OSType.web:
        return 'system-ui';
      case OSType.unknown:
        return 'sans-serif';
    }
  }
  
  /// 플랫폼 이름
  static String get platformName {
    switch (osType) {
      case OSType.android:
        return 'Android';
      case OSType.ios:
        return 'iOS';
      case OSType.windows:
        return 'Windows';
      case OSType.macos:
        return 'macOS';
      case OSType.linux:
        return 'Linux';
      case OSType.web:
        return 'Web';
      case OSType.unknown:
        return 'Unknown';
    }
  }
  
  /// 플랫폼별 기본 데이터 저장소 경로
  static String get defaultDataPath {
    if (isWeb) return '/web-storage';
    if (isAndroid) return '/data/data/com.example.todo/files';
    if (isIOS) return '/Documents';
    if (isWindows) return '%APPDATA%/TodoApp';
    if (isMacOS) return '~/Library/Application Support/TodoApp';
    if (isLinux) return '~/.local/share/TodoApp';
    return '/tmp/TodoApp';
  }
}