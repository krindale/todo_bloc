/// **AI 할 일 생성 화면**
/// 
/// 사용자가 추상적인 요청을 입력하면 AI가 구체적인 할 일 목록을 생성해주는 화면입니다.
/// 직관적인 UI와 부드러운 애니메이션으로 사용자 경험을 최적화했습니다.
/// 
/// **주요 기능:**
/// - 자연어 입력을 통한 할 일 생성
/// - 추천 요청 템플릿 제공
/// - 생성된 할 일 미리보기 및 편집
/// - 선택적 할 일 저장 기능
/// - 로딩 상태 및 에러 처리
/// 
/// **사용자 플로우:**
/// 1. 추상적 요청 입력 (예: "건강을 위한 플랜을 짜줘")
/// 2. AI 생성 버튼 클릭
/// 3. 생성된 할 일 목록 확인
/// 4. 원하는 할 일만 선택하여 저장
/// 
/// **UI 특징:**
/// - Material Design 3 적용
/// - 반응형 레이아웃
/// - 부드러운 로딩 애니메이션
/// - 접근성 고려한 색상 및 폰트

import 'package:flutter/material.dart';
import '../services/ai_todo_generator_service.dart';
import '../services/hive_todo_repository.dart';
import '../model/todo_item.dart';

class AiTodoGeneratorScreen extends StatefulWidget {
  const AiTodoGeneratorScreen({super.key});

  @override
  State<AiTodoGeneratorScreen> createState() => _AiTodoGeneratorScreenState();
}

class _AiTodoGeneratorScreenState extends State<AiTodoGeneratorScreen>
    with TickerProviderStateMixin {
  final TextEditingController _requestController = TextEditingController();
  final AiTodoGeneratorService _aiService = AiTodoGeneratorService();
  late HiveTodoRepository _todoRepository;
  
  List<TodoItem>? _generatedTodos;
  Set<int> _selectedTodos = {};
  bool _isGenerating = false;
  String? _errorMessage;
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _todoRepository = HiveTodoRepository();
    
    // 애니메이션 컨트롤러 설정
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _requestController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// AI를 통해 할 일 생성
  Future<void> _generateTodos() async {
    if (_requestController.text.trim().isEmpty) {
      _showSnackBar('요청을 입력해주세요', isError: true);
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedTodos = null;
      _selectedTodos.clear();
    });

    try {
      final todos = await _aiService.generateTodos(_requestController.text.trim());
      
      setState(() {
        _generatedTodos = todos;
        _selectedTodos = Set.from(List.generate(todos.length, (index) => index));
        _isGenerating = false;
      });
      
      // 결과 표시 애니메이션
      _fadeController.forward();
      _slideController.forward();
      
    } catch (e) {
      setState(() {
        _errorMessage = '할 일 생성 중 오류가 발생했습니다: $e';
        _isGenerating = false;
      });
    }
  }

  /// 선택된 할 일들을 저장
  Future<void> _saveSelectedTodos() async {
    if (_generatedTodos == null || _selectedTodos.isEmpty) {
      _showSnackBar('저장할 할 일을 선택해주세요', isError: true);
      return;
    }

    try {
      int savedCount = 0;
      for (int index in _selectedTodos) {
        final todo = _generatedTodos![index];
        await _todoRepository.addTodo(todo);
        savedCount++;
      }
      
      _showSnackBar('$savedCount개의 할 일이 저장되었습니다');
      
      // 저장 후 초기화
      setState(() {
        _generatedTodos = null;
        _selectedTodos.clear();
        _requestController.clear();
      });
      
      _fadeController.reset();
      _slideController.reset();
      
    } catch (e) {
      _showSnackBar('저장 중 오류가 발생했습니다: $e', isError: true);
    }
  }

  /// 스낵바 표시
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 추천 요청 버튼 클릭
  void _useRecommendation(String recommendation) {
    _requestController.text = recommendation;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단 헤더
          _buildHeader(),
          const SizedBox(height: 20),
          
          // 입력 섹션
          _buildInputSection(),
          const SizedBox(height: 20),
          
          // 추천 요청 섹션
          _buildRecommendationSection(),
          const SizedBox(height: 20),
          
          // 결과 섹션
          _buildResultSection(),
        ],
      ),
    );
  }

  /// 헤더 위젯
  Widget _buildHeader() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.auto_awesome,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              'AI 할 일 생성',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '추상적인 목표를 구체적인 할 일로 변환해드립니다',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 입력 섹션
  Widget _buildInputSection() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '어떤 일을 도와드릴까요?',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _requestController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '예: 건강을 위한 플랜을 짜줘, 새로운 기술을 배우고 싶어',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateTodos,
              icon: _isGenerating
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(Icons.auto_awesome),
              label: Text(_isGenerating ? 'AI가 생각 중...' : 'AI로 할 일 생성'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 추천 요청 섹션
  Widget _buildRecommendationSection() {
    final recommendations = _aiService.getSuggestedRequests();
    
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '추천 요청',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recommendations.map((recommendation) {
                return ActionChip(
                  label: Text(
                    recommendation,
                    style: TextStyle(fontSize: 12),
                  ),
                  onPressed: () => _useRecommendation(recommendation),
                  backgroundColor: Colors.blue[50],
                  side: BorderSide(color: Colors.blue[200]!),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 결과 섹션
  Widget _buildResultSection() {
    if (_errorMessage != null) {
      return _buildErrorWidget();
    }
    
    if (_generatedTodos == null) {
      return _buildEmptyState();
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildTodoList(),
      ),
    );
  }

  /// 에러 위젯
  Widget _buildErrorWidget() {
    return SizedBox(
      height: 300,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[300],
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red[700]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                  });
                },
                child: Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    return SizedBox(
      height: 300,
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                '위에 원하는 일을 입력하고\nAI 생성 버튼을 눌러보세요!',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 할 일 목록 위젯
  Widget _buildTodoList() {
    return Card(
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.checklist, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  '생성된 할 일 목록',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                Spacer(),
                Text(
                  '${_selectedTodos.length}/${_generatedTodos!.length} 선택됨',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // 할 일 목록
          SizedBox(
            height: 400, // 고정 높이 설정
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _generatedTodos!.length,
              itemBuilder: (context, index) {
                final todo = _generatedTodos![index];
                final isSelected = _selectedTodos.contains(index);
                
                return AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[50] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedTodos.add(index);
                        } else {
                          _selectedTodos.remove(index);
                        }
                      });
                    },
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        decoration: isSelected ? null : TextDecoration.none,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            todo.category ?? '일반',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[800],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          todo.priority,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                );
              },
            ),
          ),
          
          // 저장 버튼
          Container(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _selectedTodos.isEmpty ? null : _saveSelectedTodos,
              icon: Icon(Icons.save),
              label: Text('선택된 할 일 저장 (${_selectedTodos.length}개)'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}