/// **서비스 로케이터 (의존성 주입 컨테이너)**
///
/// 앱 전체에서 사용되는 서비스들을 등록하고 관리합니다.
/// 싱글톤 패턴과 팩토리 패턴을 지원하여 적절한 생명주기를 제공하며,
/// 테스트 시에는 모킹된 서비스로 쉽게 교체할 수 있습니다.

import 'package:get_it/get_it.dart';
import '../platform/platform_strategy.dart';
import '../utils/app_logger.dart';
import '../utils/error_handler.dart';

// 클린 아키텍처 임포트 (추후 활성화)
/*
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
*/

/// **서비스 등록 타입**
enum ServiceType {
  singleton,  // 앱 생명주기 동안 하나의 인스턴스
  factory,    // 매번 새로운 인스턴스 생성
  lazySingleton, // 첫 사용 시에만 인스턴스 생성
}

/// **서비스 로케이터 클래스**
class ServiceLocator {
  static final GetIt _getIt = GetIt.instance;
  static bool _isInitialized = false;
  
  /// 초기화 여부 확인
  static bool get isInitialized => _isInitialized;
  
  /// 서비스 로케이터 초기화
  static Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.warning('ServiceLocator already initialized', tag: 'DI');
      return;
    }
    
    try {
      AppLogger.info('Initializing ServiceLocator', tag: 'DI');
      
      // 플랫폼 전략 초기화 및 등록
      await PlatformAdapter.initialize();
      _getIt.registerSingleton<PlatformStrategy>(PlatformAdapter.current);
      
      // 코어 서비스들 등록
      await _registerCoreServices();
      
      // 비즈니스 서비스들 등록
      await _registerBusinessServices();
      
      // UI 서비스들 등록
      await _registerUIServices();
      
      _isInitialized = true;
      AppLogger.info('ServiceLocator initialization completed', tag: 'DI');
      
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to initialize ServiceLocator',
        tag: 'DI',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
  
  /// 서비스 조회
  static T get<T extends Object>() {
    try {
      return _getIt.get<T>();
    } catch (error) {
      AppLogger.error(
        'Failed to get service: ${T.toString()}',
        tag: 'DI',
        error: error,
      );
      rethrow;
    }
  }
  
  /// 서비스 등록 (싱글톤)
  static void registerSingleton<T extends Object>(
    T instance, {
    String? instanceName,
  }) {
    _getIt.registerSingleton<T>(instance, instanceName: instanceName);
    AppLogger.debug('Registered singleton: ${T.toString()}', tag: 'DI');
  }
  
  /// 서비스 등록 (지연 싱글톤)
  static void registerLazySingleton<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) {
    _getIt.registerLazySingleton<T>(factory, instanceName: instanceName);
    AppLogger.debug('Registered lazy singleton: ${T.toString()}', tag: 'DI');
  }
  
  /// 서비스 등록 (팩토리)
  static void registerFactory<T extends Object>(
    T Function() factory, {
    String? instanceName,
  }) {
    _getIt.registerFactory<T>(factory, instanceName: instanceName);
    AppLogger.debug('Registered factory: ${T.toString()}', tag: 'DI');
  }
  
  /// 서비스 해제
  static Future<void> unregister<T extends Object>({
    String? instanceName,
  }) async {
    if (_getIt.isRegistered<T>(instanceName: instanceName)) {
      await _getIt.unregister<T>(instanceName: instanceName);
      AppLogger.debug('Unregistered service: ${T.toString()}', tag: 'DI');
    }
  }
  
  /// 모든 서비스 해제 (앱 종료 시)
  static Future<void> dispose() async {
    try {
      AppLogger.info('Disposing ServiceLocator', tag: 'DI');
      
      // 플랫폼 어댑터 정리
      await PlatformAdapter.dispose();
      
      // GetIt 인스턴스 초기화
      await _getIt.reset();
      
      _isInitialized = false;
      AppLogger.info('ServiceLocator disposed successfully', tag: 'DI');
      
    } catch (error, stackTrace) {
      AppLogger.error(
        'Failed to dispose ServiceLocator',
        tag: 'DI',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
  
  /// 서비스 등록 상태 확인
  static bool isRegistered<T extends Object>({String? instanceName}) {
    return _getIt.isRegistered<T>(instanceName: instanceName);
  }
  
  /// 테스트용 서비스 교체
  static void replaceForTesting<T extends Object>(
    T instance, {
    String? instanceName,
  }) {
    if (_getIt.isRegistered<T>(instanceName: instanceName)) {
      _getIt.unregister<T>(instanceName: instanceName);
    }
    _getIt.registerSingleton<T>(instance, instanceName: instanceName);
    AppLogger.debug('Replaced service for testing: ${T.toString()}', tag: 'DI');
  }
  
  /// 코어 서비스들 등록 (로깅, 에러 핸들링 등)
  static Future<void> _registerCoreServices() async {
    // 이미 AppLogger는 static으로 구현되어 있으므로 등록하지 않음
    AppLogger.debug('Core services registration completed', tag: 'DI');
  }
  
  /// 비즈니스 서비스들 등록 (데이터, AI, 동기화 등)
  static Future<void> _registerBusinessServices() async {
    // ==========================================================================
    // 클린 아키텍처 - 데이터 소스 등록
    // ==========================================================================
    
    // TODO: 실제 데이터 소스 구현 후 활성화
    /*
    // 로컬 데이터 소스
    registerLazySingleton<TodoLocalDataSource>(() => TodoHiveDataSource());
    
    // 원격 데이터 소스  
    registerLazySingleton<TodoRemoteDataSource>(() => TodoFirebaseDataSource());
    
    // ==========================================================================
    // 클린 아키텍처 - 레포지토리 등록
    // ==========================================================================
    
    registerLazySingleton<TodoRepository>(() => TodoRepositoryImpl(
      localDataSource: get<TodoLocalDataSource>(),
      remoteDataSource: get<TodoRemoteDataSource>(),
      useRemoteDataSource: _shouldUseRemoteDataSource(),
    ));
    
    // ==========================================================================
    // 클린 아키텍처 - Use Cases 등록
    // ==========================================================================
    
    registerLazySingleton(() => AddTodoUseCase(get<TodoRepository>()));
    registerLazySingleton(() => GetTodosUseCase(get<TodoRepository>()));
    registerLazySingleton(() => UpdateTodoUseCase(get<TodoRepository>()));
    registerLazySingleton(() => DeleteTodoUseCase(get<TodoRepository>()));
    registerLazySingleton(() => ToggleTodoCompletionUseCase(get<TodoRepository>()));
    */
    
    AppLogger.debug('Business services registration completed', tag: 'DI');
  }
  
  /// 플랫폼별 원격 데이터 소스 사용 여부 결정
  static bool _shouldUseRemoteDataSource() {
    // 현재 플랫폼과 네트워크 상태에 따라 결정
    return true;
  }
  
  /// UI 서비스들 등록 (네비게이션, 테마 등)  
  static Future<void> _registerUIServices() async {
    // TODO: UI 관련 서비스들 등록
    /*
    // 네비게이션 서비스
    registerLazySingleton<NavigationService>(() => NavigationService());
    
    // 테마 서비스
    registerLazySingleton<ThemeService>(() => ThemeService());
    
    // 다이얼로그 서비스
    registerLazySingleton<DialogService>(() => DialogService());
    */
    
    AppLogger.debug('UI services registration completed', tag: 'DI');
  }
}

/// **의존성 주입 믹스인**
mixin DIAware {
  /// 서비스 조회
  T getService<T extends Object>() => ServiceLocator.get<T>();
  
  /// 서비스 등록 상태 확인
  bool isServiceRegistered<T extends Object>() => ServiceLocator.isRegistered<T>();
}

/// **서비스 생명주기 관리 인터페이스**
abstract class Disposable {
  Future<void> dispose();
}

/// **초기화 가능한 서비스 인터페이스**
abstract class Initializable {
  Future<void> initialize();
}

/// **서비스 모듈 추상 클래스**
abstract class ServiceModule {
  Future<void> register(ServiceLocator locator);
}

/// **테스트용 서비스 모듈**
class TestServiceModule implements ServiceModule {
  final Map<Type, Object> _mockServices = {};
  
  void addMock<T extends Object>(T mockService) {
    _mockServices[T] = mockService;
  }
  
  @override
  Future<void> register(ServiceLocator locator) async {
    for (final entry in _mockServices.entries) {
      ServiceLocator.replaceForTesting(entry.value);
    }
  }
}