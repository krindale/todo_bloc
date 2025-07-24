import 'package:flutter/material.dart';

import '../widgets/todo_screen/task_input.dart';
import '../widgets/todo_screen/task_list.dart';
import '../model/todo_item.dart';
import '../services/todo_repository.dart';
import '../services/hive_todo_repository.dart';
import '../services/task_categorization_service.dart';
import '../services/firebase_sync_service.dart';
import '../services/platform_strategy.dart';

/// Todo 관리 메인 화면 위젯
/// 
/// 할 일 목록을 표시하고 관리하는 핵심 화면입니다.
/// SOLID 원칙을 준수하여 설계되었으며, 특히 Dependency Inversion Principle을
/// 적용하여 구체 클래스가 아닌 추상화에 의존합니다.
/// 
/// **주요 기능:**
/// - 할 일 추가, 수정, 삭제
/// - 우선순위 및 마감일 설정
/// - 플랫폼별 최적화 (Firebase/로컬)
/// - 실시간 카테고리 분류
/// - 편집 모드 지원
/// 
/// **SOLID 원칙 적용:**
/// - **SRP**: UI 렌더링과 상태 관리만 담당
/// - **OCP**: 새로운 기능 추가 시 확장 가능
/// - **LSP**: Repository 인터페이스 완전 호환
/// - **ISP**: 필요한 서비스만 의존
/// - **DIP**: 추상화(인터페이스)에 의존
/// 
/// **플랫폼별 동작:**
/// - **모바일**: 로컬 우선 + Firebase 동기화
/// - **데스크톱/웹**: Firebase 중심 + 로컬 캐시
/// 
/// Example:
/// ```dart
/// // 의존성 주입 방식 (권장)
/// TodoScreen(
///   todoRepository: MockTodoRepository(),
///   categorizationService: TestCategorizationService(),
///   firebaseSyncService: null, // 오프라인 모드
/// )
/// 
/// // 기본 설정 사용
/// TodoScreen.withDefaults()
/// ```
class TodoScreen extends StatefulWidget {
  /// Todo 데이터 저장소 인터페이스
  final TodoRepository todoRepository;
  
  /// 할 일 자동 분류 서비스
  final TaskCategorizationService categorizationService;
  
  /// Firebase 동기화 서비스 (선택적)
  final FirebaseSyncService? firebaseSyncService;

  /// TodoScreen 생성자
  /// 
  /// Dependency Inversion Principle을 적용하여 모든 의존성을
  /// 생성자를 통해 주입받습니다. 이를 통해 테스트 용이성과
  /// 코드의 유연성을 향상시킵니다.
  /// 
  /// Parameters:
  ///   [todoRepository] - Todo 데이터 관리 인터페이스
  ///   [categorizationService] - 카테고리 분류 서비스
  ///   [firebaseSyncService] - Firebase 동기화 (null 가능)
  /// 
  /// Example:
  /// ```dart
  /// // 프로덕션 환경
  /// TodoScreen(
  ///   todoRepository: HiveTodoRepository(),
  ///   categorizationService: TaskCategorizationService(),
  ///   firebaseSyncService: FirebaseSyncService(),
  /// )
  /// 
  /// // 테스트 환경
  /// TodoScreen(
  ///   todoRepository: MockRepository(),
  ///   categorizationService: MockCategorization(),
  ///   firebaseSyncService: null,
  /// )
  /// ```
  const TodoScreen({
    Key? key,
    required this.todoRepository,
    required this.categorizationService,
    this.firebaseSyncService,
  }) : super(key: key);

  /// 기본 의존성으로 TodoScreen을 생성하는 팩토리 메서드
  /// 
  /// 기존 코드와의 하위 호환성을 위해 제공됩니다.
  /// 프로덕션 환경에서 사용하는 기본 서비스들로 구성됩니다.
  /// 
  /// 포함되는 서비스:
  /// - **HiveTodoRepository**: 로컬 저장소 + 플랫폼 전략
  /// - **TaskCategorizationService**: 자동 카테고리 분류
  /// - **FirebaseSyncService**: 클라우드 동기화
  /// 
  /// Returns:
  ///   기본 서비스들로 구성된 TodoScreen 인스턴스
  /// 
  /// Example:
  /// ```dart
  /// // 간단한 사용법 (기존 코드 호환)
  /// Widget build(BuildContext context) {
  ///   return TodoScreen.withDefaults();
  /// }
  /// ```
  factory TodoScreen.withDefaults() {
    return TodoScreen(
      todoRepository: HiveTodoRepository(),
      categorizationService: TaskCategorizationService(),
      firebaseSyncService: FirebaseSyncService(),
    );
  }

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

/// TodoScreen의 상태를 관리하는 클래스
/// 
/// UI 상태와 비즈니스 로직을 분리하여 관리합니다.
/// 플랫폼별 동작을 지원하고 편집 모드를 처리합니다.
class _TodoScreenState extends State<TodoScreen> {
  // ==================== UI 상태 관리 ====================
  
  /// 할 일 입력 텍스트 컨트롤러
  final TextEditingController _taskController = TextEditingController();
  
  /// 선택된 우선순위 (기본값: 'High')
  String _selectedPriority = 'High';
  
  /// 선택된 마감일 (선택적)
  DateTime? _selectedDate;
  
  /// 현재 표시중인 할 일 목록
  List<TodoItem> _tasks = [];
  
  /// 편집 중인 항목의 인덱스 (null이면 새 항목 추가 모드)
  int? _editingIndex;
  
  /// Firebase 전용 플랫폼에서 편집 중인 Todo 참조
  TodoItem? _editingTodo;

  // ==================== 의존성 (DIP 적용) ====================
  
  /// Todo 데이터 저장소 인터페이스
  late final TodoRepository _todoRepository;
  
  /// 할 일 자동 분류 서비스
  late final TaskCategorizationService _categorizationService;
  
  /// Firebase 동기화 서비스
  late final FirebaseSyncService _firebaseService;
  
  /// 플랫폼별 처리 전략
  late final PlatformStrategy _platformStrategy;
  
  /// 현재 플랫폼이 Firebase 전용인지 여부
  bool get _shouldUseFirebaseOnly => _platformStrategy.shouldUseFirebaseOnly();

  /// 위젯 초기화
  /// 
  /// 주입받은 의존성들을 설정하고 플랫폼에 따라 초기 데이터를 로드합니다.
  /// 
  /// 초기화 과정:
  /// 1. 주입받은 서비스들을 내부 변수에 할당
  /// 2. 플랫폼 전략 생성
  /// 3. 모바일 플랫폼인 경우 로컬 데이터 로드
  @override
  void initState() {
    super.initState();
    
    // DIP: 구체 클래스가 아닌 주입받은 추상화 사용
    _todoRepository = widget.todoRepository;
    _categorizationService = widget.categorizationService;
    _firebaseService = widget.firebaseSyncService ?? FirebaseSyncService();
    _platformStrategy = PlatformStrategyFactory.create();
    
    // 모바일 플랫폼에서만 초기 로드 (Firebase 전용은 스트림 사용)
    if (!_shouldUseFirebaseOnly) {
      _loadTodos();
    }
  }

  // ==================== 데이터 관리 메서드 ====================
  
  /// 저장된 할 일 목록을 불러와서 UI를 업데이트합니다.
  /// 
  /// 모바일 플랫폼에서 주로 사용되며, Repository를 통해
  /// 데이터를 조회한 후 UI 상태를 업데이트합니다.
  /// 
  /// Firebase 전용 플랫폼에서는 실시간 스트림을 사용하므로
  /// 이 메서드는 초기 로드에만 사용됩니다.
  void _loadTodos() async {
    final data = await _todoRepository.getTodos();
    setState(() {
      _tasks = data;
    });
  }

  /// 새로운 할 일을 추가합니다.
  /// 
  /// Repository를 통해 새 할 일을 저장하고,
  /// 모바일 플랫폼인 경우 UI를 새로고침합니다.
  /// 
  /// Parameters:
  ///   [newTodo] - 추가할 새로운 할 일 항목
  /// 
  /// 플랫폼별 동작:
  /// - **모바일**: 로컬 저장 후 UI 새로고침
  /// - **Firebase 전용**: 저장만 수행 (스트림이 자동 업데이트)
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

  // ✅ 할 일 업데이트 (로컬 DB용) - deprecated 메서드 사용
  void _updateTodo(int index, TodoItem updatedTodo) async {
    await _todoRepository.updateTodoByIndex(index, updatedTodo);
    _loadTodos();
  }

  // ✅ 할 일 삭제
  void _deleteTodo(int index, [List<TodoItem>? tasks]) async {
    if (_shouldUseFirebaseOnly) {
      // Firebase-only 플랫폼에서는 TodoItem으로 삭제
      final taskList = tasks ?? _tasks;
      if (index < taskList.length) {
        final todoToDelete = taskList[index];
        await _todoRepository.deleteTodo(todoToDelete);
      }
    } else {
      await _todoRepository.deleteTodoByIndex(index);
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