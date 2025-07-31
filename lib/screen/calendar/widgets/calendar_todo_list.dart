/// **캘린더 Todo 목록 위젯**
/// 
/// 선택된 날짜의 Todo 항목들을 표시하는 위젯입니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/todo_entity.dart';
import '../../../presentation/providers/todo_provider.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../screen/widgets/todo_item_card.dart';

class CalendarTodoList extends ConsumerWidget {
  final DateTime selectedDate;
  final List<TodoEntity> todos;

  const CalendarTodoList({
    super.key,
    required this.selectedDate,
    required this.todos,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildTodoList(context, ref),
        ],
      ),
    );
  }

  /// 헤더 구성
  Widget _buildHeader(BuildContext context) {
    final dateText = DateFormatter.formatMonthDayWeekday(selectedDate);
    final isToday = _isToday(selectedDate);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_note,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            dateText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (isToday) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '오늘',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
          const Spacer(),
          _buildTodoStats(context),
        ],
      ),
    );
  }

  /// Todo 통계 표시
  Widget _buildTodoStats(BuildContext context) {
    final completedCount = todos.where((todo) => todo.isCompleted).length;
    final totalCount = todos.length;
    
    if (totalCount == 0) {
      return Text(
        '할 일 없음',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
      );
    }
    
    return Row(
      children: [
        Text(
          '$completedCount/$totalCount',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 40,
          height: 4,
          child: LinearProgressIndicator(
            value: totalCount > 0 ? completedCount / totalCount : 0,
            backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// Todo 목록 구성
  Widget _buildTodoList(BuildContext context, WidgetRef ref) {
    if (todos.isEmpty) {
      return _buildEmptyState(context);
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: todos.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final todo = todos[index];
          return TodoItemCard(
            todo: todo,
            onToggleComplete: () => _toggleTodoCompletion(ref, todo.id),
            onEdit: () => _editTodo(context, todo),
            onDelete: () => _deleteTodo(ref, todo.id),
            showDate: false, // 캘린더에서는 날짜 표시 안함
          );
        },
      ),
    );
  }

  /// 빈 상태 표시
  Widget _buildEmptyState(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              size: 48,
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '이 날에는 할 일이 없습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI 생성 버튼으로 새로운 할 일을 추가해보세요',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 오늘 날짜 확인
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  /// Todo 완료 상태 토글
  void _toggleTodoCompletion(WidgetRef ref, String todoId) {
    try {
      ref.read(todoListProvider.notifier).toggleCompletion(todoId);
      AppLogger.info('Todo completion toggled: $todoId', tag: 'Calendar');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to toggle todo completion', 
        tag: 'Calendar', error: e, stackTrace: stackTrace);
    }
  }

  /// Todo 편집
  void _editTodo(BuildContext context, TodoEntity todo) {
    // TODO: Todo 편집 화면으로 이동
    AppLogger.info('Edit todo requested: ${todo.id}', tag: 'Calendar');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Todo 편집 기능은 곧 추가될 예정입니다.')),
    );
  }

  /// Todo 삭제
  void _deleteTodo(WidgetRef ref, String todoId) {
    try {
      ref.read(todoListProvider.notifier).deleteTodo(todoId);
      AppLogger.info('Todo deleted: $todoId', tag: 'Calendar');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete todo', 
        tag: 'Calendar', error: e, stackTrace: stackTrace);
    }
  }
}