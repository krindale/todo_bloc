/// **메인 탭 화면**
/// 
/// Task, Calendar, Summary, Link 탭을 관리하는 메인 화면입니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/app_logger.dart';
import 'todo_screen.dart';
import 'calendar/calendar_screen.dart';
import 'task_summary_screen.dart';
import 'saved_link_screen.dart';
import '../widgets/ai_generator/ai_todo_generator_dialog.dart';

/// 탭 인덱스 Provider
final selectedTabIndexProvider = StateProvider<int>((ref) => 0);

/// 메인 탭 화면
class MainTabScreen extends ConsumerStatefulWidget {
  const MainTabScreen({super.key});

  @override
  ConsumerState<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends ConsumerState<MainTabScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<_TodoScreenWrapperState> _todoScreenKey = GlobalKey<_TodoScreenWrapperState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    AppLogger.info('MainTabScreen initialized', tag: 'UI');
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    
    final newIndex = _tabController.index;
    ref.read(selectedTabIndexProvider.notifier).state = newIndex;
    AppLogger.debug('Tab changed to index: $newIndex', tag: 'UI');
  }

  /// AI Todo Generator 다이얼로그 표시
  void _showAiGeneratorDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AiTodoGeneratorDialog(
        onTodosAdded: () {
          // AI로 생성된 할 일이 추가되면 TodoScreen 새로고침
          _todoScreenKey.currentState?.refreshTodos();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedTabIndex = ref.watch(selectedTabIndexProvider);
    
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildTabBarView(),
      floatingActionButton: _buildFloatingActionButton(selectedTabIndex),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 앱바 구성
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Todo Manager',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      bottom: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.task_alt, size: 20),
            text: 'Tasks',
          ),
          Tab(
            icon: Icon(Icons.calendar_month, size: 20),
            text: 'Calendar',
          ),
          Tab(
            icon: Icon(Icons.analytics, size: 20),
            text: 'Summary',
          ),
          Tab(
            icon: Icon(Icons.link, size: 20),
            text: 'Links',
          ),
        ],
      ),
    );
  }

  /// 탭바 뷰 구성
  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        TodoScreenWrapper(key: _todoScreenKey),
        const CalendarScreen(),
        const TaskSummaryScreen(),
        const SavedLinkScreen(),
      ],
    );
  }

  /// 플로팅 액션 버튼 구성 (Task 탭에서만 표시)
  Widget? _buildFloatingActionButton(int selectedIndex) {
    if (selectedIndex != 0) return null; // Task 탭이 아니면 null 반환

    return FloatingActionButton.extended(
      onPressed: _showAiGeneratorDialog,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      icon: const Icon(Icons.auto_awesome, size: 20),
      label: const Text(
        'AI 생성',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      elevation: 4,
      focusElevation: 6,
      hoverElevation: 6,
      highlightElevation: 8,
    );
  }
}

/// TodoScreen을 감싸는 Wrapper 클래스
/// GlobalKey를 통해 TodoScreen의 메서드에 접근할 수 있도록 합니다.
class TodoScreenWrapper extends StatefulWidget {
  const TodoScreenWrapper({super.key});

  @override
  State<TodoScreenWrapper> createState() => _TodoScreenWrapperState();
}

class _TodoScreenWrapperState extends State<TodoScreenWrapper> {
  final GlobalKey<TodoScreenState> _todoScreenKey = GlobalKey<TodoScreenState>();

  /// AI에서 할 일이 추가되었을 때 호출되는 새로고침 메서드
  void refreshTodos() {
    _todoScreenKey.currentState?.refreshTodos();
  }

  @override
  Widget build(BuildContext context) {
    return TodoScreen.withDefaults(key: _todoScreenKey);
  }
}