import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'model/todo_item.dart';
import 'screen/tabbar/task_tabbar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Hive 초기화 (await 사용)
  await Hive.initFlutter();
  Hive.registerAdapter(TodoItemAdapter()); // TodoItem 어댑터 등록
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false, // Material 3 비활성화
      ),
      home: TaskTabbarScreen(),
    );
  }
}
