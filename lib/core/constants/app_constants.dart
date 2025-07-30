/// **앱 전체 상수 정의**
/// 
/// 매직 넘버, 하드코딩된 문자열, 애니메이션 설정 등을 중앙 집중적으로 관리합니다.
/// 이를 통해 코드 유지보수성을 높이고 일관성을 보장합니다.

import 'package:flutter/material.dart';

/// **애니메이션 관련 상수**
class AnimationConstants {
  AnimationConstants._();
  
  static const Duration fadeAnimation = Duration(milliseconds: 500);
  static const Duration slideAnimation = Duration(milliseconds: 300);
  static const Duration recommendationAnimation = Duration(milliseconds: 400);
  static const Duration headerAnimation = Duration(milliseconds: 350);
  static const Duration todoItemAnimation = Duration(milliseconds: 200);
  static const Duration rippleAnimation = Duration(milliseconds: 150);
}

/// **UI 레이아웃 관련 상수**
class LayoutConstants {
  LayoutConstants._();
  
  // 패딩 및 마진
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double cardPadding = 12.0;
  
  // 보더 및 모서리
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  static const double chipBorderRadius = 20.0;
  
  // 높이 및 너비
  static const double appBarHeight = 56.0;
  static const double todoItemHeight = 80.0;
  static const double buttonHeight = 48.0;
  static const double minTouchTarget = 44.0;
  
  // 간격
  static const double defaultSpacing = 16.0;
  static const double smallSpacing = 8.0;
  static const double largeSpacing = 24.0;
  static const double sectionSpacing = 32.0;
  
  // 반응형 브레이크포인트
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
}

/// **텍스트 및 폰트 관련 상수**
class TextConstants {
  TextConstants._();
  
  // 폰트 크기
  static const double headlineLarge = 32.0;
  static const double headlineMedium = 28.0;
  static const double headlineSmall = 24.0;
  static const double titleLarge = 22.0;
  static const double titleMedium = 16.0;
  static const double titleSmall = 14.0;
  static const double bodyLarge = 16.0;
  static const double bodyMedium = 14.0;
  static const double bodySmall = 12.0;
  static const double labelLarge = 14.0;
  static const double labelMedium = 12.0;
  static const double labelSmall = 10.0;
  
  // 라인 높이
  static const double defaultLineHeight = 1.4;
  static const double compactLineHeight = 1.2;
  static const double relaxedLineHeight = 1.6;
  
  // 최대 라인 수
  static const int todoTitleMaxLines = 2;
  static const int descriptionMaxLines = 3;
  static const int singleLine = 1;
}

/// **할 일 우선순위 관련 상수**
class PriorityConstants {
  PriorityConstants._();
  
  static const String high = 'High';
  static const String medium = 'Medium';  
  static const String low = 'Low';
  
  static const List<String> allPriorities = [high, medium, low];
  
  static const Map<String, Color> priorityColors = {
    high: Colors.red,
    medium: Colors.orange, 
    low: Colors.green,
  };
  
  static const Map<String, IconData> priorityIcons = {
    high: Icons.priority_high,
    medium: Icons.remove,
    low: Icons.low_priority,
  };
}

/// **할 일 카테고리 관련 상수**
class CategoryConstants {
  CategoryConstants._();
  
  static const String general = '일반';
  static const String work = '업무';
  static const String personal = '개인';
  static const String health = '건강';
  static const String study = '학습';
  static const String finance = '재정';
  static const String lifestyle = '생활';
  
  static const List<String> defaultCategories = [
    general, work, personal, health, study, finance, lifestyle
  ];
  
  static const Map<String, Color> categoryColors = {
    general: Colors.grey,
    work: Colors.blue,
    personal: Colors.purple,
    health: Colors.green,
    study: Colors.indigo,
    finance: Colors.teal,
    lifestyle: Colors.orange,
  };
  
  static const Map<String, IconData> categoryIcons = {
    general: Icons.task_alt,
    work: Icons.work,
    personal: Icons.person,
    health: Icons.health_and_safety,
    study: Icons.school,
    finance: Icons.attach_money,
    lifestyle: Icons.home,
  };
}

/// **데이터베이스 관련 상수**
class DatabaseConstants {
  DatabaseConstants._();
  
  // Hive 타입 ID
  static const int todoItemTypeId = 0;
  static const int savedLinkTypeId = 1;
  
  // Hive 박스 이름
  static const String todoBoxName = 'todos';
  static const String settingsBoxName = 'settings';
  static const String cacheBoxName = 'cache';
  
  // Firebase 컬렉션 이름
  static const String todosCollection = 'todos';
  static const String usersCollection = 'users';
  static const String settingsCollection = 'settings';
  
  // 설정 키
  static const String themeKey = 'theme';
  static const String languageKey = 'language';
  static const String notificationsKey = 'notifications';
}

/// **네트워크 관련 상수**
class NetworkConstants {
  NetworkConstants._();
  
  // 타임아웃
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(minutes: 2);
  static const Duration downloadTimeout = Duration(minutes: 5);
  
  // 재시도
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // HTTP 상태 코드
  static const int httpOk = 200;
  static const int httpCreated = 201;
  static const int httpBadRequest = 400;
  static const int httpUnauthorized = 401;
  static const int httpForbidden = 403;
  static const int httpNotFound = 404;
  static const int httpTooManyRequests = 429;
  static const int httpInternalServerError = 500;
}

/// **앱 문자열 상수**
class AppStrings {
  AppStrings._();
  
  // 앱 정보
  static const String appName = 'Task Manager';
  static const String appVersion = '1.0.0';
  
  // 탭 제목
  static const String tasksTab = 'Tasks';
  static const String aiGeneratorTab = 'AI Generator';
  static const String summaryTab = 'Summary';
  static const String linksTab = 'Links';
  
  // 공통 액션
  static const String save = '저장';
  static const String cancel = '취소';
  static const String delete = '삭제';
  static const String edit = '편집';
  static const String add = '추가';
  static const String retry = '다시 시도';
  static const String logout = '로그아웃';
  
  // AI 생성 화면
  static const String aiGeneratorTitle = 'AI 할 일 생성';
  static const String aiGeneratorDescription = '추상적인 목표를 구체적인 할 일로 변환해드립니다';
  static const String generateButton = 'AI로 할 일 생성';
  static const String generating = 'AI가 생각 중...';
  static const String recommendationsTitle = '추천 요청';
  static const String generatedTodosTitle = '생성된 할 일 목록';
  static const String resetButton = '다시 생성하기';
  
  // 에러 메시지
  static const String genericError = '오류가 발생했습니다';
  static const String networkError = '네트워크 연결을 확인해주세요';
  static const String loginError = '로그인 중 오류가 발생했습니다';
  static const String logoutError = '로그아웃 중 오류가 발생했습니다';
  static const String saveError = '저장 중 오류가 발생했습니다';
  static const String loadError = '데이터를 불러오는 중 오류가 발생했습니다';
  
  // 성공 메시지
  static const String saveSuccess = '저장되었습니다';
  static const String deleteSuccess = '삭제되었습니다';
  static const String updateSuccess = '업데이트되었습니다';
  
  // 플레이스홀더
  static const String todoTitlePlaceholder = '할 일을 입력하세요';
  static const String searchPlaceholder = '검색어를 입력하세요';
  static const String aiRequestPlaceholder = '예: 건강을 위한 플랜을 짜줘, 새로운 기술을 배우고 싶어';
  static const String newRequestPlaceholder = '새로운 요청을 입력하세요';
}

/// **테마 관련 상수**
class ThemeConstants {
  ThemeConstants._();
  
  // 색상
  static const Color primaryColor = Colors.blue;
  static const Color secondaryColor = Colors.blueAccent;
  static const Color errorColor = Colors.red;
  static const Color warningColor = Colors.orange;
  static const Color successColor = Colors.green;
  static const Color infoColor = Colors.blue;
  
  // 그림자
  static const List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
  
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];
  
  // 투명도
  static const double disabledOpacity = 0.38;
  static const double hoverOpacity = 0.04;
  static const double focusOpacity = 0.12;
  static const double selectedOpacity = 0.08;
}

/// **유효성 검사 관련 상수**
class ValidationConstants {
  ValidationConstants._();
  
  // 길이 제한
  static const int todoTitleMinLength = 1;
  static const int todoTitleMaxLength = 100;
  static const int descriptionMaxLength = 500;
  static const int categoryMaxLength = 50;
  
  // 정규식 패턴
  static const String emailPattern = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
  static const String urlPattern = r'^https?:\/\/.+';
  
  // 에러 메시지
  static const String requiredField = '필수 입력 항목입니다';
  static const String tooShort = '너무 짧습니다';
  static const String tooLong = '너무 깁니다';
  static const String invalidEmail = '유효하지 않은 이메일 형식입니다';
  static const String invalidUrl = '유효하지 않은 URL 형식입니다';
}

/// **환경 변수 키 상수**
class EnvironmentConstants {
  EnvironmentConstants._();
  
  static const String geminiApiKey = 'GEMINI_API_KEY';
  static const String firebaseApiKey = 'FIREBASE_API_KEY';
  static const String sentryDsn = 'SENTRY_DSN';
  static const String appEnvironment = 'APP_ENVIRONMENT';
}

/// **로깅 관련 상수**  
class LogConstants {
  LogConstants._();
  
  static const String debugTag = '[DEBUG]';
  static const String infoTag = '[INFO]';
  static const String warningTag = '[WARNING]';
  static const String errorTag = '[ERROR]';
  
  static const int maxLogLength = 1000;
  static const int maxLogFiles = 10;
}