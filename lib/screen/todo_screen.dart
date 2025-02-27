import 'package:flutter/material.dart';

import '../widgets/todo_screen/task_input.dart';
import '../widgets/todo_screen/task_list.dart';

import '../../../model/todo_item.dart';
import '../../../util/todo_database.dart';

// 5. Main Todo Screen Widget
class TodoScreen extends StatefulWidget {
  const TodoScreen({Key? key}) : super(key: key);

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _taskController = TextEditingController();
  String _selectedPriority = 'High';
  DateTime? _selectedDate;
  List<TodoItem> _tasks = [];
  int? _editingIndex; // 현재 수정 중인 할 일의 인덱스 (null이면 새 할 일 추가 모드)

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // ✅ 할 일 불러오기
  void _loadTodos() async {
    final data = await TodoDatabase.getTodos();
    setState(() {
      _tasks = data;
    });
  }

  // ✅ 할 일 추가
  void _addTodo(TodoItem newTodo) async {
    await TodoDatabase.addTodo(newTodo);
    _loadTodos();
  }
  // ✅ 할 일 업데이트
  void _updateTodo(int index, TodoItem updatedTodo) async {
    await TodoDatabase.updateTodo(index, updatedTodo);
    _loadTodos();
  }

  // ✅ 할 일 삭제
  void _deleteTodo(int index) async {
    await TodoDatabase.deleteTodo(index);
    _loadTodos();
  }

  void _addOrUpdateTask() {
    if (_taskController.text.isEmpty || _selectedDate == null) return;

    setState(() {
      if (_editingIndex == null) {
        var newTodo = TodoItem(
          title: _taskController.text,
          priority: _selectedPriority,
          dueDate: _selectedDate!,
          isCompleted: false,
        );
        _addTodo(newTodo);
      } else {
        // 기존 할 일 수정
      var updatedTodo = TodoItem(
        title: _taskController.text,
        priority: _selectedPriority,
        dueDate: _selectedDate!,
        isCompleted: _tasks[_editingIndex!].isCompleted,
      );
      _updateTodo(_editingIndex!, updatedTodo);
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
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}