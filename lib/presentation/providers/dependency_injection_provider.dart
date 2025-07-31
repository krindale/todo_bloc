/// **의존성 주입 Provider**
/// 
/// 클린 아키텍처의 의존성 주입을 Riverpod으로 구현합니다.
/// 각 레이어의 구현체들을 제공하고 의존성을 관리합니다.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Data layer
import '../../data/datasources/todo_local_datasource.dart';
import '../../data/datasources/todo_remote_datasource.dart';
import '../../data/repositories/todo_repository_impl.dart';

// Domain layer
import '../../domain/repositories/todo_repository.dart';
import '../../domain/usecases/add_todo_usecase.dart';
import '../../domain/usecases/get_todos_usecase.dart';
import '../../domain/usecases/update_todo_usecase.dart';
import '../../domain/usecases/delete_todo_usecase.dart';
import '../../domain/usecases/toggle_todo_completion_usecase.dart';

part 'dependency_injection_provider.g.dart';

// =============================================================================
// Data Source Providers
// =============================================================================

/// 로컬 데이터 소스 Provider
@riverpod
TodoLocalDataSource todoLocalDataSource(TodoLocalDataSourceRef ref) {
  return TodoHiveDataSource();
}

/// 원격 데이터 소스 Provider
@riverpod
TodoRemoteDataSource todoRemoteDataSource(TodoRemoteDataSourceRef ref) {
  return TodoFirebaseDataSource();
}

// =============================================================================
// Repository Providers
// =============================================================================

/// Todo 레포지토리 Provider
@riverpod
TodoRepository todoRepository(TodoRepositoryRef ref) {
  final localDataSource = ref.read(todoLocalDataSourceProvider);
  final remoteDataSource = ref.read(todoRemoteDataSourceProvider);
  
  // 플랫폼별 설정 (나중에 설정으로 분리 가능)
  const useRemoteDataSource = true;
  
  return TodoRepositoryImpl(
    localDataSource: localDataSource,
    remoteDataSource: remoteDataSource,
    useRemoteDataSource: useRemoteDataSource,
  );
}

// =============================================================================
// Use Case Providers
// =============================================================================

/// Todo 추가 Use Case Provider
@riverpod
AddTodoUseCase addTodoUseCase(AddTodoUseCaseRef ref) {
  final repository = ref.read(todoRepositoryProvider);
  return AddTodoUseCase(repository);
}

/// Todo 조회 Use Case Provider
@riverpod
GetTodosUseCase getTodosUseCase(GetTodosUseCaseRef ref) {
  final repository = ref.read(todoRepositoryProvider);
  return GetTodosUseCase(repository);
}

/// Todo 수정 Use Case Provider
@riverpod
UpdateTodoUseCase updateTodoUseCase(UpdateTodoUseCaseRef ref) {
  final repository = ref.read(todoRepositoryProvider);
  return UpdateTodoUseCase(repository);
}

/// Todo 삭제 Use Case Provider
@riverpod
DeleteTodoUseCase deleteTodoUseCase(DeleteTodoUseCaseRef ref) {
  final repository = ref.read(todoRepositoryProvider);
  return DeleteTodoUseCase(repository);
}

/// Todo 완료 토글 Use Case Provider
@riverpod
ToggleTodoCompletionUseCase toggleTodoCompletionUseCase(
    ToggleTodoCompletionUseCaseRef ref) {
  final repository = ref.read(todoRepositoryProvider);
  return ToggleTodoCompletionUseCase(repository);
}

// =============================================================================
// Configuration Providers
// =============================================================================

/// 앱 설정 Provider
@riverpod
class AppConfig extends _$AppConfig {
  @override
  Map<String, dynamic> build() {
    return {
      'useRemoteSync': true,
      'offlineMode': false,
      'syncInterval': const Duration(minutes: 5),
      'maxRetryAttempts': 3,
    };
  }

  void updateConfig(String key, dynamic value) {
    state = {...state, key: value};
  }
}

/// 플랫폼 전략 Provider
@riverpod
class PlatformStrategy extends _$PlatformStrategy {
  @override
  String build() {
    // 플랫폼 감지 로직 (기존 코드에서 이전)
    return 'mobile'; // 또는 'desktop', 'web'
  }

  void setPlatform(String platform) {
    state = platform;
  }
}