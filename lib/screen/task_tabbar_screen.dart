import 'package:flutter/material.dart';
import 'todo_screen.dart';
import 'task_summary_screen.dart';
import 'saved_links_screen.dart';

class TaskTabbarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Task Manager'),
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
            TodoScreen(),
            TaskSummaryScreen(),
            SavedLinksScreen(),
          ],
        ),
      ),
    );
  }
}
