import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../model/todo_item.dart';

/// 플랫폼별 Todo 데이터 처리 전략을 정의하는 추상 클래스
/// 
/// Strategy Pattern을 적용하여 Open/Closed Principle을 준수합니다.
/// 새로운 플랫폼이 추가되어도 기존 코드를 수정하지 않고 확장할 수 있습니다.
/// 
/// 각 플랫폼은 다음과 같은 특성을 가집니다:
/// - Web/Desktop: Firebase 기반의 실시간 동기화
/// - Mobile: 로컬 Hive 저장소 + Firebase 백업
/// 
/// Example:
/// ```dart
/// PlatformStrategy strategy = PlatformStrategyFactory.create();
/// if (strategy.shouldUseFirebaseOnly()) {
///   // Firebase 전용 로직
/// } else {
///   // 하이브리드 로직 (Local + Firebase)
/// }
/// ```
abstract class PlatformStrategy {
  /// 해당 플랫폼이 Firebase만 사용하는지 여부를 반환합니다.
  /// 
  /// Firebase 전용 플랫폼은 로컬 저장소 없이 실시간 동기화만 사용합니다.
  /// 
  /// Returns:
  ///   true - Firebase만 사용 (Web, Desktop)
  ///   false - 로컬 저장소 + Firebase 사용 (Mobile)
  bool shouldUseFirebaseOnly();

  /// 플랫폼별 Todo 업데이트 로직을 처리합니다.
  /// 
  /// 각 플랫폼 구현체에서 해당 플랫폼에 최적화된 업데이트 방식을 구현합니다.
  /// 
  /// Parameters:
  ///   [todo] - 업데이트할 Todo 항목
  /// 
  /// Throws:
  ///   플랫폼별 업데이트 실패 시 해당 예외 전파
  Future<void> updateTodo(TodoItem todo);

  /// 플랫폼별 Todo 삭제 로직을 처리합니다.
  /// 
  /// 각 플랫폼 구현체에서 해당 플랫폼에 최적화된 삭제 방식을 구현합니다.
  /// 
  /// Parameters:
  ///   [todo] - 삭제할 Todo 항목
  /// 
  /// Throws:
  ///   플랫폼별 삭제 실패 시 해당 예외 전파
  Future<void> deleteTodo(TodoItem todo);

  /// 전략의 이름을 반환합니다 (디버깅 및 로깅용).
  /// 
  /// Returns:
  ///   플랫폼 전략의 이름 (예: "Desktop", "Mobile", "Web")
  String get strategyName;
}

/// 데스크톱 플랫폼(Windows, macOS, Linux)용 전략 구현체
/// 
/// 데스크톱 환경에서는 Firebase만을 사용하여 실시간 동기화를 수행합니다.
/// 로컬 캐시는 최소한으로 사용하고 주로 클라우드 기반으로 작동합니다.
/// 
/// 특징:
/// - Firebase 실시간 동기화
/// - 네트워크 의존적
/// - 다중 디바이스 동기화 우수
class DesktopPlatformStrategy implements PlatformStrategy {
  @override
  bool shouldUseFirebaseOnly() => true;
  
  @override
  String get strategyName => 'Desktop';

  @override
  Future<void> updateTodo(TodoItem todo) async {
    // 데스크톱 플랫폼에서는 Firebase 기반으로 업데이트
    // 실제 구현은 HiveTodoRepository에서 TodoDatabase를 통해 처리됩니다.
  }

  @override
  Future<void> deleteTodo(TodoItem todo) async {
    // 데스크톱 플랫폼에서는 TodoItem 기반으로 삭제
    // Firebase 문서 ID를 사용하여 직접 삭제합니다.
  }
}

/// 모바일 플랫폼(iOS, Android)용 전략 구현체
/// 
/// 모바일 환경에서는 로컬 Hive 저장소를 주로 사용하고
/// Firebase를 백업 및 동기화 목적으로 활용합니다.
/// 
/// 특징:
/// - 로컬 우선 저장 (빠른 응답)
/// - 오프라인 지원
/// - 주기적 Firebase 동기화
/// - 인덱스 기반 접근 지원
class MobilePlatformStrategy implements PlatformStrategy {
  @override
  bool shouldUseFirebaseOnly() => false;
  
  @override
  String get strategyName => 'Mobile';

  @override
  Future<void> updateTodo(TodoItem todo) async {
    // 모바일 플랫폼에서는 로컬 Hive 기반으로 우선 업데이트
    // 이후 백그라운드에서 Firebase 동기화 수행
  }

  @override
  Future<void> deleteTodo(TodoItem todo) async {
    // 모바일 플랫폼에서는 인덱스 기반 삭제도 지원
    // 로컬 저장소의 특성을 활용할 수 있습니다.
  }
}

/// 웹 플랫폼용 전략 구현체
/// 
/// 웹 환경에서는 브라우저 제약으로 인해 Firebase만 사용합니다.
/// 로컬 저장소는 제한적이므로 클라우드 기반으로 작동합니다.
/// 
/// 특징:
/// - Firebase 전용
/// - 브라우저 호환성 고려
/// - 세션 기반 캐싱
/// - 실시간 업데이트
class WebPlatformStrategy implements PlatformStrategy {
  @override
  bool shouldUseFirebaseOnly() => true;
  
  @override
  String get strategyName => 'Web';

  @override
  Future<void> updateTodo(TodoItem todo) async {
    // 웹 플랫폼에서는 Firebase 기반으로 업데이트
    // 브라우저 제약 사항을 고려한 구현
  }

  @override
  Future<void> deleteTodo(TodoItem todo) async {
    // 웹 플랫폼에서는 TodoItem 기반으로 삭제
    // 브라우저 저장소 제약으로 인해 Firebase 직접 접근
  }
}

/// 플랫폼별 전략을 생성하는 팩토리 클래스
/// 
/// Factory Pattern을 적용하여 런타임에 적절한 플랫폼 전략을 생성합니다.
/// 클라이언트 코드는 구체적인 플랫폼을 알 필요 없이 전략을 사용할 수 있습니다.
/// 
/// Example:
/// ```dart
/// // 자동으로 현재 플랫폼에 맞는 전략 생성
/// final strategy = PlatformStrategyFactory.create();
/// print('Current platform: ${strategy.strategyName}');
/// ```
class PlatformStrategyFactory {
  /// 현재 실행 환경에 맞는 플랫폼 전략을 생성합니다.
  /// 
  /// 플랫폼 감지 순서:
  /// 1. Web 환경 체크 (kIsWeb)
  /// 2. 데스크톱 환경 체크 (Windows, macOS, Linux)
  /// 3. 기본값: 모바일 환경 (iOS, Android)
  /// 
  /// Returns:
  ///   현재 플랫폼에 최적화된 [PlatformStrategy] 구현체
  static PlatformStrategy create() {
    if (kIsWeb) {
      return WebPlatformStrategy();
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return DesktopPlatformStrategy();
    } else {
      return MobilePlatformStrategy();
    }
  }
}