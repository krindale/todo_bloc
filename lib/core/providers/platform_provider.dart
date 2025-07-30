import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../platform/platform_strategy.dart';

part 'platform_provider.g.dart';

/// Platform strategy provider
/// 
/// 플랫폼별 전략을 제공하는 Riverpod 프로바이더입니다.
/// 앱 전체에서 사용할 수 있는 싱글톤 인스턴스를 제공합니다.
@Riverpod(keepAlive: true)
PlatformStrategy platformStrategy(PlatformStrategyRef ref) {
  return PlatformStrategyFactory.create();
}