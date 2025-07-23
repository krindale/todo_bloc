import 'package:flutter/material.dart';

import '../widgets/todo_screen/task_input.dart';
import '../widgets/todo_screen/task_list.dart';
import '../model/todo_item.dart';
import '../services/todo_repository.dart';
import '../services/hive_todo_repository.dart';
import '../services/task_categorization_service.dart';

// 5. Main Todo Screen Widget
class TodoScreen extends StatefulWidget {
  final TodoRepository? todoRepository;
  final TaskCategorizationService? categorizationService;

  const TodoScreen({
    Key? key,
    this.todoRepository,
    this.categorizationService,
  }) : super(key: key);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _taskController = TextEditingController();
  String _selectedPriority = 'High';
  DateTime? _selectedDate;
  List<TodoItem> _tasks = [];
  int? _editingIndex; // 현재 수정 중인 할 일의 인덱스 (null이면 새 할 일 추가 모드)

  late final TodoRepository _todoRepository;
  late final TaskCategorizationService _categorizationService;

  @override
  void initState() {
    super.initState();
    _todoRepository = widget.todoRepository ?? HiveTodoRepository();
    _categorizationService = widget.categorizationService ?? TaskCategorizationService();
    _loadTodos();
  }

  // ✅ 할 일 불러오기
  void _loadTodos() async {
    final data = await _todoRepository.getTodos();
    setState(() {
      _tasks = data;
    });
  }

  // ✅ 할 일 추가
  void _addTodo(TodoItem newTodo) async {
    await _todoRepository.addTodo(newTodo);
    _loadTodos();
  }
  // ✅ 할 일 업데이트
  void _updateTodo(int index, TodoItem updatedTodo) async {
    await _todoRepository.updateTodo(index, updatedTodo);
    _loadTodos();
  }

  // ✅ 할 일 삭제
  void _deleteTodo(int index) async {
    await _todoRepository.deleteTodo(index);
    _loadTodos();
  }

  void _addOrUpdateTask() {
    if (_taskController.text.isEmpty) return;

    // 날짜가 선택되지 않은 경우 오늘 날짜를 기본값으로 사용
    final dueDate = _selectedDate ?? DateTime.now();

    setState(() {
      if (_editingIndex == null) {
        // 새 할 일 추가 - 자동 카테고리 분류
        var newTodo = TodoItem(
          title: _taskController.text,
          priority: _selectedPriority,
          dueDate: dueDate,
          isCompleted: false,
        );
        // 자동 분류된 할 일로 업데이트
        final categorizedTodo = _categorizationService.categorizeAndUpdateTask(newTodo);
        _addTodo(categorizedTodo);
      } else {
        // 기존 할 일 수정 - 제목이 변경되면 다시 분류
        var updatedTodo = TodoItem(
          title: _taskController.text,
          priority: _selectedPriority,
          dueDate: dueDate,
          isCompleted: _tasks[_editingIndex!].isCompleted,
        );
        // 자동 분류된 할 일로 업데이트
        final categorizedTodo = _categorizationService.categorizeAndUpdateTask(updatedTodo);
        _updateTodo(_editingIndex!, categorizedTodo);
        _editingIndex = null; // 수정 완료 후 초기화
      }
      _taskController.clear();
      _selectedDate = null;
    });
  }

  /// **수정 취소 (초기화)** 메서드
  void _cancelEditing() {
    setState(() {
      _editingIndex = null;
      _taskController.clear();
      _selectedDate = null;
    });
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TaskInput(
            taskController: _taskController,
            selectedPriority: _selectedPriority,
            selectedDate: _selectedDate,
            onPickDate: _pickDate,
            onAddOrUpdateTask: _addOrUpdateTask,
            onCancelEditing: _cancelEditing,
            isEditing: _editingIndex != null,
            onPriorityChanged: (priority) {
              setState(() {
                _selectedPriority = priority;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TaskList(
              tasks: _tasks,
              onEdit: (index) {
                setState(() {
                  _editingIndex = index;
                  _taskController.text = _tasks[index].title;
                  _selectedPriority = _tasks[index].priority;
                  _selectedDate = _tasks[index].dueDate;
                });
              },
              onDelete: (index) {
                setState(() {
                  _tasks.removeAt(index);
                  _deleteTodo(index);
                });
              },
              onCompleteChanged: (index, value) {
                setState(() {
                  _tasks[index] = TodoItem(
                    title: _tasks[index].title,
                    priority: _tasks[index].priority,
                    dueDate: _tasks[index].dueDate,
                    isCompleted: value ?? false,
                    category: _tasks[index].category,
                  );
                });
                // 데이터베이스에 업데이트하여 task summary에 실시간 반영
                _updateTodo(index, _tasks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}