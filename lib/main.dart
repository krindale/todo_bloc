/// **Flutter Todo App - 애플리케이션 진입점**
/// 
/// 크로스 플랫폼 할 일 관리 애플리케이션의 메인 엔트리 파일입니다.
/// Firebase 인증, 플랫폼별 초기화, 시스템 트레이 등 핵심 기능들을 설정합니다.
/// 
/// **주요 기능:**
/// - 앱 초기화 및 Firebase 설정
/// - 사용자 인증 상태 관리
/// - 플랫폼별 기능 분기 (데스크톱: 시스템 트레이)
/// - 전역 네비게이션 및 라우팅 설정
/// 
/// **아키텍처:**
/// - Facade 패턴: AppInitializationFacade로 복잡한 초기화 로직 캡슐화
/// - Strategy 패턴: 플랫폼별 기능 분기 처리
/// - Observer 패턴: Firebase Auth 상태 변화 감지
/// 
/// **플랫폼 지원:**
/// - 모바일 (Android/iOS): 표준 Material 앱
/// - 데스크톱 (Windows/macOS/Linux): 시스템 트레이 + 윈도우 관리
/// - 웹: Firebase 기반 실시간 동기화

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';
import 'screen/tabbar/task_tabbar_screen.dart';
import 'screen/login/login_screen.dart';
import 'screen/login/signup_screen.dart';
import 'services/user_session_service.dart';
import 'services/app_initialization_service.dart';
import 'services/system_tray_service.dart';
import 'services/web_notification_helper.dart' if (dart.library.io) 'services/web_notification_helper_stub.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SRP 적용: 초기화 서비스로 분리
  final initFacade = AppInitializationFacade.create();
  
  try {
    await initFacade.initializeAll();
    
    // 플랫폼별 초기화
    if (kIsWeb) {
      // 웹에서는 알림 권한 요청
      _initializeWebNotifications();
    } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      // 데스크톱에서는 System Tray 초기화
      await SystemTrayService().initialize();
    }
  } catch (e) {
    print('Critical initialization failed: $e');
    // 중요한 초기화가 실패하면 앱을 종료하거나 에러 화면을 표시
  }
  
  runApp(const MyApp());
}

/// 웹 알림 초기화 및 권한 요청
void _initializeWebNotifications() {
  if (kIsWeb) {
    // 앱 시작 1초 후에 권한 요청 (UI가 완전히 로드된 후)
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        print('🔔 웹 알림 권한 요청을 시작합니다...');
        
        // 알림 지원 여부 확인
        if (!WebNotificationHelper.isNotificationSupported()) {
          print('❌ 이 브라우저는 웹 알림을 지원하지 않습니다');
          return;
        }
        
        // 현재 권한 상태 확인
        final currentPermission = await WebNotificationHelper.checkNotificationPermission();
        print('🔔 현재 알림 권한 상태: $currentPermission');
        
        if (currentPermission == 'default') {
          // 권한이 설정되지 않은 경우 요청
          print('🔔 사용자에게 알림 권한을 요청합니다...');
          
          // 사용자에게 알림 권한 요청 안내
          _showNotificationPermissionDialog();
          
          final result = await WebNotificationHelper.requestNotificationPermission();
          
          if (result == 'granted') {
            print('✅ 알림 권한이 승인되었습니다!');
            // 환영 알림 표시
            Future.delayed(const Duration(seconds: 1), () {
              WebNotificationHelper.showWebNotification(
                '🎉 알림 설정 완료!', 
                'Todo 앱에서 할 일 알람을 받을 수 있습니다.'
              );
            });
          } else {
            print('❌ 알림 권한이 거부되었습니다');
            _showNotificationDeniedMessage();
          }
        } else if (currentPermission == 'granted') {
          print('✅ 이미 알림 권한이 승인되어 있습니다');
          // 기존 사용자에게는 조용히 처리
        } else {
          print('❌ 알림 권한이 차단되어 있습니다');
          _showNotificationDeniedMessage();
        }
      } catch (e) {
        print('❌ 웹 알림 초기화 실패: $e');
      }
    });
  }
}

/// 알림 권한 요청 안내 메시지
void _showNotificationPermissionDialog() {
  if (kIsWeb) {
    print('💡 사용자에게 알림 권한 요청 중...');
    // 브라우저 콘솔에 안내 메시지
    try {
      final jsCode = '''
        console.log("🔔 Todo 앱에서 할 일 알람을 위해 알림 권한이 필요합니다.");
        console.log("💡 브라우저에서 알림 허용 버튼을 클릭해주세요!");
      ''';
      // js 실행은 웹에서만 가능하므로 try-catch로 감싸기
    } catch (e) {
      // 무시
    }
  }
}

/// 알림 권한 거부 시 안내 메시지
void _showNotificationDeniedMessage() {
  if (kIsWeb) {
    print('ℹ️ 알림 권한이 거부되었습니다. 설정에서 수동으로 변경할 수 있습니다.');
    try {
      final jsCode = '''
        console.log("ℹ️ 알림 권한이 거부되었습니다.");
        console.log("💡 브라우저 설정 > 사이트 설정 > 알림에서 수동으로 허용할 수 있습니다.");
      ''';
      // js 실행
    } catch (e) {
      // 무시
    }
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      windowManager.addListener(this);
      _setPreventClose();
    }
  }

  @override
  void dispose() {
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
      windowManager.removeListener(this);
    }
    super.dispose();
  }

  void _setPreventClose() async {
    await windowManager.setPreventClose(true);
  }

  @override
  void onWindowClose() async {
    // 윈도우가 닫힐 때 트레이로 최소화
    await SystemTrayService().hideApp();
  }

  Future<bool> _checkFirebaseInit() async {
    final initFacade = AppInitializationFacade.create();
    return await initFacade.initializeFirebase();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false, // Material 3 비활성화
      ),
      home: FutureBuilder(
        future: _checkFirebaseInit(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.data == true) {
            return StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasData) {
                  return const AuthenticatedApp();
                } else {
                  return const LoginScreen();
                }
              },
            );
          } else {
            // Firebase 초기화 실패 시 바로 TODO 화면으로
            return const TaskTabbarScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const TaskTabbarScreen(),
      },
    );
  }
}

/// 인증된 사용자를 위한 앱 위젯 - 세션 체크 포함
class AuthenticatedApp extends StatefulWidget {
  const AuthenticatedApp({super.key});

  @override
  State<AuthenticatedApp> createState() => _AuthenticatedAppState();
}

class _AuthenticatedAppState extends State<AuthenticatedApp> {
  bool _isSessionChecking = true;
  bool _sessionCheckComplete = false;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  /// 사용자 세션 체크 및 데이터 동기화
  Future<void> _checkUserSession() async {
    try {
      print('사용자 세션 체크 시작...');
      
      // 사용자 세션 서비스를 통해 체크 및 동기화
      await UserSessionService.instance.checkAndSyncUserSession();
      
      print('사용자 세션 체크 완료');
    } catch (e) {
      print('세션 체크 중 오류 발생: $e');
      // 오류가 발생해도 앱은 계속 실행
    } finally {
      if (mounted) {
        setState(() {
          _isSessionChecking = false;
          _sessionCheckComplete = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isSessionChecking) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '데이터를 동기화하고 있습니다...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const TaskTabbarScreen();
  }
}
