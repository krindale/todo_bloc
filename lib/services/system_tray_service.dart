import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

/// 시스템 트레이 관리 서비스 (데스크톱 전용)
/// 
/// Single Responsibility Principle을 적용하여 시스템 트레이 관련 
/// 기능만을 담당하는 서비스입니다.
/// 
/// 주요 기능:
/// - **트레이 아이콘 생성 및 관리**
/// - **컨텍스트 메뉴 구성**
/// - **앱 표시/숨김 제어**
/// - **이벤트 처리 (클릭, 우클릭)**
/// - **앱 종료 관리**
/// 
/// 지원 플랫폼: Windows, macOS, Linux
/// 
/// 디자인 패턴:
/// - **Singleton**: 앱 전체에서 하나의 인스턴스만 사용
/// - **Observer**: 시스템 이벤트 감지 및 처리
/// 
/// Example:
/// ```dart
/// // 시스템 트레이 초기화
/// final trayService = SystemTrayService();
/// await trayService.initialize();
/// 
/// // 앱 제어
/// await trayService.showApp();    // 앱 표시
/// await trayService.hideApp();    // 트레이로 숨김
/// await trayService.exitApp();    // 완전 종료
/// 
/// // 상태 확인
/// if (trayService.isInitialized) {
///   print('시스템 트레이 사용 가능');
/// }
/// ```
class SystemTrayService {
  /// 시스템 트레이 인스턴스
  final SystemTray _systemTray = SystemTray();
  
  /// 컨텍스트 메뉴 인스턴스
  final Menu _menuMain = Menu();
  
  /// 초기화 상태 플래그
  bool _isInitialized = false;

  /// Singleton 인스턴스
  static final SystemTrayService _instance = SystemTrayService._internal();
  
  /// Singleton 팩토리 생성자
  /// 
  /// 앱 전체에서 하나의 SystemTrayService 인스턴스만 사용하도록 보장합니다.
  /// 이는 시스템 트레이가 앱당 하나만 존재해야 하는 특성 때문입니다.
  /// 
  /// Returns:
  ///   SystemTrayService의 유일한 인스턴스
  factory SystemTrayService() => _instance;
  
  /// 내부 생성자 (Singleton 패턴)
  SystemTrayService._internal();

  /// 시스템 트레이 초기화 상태를 반환합니다.
  /// 
  /// Returns:
  ///   true - 초기화 완료, false - 미초기화
  bool get isInitialized => _isInitialized;

  /// 시스템 트레이를 초기화합니다.
  /// 
  /// 다음 단계를 순차적으로 수행합니다:
  /// 1. 트레이 아이콘 생성 및 설정
  /// 2. 컨텍스트 메뉴 구성
  /// 3. 이벤트 핸들러 등록
  /// 4. 초기화 상태 업데이트
  /// 
  /// 아이콘 설정:
  /// - 경로: `assets/images/tray_icon.ico`
  /// - 타이틀: "Todo App"
  /// - 툴팁: "Todo 관리 앱 - 우클릭하세요"
  /// 
  /// Throws:
  ///   - 아이콘 파일을 찾을 수 없는 경우
  ///   - 시스템 트레이 생성 실패 시
  ///   - 메뉴 구성 실패 시
  /// 
  /// Example:
  /// ```dart
  /// try {
  ///   await SystemTrayService().initialize();
  ///   print('트레이 사용 가능');
  /// } catch (e) {
  ///   print('트레이 생성 실패: $e');
  /// }
  /// ```
  Future<void> initialize() async {
    try {
      // 1. 시스템 트레이 아이콘 초기화
      await _systemTray.initSystemTray(
        iconPath: 'assets/images/tray_icon.ico',
        title: "Todo App", 
        toolTip: "Todo 관리 앱 - 우클릭하세요",
      );
      
      print('System tray icon initialized');
      
      // 2. 컨텍스트 메뉴 구성 및 설정
      await _buildContextMenu();
      await _systemTray.setContextMenu(_menuMain);
      print('Context menu attached to system tray');
      
      // 3. 이벤트 핸들러 등록
      _registerEventHandlers();
      
      // 4. 초기화 완료 표시
      _isInitialized = true;
      print('System tray initialized successfully');
    } catch (e) {
      print('System tray initialization failed: $e');
      rethrow;
    }
  }

  /// 시스템 트레이 컨텍스트 메뉴를 구성합니다.
  /// 
  /// 메뉴 구성:
  /// - **Show Todo App**: 숨겨진 앱을 다시 표시
  /// - **Hide App**: 앱을 트레이로 숨김
  /// - **구분선**
  /// - **Exit App**: 완전 종료
  /// 
  /// 각 메뉴 항목은 해당하는 액션 메서드와 연결됩니다.
  Future<void> _buildContextMenu() async {
    await _menuMain.buildFrom([
      MenuItemLabel(
        label: 'Show Todo App',
        onClicked: (menuItem) {
          print('[MENU] Show Todo App clicked');
          showApp();
        }
      ),
      MenuItemLabel(
        label: 'Hide App',
        onClicked: (menuItem) {
          print('[MENU] Hide App clicked');  
          hideApp();
        }
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Exit App',
        onClicked: (menuItem) {
          print('[MENU] Exit App clicked');
          exitApp();
        }
      ),
    ]);
  }

  /// 시스템 트레이 이벤트 핸들러를 등록합니다.
  /// 
  /// 처리하는 이벤트:
  /// - **좌클릭**: 앱 표시 (showApp 호출)
  /// - **우클릭**: 컨텍스트 메뉴 표시 (자동 + 수동 처리)
  /// - **기타**: 로그 출력
  /// 
  /// Observer 패턴을 사용하여 시스템 이벤트를 감지하고 처리합니다.
  void _registerEventHandlers() {
    _systemTray.registerSystemTrayEventHandler((eventName) {
      print('=== System tray event: $eventName ===');
      
      switch (eventName) {
        case kSystemTrayEventClick:
          print('Left click - showing app');
          showApp();
          break;
        case kSystemTrayEventRightClick:
          print('Right click - context menu should auto-show');
          // 우클릭 시 자동으로 메뉴가 표시되지 않으면 수동으로 호출
          try {
            _systemTray.popUpContextMenu();
            print('Manually triggered context menu');
          } catch (e) {
            print('Failed to manually show context menu: $e');
          }
          break;
        default:
          print('Unknown tray event: $eventName');
      }
    });
  }

  /// 앱을 화면에 표시하고 포커스를 설정합니다.
  /// 
  /// 트레이로 숨겨진 앱을 다시 활성화할 때 사용됩니다.
  /// Window Manager를 통해 창을 표시하고 포커스를 설정합니다.
  /// 
  /// 사용 시나리오:
  /// - 트레이 아이콘 좌클릭
  /// - 컨텍스트 메뉴에서 "Show Todo App" 선택
  /// 
  /// Example:
  /// ```dart
  /// await SystemTrayService().showApp();
  /// ```
  Future<void> showApp() async {
    await windowManager.show();
    await windowManager.focus();
  }

  /// 앱을 시스템 트레이로 숨깁니다.
  /// 
  /// 앱은 종료되지 않고 백그라운드에서 계속 실행되며,
  /// 트레이 아이콘을 통해 언제든 다시 표시할 수 있습니다.
  /// 
  /// 사용 시나리오:
  /// - 창 닫기 버튼 클릭 시
  /// - 컨텍스트 메뉴에서 "Hide App" 선택
  /// - 최소화 동작 시
  /// 
  /// Example:
  /// ```dart
  /// await SystemTrayService().hideApp();
  /// ```
  Future<void> hideApp() async {
    await windowManager.hide();
  }

  /// 앱을 완전히 종료합니다.
  /// 
  /// 다음 단계를 순차적으로 수행합니다:
  /// 1. 시스템 트레이 정리
  /// 2. 윈도우 매니저 정리
  /// 3. 프로세스 종료 (exit(0))
  /// 
  /// 각 단계에서 오류가 발생해도 다음 단계를 계속 진행하여
  /// 확실한 종료를 보장합니다.
  /// 
  /// 사용 시나리오:
  /// - 컨텍스트 메뉴에서 "Exit App" 선택
  /// - 프로그래밍적 종료 요청
  /// 
  /// Example:
  /// ```dart
  /// await SystemTrayService().exitApp(); // 앱 완전 종료
  /// ```
  Future<void> exitApp() async {
    print('앱 종료 시작...');
    
    // 1. 시스템 트레이 정리
    try {
      await _systemTray.destroy();
      print('시스템 트레이 정리 완료');
    } catch (e) {
      print('시스템 트레이 정리 중 오류: $e');
    }
    
    // 2. 윈도우 매니저 정리
    try {
      await windowManager.destroy();
      print('윈도우 종료 완료');
    } catch (e) {
      print('윈도우 종료 중 오류: $e');
    }
    
    // 3. 프로세스 종료
    print('앱 완전 종료');
    exit(0);
  }

  /// 시스템 트레이 리소스를 정리합니다.
  /// 
  /// 앱 종료 시 또는 서비스를 재초기화할 때 사용됩니다.
  /// exitApp()과 달리 프로세스를 종료하지 않고 트레이만 정리합니다.
  /// 
  /// Example:
  /// ```dart
  /// await SystemTrayService().dispose(); // 트레이만 정리
  /// ```
  Future<void> dispose() async {
    if (_isInitialized) {
      try {
        await _systemTray.destroy();
        _isInitialized = false;
        print('System tray disposed successfully');
      } catch (e) {
        print('System tray disposal failed: $e');
      }
    }
  }
}