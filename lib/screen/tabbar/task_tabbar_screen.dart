import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../todo_screen.dart';
import '../task_summary_screen.dart';
import '../saved_links_screen.dart';
import '../../util/todo_database.dart';
import '../../services/saved_link_repository.dart';
import '../../services/user_session_service.dart';

class TaskTabbarScreen extends StatelessWidget {
  const TaskTabbarScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Task Manager'),
          automaticallyImplyLeading: false, // 백버튼 제거
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'logout') {
                  try {
                    // 사용자 세션 서비스를 통한 로그아웃 처리
                    await UserSessionService.instance.onUserLogout();
                    
                    // Firebase 로그아웃
                    await FirebaseAuth.instance.signOut();
                    
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
                      );
                    }
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('로그아웃'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Task List'),
              Tab(text: 'Task Summary'),
              Tab(text: 'Saved Links'), // 새 탭 추가
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TodoScreen.withDefaults(),
            TaskSummaryScreen(),
            SavedLinksScreen(),
          ],
        ),
      ),
    );
  }
}
