import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/services/gemini_service.dart';

void main() {
  group('GeminiService', () {
    late GeminiService service;

    setUp(() {
      service = GeminiService();
    });

    test('should be singleton', () {
      final service1 = GeminiService();
      final service2 = GeminiService();
      expect(identical(service1, service2), isTrue);
    });

    test('should provide usage info', () async {
      final info = await service.getUsageInfo();
      expect(info, isA<Map<String, dynamic>>());
      expect(info['status'], equals('active'));
      expect(info['model'], equals('gemini-1.5-flash'));
    });

    test('should handle missing API key gracefully', () async {
      // API 키가 없으면 폴백 메커니즘이 작동해야 함
      final todos = await service.generateTodos('건강 관리하기');
      expect(todos, isA<List>());
      expect(todos.isNotEmpty, isTrue);
      
      // 폴백으로 생성된 할 일은 최소 2개 이상
      expect(todos.length, greaterThanOrEqualTo(2));
    });

    test('should generate meaningful fallback todos for health request', () async {
      final todos = await service.generateTodos('건강을 위한 계획');
      expect(todos, isA<List>());
      expect(todos.isNotEmpty, isTrue);
      
      // 건강 관련 키워드가 포함된 할 일이 생성되어야 함
      final healthRelated = todos.any((todo) => 
        todo.title.contains('운동') || 
        todo.title.contains('건강') ||
        todo.category == '건강'
      );
      expect(healthRelated, isTrue);
    });

    test('should generate meaningful fallback todos for study request', () async {
      final todos = await service.generateTodos('공부 계획 세우기');
      expect(todos, isA<List>());
      expect(todos.isNotEmpty, isTrue);
      
      // 학습 관련 키워드가 포함된 할 일이 생성되어야 함
      final studyRelated = todos.any((todo) => 
        todo.title.contains('공부') || 
        todo.title.contains('학습') ||
        todo.category == '학습'
      );
      expect(studyRelated, isTrue);
    });

    test('should generate general todos for unrecognized requests', () async {
      final todos = await service.generateTodos('새로운 목표 달성하기');
      expect(todos, isA<List>());
      expect(todos.isNotEmpty, isTrue);
      
      // 일반적인 할 일이 생성되어야 함
      final hasGeneralCategory = todos.any((todo) => todo.category == '일반');
      expect(hasGeneralCategory, isTrue);
    });
  });
}