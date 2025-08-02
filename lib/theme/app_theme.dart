/// **애플리케이션 테마 정의**
/// 
/// 다크모드와 라이트모드를 위한 완전한 테마 시스템을 제공합니다.
/// 
/// **주요 기능:**
/// - Material Design 3 기반 색상 시스템
/// - 높은 대비율을 가진 접근성 친화적 색상
/// - 일관된 디자인 시스템
/// - Todo 앱에 최적화된 색상 팔레트
/// 
/// **색상 철학:**
/// - 라이트 모드: 따뜻하고 부드러운 색조
/// - 다크 모드: 눈의 피로를 줄이는 어두운 색조
/// - 브랜드 색상: 파란색 계열로 신뢰감과 집중력 강조

import 'package:flutter/material.dart';

/// 애플리케이션 테마 클래스
class AppTheme {
  // 브랜드 색상 팔레트
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF1976D2);
  static const Color accentBlue = Color(0xFF03A9F4);
  
  // 라이트 모드 색상
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightBorder = Color(0xFFE1E4E8);
  
  // 다크 모드 색상
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBackground = Color(0xFF2D2D2D);
  static const Color darkText = Color(0xFFE1E1E1);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF424242);
  static const Color darkBorder = Color(0xFF3A3A3A);
  
  // 상태 색상
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color infoColor = Color(0xFF2196F3);
  
  // Todo 상태별 색상
  static const Color todoCompletedLight = Color(0xFF4CAF50);
  static const Color todoCompletedDark = Color(0xFF66BB6A);
  static const Color todoPendingLight = Color(0xFFFF9800);
  static const Color todoPendingDark = Color(0xFFFFB74D);
  static const Color todoHighPriorityLight = Color(0xFFF44336);
  static const Color todoHighPriorityDark = Color(0xFFE57373);

  /// 라이트 테마 정의
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      
      // 색상 스키마
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: lightSurface,
        background: lightBackground,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightText,
        onBackground: lightText,
        onError: Colors.white,
      ),
      
      // 앱바 테마
      appBarTheme: const AppBarTheme(
        backgroundColor: lightSurface,
        foregroundColor: lightText,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: lightText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: lightText),
      ),
      
      // 카드 테마
      cardTheme: CardThemeData(
        color: lightCardBackground,
        elevation: 2,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: lightBorder, width: 0.5),
        ),
      ),
      
      // 리스트 타일 테마
      listTileTheme: const ListTileThemeData(
        tileColor: lightSurface,
        textColor: lightText,
        iconColor: lightTextSecondary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // 텍스트 테마
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: lightText, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: lightText, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: lightText, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: lightText, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: lightText, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: lightText, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: lightText, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: lightText, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: lightText, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: lightText),
        bodyMedium: TextStyle(color: lightText),
        bodySmall: TextStyle(color: lightTextSecondary),
        labelLarge: TextStyle(color: lightText, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: lightTextSecondary),
        labelSmall: TextStyle(color: lightTextSecondary),
      ),
      
      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        hintStyle: const TextStyle(color: lightTextSecondary),
      ),
      
      // 플로팅 액션 버튼 테마
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      
      // 스위치 테마
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryBlue;
          }
          return Colors.grey[400];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryBlue.withOpacity(0.5);
          }
          return Colors.grey[300];
        }),
      ),
      
      // 구분선 테마
      dividerTheme: const DividerThemeData(
        color: lightDivider,
        thickness: 0.5,
      ),
      
      // 스캐폴드 배경색
      scaffoldBackgroundColor: lightBackground,
    );
  }

  /// 다크 테마 정의
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      
      // 색상 스키마
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: darkSurface,
        background: darkBackground,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
        onBackground: darkText,
        onError: Colors.white,
      ),
      
      // 앱바 테마
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkText,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: darkText),
      ),
      
      // 카드 테마
      cardTheme: CardThemeData(
        color: darkCardBackground,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: darkBorder, width: 0.5),
        ),
      ),
      
      // 리스트 타일 테마
      listTileTheme: const ListTileThemeData(
        tileColor: darkSurface,
        textColor: darkText,
        iconColor: darkTextSecondary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      
      // 텍스트 테마
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: darkText, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: darkText, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: darkText, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: darkText, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: darkText, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: darkText, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: darkText),
        bodyMedium: TextStyle(color: darkText),
        bodySmall: TextStyle(color: darkTextSecondary),
        labelLarge: TextStyle(color: darkText, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: darkTextSecondary),
        labelSmall: TextStyle(color: darkTextSecondary),
      ),
      
      // 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        hintStyle: const TextStyle(color: darkTextSecondary),
      ),
      
      // 플로팅 액션 버튼 테마
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      
      // 스위치 테마
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryBlue;
          }
          return Colors.grey[600];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryBlue.withOpacity(0.5);
          }
          return Colors.grey[700];
        }),
      ),
      
      // 구분선 테마
      dividerTheme: const DividerThemeData(
        color: darkDivider,
        thickness: 0.5,
      ),
      
      // 스캐폴드 배경색
      scaffoldBackgroundColor: darkBackground,
    );
  }

  /// Todo 항목 상태별 색상 가져오기
  static Color getTodoStatusColor(bool isCompleted, bool isDarkMode) {
    if (isCompleted) {
      return isDarkMode ? todoCompletedDark : todoCompletedLight;
    }
    return isDarkMode ? todoPendingDark : todoPendingLight;
  }

  /// 우선순위별 색상 가져오기
  static Color getPriorityColor(bool isHighPriority, bool isDarkMode) {
    if (isHighPriority) {
      return isDarkMode ? todoHighPriorityDark : todoHighPriorityLight;
    }
    return isDarkMode ? todoPendingDark : todoPendingLight;
  }

  /// 테마별 아이콘 색상
  static Color getIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  /// 테마별 보조 텍스트 색상
  static Color getSecondaryTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : lightTextSecondary;
  }

  /// 테마별 구분선 색상
  static Color getDividerColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkDivider
        : lightDivider;
  }
}