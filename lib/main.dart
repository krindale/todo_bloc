import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
