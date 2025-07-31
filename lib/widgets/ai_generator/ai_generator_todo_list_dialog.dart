/// **AI Generator Todo 목록 위젯 (다이얼로그용)**
/// 
/// AI가 생성한 Todo 텍스트 목록을 표시하고 선택할 수 있는 위젯입니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/providers/todo_provider.dart';
import '../../domain/entities/todo_entity.dart';
import '../../core/utils/app_logger.dart';
import '../../services/hive_todo_repository.dart';
import '../../model/todo_item.dart';

class AiGeneratorTodoList extends ConsumerStatefulWidget {
  final List<String> todos;

  const AiGeneratorTodoList({
    super.key,
    required this.todos,
  });

  @override
  ConsumerState<AiGeneratorTodoList> createState() => _AiGeneratorTodoListState();
}

class _AiGeneratorTodoListState extends ConsumerState<AiGeneratorTodoList> {
  final Set<int> _selectedIndices = {};

  @override
  void initState() {
    super.initState();
    // 기본적으로 모든 항목 선택
    _selectedIndices.addAll(List.generate(widget.todos.length, (index) => index));
  }

  /// 선택된 Todo들을 실제 Todo로 추가
  void _addSelectedTodos() async {
    if (_selectedIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('추가할 항목을 선택해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final selectedTodos = _selectedIndices
          .map((index) => widget.todos[index])
          .toList();

      // 기존 Hive Repository에 TODO 추가 (TodoScreen과 호환)
      final hiveRepository = HiveTodoRepository();
      
      for (final todoTitle in selectedTodos) {
        // 기존 TodoItem 형식으로 생성
        final todoItem = TodoItem(
          title: todoTitle.trim(),
          priority: 'Medium',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          isCompleted: false,
          category: 'Personal',
        );
        
        await hiveRepository.addTodo(todoItem);
        
        // 새로운 Riverpod Provider에도 추가 (캘린더 등 다른 기능과 호환)
        try {
          await ref.read(todoListProvider.notifier).addTodo(
            title: todoTitle.trim(),
            description: '',
            priority: TodoPriority.medium,
            dueDate: DateTime.now().add(const Duration(days: 1)),
            category: TodoCategory.personal,
          );
        } catch (e) {
          // Riverpod 시스템 실패해도 계속 진행
          AppLogger.warning('Failed to add to Riverpod system: $e', tag: 'AI');
        }
      }

      AppLogger.info('Added ${selectedTodos.length} AI-generated todos to both systems', tag: 'AI');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${selectedTodos.length}개의 할 일이 추가되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to add AI-generated todos', 
        tag: 'AI', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('할 일 추가 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildHeader(),
          
          const SizedBox(height: 12),
          
          // Todo 목록
          Expanded(
            child: _buildTodoList(),
          ),
          
          const SizedBox(height: 16),
          
          // 액션 버튼들
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// 헤더 구성
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.checklist,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          '생성된 할 일 목록',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_selectedIndices.length}/${widget.todos.length} 선택',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
      ],
    );
  }

  /// Todo 목록 구성
  Widget _buildTodoList() {
    return ListView.separated(
      itemCount: widget.todos.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final todo = widget.todos[index];
        final isSelected = _selectedIndices.contains(index);
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedIndices.add(index);
                  } else {
                    _selectedIndices.remove(index);
                  }
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              todo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () {
              setState(() {
                if (_selectedIndices.contains(index)) {
                  _selectedIndices.remove(index);
                } else {
                  _selectedIndices.add(index);
                }
              });
            },
          ),
        );
      },
    );
  }

  /// 액션 버튼들 구성
  Widget _buildActionButtons() {
    return Row(
      children: [
        // 전체 선택/해제
        TextButton.icon(
          onPressed: () {
            setState(() {
              if (_selectedIndices.length == widget.todos.length) {
                _selectedIndices.clear();
              } else {
                _selectedIndices.clear();
                _selectedIndices.addAll(List.generate(widget.todos.length, (index) => index));
              }
            });
          },
          icon: Icon(
            _selectedIndices.length == widget.todos.length 
                ? Icons.deselect 
                : Icons.select_all,
            size: 16,
          ),
          label: Text(
            _selectedIndices.length == widget.todos.length 
                ? '전체 해제' 
                : '전체 선택',
          ),
        ),
        
        const Spacer(),
        
        // 추가 버튼
        ElevatedButton.icon(
          onPressed: _selectedIndices.isEmpty ? null : _addSelectedTodos,
          icon: const Icon(Icons.add, size: 18),
          label: Text('할 일 추가 (${_selectedIndices.length})'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }
}