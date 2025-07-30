/// **중앙집중식 로깅 시스템**
///
/// 앱 전체에서 일관된 로깅을 제공합니다.
/// 개발/프로덕션 환경에 따라 다른 로깅 레벨을 적용하고,
/// 향후 외부 로깅 서비스(Crashlytics, Sentry 등) 연동을 위한 기반을 제공합니다.

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// **로그 레벨 정의**
enum LogLevel {
  debug(0),
  info(1), 
  warning(2),
  error(3);
  
  const LogLevel(this.value);
  final int value;
  
  bool operator >=(LogLevel other) => value >= other.value;
}

/// **로그 엔트리 모델**
class LogEntry {
  final LogLevel level;
  final String message;
  final String? tag;
  final Object? error;
  final StackTrace? stackTrace;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  
  const LogEntry({
    required this.level,
    required this.message,
    this.tag,
    this.error,
    this.stackTrace,
    required this.timestamp,
    this.metadata,
  });
  
  @override
  String toString() {
    final buffer = StringBuffer();
    
    // 타임스탬프
    buffer.write('[${timestamp.toIso8601String()}] ');
    
    // 로그 레벨
    switch (level) {
      case LogLevel.debug:
        buffer.write(LogConstants.debugTag);
        break;
      case LogLevel.info:
        buffer.write(LogConstants.infoTag);
        break;
      case LogLevel.warning:
        buffer.write(LogConstants.warningTag);
        break;
      case LogLevel.error:
        buffer.write(LogConstants.errorTag);
        break;
    }
    
    // 태그
    if (tag != null) {
      buffer.write(' [$tag]');
    }
    
    // 메시지
    buffer.write(' $message');
    
    // 에러 정보
    if (error != null) {
      buffer.write('\nError: $error');
    }
    
    // 스택 트레이스
    if (stackTrace != null) {
      buffer.write('\nStackTrace: $stackTrace');
    }
    
    // 메타데이터
    if (metadata != null && metadata!.isNotEmpty) {
      buffer.write('\nMetadata: $metadata');
    }
    
    return buffer.toString();
  }
}

/// **로거 인터페이스**
abstract class Logger {
  void log(LogEntry entry);
  void debug(String message, {String? tag, Map<String, dynamic>? metadata});
  void info(String message, {String? tag, Map<String, dynamic>? metadata});
  void warning(String message, {String? tag, Object? error, Map<String, dynamic>? metadata});
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata});
}

/// **콘솔 로거 구현**
class ConsoleLogger implements Logger {
  final LogLevel minLevel;
  
  const ConsoleLogger({this.minLevel = LogLevel.debug});
  
  @override
  void log(LogEntry entry) {
    if (entry.level >= minLevel) {
      final message = entry.toString();
      
      // 메시지 길이 제한
      final truncatedMessage = message.length > LogConstants.maxLogLength
          ? '${message.substring(0, LogConstants.maxLogLength)}...[TRUNCATED]'
          : message;
      
      if (kDebugMode) {
        // 개발 모드에서는 developer.log 사용
        developer.log(
          truncatedMessage,
          name: entry.tag ?? 'App',
          level: entry.level.value * 100,
          error: entry.error,
          stackTrace: entry.stackTrace,
        );
      } else {
        // 릴리즈 모드에서는 print 사용 (필요시에만)
        if (entry.level >= LogLevel.error) {
          print(truncatedMessage);
        }
      }
    }
  }
  
  @override
  void debug(String message, {String? tag, Map<String, dynamic>? metadata}) {
    log(LogEntry(
      level: LogLevel.debug,
      message: message,
      tag: tag,
      timestamp: DateTime.now(),
      metadata: metadata,
    ));
  }
  
  @override
  void info(String message, {String? tag, Map<String, dynamic>? metadata}) {
    log(LogEntry(
      level: LogLevel.info,
      message: message,
      tag: tag,
      timestamp: DateTime.now(),
      metadata: metadata,
    ));
  }
  
  @override
  void warning(String message, {String? tag, Object? error, Map<String, dynamic>? metadata}) {
    log(LogEntry(
      level: LogLevel.warning,
      message: message,
      tag: tag,
      error: error,
      timestamp: DateTime.now(),
      metadata: metadata,
    ));
  }
  
  @override
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    log(LogEntry(
      level: LogLevel.error,
      message: message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      timestamp: DateTime.now(),
      metadata: metadata,
    ));
  }
}

/// **복합 로거 (여러 로거를 함께 사용)**
class CompositeLogger implements Logger {
  final List<Logger> _loggers;
  
  const CompositeLogger(this._loggers);
  
  @override
  void log(LogEntry entry) {
    for (final logger in _loggers) {
      logger.log(entry);
    }
  }
  
  @override
  void debug(String message, {String? tag, Map<String, dynamic>? metadata}) {
    for (final logger in _loggers) {
      logger.debug(message, tag: tag, metadata: metadata);
    }
  }
  
  @override
  void info(String message, {String? tag, Map<String, dynamic>? metadata}) {
    for (final logger in _loggers) {
      logger.info(message, tag: tag, metadata: metadata);
    }
  }
  
  @override
  void warning(String message, {String? tag, Object? error, Map<String, dynamic>? metadata}) {
    for (final logger in _loggers) {
      logger.warning(message, tag: tag, error: error, metadata: metadata);
    }
  }
  
  @override
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    for (final logger in _loggers) {
      logger.error(message, tag: tag, error: error, stackTrace: stackTrace, metadata: metadata);
    }
  }
}

/// **글로벌 앱 로거**
class AppLogger {
  static Logger _instance = ConsoleLogger(
    minLevel: kDebugMode ? LogLevel.debug : LogLevel.warning,
  );
  
  /// 로거 인스턴스 설정 (앱 초기화 시 호출)
  static void initialize(Logger logger) {
    _instance = logger;
  }
  
  /// 현재 로거 인스턴스 반환
  static Logger get instance => _instance;
  
  // 편의 메서드들
  static void debug(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _instance.debug(message, tag: tag, metadata: metadata);
  }
  
  static void info(String message, {String? tag, Map<String, dynamic>? metadata}) {
    _instance.info(message, tag: tag, metadata: metadata);
  }
  
  static void warning(String message, {String? tag, Object? error, Map<String, dynamic>? metadata}) {
    _instance.warning(message, tag: tag, error: error, metadata: metadata);
  }
  
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace, Map<String, dynamic>? metadata}) {
    _instance.error(message, tag: tag, error: error, stackTrace: stackTrace, metadata: metadata);
  }
}