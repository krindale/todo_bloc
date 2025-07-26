import 'package:flutter/material.dart';
import 'task_card.dart';
import '../../model/todo_item.dart';

// 4. Task List Widget
class TaskList extends StatelessWidget {
  final List<TodoItem> tasks;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final Function(int, bool?) onCompleteChanged;

  const TaskList({
    Key? key,
    required this.tasks,
    required this.onEdit,
    required this.onDelete,
    required this.onCompleteChanged,
  }) : super(key: key);

  Map<String, List<TodoItem>> _groupTasksByStatus() {
    final Map<String, List<TodoItem>> groupedTasks = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 지난 날의 완료된 할일들
    final pastCompleted = <TodoItem>[];
    // 오늘과 미래의 할일들 (완료/미완료 구분 없이)
    final currentAndFuture = <TodoItem>[];
    // 지난 날의 미완료된 할일들 (중요)
    final pastIncomplete = <TodoItem>[];

    for (final task in tasks) {
      final taskDate = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      final isPast = taskDate.isBefore(today);
      
      if (isPast && task.isCompleted) {
        pastCompleted.add(task);
      } else if (isPast && !task.isCompleted) {
        pastIncomplete.add(task);
      } else {
        currentAndFuture.add(task);
      }
    }

    // 그룹별로 정리
    if (pastCompleted.isNotEmpty) {
      groupedTasks['지난 날 완료된 할일'] = pastCompleted;
    }
    
    if (pastIncomplete.isNotEmpty) {
      groupedTasks['지난 날 미완료된 할일'] = pastIncomplete;
    }
    
    if (currentAndFuture.isNotEmpty) {
      groupedTasks['현재 및 예정된 할일'] = currentAndFuture;
    }

    return groupedTasks;
  }

  List<MapEntry<String, List<TodoItem>>> _getSortedGroups() {
    final groupedTasks = _groupTasksByStatus();
    final sortedEntries = <MapEntry<String, List<TodoItem>>>[];
    
    // 정렬 순서: 지난 날 완료 → 현재/예정 → 지난 날 미완료
    if (groupedTasks.containsKey('지난 날 완료된 할일')) {
      sortedEntries.add(MapEntry('지난 날 완료된 할일', groupedTasks['지난 날 완료된 할일']!));
    }
    
    if (groupedTasks.containsKey('현재 및 예정된 할일')) {
      sortedEntries.add(MapEntry('현재 및 예정된 할일', groupedTasks['현재 및 예정된 할일']!));
    }
    
    if (groupedTasks.containsKey('지난 날 미완료된 할일')) {
      sortedEntries.add(MapEntry('지난 날 미완료된 할일', groupedTasks['지난 날 미완료된 할일']!));
    }
    
    return sortedEntries;
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text(
          '할 일이 없습니다!',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final groupedTasks = _getSortedGroups();

    return AnimatedList(
      initialItemCount: groupedTasks.length,
      itemBuilder: (context, groupIndex, animation) {
        if (groupIndex >= groupedTasks.length) {
          return Container(); // 안전장치
        }
        
        final entry = groupedTasks[groupIndex];
        final groupName = entry.key;
        final groupTasks = entry.value;

        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(1.0, 0.0), // 오른쪽에서 시작
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: FadeTransition(
            opacity: animation,
            child: _TaskGroupWidget(
              key: ValueKey('$groupName-${groupTasks.length}'),
              groupName: groupName,
              tasks: groupTasks,
              onEdit: (taskIndex) {
                final originalIndex = tasks.indexOf(groupTasks[taskIndex]);
                onEdit(originalIndex);
              },
              onDelete: (taskIndex) {
                final originalIndex = tasks.indexOf(groupTasks[taskIndex]);
                onDelete(originalIndex);
              },
              onCompleteChanged: (taskIndex, value) {
                final originalIndex = tasks.indexOf(groupTasks[taskIndex]);
                onCompleteChanged(originalIndex, value);
              },
              isCollapsible: groupName == '지난 날 완료된 할일',
            ),
          ),
        );
      },
    );
  }
}

class _TaskGroupWidget extends StatefulWidget {
  final String groupName;
  final List<TodoItem> tasks;
  final Function(int) onEdit;
  final Function(int) onDelete;
  final Function(int, bool?) onCompleteChanged;
  final bool isCollapsible;

  const _TaskGroupWidget({
    Key? key,
    required this.groupName,
    required this.tasks,
    required this.onEdit,
    required this.onDelete,
    required this.onCompleteChanged,
    this.isCollapsible = false,
  }) : super(key: key);

  @override
  _TaskGroupWidgetState createState() => _TaskGroupWidgetState();
}

class _TaskGroupWidgetState extends State<_TaskGroupWidget> 
    with SingleTickerProviderStateMixin {
  bool _isCollapsed = true; // 기본적으로 접힌 상태
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _iconRotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _iconRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
    });
    
    if (_isCollapsed) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.isCollapsible ? _toggleCollapse : null,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _getGroupColor(widget.groupName),
                borderRadius: widget.isCollapsible && _isCollapsed 
                    ? BorderRadius.circular(8.0)
                    : const BorderRadius.vertical(top: Radius.circular(8.0)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getGroupIcon(widget.groupName),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      '${widget.groupName} (${widget.tasks.length}개)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (widget.isCollapsible) ...[
                    AnimatedBuilder(
                      animation: _iconRotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _iconRotationAnimation.value * 3.14159, // π radians = 180도
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 24,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (!widget.isCollapsible)
            // 접을 수 없는 그룹은 바로 표시
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: widget.tasks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final task = entry.value;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 200),
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 0.95 + (0.05 * value),
                          child: Opacity(
                            opacity: value,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 4.0),
                              child: TaskCard(
                                key: ValueKey('${task.title}-${task.dueDate}-${task.isCompleted}'),
                                task: task,
                                onEdit: () => widget.onEdit(index),
                                onDelete: () => widget.onDelete(index),
                                onCompleteChanged: (value) => widget.onCompleteChanged(index, value),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            )
          else
            // 접을 수 있는 그룹은 애니메이션 적용
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: FadeTransition(
                opacity: _expandAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: widget.tasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final task = entry.value;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 200),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          builder: (context, value, child) {
                            return Transform.scale(
                              scale: 0.95 + (0.05 * value),
                              child: Opacity(
                                opacity: value,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: TaskCard(
                                    key: ValueKey('${task.title}-${task.dueDate}-${task.isCompleted}'),
                                    task: task,
                                    onEdit: () => widget.onEdit(index),
                                    onDelete: () => widget.onDelete(index),
                                    onCompleteChanged: (value) => widget.onCompleteChanged(index, value),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getGroupColor(String groupName) {
    switch (groupName) {
      case '지난 날 완료된 할일':
        return Colors.green.shade600;
      case '현재 및 예정된 할일':
        return Colors.blue.shade600;
      case '지난 날 미완료된 할일':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getGroupIcon(String groupName) {
    switch (groupName) {
      case '지난 날 완료된 할일':
        return Icons.check_circle;
      case '현재 및 예정된 할일':
        return Icons.schedule;
      case '지난 날 미완료된 할일':
        return Icons.warning;
      default:
        return Icons.list;
    }
  }
}