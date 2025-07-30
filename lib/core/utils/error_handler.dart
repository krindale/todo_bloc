/// **중앙집중식 에러 핸들링 시스템**
///
/// 앱 전체에서 일관된 에러 처리를 제공합니다.
/// 에러 타입별로 적절한 처리 로직을 적용하고,
/// 사용자에게 의미있는 메시지를 제공합니다.

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_logger.dart';
import '../constants/app_constants.dart';

/// **앱 에러 타입 정의**
enum AppErrorType {
  network,
  authentication,
  permission,
  validation,
  storage,
  unknown,
}

/// **앱 에러 모델**
class AppError implements Exception {
  final AppErrorType type;
  final String message;
  final String? userMessage;
  final Object? originalError;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;
  
  const AppError({
    required this.type,
    required this.message,
    this.userMessage,
    this.originalError,
    this.stackTrace,
    this.metadata,
  });
  
  /// 사용자에게 표시할 메시지 반환
  String get displayMessage => userMessage ?? _getDefaultUserMessage();
  
  String _getDefaultUserMessage() {
    switch (type) {
      case AppErrorType.network:
        return AppStrings.networkError;
      case AppErrorType.authentication:
        return AppStrings.loginError;
      case AppErrorType.permission:
        return '권한이 필요합니다';
      case AppErrorType.validation:
        return '입력값을 확인해주세요';
      case AppErrorType.storage:
        return '데이터 처리 중 오류가 발생했습니다';
      case AppErrorType.unknown:
        return AppStrings.genericError;
    }
  }
  
  @override
  String toString() {
    return 'AppError(type: $type, message: $message, originalError: $originalError)';
  }
}

/// **에러 핸들러 결과**
class ErrorHandlingResult<T> {
  final T? data;
  final AppError? error;
  final bool isSuccess;
  
  const ErrorHandlingResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });
  
  factory ErrorHandlingResult.success(T data) {
    return ErrorHandlingResult._(data: data, isSuccess: true);
  }
  
  factory ErrorHandlingResult.failure(AppError error) {
    return ErrorHandlingResult._(error: error, isSuccess: false);
  }
  
  /// 성공 시 데이터 반환, 실패 시 예외 발생
  T getOrThrow() {
    if (isSuccess && data != null) {
      return data!;
    }
    throw error!;
  }
}

/// **에러 핸들러 클래스**
class ErrorHandler {
  ErrorHandler._();
  
  /// 비동기 작업을 안전하게 실행하고 에러를 처리
  static Future<ErrorHandlingResult<T>> handleAsync<T>(
    Future<T> Function() operation, {
    String? tag,
    Map<String, dynamic>? metadata,
    AppError Function(Object error, StackTrace stackTrace)? customErrorMapper,
  }) async {
    try {
      final result = await operation();
      return ErrorHandlingResult.success(result);
    } catch (error, stackTrace) {
      final appError = customErrorMapper?.call(error, stackTrace) ?? 
                      _mapErrorToAppError(error, stackTrace);
      
      // 로깅
      AppLogger.error(
        'Error in async operation: ${appError.message}',
        tag: tag,
        error: appError.originalError,
        stackTrace: stackTrace,
        metadata: {
          ...?metadata,
          'errorType': appError.type.name,
          'userMessage': appError.userMessage,
        },
      );
      
      return ErrorHandlingResult.failure(appError);
    }
  }
  
  /// 동기 작업을 안전하게 실행하고 에러를 처리
  static ErrorHandlingResult<T> handleSync<T>(
    T Function() operation, {
    String? tag,
    Map<String, dynamic>? metadata,
    AppError Function(Object error, StackTrace stackTrace)? customErrorMapper,
  }) {
    try {
      final result = operation();
      return ErrorHandlingResult.success(result);
    } catch (error, stackTrace) {
      final appError = customErrorMapper?.call(error, stackTrace) ?? 
                      _mapErrorToAppError(error, stackTrace);
      
      // 로깅
      AppLogger.error(
        'Error in sync operation: ${appError.message}',
        tag: tag,
        error: appError.originalError,
        stackTrace: stackTrace,
        metadata: {
          ...?metadata,
          'errorType': appError.type.name,
          'userMessage': appError.userMessage,
        },
      );
      
      return ErrorHandlingResult.failure(appError);
    }
  }
  
  /// 사용자에게 에러 메시지를 표시
  static void showErrorToUser(
    BuildContext context,
    AppError error, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;
    
    final snackBar = SnackBar(
      content: Text(error.displayMessage),
      backgroundColor: ThemeConstants.errorColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      action: action,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  /// 에러와 함께 재시도 옵션을 제공하는 스낵바
  static void showErrorWithRetry(
    BuildContext context,
    AppError error,
    VoidCallback onRetry, {
    String retryLabel = '다시 시도',
  }) {
    showErrorToUser(
      context,
      error,
      action: SnackBarAction(
        label: retryLabel,
        onPressed: onRetry,
        textColor: Colors.white,
      ),
    );
  }
  
  /// Object를 AppError로 변환
  static AppError _mapErrorToAppError(Object error, StackTrace stackTrace) {
    // Firebase Auth 에러
    if (error is FirebaseAuthException) {
      return AppError(
        type: AppErrorType.authentication,
        message: 'Firebase Auth Error: ${error.code}',
        userMessage: _getFirebaseAuthErrorMessage(error.code),
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // Firestore 에러
    if (error is FirebaseException) {
      return AppError(
        type: AppErrorType.storage,
        message: 'Firebase Error: ${error.code}',
        userMessage: _getFirebaseErrorMessage(error.code),
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // 네트워크 에러
    if (error is SocketException) {
      return AppError(
        type: AppErrorType.network,
        message: 'Network Error: ${error.message}',
        userMessage: AppStrings.networkError,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // 타임아웃 에러
    if (error is TimeoutException) {
      return AppError(
        type: AppErrorType.network,
        message: 'Timeout Error: ${error.message}',
        userMessage: '요청 시간이 초과되었습니다',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // 형변환 에러
    if (error is TypeError || error is CastError) {
      return AppError(
        type: AppErrorType.validation,
        message: 'Type Error: $error',
        userMessage: '데이터 형식이 올바르지 않습니다',
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // 인수 에러
    if (error is ArgumentError) {
      return AppError(
        type: AppErrorType.validation,
        message: 'Argument Error: ${error.message}',
        userMessage: ValidationConstants.requiredField,
        originalError: error,
        stackTrace: stackTrace,
      );
    }
    
    // 기본 에러
    return AppError(
      type: AppErrorType.unknown,
      message: 'Unknown Error: $error',
      userMessage: AppStrings.genericError,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
  
  /// Firebase Auth 에러 코드를 사용자 친화적 메시지로 변환
  static String _getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return '등록되지 않은 사용자입니다';
      case 'wrong-password':
        return '비밀번호가 올바르지 않습니다';
      case 'invalid-email':
        return '유효하지 않은 이메일 주소입니다';
      case 'user-disabled':
        return '비활성화된 계정입니다';
      case 'too-many-requests':
        return '너무 많은 요청이 발생했습니다. 잠시 후 다시 시도해주세요';
      case 'operation-not-allowed':
        return '허용되지 않은 작업입니다';
      case 'weak-password':
        return '비밀번호가 너무 약합니다';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일 주소입니다';
      default:
        return AppStrings.loginError;
    }
  }
  
  /// Firebase 에러 코드를 사용자 친화적 메시지로 변환
  static String _getFirebaseErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'permission-denied':
        return '권한이 없습니다';
      case 'not-found':
        return '요청한 데이터를 찾을 수 없습니다';
      case 'already-exists':
        return '이미 존재하는 데이터입니다';
      case 'resource-exhausted':
        return '할당량을 초과했습니다';
      case 'failed-precondition':
        return '작업 조건이 충족되지 않았습니다';
      case 'aborted':
        return '작업이 중단되었습니다';
      case 'out-of-range':
        return '범위를 벗어난 요청입니다';
      case 'unimplemented':
        return '구현되지 않은 기능입니다';
      case 'internal':
        return '내부 서버 오류가 발생했습니다';
      case 'unavailable':
        return '서비스를 사용할 수 없습니다';
      case 'data-loss':
        return '데이터 손실이 발생했습니다';
      case 'unauthenticated':
        return '인증이 필요합니다';
      default:
        return AppStrings.genericError;
    }
  }
}

/// **에러 핸들링 믹스인**
mixin ErrorHandlingMixin {
  /// 안전하게 setState 호출
  void safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }
  
  /// 위젯이 마운트된 상태인지 확인
  bool get mounted;
  
  /// setState 메서드 (StatefulWidget에서 구현)
  void setState(VoidCallback fn);
  
  /// 에러를 사용자에게 표시
  void showError(BuildContext context, AppError error) {
    ErrorHandler.showErrorToUser(context, error);
  }
  
  /// 에러와 함께 재시도 옵션 제공
  void showErrorWithRetry(
    BuildContext context,
    AppError error,
    VoidCallback onRetry,
  ) {
    ErrorHandler.showErrorWithRetry(context, error, onRetry);
  }
}