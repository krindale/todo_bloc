import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'model/todo_item.dart';
import 'screen/tabbar/task_tabbar_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Hive 초기화 (await 사용)
  await Hive.initFlutter();
  Hive.registerAdapter(TodoItemAdapter()); // TodoItem 어댑터 등록
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
                  return TaskTabbarScreen();
                } else {
                  return const LoginScreen();
                }
              },
            );
          } else {
            // Firebase 초기화 실패 시 바로 TODO 화면으로
            return TaskTabbarScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => TaskTabbarScreen(),
      },
    );
  }
}
