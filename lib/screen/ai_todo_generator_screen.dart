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
import '../widgets/ai_generator/ai_generator_header.dart';
import '../widgets/ai_generator/ai_generator_input_section.dart';
import '../widgets/ai_generator/ai_generator_recommendation_section.dart';
import '../widgets/ai_generator/ai_generator_todo_list.dart';
import '../widgets/ai_generator/ai_generator_error_widget.dart';

class AiTodoGeneratorScreen extends StatefulWidget {
  final TabController? tabController;

  const AiTodoGeneratorScreen({super.key, this.tabController});

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
  late AnimationController _recommendationController;
  late AnimationController _headerController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _recommendationAnimation;
  late Animation<double> _headerAnimation;

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
    _recommendationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    _recommendationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _recommendationController, curve: Curves.easeInOut),
    );
    _headerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeInOut),
    );

    // 초기에 추천 섹션과 헤더를 표시
    _recommendationController.forward();
    _headerController.forward();
  }

  @override
  void dispose() {
    _requestController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _recommendationController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  /// AI를 통해 할 일 생성
  Future<void> _generateTodos() async {
    if (_requestController.text.trim().isEmpty) {
      _showSnackBar('요청을 입력해주세요', isError: true);
      return;
    }

    // 먼저 UI 상태를 업데이트하여 헤더/추천 섹션 숨기기
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedTodos = null;
      _selectedTodos.clear();
    });

    try {
      final todos =
          await _aiService.generateTodos(_requestController.text.trim());

      setState(() {
        _generatedTodos = todos;
        _selectedTodos =
            Set.from(List.generate(todos.length, (index) => index));
        _isGenerating = false;
      });

      // 애니메이션 (헤더/추천 섹션 페이드 아웃)
      _recommendationController.reverse();
      _headerController.reverse();

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

      // 추천 섹션 다시 표시
      _recommendationController.forward();

      // Tasks 탭으로 이동 (0번 인덱스)
      if (widget.tabController != null) {
        widget.tabController!.animateTo(0);
      }
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
    print('🔍 _useRecommendation 호출됨: $recommendation');
    print('🔍 현재 텍스트 필드 값: "${_requestController.text}"');

    // 텍스트 컨트롤러 직접 조작
    _requestController.clear();
    _requestController.text = recommendation;

    // 커서를 텍스트 끝으로 이동
    _requestController.selection = TextSelection.fromPosition(
      TextPosition(offset: _requestController.text.length),
    );

    print('🔍 설정 후 텍스트 필드 값: "${_requestController.text}"');

    setState(() {
      // UI 강제 업데이트
    });

    print('🔍 setState 완료');
  }

  /// 초기화하고 추천 요청 다시 표시
  void _resetAndShowRecommendations() {
    setState(() {
      _generatedTodos = null;
      _selectedTodos.clear();
      _errorMessage = null;
      _requestController.clear();
    });

    _fadeController.reset();
    _slideController.reset();

    // 추천 섹션과 헤더 페이드 인
    _recommendationController.forward();
    _headerController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단 헤더 (애니메이션 적용)
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            child: AnimatedBuilder(
              animation: _headerAnimation,
              builder: (context, child) {
                if (_generatedTodos == null && _errorMessage == null) {
                  return FadeTransition(
                    opacity: _headerAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, -0.2),
                        end: Offset.zero,
                      ).animate(_headerController),
                      child: Column(
                        children: [
                          const AiGeneratorHeader(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),

          // 입력 섹션 (할 일 생성 시 상단으로 이동)
          AiGeneratorInputSection(
            controller: _requestController,
            isGenerating: _isGenerating,
            hasResults: _generatedTodos != null || _errorMessage != null,
            onGenerate: _generateTodos,
          ),
          const SizedBox(height: 20),

          // 추천 요청 섹션 (애니메이션 적용)
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: AnimatedBuilder(
              animation: _recommendationAnimation,
              builder: (context, child) {
                if (_generatedTodos == null &&
                    _errorMessage == null &&
                    !_isGenerating) {
                  return IgnorePointer(
                    ignoring: _recommendationController.isAnimating,
                    child: FadeTransition(
                      opacity: _recommendationAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, -0.1),
                          end: Offset.zero,
                        ).animate(_recommendationController),
                        child: Column(
                          children: [
                            AiGeneratorRecommendationSection(
                              onRecommendationTap: _useRecommendation,
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),

          // 결과 섹션
          _buildResultSection(),
        ],
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
    return AiGeneratorErrorWidget(
      errorMessage: _errorMessage!,
      onRetry: () {
        setState(() {
          _errorMessage = null;
        });
      },
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    return const SizedBox.shrink();
  }

  /// 할 일 목록 위젯
  Widget _buildTodoList() {
    return AiGeneratorTodoList(
      todos: _generatedTodos!,
      selectedTodos: _selectedTodos,
      onTodoToggle: (index, value) {
        setState(() {
          if (value) {
            _selectedTodos.add(index);
          } else {
            _selectedTodos.remove(index);
          }
        });
      },
      onSave: _saveSelectedTodos,
      onReset: _resetAndShowRecommendations,
    );
  }
}
