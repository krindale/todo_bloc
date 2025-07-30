import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../services/todo_repository.dart';
import '../../services/hive_todo_repository.dart';
import 'platform_provider.dart';

part 'repository_provider.g.dart';

/// Todo repository provider
/// 
/// TodoRepository 인터페이스를 구현한 HiveTodoRepository를 제공합니다.
/// 플랫폼 전략과 함께 의존성 주입됩니다.
@Riverpod(keepAlive: true)
TodoRepository todoRepository(TodoRepositoryRef ref) {
  final platformStrategy = ref.watch(platformStrategyProvider);
  return HiveTodoRepository(platformStrategy);
}