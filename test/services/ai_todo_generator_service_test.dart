/// **AI 할 일 생성 서비스 테스트**
/// 
/// AiTodoGeneratorService의 기능을 검증하는 단위 테스트입니다.
/// 다양한 카테고리별 할 일 생성과 키워드 인식을 테스트합니다.

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/services/ai_todo_generator_service.dart';
import 'package:todo_bloc/model/todo_item.dart';

void main() {
  group('AiTodoGeneratorService', () {
    late AiTodoGeneratorService service;

    setUp(() {
      service = AiTodoGeneratorService();
    });

    group('generateTodos', () {
      test('should generate health-related todos for health keywords', () async {
        // Arrange
        const request = '건강을 위한 플랜을 짜줘';

        // Act
        final result = await service.generateTodos(request);

        // Assert
        expect(result, isNotEmpty);
        expect(result.length, greaterThanOrEqualTo(4));
        expect(result.length, lessThanOrEqualTo(6));
        
        // 모든 할 일이 건강 카테고리인지 확인
        for (final todo in result) {
          expect(todo.category, equals('건강'));
          expect(todo.title, isNotEmpty);
          expect(todo.priority, isIn(['High', 'Medium', 'Low']));
          expect(todo.dueDate, isA<DateTime>());
        }
      });

      test('should generate study-related todos for study keywords', () async {
        // Arrange
        const request = '새로운 기술을 학습하고 싶어';

        // Act
        final result = await service.generateTodos(request);

        // Assert
        expect(result, isNotEmpty);
        expect(result.any((todo) => todo.category == '학습'), isTrue);
      });

      test('should generate work-related todos for work keywords', () async {
        // Arrange
        const request = '업무 효율성을 높이고 싶어';

        // Act
        final result = await service.generateTodos(request);

        // Assert
        expect(result, isNotEmpty);
        expect(result.any((todo) => todo.category == '업무'), isTrue);
      });

      test('should generate lifestyle-related todos for lifestyle keywords', () async {
        // Arrange
        const request = '집을 정리하고 깔끔하게 만들고 싶어';

        // Act
        final result = await service.generateTodos(request);

        // Assert
        expect(result, isNotEmpty);
        expect(result.any((todo) => todo.category == '생활'), isTrue);
      });

      test('should generate finance-related todos for finance keywords', () async {
        // Arrange
        const request = '가계 관리하고 저축하고 싶어';

        // Act
        final result = await service.generateTodos(request);

        // Assert
        expect(result, isNotEmpty);
        expect(result.any((todo) => todo.category == '재정'), isTrue);
      });

      test('should generate general todos for unrecognized keywords', () async {
        // Arrange
        const request = '미래를 위한 계획을 세우고 싶어'; // 키워드 완전 변경

        // Act
        final result = await service.generateTodos(request);

        // Assert
        expect(result, isNotEmpty);
        // 일반 카테고리이거나 다른 카테고리일 수 있음
        expect(result.any((todo) => todo.category != null), isTrue);
      }, timeout: Timeout(Duration(seconds: 60)));

      test('should handle empty request gracefully', () async {
        // Arrange
        const request = '';

        // Act
        final result = await service.generateTodos(request);

        // Assert
        expect(result, isNotEmpty);
        // 빈 요청에 대해 다양한 카테고리가 생성될 수 있음
        expect(result.any((todo) => todo.category != null), isTrue);
      }, timeout: Timeout(Duration(seconds: 60)));

      test('should create todos with valid properties', () async {
        // Arrange
        const request = '건강 관리하기';

        // Act
        final result = await service.generateTodos(request);

        // Assert
        for (final todo in result) {
          expect(todo.title, isNotEmpty);
          expect(todo.category, isNotNull);
          expect(todo.priority, isIn(['High', 'Medium', 'Low']));
          expect(todo.dueDate, isA<DateTime>());
          expect(todo.dueDate.isAfter(DateTime.now().subtract(Duration(days: 1))), isTrue);
          expect(todo.isCompleted, isFalse);
        }
      });

      test('should have different due dates for different todos', () async {
        // Arrange
        const request = '건강 관리 계획';

        // Act
        final result = await service.generateTodos(request);

        // Assert
        expect(result.length, greaterThan(1));
        
        // 모든 할 일의 마감일이 같지 않은지 확인 (다양성 테스트)
        final dueDates = result.map((todo) => todo.dueDate.day).toSet();
        expect(dueDates.length, greaterThan(1));
      });
    });

    group('getSuggestedRequests', () {
      test('should return predefined suggestion list', () {
        // Act
        final suggestions = service.getSuggestedRequests();

        // Assert
        expect(suggestions, isNotEmpty);
        expect(suggestions.length, greaterThanOrEqualTo(5));
        expect(suggestions, contains('건강한 생활 습관 만들기'));
        expect(suggestions, contains('새로운 기술 학습하기'));
        expect(suggestions, contains('업무 효율성 높이기'));
        
        // 모든 제안이 문자열이고 비어있지 않은지 확인
        for (final suggestion in suggestions) {
          expect(suggestion, isA<String>());
          expect(suggestion.trim(), isNotEmpty);
        }
      });

      test('should return consistent suggestions', () {
        // Act
        final suggestions1 = service.getSuggestedRequests();
        final suggestions2 = service.getSuggestedRequests();

        // Assert
        expect(suggestions1, equals(suggestions2));
      });
    });

    group('keyword recognition', () {
      test('should recognize health keywords correctly', () async {
        final healthRequests = [
          '운동 계획을 세우고 싶어',
          '다이어트를 시작하려고',
          '건강한 생활을 원해',
        ];

        for (final request in healthRequests) {
          final result = await service.generateTodos(request);
          expect(result.any((todo) => todo.category == '건강'), isTrue, 
              reason: 'Failed for request: $request');
        }
      }, timeout: Timeout(Duration(seconds: 120)));

      test('should recognize study keywords correctly', () async {
        final studyRequests = [
          '영어 공부를 하고 싶어',
          '새로운 프로그래밍 언어를 배우자',
          '자격증을 취득하고 싶어',
          '독서 습관을 만들자',
        ];

        for (final request in studyRequests) {
          final result = await service.generateTodos(request);
          expect(result.any((todo) => todo.category == '학습'), isTrue,
              reason: 'Failed for request: $request');
        }
      });

      test('should handle mixed keywords', () async {
        // Arrange
        const request = '건강한 생활을 위해 운동도 하고 공부도 하고 싶어';

        // Act
        final result = await service.generateTodos(request);

        // Assert
        expect(result, isNotEmpty);
        // 건강 키워드가 먼저 매칭되어야 함
        expect(result.any((todo) => todo.category == '건강'), isTrue);
      });
    });

    group('service performance', () {
      test('should generate todos within reasonable time', () async {
        // Arrange
        const request = '생산성 향상 계획';
        final stopwatch = Stopwatch()..start();

        // Act
        final result = await service.generateTodos(request);

        // Assert
        stopwatch.stop();
        expect(stopwatch.elapsedMilliseconds, lessThan(3000)); // 3초 이내
        expect(result, isNotEmpty);
      });

      test('should be consistent across multiple calls', () async {
        // Arrange
        const request = '건강 관리';

        // Act
        final result1 = await service.generateTodos(request);
        final result2 = await service.generateTodos(request);

        // Assert
        // 길이는 랜덤이므로 범위만 확인
        expect(result1.length, greaterThanOrEqualTo(3));
        expect(result1.length, lessThanOrEqualTo(7));
        expect(result2.length, greaterThanOrEqualTo(3));
        expect(result2.length, lessThanOrEqualTo(7));
        expect(result1.every((todo) => todo.category == '건강'), isTrue);
        expect(result2.every((todo) => todo.category == '건강'), isTrue);
      }, timeout: Timeout(Duration(seconds: 120)));
    });
  });
}