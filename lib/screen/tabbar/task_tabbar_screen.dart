/// **메인 탭바 네비게이션 화면**
/// 
/// 앱의 핵심 기능들을 탭 형태로 구성한 메인 네비게이션 화면입니다.
/// Material Design의 TabBar를 활용하여 직관적인 네비게이션을 제공합니다.
/// 
/// **탭 구성:**
/// - **Tasks**: TodoScreen - 할 일 추가/관리
/// - **AI Generator**: AI 할 일 생성 (현재 플로팅 버튼으로 이동)
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
/// - TabController: 탭 상태 관리 및 프로그래밍 방식 전환
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
import '../../services/user_session_service.dart';

class TaskTabbarScreen extends StatefulWidget {
  const TaskTabbarScreen({super.key});
  
  @override
  State<TaskTabbarScreen> createState() => _TaskTabbarScreenState();
}

class _TaskTabbarScreenState extends State<TaskTabbarScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          controller: _tabController,
          tabs: [
            Tab(text: 'Tasks'),
            Tab(text: 'AI Generator'),
            Tab(text: 'Summary'),
            Tab(text: 'Links'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          TodoScreen.withDefaults(),      // Tasks 탭
          _buildAiGeneratorPlaceholder(), // AI Generator 탭 (플레이스홀더)
          TaskSummaryScreen(),            // Summary 탭  
          SavedLinksScreen(),             // Links 탭
        ],
      ),
    );
  }

  /// AI Generator 플레이스홀더 위젯
  Widget _buildAiGeneratorPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'AI 생성기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'AI 생성기는 Tasks 탭의 플로팅 버튼으로 이동했습니다.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}