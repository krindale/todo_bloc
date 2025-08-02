/// **앱 테마 데이터 테스트**
/// 
/// AppTheme 클래스의 테마 정의와 유틸리티 메서드를 검증하는 테스트입니다.
/// 
/// **테스트 범위:**
/// - 라이트/다크 테마 데이터 구조
/// - 색상 팔레트 일관성
/// - 유틸리티 메서드 동작
/// - 테마 호환성 및 접근성
/// - 컴포넌트별 테마 설정

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../lib/theme/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    group('테마 데이터 구조 검증', () {
      test('should have valid light theme data', () {
        final lightTheme = AppTheme.lightTheme;
        
        // 기본 테마 속성 확인
        expect(lightTheme, isA<ThemeData>());
        expect(lightTheme.brightness, equals(Brightness.light));
        expect(lightTheme.useMaterial3, isTrue);
        
        // 색상 스키마 확인
        final colorScheme = lightTheme.colorScheme;
        expect(colorScheme.brightness, equals(Brightness.light));
        expect(colorScheme.primary, equals(AppTheme.primaryBlue));
        expect(colorScheme.secondary, equals(AppTheme.accentBlue));
        expect(colorScheme.surface, equals(AppTheme.lightSurface));
        expect(colorScheme.background, equals(AppTheme.lightBackground));
        expect(colorScheme.error, equals(AppTheme.errorColor));
      });

      test('should have valid dark theme data', () {
        final darkTheme = AppTheme.darkTheme;
        
        // 기본 테마 속성 확인
        expect(darkTheme, isA<ThemeData>());
        expect(darkTheme.brightness, equals(Brightness.dark));
        expect(darkTheme.useMaterial3, isTrue);
        
        // 색상 스키마 확인
        final colorScheme = darkTheme.colorScheme;
        expect(colorScheme.brightness, equals(Brightness.dark));
        expect(colorScheme.primary, equals(AppTheme.primaryBlue));
        expect(colorScheme.secondary, equals(AppTheme.accentBlue));
        expect(colorScheme.surface, equals(AppTheme.darkSurface));
        expect(colorScheme.background, equals(AppTheme.darkBackground));
        expect(colorScheme.error, equals(AppTheme.errorColor));
      });

      test('should have consistent primary colors across themes', () {
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;
        
        // 브랜드 색상은 두 테마에서 동일해야 함
        expect(lightTheme.colorScheme.primary, equals(darkTheme.colorScheme.primary));
        expect(lightTheme.colorScheme.secondary, equals(darkTheme.colorScheme.secondary));
        expect(lightTheme.colorScheme.error, equals(darkTheme.colorScheme.error));
      });
    });

    group('색상 팔레트 검증', () {
      test('should have defined brand colors', () {
        expect(AppTheme.primaryBlue, equals(const Color(0xFF2196F3)));
        expect(AppTheme.primaryBlueDark, equals(const Color(0xFF1976D2)));
        expect(AppTheme.accentBlue, equals(const Color(0xFF03A9F4)));
      });

      test('should have light mode colors', () {
        expect(AppTheme.lightBackground, equals(const Color(0xFFFAFAFA)));
        expect(AppTheme.lightSurface, equals(const Color(0xFFFFFFFF)));
        expect(AppTheme.lightCardBackground, equals(const Color(0xFFFFFFFF)));
        expect(AppTheme.lightText, equals(const Color(0xFF212121)));
        expect(AppTheme.lightTextSecondary, equals(const Color(0xFF757575)));
      });

      test('should have dark mode colors', () {
        expect(AppTheme.darkBackground, equals(const Color(0xFF121212)));
        expect(AppTheme.darkSurface, equals(const Color(0xFF1E1E1E)));
        expect(AppTheme.darkCardBackground, equals(const Color(0xFF2D2D2D)));
        expect(AppTheme.darkText, equals(const Color(0xFFE1E1E1)));
        expect(AppTheme.darkTextSecondary, equals(const Color(0xFFB0B0B0)));
      });

      test('should have status colors', () {
        expect(AppTheme.successColor, equals(const Color(0xFF4CAF50)));
        expect(AppTheme.warningColor, equals(const Color(0xFFFF9800)));
        expect(AppTheme.errorColor, equals(const Color(0xFFF44336)));
        expect(AppTheme.infoColor, equals(const Color(0xFF2196F3)));
      });

      test('should have todo status colors', () {
        expect(AppTheme.todoCompletedLight, equals(const Color(0xFF4CAF50)));
        expect(AppTheme.todoCompletedDark, equals(const Color(0xFF66BB6A)));
        expect(AppTheme.todoPendingLight, equals(const Color(0xFFFF9800)));
        expect(AppTheme.todoPendingDark, equals(const Color(0xFFFFB74D)));
        expect(AppTheme.todoHighPriorityLight, equals(const Color(0xFFF44336)));
        expect(AppTheme.todoHighPriorityDark, equals(const Color(0xFFE57373)));
      });
    });

    group('컴포넌트 테마 검증', () {
      test('should have proper app bar theme for light mode', () {
        final lightTheme = AppTheme.lightTheme;
        final appBarTheme = lightTheme.appBarTheme;
        
        expect(appBarTheme.backgroundColor, equals(AppTheme.lightSurface));
        expect(appBarTheme.foregroundColor, equals(AppTheme.lightText));
        expect(appBarTheme.elevation, equals(0));
        expect(appBarTheme.scrolledUnderElevation, equals(1));
        expect(appBarTheme.surfaceTintColor, equals(Colors.transparent));
      });

      test('should have proper app bar theme for dark mode', () {
        final darkTheme = AppTheme.darkTheme;
        final appBarTheme = darkTheme.appBarTheme;
        
        expect(appBarTheme.backgroundColor, equals(AppTheme.darkSurface));
        expect(appBarTheme.foregroundColor, equals(AppTheme.darkText));
        expect(appBarTheme.elevation, equals(0));
        expect(appBarTheme.scrolledUnderElevation, equals(1));
        expect(appBarTheme.surfaceTintColor, equals(Colors.transparent));
      });

      test('should have proper card theme for both modes', () {
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;
        
        // 라이트 모드 카드 테마
        final lightCardTheme = lightTheme.cardTheme;
        expect(lightCardTheme.color, equals(AppTheme.lightCardBackground));
        expect(lightCardTheme.elevation, equals(2));
        expect(lightCardTheme.shadowColor, equals(Colors.black26));
        
        // 다크 모드 카드 테마
        final darkCardTheme = darkTheme.cardTheme;
        expect(darkCardTheme.color, equals(AppTheme.darkCardBackground));
        expect(darkCardTheme.elevation, equals(4));
        expect(darkCardTheme.shadowColor, equals(Colors.black54));
      });

      test('should have proper floating action button theme', () {
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;
        
        // 두 테마 모두 동일한 FAB 설정
        expect(lightTheme.floatingActionButtonTheme.backgroundColor, equals(AppTheme.primaryBlue));
        expect(lightTheme.floatingActionButtonTheme.foregroundColor, equals(Colors.white));
        expect(darkTheme.floatingActionButtonTheme.backgroundColor, equals(AppTheme.primaryBlue));
        expect(darkTheme.floatingActionButtonTheme.foregroundColor, equals(Colors.white));
      });

      test('should have proper switch theme configuration', () {
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;
        
        // 스위치 테마가 정의되어 있는지 확인
        expect(lightTheme.switchTheme, isNotNull);
        expect(darkTheme.switchTheme, isNotNull);
        
        // 스위치 색상 설정 확인
        expect(lightTheme.switchTheme.thumbColor, isA<MaterialStateProperty<Color?>>());
        expect(lightTheme.switchTheme.trackColor, isA<MaterialStateProperty<Color?>>());
        expect(darkTheme.switchTheme.thumbColor, isA<MaterialStateProperty<Color?>>());
        expect(darkTheme.switchTheme.trackColor, isA<MaterialStateProperty<Color?>>());
      });
    });

    group('유틸리티 메서드 테스트', () {
      testWidgets('should return correct todo status colors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: Builder(
              builder: (context) {
                // 라이트 모드에서 완료된 할 일 색상
                final lightCompletedColor = AppTheme.getTodoStatusColor(true, false);
                expect(lightCompletedColor, equals(AppTheme.todoCompletedLight));
                
                // 다크 모드에서 완료된 할 일 색상
                final darkCompletedColor = AppTheme.getTodoStatusColor(true, true);
                expect(darkCompletedColor, equals(AppTheme.todoCompletedDark));
                
                // 라이트 모드에서 대기 중인 할 일 색상
                final lightPendingColor = AppTheme.getTodoStatusColor(false, false);
                expect(lightPendingColor, equals(AppTheme.todoPendingLight));
                
                // 다크 모드에서 대기 중인 할 일 색상
                final darkPendingColor = AppTheme.getTodoStatusColor(false, true);
                expect(darkPendingColor, equals(AppTheme.todoPendingDark));
                
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return correct priority colors', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            home: Builder(
              builder: (context) {
                // 라이트 모드에서 높은 우선순위 색상
                final lightHighPriorityColor = AppTheme.getPriorityColor(true, false);
                expect(lightHighPriorityColor, equals(AppTheme.todoHighPriorityLight));
                
                // 다크 모드에서 높은 우선순위 색상
                final darkHighPriorityColor = AppTheme.getPriorityColor(true, true);
                expect(darkHighPriorityColor, equals(AppTheme.todoHighPriorityDark));
                
                // 라이트 모드에서 일반 우선순위 색상
                final lightNormalPriorityColor = AppTheme.getPriorityColor(false, false);
                expect(lightNormalPriorityColor, equals(AppTheme.todoPendingLight));
                
                // 다크 모드에서 일반 우선순위 색상
                final darkNormalPriorityColor = AppTheme.getPriorityColor(false, true);
                expect(darkNormalPriorityColor, equals(AppTheme.todoPendingDark));
                
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('should return correct context-based colors', (tester) async {
        // 라이트 테마 테스트
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.light,
            home: Builder(
              builder: (context) {
                final iconColor = AppTheme.getIconColor(context);
                final secondaryTextColor = AppTheme.getSecondaryTextColor(context);
                final dividerColor = AppTheme.getDividerColor(context);
                
                expect(iconColor, equals(AppTheme.lightTextSecondary));
                expect(secondaryTextColor, equals(AppTheme.lightTextSecondary));
                expect(dividerColor, equals(AppTheme.lightDivider));
                
                return Container();
              },
            ),
          ),
        );
        
        // 다크 테마 테스트
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: Builder(
              builder: (context) {
                final iconColor = AppTheme.getIconColor(context);
                final secondaryTextColor = AppTheme.getSecondaryTextColor(context);
                final dividerColor = AppTheme.getDividerColor(context);
                
                expect(iconColor, equals(AppTheme.darkTextSecondary));
                expect(secondaryTextColor, equals(AppTheme.darkTextSecondary));
                expect(dividerColor, equals(AppTheme.darkDivider));
                
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('접근성 및 대비율 검증', () {
      test('should have sufficient contrast ratios for text', () {
        // 라이트 모드 대비율 검증
        final lightBackgroundLuminance = AppTheme.lightBackground.computeLuminance();
        final lightTextLuminance = AppTheme.lightText.computeLuminance();
        final lightContrast = _calculateContrastRatio(lightBackgroundLuminance, lightTextLuminance);
        
        expect(lightContrast, greaterThan(4.5)); // WCAG AA 표준
        
        // 다크 모드 대비율 검증
        final darkBackgroundLuminance = AppTheme.darkBackground.computeLuminance();
        final darkTextLuminance = AppTheme.darkText.computeLuminance();
        final darkContrast = _calculateContrastRatio(darkBackgroundLuminance, darkTextLuminance);
        
        expect(darkContrast, greaterThan(4.5)); // WCAG AA 표준
      });

      test('should have sufficient contrast for interactive elements', () {
        // 버튼 대비율 검증
        final primaryLuminance = AppTheme.primaryBlue.computeLuminance();
        final whiteLuminance = Colors.white.computeLuminance();
        final buttonContrast = _calculateContrastRatio(primaryLuminance, whiteLuminance);
        
        expect(buttonContrast, greaterThan(3.0)); // WCAG AA 표준 (대형 텍스트/버튼)
      });
    });

    group('테마 일관성 검증', () {
      test('should use consistent spacing and sizes', () {
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;
        
        // 카드 모서리 반지름 일관성
        final lightCardShape = lightTheme.cardTheme.shape as RoundedRectangleBorder;
        final darkCardShape = darkTheme.cardTheme.shape as RoundedRectangleBorder;
        
        expect(lightCardShape.borderRadius, equals(darkCardShape.borderRadius));
      });

      test('should have proper elevation hierarchy', () {
        final lightTheme = AppTheme.lightTheme;
        final darkTheme = AppTheme.darkTheme;
        
        // 엘레베이션 계층 확인
        final lightAppBarElevation = lightTheme.appBarTheme.elevation!;
        final lightCardElevation = lightTheme.cardTheme.elevation!;
        final lightFabElevation = lightTheme.floatingActionButtonTheme.elevation!;
        
        expect(lightAppBarElevation, lessThan(lightCardElevation));
        expect(lightCardElevation, lessThan(lightFabElevation));
        
        // 다크 모드는 일반적으로 더 높은 엘레베이션 사용
        final darkCardElevation = darkTheme.cardTheme.elevation!;
        expect(darkCardElevation, greaterThanOrEqualTo(lightCardElevation));
      });
    });
  });
}

/// 두 색상 간의 대비율을 계산하는 헬퍼 함수
double _calculateContrastRatio(double luminance1, double luminance2) {
  final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
  final darker = luminance1 > luminance2 ? luminance2 : luminance1;
  return (lighter + 0.05) / (darker + 0.05);
}