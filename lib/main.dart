import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'model/todo_item.dart';
import 'model/saved_link.dart';
import 'screen/tabbar/task_tabbar_screen.dart';
import 'screen/login/login_screen.dart';
import 'screen/login/signup_screen.dart';
import 'services/user_session_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Hive 초기화 (await 사용)
  await Hive.initFlutter();
  Hive.registerAdapter(TodoItemAdapter()); // TodoItem 어댑터 등록
  Hive.registerAdapter(SavedLinkAdapter()); // SavedLink 어댑터 등록
  
  // 윈도우 매니저 초기화 (데스크톱 플랫폼만)
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    
    WindowOptions windowOptions = const WindowOptions(
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
    
    await initSystemTray();
  }
  
  runApp(const MyApp());
}

final SystemTray _systemTray = SystemTray();
final Menu _menuMain = Menu();
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> initSystemTray() async {
  try {
    // 시스템 트레이 초기화
    await _systemTray.initSystemTray(
      iconPath: 'assets/images/tray_icon.ico',
      title: "Todo App", 
      toolTip: "Todo 관리 앱 - 우클릭하세요",
    );
    
    print('System tray icon initialized');
    
    // 컨텍스트 메뉴 생성 및 설정
    print('Building context menu...');
    
    await _menuMain.buildFrom([
      MenuItemLabel(
        label: 'Show Todo App',
        onClicked: (menuItem) {
          print('[MENU] Show Todo App clicked');
          _showApp();
        }
      ),
      MenuItemLabel(
        label: 'Hide App',
        onClicked: (menuItem) {
          print('[MENU] Hide App clicked');  
          _hideApp();
        }
      ),
      MenuSeparator(),
      MenuItemLabel(
        label: 'Exit App',
        onClicked: (menuItem) {
          print('[MENU] Exit App clicked');
          _exitApp();
        }
      ),
    ]);
    
    print('Menu built successfully');
    
    // 시스템 트레이에 메뉴 설정
    await _systemTray.setContextMenu(_menuMain);
    print('Context menu attached to system tray');
    
    // 트레이 아이콘 이벤트 처리
    _systemTray.registerSystemTrayEventHandler((eventName) {
      print('=== System tray event: $eventName ===');
      
      switch (eventName) {
        case kSystemTrayEventClick:
          print('Left click - showing app');
          _showApp();
          break;
        case kSystemTrayEventRightClick:
          print('Right click - context menu should auto-show');
          // 우클릭 시 자동으로 컨텍스트 메뉴가 표시되어야 함
          // 만약 자동으로 표시되지 않는다면 수동으로 호출 시도
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
    
    print('System tray initialized successfully');
  } catch (e) {
    print('System tray initialization failed: $e');
    print('Error details: ${e.toString()}');
  }
}

void _showApp() async {
  // Flutter 앱을 표시
  await windowManager.show();
  await windowManager.focus();
}

void _hideApp() async {
  // Flutter 앱을 숨기기 (트레이로 최소화)
  await windowManager.hide();
}

void _exitApp() async {
  print('앱 종료 시작...');
  
  try {
    // 시스템 트레이 정리
    await _systemTray.destroy();
    print('시스템 트레이 정리 완료');
  } catch (e) {
    print('시스템 트레이 정리 중 오류: $e');
  }
  
  try {
    // 윈도우 종료
    await windowManager.destroy();
    print('윈도우 종료 완료');
  } catch (e) {
    print('윈도우 종료 중 오류: $e');
  }
  
  print('앱 완전 종료');
  exit(0);
}

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
    _hideApp();
  }

  Future<bool> _checkFirebaseInit() async {
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
