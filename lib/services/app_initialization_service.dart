import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../model/todo_item.dart';
import '../model/saved_link.dart';
import '../firebase_options.dart';

/// 앱 초기화 서비스를 위한 추상 인터페이스
/// 
/// Single Responsibility Principle을 적용하여 각 초기화 서비스가
/// 하나의 명확한 책임만 가지도록 설계되었습니다.
/// 
/// Template Method Pattern의 기반이 되며, 각 구체 서비스는
/// 자신의 특화된 초기화 로직을 구현합니다.
/// 
/// Example:
/// ```dart
/// class CustomInitService implements InitializationService {
///   @override
///   String get serviceName => 'Custom Service';
/// 
///   @override
///   Future<void> initialize() async {
///     // 커스텀 초기화 로직
///   }
/// }
/// ```
abstract class InitializationService {
  /// 해당 서비스의 초기화를 수행합니다.
  /// 
  /// 각 구현체에서 자신의 초기화 로직을 정의해야 합니다.
  /// 초기화 실패 시 예외를 던져야 합니다.
  /// 
  /// Throws:
  ///   초기화 실패 시 관련 예외 발생
  Future<void> initialize();

  /// 서비스의 이름을 반환합니다.
  /// 
  /// 디버깅 및 로깅 목적으로 사용됩니다.
  /// 
  /// Returns:
  ///   서비스 이름 (예: "Hive Database", "Firebase")
  String get serviceName;
}

/// Hive 로컬 데이터베이스 초기화 서비스
/// 
/// Hive Flutter 초기화 및 데이터 모델 어댑터 등록을 담당합니다.
/// 모든 플랫폼에서 공통으로 사용되는 필수 초기화 서비스입니다.
/// 
/// 담당 업무:
/// - Hive Flutter 환경 초기화
/// - TodoItem 어댑터 등록
/// - SavedLink 어댑터 등록
/// 
/// Example:
/// ```dart
/// final hiveService = HiveInitializationService();
/// await hiveService.initialize(); // Hive 초기화 완료
/// ```
class HiveInitializationService implements InitializationService {
  @override
  String get serviceName => 'Hive Database';

  /// Hive 데이터베이스를 초기화합니다.
  /// 
  /// Flutter 환경에 맞게 Hive를 초기화하고, 
  /// 앱에서 사용하는 모든 데이터 모델의 어댑터를 등록합니다.
  /// 
  /// Throws:
  ///   - Hive 초기화 실패 시 HiveError
  ///   - 어댑터 등록 실패 시 관련 예외
  @override
  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TodoItemAdapter());
    Hive.registerAdapter(SavedLinkAdapter());
  }
}

/// Firebase 백엔드 서비스 초기화
/// 
/// Firebase Core 초기화 및 플랫폼별 설정을 담당합니다.
/// 네트워크 의존적이며, 실패 시에도 앱이 동작할 수 있도록 설계되었습니다.
/// 
/// 담당 업무:
/// - Firebase Core 초기화
/// - 플랫폼별 Firebase 설정 적용
/// - 연결 상태 확인
/// 
/// Example:
/// ```dart
/// // 초기화 시도
/// final firebaseService = FirebaseInitializationService();
/// try {
///   await firebaseService.initialize();
///   print('Firebase 사용 가능');
/// } catch (e) {
///   print('Firebase 사용 불가, 로컬 모드로 동작');
/// }
/// 
/// // 사용 가능 여부 체크
/// final isAvailable = await FirebaseInitializationService.checkAvailability();
/// ```
class FirebaseInitializationService implements InitializationService {
  @override
  String get serviceName => 'Firebase';

  /// Firebase를 초기화합니다.
  /// 
  /// 플랫폼별 Firebase 설정을 적용하고 연결을 설정합니다.
  /// 초기화 실패 시 예외를 상위로 전파하여 적절한 처리가 가능하도록 합니다.
  /// 
  /// Throws:
  ///   - Firebase 설정 오류 시 FirebaseException
  ///   - 네트워크 연결 실패 시 관련 예외
  @override
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      print('Firebase initialization failed: $e');
      rethrow;  // 상위에서 처리하도록 전파
    }
  }

  /// Firebase 사용 가능 여부를 확인합니다.
  /// 
  /// 실제 초기화를 시도해보고 성공 여부를 반환합니다.
  /// 이 메서드는 앱의 동작 모드를 결정하는 데 사용됩니다.
  /// 
  /// Returns:
  ///   true - Firebase 사용 가능 (온라인 모드)
  ///   false - Firebase 사용 불가 (오프라인 모드)
  /// 
  /// Example:
  /// ```dart
  /// if (await FirebaseInitializationService.checkAvailability()) {
  ///   // 온라인 모드: Firebase + 로컬 동기화
  /// } else {
  ///   // 오프라인 모드: 로컬 저장소만 사용
  /// }
  /// ```
  static Future<bool> checkAvailability() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return true;
    } catch (e) {
      print('Firebase not available: $e');
      return false;
    }
  }
}

/// 윈도우 매니저 초기화 서비스 (데스크톱 전용)
/// 
/// 데스크톱 플랫폼에서 창 관리를 위한 초기화를 담당합니다.
/// 웹이나 모바일 플랫폼에서는 자동으로 스킵됩니다.
/// 
/// 담당 업무:
/// - 플랫폼 호환성 체크
/// - 윈도우 매니저 초기화
/// - 기본 창 설정 적용
/// - 창 표시 및 포커스
/// 
/// 지원 플랫폼: Windows, macOS, Linux
/// 
/// Example:
/// ```dart
/// final windowService = WindowInitializationService();
/// await windowService.initialize(); // 데스크톱에서만 실행됨
/// ```
class WindowInitializationService implements InitializationService {
  @override
  String get serviceName => 'Window Manager';

  /// 윈도우 매니저를 초기화합니다.
  /// 
  /// 플랫폼 체크를 먼저 수행하고, 데스크톱 플랫폼인 경우에만
  /// 윈도우 매니저를 초기화하고 기본 창 설정을 적용합니다.
  /// 
  /// 창 설정:
  /// - 크기: 1200x800
  /// - 위치: 화면 중앙
  /// - 투명 배경 지원
  /// - 작업표시줄 표시
  /// - 일반적인 타이틀바 스타일
  /// 
  /// Returns:
  ///   웹이나 모바일 플랫폼에서는 즉시 반환 (no-op)
  /// 
  /// Throws:
  ///   윈도우 매니저 초기화 실패 시 관련 예외
  @override
  Future<void> initialize() async {
    if (kIsWeb || !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      return; // 데스크톱이 아니면 초기화하지 않음
    }

    await windowManager.ensureInitialized();
    
    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );
    
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }
}

/// 앱 초기화 통합 관리 클래스 (Facade Pattern)
/// 
/// 여러 초기화 서비스를 통합 관리하여 클라이언트 코드의 복잡성을 줄입니다.
/// Facade Pattern을 적용하여 복잡한 초기화 과정을 단순한 인터페이스로 제공합니다.
/// 
/// 관리하는 서비스들:
/// - **Hive**: 로컬 데이터베이스 (필수)
/// - **Window Manager**: 데스크톱 창 관리 (데스크톱만)
/// - **Firebase**: 백엔드 서비스 (선택적)
/// 
/// 특징:
/// - 필수 서비스 실패 시 앱 시작 중단
/// - 선택적 서비스 실패 시 기능 제한으로 계속 진행
/// - 상세한 로깅으로 디버깅 지원
/// 
/// Example:
/// ```dart
/// // 기본 초기화 (Firebase 제외)
/// final facade = AppInitializationFacade.create();
/// await facade.initializeAll();
/// 
/// // Firebase 별도 초기화 (실패해도 계속 진행)
/// final hasFirebase = await facade.initializeFirebase();
/// if (hasFirebase) {
///   print('온라인 모드로 시작');
/// } else {
///   print('오프라인 모드로 시작');
/// }
/// ```
class AppInitializationFacade {
  /// 초기화할 서비스 목록
  final List<InitializationService> _services;

  /// AppInitializationFacade 생성자
  /// 
  /// Parameters:
  ///   [_services] - 초기화할 서비스 목록
  AppInitializationFacade(this._services);

  /// 기본 초기화 서비스들로 팩토리 생성자
  /// 
  /// 앱 구동에 필수적인 서비스들만 포함합니다:
  /// - Hive 데이터베이스 (모든 플랫폼)
  /// - Window Manager (데스크톱만)
  /// 
  /// Firebase는 별도로 초기화하여 실패 시에도 앱이 동작하도록 합니다.
  /// 
  /// Returns:
  ///   기본 서비스들로 구성된 [AppInitializationFacade] 인스턴스
  factory AppInitializationFacade.create() {
    return AppInitializationFacade([
      HiveInitializationService(),
      WindowInitializationService(),
      // Firebase는 별도로 체크 후 초기화
    ]);
  }

  /// 모든 등록된 서비스를 순차적으로 초기화합니다.
  /// 
  /// 각 서비스를 순서대로 초기화하며, 상세한 로그를 출력합니다.
  /// 어느 한 서비스라도 실패하면 즉시 중단되고 예외가 전파됩니다.
  /// 
  /// 초기화 순서:
  /// 1. Hive 데이터베이스
  /// 2. Window Manager (데스크톱만)
  /// 
  /// Throws:
  ///   초기화 실패한 서비스의 예외를 상위로 전파
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   await facade.initializeAll();
  ///   print('필수 초기화 완료');
  /// } catch (e) {
  ///   print('초기화 실패, 앱 종료: $e');
  ///   exit(1);
  /// }
  /// ```
  Future<void> initializeAll() async {
    for (final service in _services) {
      try {
        print('Initializing ${service.serviceName}...');
        await service.initialize();
        print('${service.serviceName} initialized successfully');
      } catch (e) {
        print('Failed to initialize ${service.serviceName}: $e');
        rethrow;  // 필수 서비스 실패 시 앱 중단
      }
    }
  }

  /// Firebase를 별도로 초기화합니다 (실패 허용).
  /// 
  /// Firebase는 네트워크 의존적이므로 실패해도 앱이 계속 동작해야 합니다.
  /// 초기화 성공 여부를 반환하여 앱이 적절한 모드로 동작할 수 있도록 합니다.
  /// 
  /// 동작 모드:
  /// - **성공**: 온라인 모드 (Firebase + 로컬 동기화)
  /// - **실패**: 오프라인 모드 (로컬 저장소만)
  /// 
  /// Returns:
  ///   true - Firebase 초기화 성공 (온라인 모드)
  ///   false - Firebase 초기화 실패 (오프라인 모드)
  /// 
  /// Example:
  /// ```dart
  /// final hasFirebase = await facade.initializeFirebase();
  /// 
  /// if (hasFirebase) {
  ///   // Firebase 기능 활성화
  ///   enableRealtimeSync();
  ///   showOnlineIndicator();
  /// } else {
  ///   // 로컬 모드로 제한
  ///   showOfflineWarning();
  ///   disableCloudFeatures();
  /// }
  /// ```
  Future<bool> initializeFirebase() async {
    try {
      final firebaseService = FirebaseInitializationService();
      print('Initializing ${firebaseService.serviceName}...');
      await firebaseService.initialize();
      print('${firebaseService.serviceName} initialized successfully');
      return true;
    } catch (e) {
      print('Firebase initialization failed, continuing without Firebase: $e');
      return false;
    }
  }
}