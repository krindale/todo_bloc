import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../widgets/todo_screen/task_input.dart';
import '../widgets/todo_screen/task_list.dart';
import '../model/todo_item.dart';
import '../services/todo_repository.dart';
import '../services/hive_todo_repository.dart';
import '../services/task_categorization_service.dart';
import '../services/firebase_sync_service.dart';

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
  TodoItem? _editingTodo; // Firebase-only 모드에서 수정 중인 Todo 저장

  late final TodoRepository _todoRepository;
  late final TaskCategorizationService _categorizationService;
  late final FirebaseSyncService _firebaseService;
  
  bool get _shouldUseFirebaseOnly => kIsWeb || Platform.isMacOS || Platform.isWindows;

  @override
  void initState() {
    super.initState();
    _todoRepository = widget.todoRepository ?? HiveTodoRepository();
    _categorizationService = widget.categorizationService ?? TaskCategorizationService();
    _firebaseService = FirebaseSyncService();
    
    if (!_shouldUseFirebaseOnly) {
      _loadTodos();
    }
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
    if (!_shouldUseFirebaseOnly) {
      _loadTodos();
    }
  }
  // ✅ 할 일 업데이트 (Firebase-only용)
  void _updateTodoFirebase(TodoItem originalTodo, TodoItem updatedTodo) async {
    if (originalTodo.firebaseDocId != null) {
      final updatedWithDocId = TodoItem(
        title: updatedTodo.title,
        priority: updatedTodo.priority,
        dueDate: updatedTodo.dueDate,
        isCompleted: updatedTodo.isCompleted,
        category: updatedTodo.category,
        firebaseDocId: originalTodo.firebaseDocId,
      );
      await _firebaseService.updateTodoInFirestore(updatedWithDocId);
    }
  }

  // ✅ 할 일 업데이트 (로컬 DB용)
  void _updateTodo(int index, TodoItem updatedTodo) async {
    await _todoRepository.updateTodo(index, updatedTodo);
    _loadTodos();
  }

  // ✅ 할 일 삭제
  void _deleteTodo(int index, [List<TodoItem>? tasks]) async {
    if (_shouldUseFirebaseOnly) {
      // Firebase-only 플랫폼에서는 TodoItem으로 삭제
      final taskList = tasks ?? _tasks;
      if (index < taskList.length) {
        final todoToDelete = taskList[index];
        if (_todoRepository is HiveTodoRepository) {
          await (_todoRepository as HiveTodoRepository).deleteTodoByItem(todoToDelete);
        }
      }
    } else {
      await _todoRepository.deleteTodo(index);
      _loadTodos();
    }
  }

  void _addOrUpdateTask() async {
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
          firebaseDocId: null, // 새 항목이므로 null
        );
        // 자동 분류된 할 일로 업데이트
        final categorizedTodo = _categorizationService.categorizeAndUpdateTask(newTodo);
        _addTodo(categorizedTodo);
      } else {
        // 기존 할 일 수정 - 제목이 변경되면 다시 분류
        if (_shouldUseFirebaseOnly && _editingTodo != null) {
          // Firebase-only 모드
          var updatedTodo = TodoItem(
            title: _taskController.text,
            priority: _selectedPriority,
            dueDate: dueDate,
            isCompleted: _editingTodo!.isCompleted,
            category: _editingTodo!.category,
            firebaseDocId: _editingTodo!.firebaseDocId,
          );
          // 자동 분류된 할 일로 업데이트
          final categorizedTodo = _categorizationService.categorizeAndUpdateTask(updatedTodo);
          
          // setState 밖에서 Firebase 업데이트 수행
          final originalTodo = _editingTodo!;
          setState(() {
            _editingTodo = null;
            _editingIndex = null;
            _taskController.clear();
            _selectedDate = null;
          });
          
          // Firebase 업데이트 (비동기로 실행하지만 await하지 않음)
          _updateTodoFirebase(originalTodo, categorizedTodo);
          return;
        } else if (!_shouldUseFirebaseOnly && _editingIndex != null) {
          // 로컬 DB 모드
          var updatedTodo = TodoItem(
            title: _taskController.text,
            priority: _selectedPriority,
            dueDate: dueDate,
            isCompleted: _tasks[_editingIndex!].isCompleted,
            category: _tasks[_editingIndex!].category,
            firebaseDocId: _tasks[_editingIndex!].firebaseDocId,
          );
          // 자동 분류된 할 일로 업데이트
          final categorizedTodo = _categorizationService.categorizeAndUpdateTask(updatedTodo);
          _updateTodo(_editingIndex!, categorizedTodo);
        }
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
      _editingTodo = null;
      _taskController.clear();
      _selectedDate = null;
    });
  }

  /// **삭제 확인 다이얼로그** 메서드
  void _showDeleteConfirmDialog(int index, List<TodoItem> tasks) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('할 일 삭제'),
          content: Text('정말로 "${tasks[index].title}"을(를) 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                if (!_shouldUseFirebaseOnly) {
                  setState(() {
                    _tasks.removeAt(index);
                  });
                }
                _deleteTodo(index, tasks);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
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
    if (_shouldUseFirebaseOnly) {
      return _buildWithFirebaseStream();
    } else {
      return _buildWithLocalData();
    }
  }

  Widget _buildWithFirebaseStream() {
    return StreamBuilder<List<TodoItem>>(
      stream: _firebaseService.todosStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('오류: ${snapshot.error}'));
        }
        
        final tasks = snapshot.data ?? [];
        
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
                  tasks: tasks,
                  onEdit: (index) {
                    setState(() {
                      _editingIndex = index;
                      _editingTodo = tasks[index]; // Firebase-only 모드용
                      _taskController.text = tasks[index].title;
                      _selectedPriority = tasks[index].priority;
                      _selectedDate = tasks[index].dueDate;
                    });
                  },
                  onDelete: (index) {
                    _showDeleteConfirmDialog(index, tasks);
                  },
                  onCompleteChanged: (index, value) {
                    final updatedTodo = TodoItem(
                      title: tasks[index].title,
                      priority: tasks[index].priority,
                      dueDate: tasks[index].dueDate,
                      isCompleted: value ?? false,
                      category: tasks[index].category,
                      firebaseDocId: tasks[index].firebaseDocId,
                    );
                    _updateTodoFirebase(tasks[index], updatedTodo);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWithLocalData() {
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
                _showDeleteConfirmDialog(index, _tasks);
              },
              onCompleteChanged: (index, value) {
                setState(() {
                  _tasks[index] = TodoItem(
                    title: _tasks[index].title,
                    priority: _tasks[index].priority,
                    dueDate: _tasks[index].dueDate,
                    isCompleted: value ?? false,
                    category: _tasks[index].category,
                    firebaseDocId: _tasks[index].firebaseDocId,
                  );
                });
                _updateTodo(index, _tasks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}