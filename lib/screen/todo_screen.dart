import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/todo_item.dart';
import '../util/todo_database.dart';

class TodoScreen extends StatefulWidget {
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
        _loadTodos();
      } else {
        // 기존 할 일 수정
        var updatedTodo = TodoItem(
          title: _taskController.text,
          priority: _selectedPriority,
          dueDate: _selectedDate!,
          isCompleted: _tasks[_editingIndex!].isCompleted,
        );
        _updateTodo(_editingIndex!, updatedTodo);
        _loadTodos();
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
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildTaskInput(),
          SizedBox(height: 16),
          Expanded(child: _buildTaskList()),
        ],
      ),
    );
  }

Widget _buildTaskInput() {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 4,
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _taskController,
            decoration: InputDecoration(
              labelText: 'Task Description',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildPrioritySelector()),
              if (_editingIndex != null) ...[
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _cancelEditing,
                  child: Text('Cancel'),
                ),
              ],
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.date_range),
                  label: Text(_selectedDate == null
                      ? 'Due Date'
                      : DateFormat.yMMMd().format(_selectedDate!)),
                  onPressed: _pickDate,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _addOrUpdateTask,
                  child: Text(_editingIndex == null ? '+ Add Task' : 'Update Task'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
  Widget _buildPrioritySelector() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ToggleButtons(
        borderRadius: BorderRadius.circular(12),
        isSelected: ['High', 'Medium', 'Low'].map((e) => e == _selectedPriority).toList(),
        onPressed: (int index) {
          setState(() {
            _selectedPriority = ['High', 'Medium', 'Low'][index];
          });
        },
        constraints: BoxConstraints(
          minHeight: 30.0,
          minWidth: 60.0,
        ),
        children: [
          Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), child: Text('High')),
          Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), child: Text('Medium')),
          Padding(padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), child: Text('Low')),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(index);
      },
    );
  }

  Widget _buildTaskCard(int index) {
    TodoItem task = _tasks[index];
    Color priorityColor;
    switch (task.priority) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.green;
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        leading: Container(
          width: 5,
          height: double.infinity,
          color: priorityColor,
        ),
        title: Text(task.title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Due: ${DateFormat.yMMMd().format(task.dueDate)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (bool? value) {
                setState(() {
                  _tasks[index] = TodoItem(
                    title: task.title,
                    priority: task.priority,
                    dueDate: task.dueDate,
                    isCompleted: value ?? false,
                  );
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                setState(() {
                  _editingIndex = index;
                  _taskController.text = task.title;
                  _selectedPriority = task.priority;
                  _selectedDate = task.dueDate;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  _tasks.removeAt(index);
                  _deleteTodo(index);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}