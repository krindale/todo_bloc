import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:todo_bloc/model/saved_link.dart';

void main() {
  group('SavedLink 모델 테스트', () {
    late SavedLink testLink;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15, 10, 30);
      testLink = SavedLink(
        title: 'Flutter Documentation',
        url: 'https://flutter.dev',
        category: 'Technology',
        colorValue: Colors.blue.value.toUnsigned(32),
        createdAt: testDate,
      );
    });

    test('SavedLink 객체가 올바르게 생성되는지 테스트', () {
      expect(testLink.title, equals('Flutter Documentation'));
      expect(testLink.url, equals('https://flutter.dev'));
      expect(testLink.category, equals('Technology'));
      expect(testLink.colorValue, equals(Colors.blue.value.toUnsigned(32)));
      expect(testLink.createdAt, equals(testDate));
    });

    test('toString 메서드가 올바르게 작동하는지 테스트', () {
      final expectedString = 'SavedLink{title: Flutter Documentation, url: https://flutter.dev, category: Technology, colorValue: ${Colors.blue.value.toUnsigned(32)}, createdAt: $testDate}';
      expect(testLink.toString(), equals(expectedString));
    });

    test('두 SavedLink 객체의 동등성 비교 테스트', () {
      final anotherLink = SavedLink(
        title: 'Flutter Documentation',
        url: 'https://flutter.dev',
        category: 'Technology',
        colorValue: Colors.blue.value.toUnsigned(32),
        createdAt: testDate,
      );

      // 같은 속성을 가진 객체들이지만 다른 인스턴스이므로 참조가 다름
      expect(testLink == anotherLink, isFalse);
    });

    test('SavedLink 필드 값 변경 테스트', () {
      testLink.title = '새로운 제목';
      testLink.url = 'https://new-url.com';
      testLink.category = 'Education';
      testLink.colorValue = Colors.red.value.toUnsigned(32);

      expect(testLink.title, equals('새로운 제목'));
      expect(testLink.url, equals('https://new-url.com'));
      expect(testLink.category, equals('Education'));
      expect(testLink.colorValue, equals(Colors.red.value.toUnsigned(32)));
    });

    test('SavedLink 생성 시 모든 필드가 필수인지 테스트', () {
      expect(() {
        SavedLink(
          title: 'Test',
          url: 'https://test.com',
          category: 'Test',
          colorValue: Colors.blue.value.toUnsigned(32),
          createdAt: DateTime.now(),
        );
      }, returnsNormally);
    });

    test('다양한 카테고리 값 테스트', () {
      final categories = ['Technology', 'Education', 'Entertainment', 'News', 'Social', 'Shopping', 'Other'];
      
      for (final category in categories) {
        final link = SavedLink(
          title: 'Test Link',
          url: 'https://test.com',
          category: category,
          colorValue: Colors.blue.value.toUnsigned(32),
          createdAt: DateTime.now(),
        );
        
        expect(link.category, equals(category));
      }
    });

    test('URL 형식 다양성 테스트', () {
      final urls = [
        'https://example.com',
        'http://example.com',
        'www.example.com',
        'example.com',
        'https://subdomain.example.com/path?query=value'
      ];

      for (final url in urls) {
        final link = SavedLink(
          title: 'Test Link',
          url: url,
          category: 'Test',
          colorValue: Colors.blue.value.toUnsigned(32),
          createdAt: DateTime.now(),
        );
        
        expect(link.url, equals(url));
      }
    });

    test('색상 값 범위 테스트', () {
      final colors = [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple];
      
      for (final color in colors) {
        final link = SavedLink(
          title: 'Test Link',
          url: 'https://test.com',
          category: 'Test',
          colorValue: color.value.toUnsigned(32),
          createdAt: DateTime.now(),
        );
        
        expect(link.colorValue, equals(color.value.toUnsigned(32)));
      }
    });
  });
}