/// **메인 탭바 네비게이션 화면**
/// 
/// 앱의 핵심 기능들을 탭 형태로 구성한 메인 네비게이션 화면입니다.
/// Material Design의 TabBar를 활용하여 직관적인 네비게이션을 제공합니다.
/// 
/// **탭 구성:**
/// - **Tasks**: TodoScreen - 할 일 추가/관리
/// - **AI Generator**: AiTodoGeneratorScreen - AI 할 일 생성
/// - **Summary**: TaskSummaryScreen - 생산성 분석  
/// - **Links**: SavedLinksScreen - 북마크 관리
/// 
/// **주요 기능:**
/// - 탭 간 상태 유지 (AutomaticKeepAliveClientMixin)
/// - 로그아웃 기능 (AppBar 액션)
/// - Firebase 인증 상태 연동
/// - 반응형 레이아웃 (모바일/데스크톱)
/// 
/// **네비게이션 패턴:**
/// - DefaultTabController: 탭 상태 관리
/// - 각 탭의 독립적인 상태 관리
/// - 앱바 통합 (제목, 액션 버튼)
/// 
/// **사용자 경험:**
/// - 부드러운 탭 전환 애니메이션
/// - 현재 탭 시각적 표시
/// - 접근성 지원 (탭 라벨)
/// - 일관된 머티리얼 디자인

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../todo_screen.dart';
import '../task_summary_screen.dart';
import '../saved_links_screen.dart';
import '../ai_todo_generator_screen.dart';
import '../../util/todo_database.dart';
import '../../services/saved_link_repository.dart';
import '../../services/user_session_service.dart';

class TaskTabbarScreen extends StatelessWidget {
  const TaskTabbarScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
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
              Tab(text: 'Tasks'),
              Tab(text: 'AI Generator'),
              Tab(text: 'Summary'),
              Tab(text: 'Links'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TodoScreen.withDefaults(),      // Tasks 탭
            AiTodoGeneratorScreen(),        // AI Generator 탭
            TaskSummaryScreen(),            // Summary 탭  
            SavedLinksScreen(),             // Links 탭
          ],
        ),
      ),
    );
  }
}
