import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../services/ai_todo_generator_service.dart';
import '../../model/todo_item.dart';

part 'ai_todo_provider.g.dart';

/// AI Todo Generator service provider
@Riverpod(keepAlive: true)
AiTodoGeneratorService aiTodoGeneratorService(AiTodoGeneratorServiceRef ref) {
  return AiTodoGeneratorService();
}

/// AI Todo generation state notifier
@riverpod
class AiTodoGenerator extends _$AiTodoGenerator {
  @override
  AsyncValue<List<TodoItem>?> build() {
    return const AsyncValue.data(null);
  }

  /// AI를 사용하여 Todo 생성
  Future<void> generateTodos(String prompt) async {
    state = const AsyncValue.loading();
    
    try {
      final service = ref.read(aiTodoGeneratorServiceProvider);
      final todos = await service.generateTodos(prompt);
      state = AsyncValue.data(todos);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// 생성된 Todo 초기화
  void clearGeneratedTodos() {
    state = const AsyncValue.data(null);
  }
}

/// 현재 AI 생성 상태를 나타내는 provider
@riverpod
bool isAiGenerating(IsAiGeneratingRef ref) {
  final aiState = ref.watch(aiTodoGeneratorProvider);
  return aiState.isLoading;
}

/// AI 생성 에러 메시지 provider
@riverpod
String? aiGenerationError(AiGenerationErrorRef ref) {
  final aiState = ref.watch(aiTodoGeneratorProvider);
  return aiState.hasError ? aiState.error.toString() : null;
}