/// **앱 상수 테스트**
///
/// 앱에서 사용되는 상수들이 올바르게 정의되어 있는지 검증합니다.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../../../lib/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    group('AnimationConstants', () {
      test('should have positive durations', () {
        expect(AnimationConstants.fadeAnimation.inMilliseconds, greaterThan(0));
        expect(AnimationConstants.slideAnimation.inMilliseconds, greaterThan(0));
        expect(AnimationConstants.recommendationAnimation.inMilliseconds, greaterThan(0));
        expect(AnimationConstants.headerAnimation.inMilliseconds, greaterThan(0));
        expect(AnimationConstants.todoItemAnimation.inMilliseconds, greaterThan(0));
        expect(AnimationConstants.rippleAnimation.inMilliseconds, greaterThan(0));
      });
      
      test('should have reasonable animation durations', () {
        // 애니메이션 지속시간이 합리적인 범위 내에 있는지 확인
        expect(AnimationConstants.fadeAnimation.inMilliseconds, lessThan(2000));
        expect(AnimationConstants.slideAnimation.inMilliseconds, lessThan(1000));
        expect(AnimationConstants.rippleAnimation.inMilliseconds, lessThan(500));
      });
    });

    group('LayoutConstants', () {
      test('should have positive dimensions', () {
        expect(LayoutConstants.defaultPadding, greaterThan(0));
        expect(LayoutConstants.smallPadding, greaterThan(0));
        expect(LayoutConstants.largePadding, greaterThan(0));
        expect(LayoutConstants.cardPadding, greaterThan(0));
        
        expect(LayoutConstants.defaultBorderRadius, greaterThan(0));
        expect(LayoutConstants.smallBorderRadius, greaterThan(0));
        expect(LayoutConstants.largeBorderRadius, greaterThan(0));
        expect(LayoutConstants.chipBorderRadius, greaterThan(0));
      });
      
      test('should have logical size relationships', () {
        // 크기 관계가 논리적인지 확인
        expect(LayoutConstants.smallPadding, lessThan(LayoutConstants.defaultPadding));
        expect(LayoutConstants.defaultPadding, lessThan(LayoutConstants.largePadding));
        
        expect(LayoutConstants.smallBorderRadius, lessThan(LayoutConstants.defaultBorderRadius));
        expect(LayoutConstants.defaultBorderRadius, lessThan(LayoutConstants.largeBorderRadius));
      });
      
      test('should have positive breakpoints', () {
        expect(LayoutConstants.mobileBreakpoint, greaterThan(0));
        expect(LayoutConstants.tabletBreakpoint, greaterThan(LayoutConstants.mobileBreakpoint));
        expect(LayoutConstants.desktopBreakpoint, greaterThan(LayoutConstants.tabletBreakpoint));
      });
    });

    group('TextConstants', () {
      test('should have positive font sizes', () {
        expect(TextConstants.headlineLarge, greaterThan(0));
        expect(TextConstants.headlineMedium, greaterThan(0));
        expect(TextConstants.headlineSmall, greaterThan(0));
        expect(TextConstants.titleLarge, greaterThan(0));
        expect(TextConstants.titleMedium, greaterThan(0));
        expect(TextConstants.titleSmall, greaterThan(0));
        expect(TextConstants.bodyLarge, greaterThan(0));
        expect(TextConstants.bodyMedium, greaterThan(0));
        expect(TextConstants.bodySmall, greaterThan(0));
        expect(TextConstants.labelLarge, greaterThan(0));
        expect(TextConstants.labelMedium, greaterThan(0));
        expect(TextConstants.labelSmall, greaterThan(0));
      });
      
      test('should have logical font size hierarchy', () {
        // 헤드라인 크기 관계
        expect(TextConstants.headlineSmall, lessThan(TextConstants.headlineMedium));
        expect(TextConstants.headlineMedium, lessThan(TextConstants.headlineLarge));
        
        // 타이틀 크기 관계
        expect(TextConstants.titleSmall, lessThan(TextConstants.titleMedium));
        expect(TextConstants.titleMedium, lessThan(TextConstants.titleLarge));
        
        // 바디 크기 관계
        expect(TextConstants.bodySmall, lessThan(TextConstants.bodyMedium));
        expect(TextConstants.bodyMedium, lessThan(TextConstants.bodyLarge));
      });
      
      test('should have positive line heights', () {
        expect(TextConstants.defaultLineHeight, greaterThan(1.0));
        expect(TextConstants.compactLineHeight, greaterThan(1.0));
        expect(TextConstants.relaxedLineHeight, greaterThan(1.0));
      });
      
      test('should have positive max lines', () {
        expect(TextConstants.todoTitleMaxLines, greaterThan(0));
        expect(TextConstants.descriptionMaxLines, greaterThan(0));
        expect(TextConstants.singleLine, equals(1));
      });
    });

    group('PriorityConstants', () {
      test('should contain all priority levels', () {
        expect(PriorityConstants.allPriorities, contains(PriorityConstants.high));
        expect(PriorityConstants.allPriorities, contains(PriorityConstants.medium));
        expect(PriorityConstants.allPriorities, contains(PriorityConstants.low));
      });
      
      test('should have colors for all priorities', () {
        for (final priority in PriorityConstants.allPriorities) {
          expect(PriorityConstants.priorityColors.containsKey(priority), isTrue);
          expect(PriorityConstants.priorityColors[priority], isA<Color>());
        }
      });
      
      test('should have icons for all priorities', () {
        for (final priority in PriorityConstants.allPriorities) {
          expect(PriorityConstants.priorityIcons.containsKey(priority), isTrue);
          expect(PriorityConstants.priorityIcons[priority], isA<IconData>());
        }
      });
    });

    group('CategoryConstants', () {
      test('should contain general category', () {
        expect(CategoryConstants.defaultCategories, contains(CategoryConstants.general));
      });
      
      test('should have colors for all categories', () {
        for (final category in CategoryConstants.defaultCategories) {
          expect(CategoryConstants.categoryColors.containsKey(category), isTrue);
          expect(CategoryConstants.categoryColors[category], isA<Color>());
        }
      });
      
      test('should have icons for all categories', () {
        for (final category in CategoryConstants.defaultCategories) {
          expect(CategoryConstants.categoryIcons.containsKey(category), isTrue);
          expect(CategoryConstants.categoryIcons[category], isA<IconData>());
        }
      });
    });

    group('DatabaseConstants', () {
      test('should have non-negative type IDs', () {
        expect(DatabaseConstants.todoItemTypeId, greaterThanOrEqualTo(0));
        expect(DatabaseConstants.savedLinkTypeId, greaterThanOrEqualTo(0));
      });
      
      test('should have non-empty box names', () {
        expect(DatabaseConstants.todoBoxName, isNotEmpty);
        expect(DatabaseConstants.settingsBoxName, isNotEmpty);
        expect(DatabaseConstants.cacheBoxName, isNotEmpty);
      });
      
      test('should have non-empty collection names', () {
        expect(DatabaseConstants.todosCollection, isNotEmpty);
        expect(DatabaseConstants.usersCollection, isNotEmpty);
        expect(DatabaseConstants.settingsCollection, isNotEmpty);
      });
    });

    group('NetworkConstants', () {
      test('should have positive timeouts', () {
        expect(NetworkConstants.defaultTimeout.inMilliseconds, greaterThan(0));
        expect(NetworkConstants.uploadTimeout.inMilliseconds, greaterThan(0));
        expect(NetworkConstants.downloadTimeout.inMilliseconds, greaterThan(0));
      });
      
      test('should have positive retry settings', () {
        expect(NetworkConstants.maxRetries, greaterThan(0));
        expect(NetworkConstants.retryDelay.inMilliseconds, greaterThan(0));
      });
      
      test('should have valid HTTP status codes', () {
        expect(NetworkConstants.httpOk, equals(200));
        expect(NetworkConstants.httpCreated, equals(201));
        expect(NetworkConstants.httpBadRequest, equals(400));
        expect(NetworkConstants.httpUnauthorized, equals(401));
        expect(NetworkConstants.httpForbidden, equals(403));
        expect(NetworkConstants.httpNotFound, equals(404));
        expect(NetworkConstants.httpTooManyRequests, equals(429));
        expect(NetworkConstants.httpInternalServerError, equals(500));
      });
    });

    group('AppStrings', () {
      test('should have non-empty app info', () {
        expect(AppStrings.appName, isNotEmpty);
        expect(AppStrings.appVersion, isNotEmpty);
      });
      
      test('should have non-empty tab titles', () {
        expect(AppStrings.tasksTab, isNotEmpty);
        expect(AppStrings.aiGeneratorTab, isNotEmpty);
        expect(AppStrings.summaryTab, isNotEmpty);
        expect(AppStrings.linksTab, isNotEmpty);
      });
      
      test('should have non-empty common actions', () {
        expect(AppStrings.save, isNotEmpty);
        expect(AppStrings.cancel, isNotEmpty);
        expect(AppStrings.delete, isNotEmpty);
        expect(AppStrings.edit, isNotEmpty);
        expect(AppStrings.add, isNotEmpty);
        expect(AppStrings.retry, isNotEmpty);
        expect(AppStrings.logout, isNotEmpty);
      });
      
      test('should have non-empty error messages', () {
        expect(AppStrings.genericError, isNotEmpty);
        expect(AppStrings.networkError, isNotEmpty);
        expect(AppStrings.loginError, isNotEmpty);
        expect(AppStrings.logoutError, isNotEmpty);
        expect(AppStrings.saveError, isNotEmpty);
        expect(AppStrings.loadError, isNotEmpty);
      });
    });

    group('ValidationConstants', () {
      test('should have positive length limits', () {
        expect(ValidationConstants.todoTitleMinLength, greaterThan(0));
        expect(ValidationConstants.todoTitleMaxLength, greaterThan(ValidationConstants.todoTitleMinLength));
        expect(ValidationConstants.descriptionMaxLength, greaterThan(0));
        expect(ValidationConstants.categoryMaxLength, greaterThan(0));
      });
      
      test('should have valid regex patterns', () {
        expect(ValidationConstants.emailPattern, isNotEmpty);
        expect(ValidationConstants.urlPattern, isNotEmpty);
        
        // 이메일 패턴 테스트
        final emailRegex = RegExp(ValidationConstants.emailPattern);
        expect(emailRegex.hasMatch('test@example.com'), isTrue);
        expect(emailRegex.hasMatch('invalid-email'), isFalse);
        
        // URL 패턴 테스트
        final urlRegex = RegExp(ValidationConstants.urlPattern);
        expect(urlRegex.hasMatch('https://example.com'), isTrue);
        expect(urlRegex.hasMatch('http://example.com'), isTrue);
        expect(urlRegex.hasMatch('invalid-url'), isFalse);
      });
      
      test('should have non-empty validation messages', () {
        expect(ValidationConstants.requiredField, isNotEmpty);
        expect(ValidationConstants.tooShort, isNotEmpty);
        expect(ValidationConstants.tooLong, isNotEmpty);
        expect(ValidationConstants.invalidEmail, isNotEmpty);
        expect(ValidationConstants.invalidUrl, isNotEmpty);
      });
    });
  });
}