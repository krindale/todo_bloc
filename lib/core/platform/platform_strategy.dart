/// **플랫폼별 전략 패턴 구현**
///
/// 플랫폼에 따라 다른 동작이 필요한 기능들을 
/// 전략 패턴으로 추상화하여 관리합니다.

import 'platform_info.dart';
import '../utils/app_logger.dart';

/// **플랫폼 전략 추상 클래스**
abstract class PlatformStrategy {
  /// Firebase만 사용할지 여부 결정
  bool shouldUseFirebaseOnly();
  
  /// 로컬 데이터베이스 사용 가능 여부
  bool canUseLocalDatabase();
  
  /// 시스템 트레이 사용 가능 여부
  bool canUseSystemTray();
  
  /// 윈도우 관리 사용 가능 여부
  bool canManageWindow();
  
  /// 백그라운드 동기화 사용 가능 여부
  bool canSyncInBackground();
  
  /// 알림 기능 사용 가능 여부
  bool canShowNotifications();
  
  /// 플랫폼별 초기화 로직
  Future<void> initialize();
  
  /// 플랫폼별 정리 로직
  Future<void> dispose();
  
  /// 플랫폼 이름
  String get platformName;
}

/// **모바일 플랫폼 전략**
class MobilePlatformStrategy implements PlatformStrategy {
  @override
  bool shouldUseFirebaseOnly() {
    // 모바일에서는 Hive + Firebase 조합 사용
    return false;
  }
  
  @override
  bool canUseLocalDatabase() => true;
  
  @override
  bool canUseSystemTray() => false;
  
  @override
  bool canManageWindow() => false;
  
  @override
  bool canSyncInBackground() => true;
  
  @override
  bool canShowNotifications() => true;
  
  @override
  Future<void> initialize() async {
    AppLogger.info('Initializing mobile platform strategy', tag: 'Platform');
    // 모바일 플랫폼 초기화 로직
    // - Hive 초기화
    // - Firebase 초기화
    // - 푸시 알림 설정
  }
  
  @override
  Future<void> dispose() async {
    AppLogger.info('Disposing mobile platform strategy', tag: 'Platform');
    // 모바일 플랫폼 정리 로직
  }
  
  @override
  String get platformName => 'Mobile (${PlatformInfo.osType.name})';
}

/// **데스크톱 플랫폼 전략**
class DesktopPlatformStrategy implements PlatformStrategy {
  @override
  bool shouldUseFirebaseOnly() {
    // 데스크톱에서는 Firebase만 사용 (Hive 이슈로 인해)
    return true;
  }
  
  @override
  bool canUseLocalDatabase() => false; // Hive 이슈로 인해 비활성화
  
  @override
  bool canUseSystemTray() => true;
  
  @override
  bool canManageWindow() => true;
  
  @override
  bool canSyncInBackground() => true;
  
  @override
  bool canShowNotifications() => true;
  
  @override
  Future<void> initialize() async {
    AppLogger.info('Initializing desktop platform strategy', tag: 'Platform');
    // 데스크톱 플랫폼 초기화 로직
    // - Firebase 초기화
    // - 시스템 트레이 설정
    // - 윈도우 관리 설정
  }
  
  @override
  Future<void> dispose() async {
    AppLogger.info('Disposing desktop platform strategy', tag: 'Platform');
    // 데스크톱 플랫폼 정리 로직
    // - 시스템 트레이 정리
    // - 윈도우 상태 저장
  }
  
  @override
  String get platformName => 'Desktop (${PlatformInfo.osType.name})';
}

/// **웹 플랫폼 전략**
class WebPlatformStrategy implements PlatformStrategy {
  @override
  bool shouldUseFirebaseOnly() {
    // 웹에서는 Firebase만 사용
    return true;
  }
  
  @override
  bool canUseLocalDatabase() => false;
  
  @override
  bool canUseSystemTray() => false;
  
  @override
  bool canManageWindow() => false;
  
  @override
  bool canSyncInBackground() => false;
  
  @override
  bool canShowNotifications() => false;
  
  @override
  Future<void> initialize() async {
    AppLogger.info('Initializing web platform strategy', tag: 'Platform');
    // 웹 플랫폼 초기화 로직
    // - Firebase 초기화
    // - 브라우저 호환성 체크
  }
  
  @override
  Future<void> dispose() async {
    AppLogger.info('Disposing web platform strategy', tag: 'Platform');
    // 웹 플랫폼 정리 로직
  }
  
  @override
  String get platformName => 'Web';
}

/// **플랫폼 전략 팩토리**
class PlatformStrategyFactory {
  PlatformStrategyFactory._();
  
  /// 현재 플랫폼에 맞는 전략 생성
  static PlatformStrategy create() {
    switch (PlatformInfo.platformType) {
      case PlatformType.mobile:
        return MobilePlatformStrategy();
      case PlatformType.desktop:
        return DesktopPlatformStrategy();
      case PlatformType.web:
        return WebPlatformStrategy();
    }
  }
}

/// **플랫폼 어댑터 - 전역 접근점**
class PlatformAdapter {
  static PlatformStrategy? _strategy;
  
  /// 플랫폼 전략 초기화
  static Future<void> initialize() async {
    _strategy = PlatformStrategyFactory.create();
    await _strategy!.initialize();
    
    AppLogger.info(
      'Platform adapter initialized for ${_strategy!.platformName}',
      tag: 'Platform',
      metadata: {
        'platformType': PlatformInfo.platformType.name,
        'osType': PlatformInfo.osType.name,
        'firebaseOnly': _strategy!.shouldUseFirebaseOnly(),
        'canUseLocalDB': _strategy!.canUseLocalDatabase(),
        'canUseSystemTray': _strategy!.canUseSystemTray(),
      },
    );
  }
  
  /// 현재 플랫폼 전략 반환
  static PlatformStrategy get current {
    if (_strategy == null) {
      throw StateError('PlatformAdapter not initialized. Call initialize() first.');
    }
    return _strategy!;
  }
  
  /// 플랫폼 전략 정리
  static Future<void> dispose() async {
    if (_strategy != null) {
      await _strategy!.dispose();
      _strategy = null;
    }
  }
  
  // 편의 메서드들 - 자주 사용되는 체크
  static bool get shouldUseFirebaseOnly => current.shouldUseFirebaseOnly();
  static bool get canUseLocalDatabase => current.canUseLocalDatabase();
  static bool get canUseSystemTray => current.canUseSystemTray();
  static bool get canManageWindow => current.canManageWindow();
  static bool get canSyncInBackground => current.canSyncInBackground();
  static bool get canShowNotifications => current.canShowNotifications();
}