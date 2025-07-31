/// **AI Todo 생성기 다이얼로그**
/// 
/// 플로팅 버튼을 통해 표시되는 AI Todo 생성 다이얼로그입니다.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/ai_todo_provider.dart';
import '../../core/utils/app_logger.dart';
import 'ai_generator_header.dart';
import 'ai_generator_input.dart';
import 'ai_generator_todo_list_dialog.dart';

class AiTodoGeneratorDialog extends ConsumerStatefulWidget {
  const AiTodoGeneratorDialog({super.key});

  @override
  ConsumerState<AiTodoGeneratorDialog> createState() => _AiTodoGeneratorDialogState();
}

class _AiTodoGeneratorDialogState extends ConsumerState<AiTodoGeneratorDialog> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // 다이얼로그가 열릴 때 자동으로 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    AppLogger.info('AI Todo Generator Dialog opened', tag: 'AI');
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// AI Todo 생성 요청
  void _generateTodos() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('요청 내용을 입력해주세요.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      AppLogger.info('Generating AI todos with prompt: $prompt', tag: 'AI');
      await ref.read(aiTodoGeneratorProvider.notifier).generateTodos(prompt);
      _controller.clear();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to generate AI todos', 
        tag: 'AI', error: e, stackTrace: stackTrace);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI 생성 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGenerating = ref.watch(isAiGeneratingProvider);
    final aiState = ref.watch(aiTodoGeneratorProvider);
    final error = ref.watch(aiGenerationErrorProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // 헤더
            const AiGeneratorHeader(),
            
            // 입력 영역
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AiGeneratorInput(
                controller: _controller,
                focusNode: _focusNode,
                onSubmit: _generateTodos,
                isLoading: isGenerating,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 생성된 Todo 목록 또는 상태 표시
            Expanded(
              child: _buildContent(
                isGenerating: isGenerating,
                aiState: aiState,
                error: error,
              ),
            ),
            
            // 하단 버튼들
            _buildBottomActions(context, isGenerating),
          ],
        ),
      ),
    );
  }

  /// 컨텐츠 영역 구성
  Widget _buildContent({
    required bool isGenerating,
    required AsyncValue aiState,
    required String? error,
  }) {
    if (error != null) {
      return _buildErrorState(error);
    }
    
    if (isGenerating) {
      return _buildLoadingState();
    }
    
    // AsyncValue에서 데이터 추출
    final generatedTodos = aiState.whenOrNull(
      data: (data) => data is List ? 
        data.map((item) => item?.toString() ?? 'Empty Todo').toList().cast<String>() : <String>[],
    ) ?? <String>[];
    
    if (generatedTodos.isEmpty) {
      return _buildEmptyState();
    }
    
    return AiGeneratorTodoList(todos: generatedTodos);
  }

  /// 로딩 상태 표시
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'AI가 할 일 목록을 생성하고 있습니다...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            '잠시만 기다려주세요',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// 빈 상태 표시
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'AI에게 할 일을 요청해보세요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '예: "내일 프레젠테이션 준비를 위한 할 일들"',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 오류 상태 표시
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'AI 생성 중 오류가 발생했습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(aiTodoGeneratorProvider.notifier).clearGeneratedTodos();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  /// 하단 액션 버튼들
  Widget _buildBottomActions(BuildContext context, bool isGenerating) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: isGenerating ? null : () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: isGenerating ? null : _generateTodos,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('AI 생성'),
          ),
        ],
      ),
    );
  }
}