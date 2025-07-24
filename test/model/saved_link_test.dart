import 'package:flutter_test/flutter_test.dart';
import 'package:todo_bloc/model/saved_link.dart';

void main() {
  group('SavedLink 모델 테스트', () {
    test('SavedLink 생성 테스트', () {
      // Given
      final now = DateTime.now();
      
      // When
      final link = SavedLink(
        title: 'Test Link',
        url: 'https://test.com',
        category: 'Work',
        colorValue: 0xFF6366F1,
        createdAt: now,
        firebaseDocId: 'test_link_doc_id',
      );

      // Then
      expect(link.title, 'Test Link');
      expect(link.url, 'https://test.com');
      expect(link.category, 'Work');
      expect(link.colorValue, 0xFF6366F1);
      expect(link.createdAt, now);
      expect(link.firebaseDocId, 'test_link_doc_id');
    });

    test('SavedLink 기본값 테스트', () {
      // Given & When
      final link = SavedLink(
        title: 'Simple Link',
        url: 'https://simple.com',
        category: 'Personal',
        colorValue: 0xFF8B5CF6,
        createdAt: DateTime.now(),
      );

      // Then
      expect(link.title, 'Simple Link');
      expect(link.url, 'https://simple.com');
      expect(link.category, 'Personal');
      expect(link.firebaseDocId, isNull);
    });

    test('SavedLink URL 유효성 테스트', () {
      // Given
      final validUrls = [
        'https://google.com',
        'http://example.com',
        'https://www.test.org',
        'https://subdomain.example.co.kr',
      ];

      // When & Then
      for (final url in validUrls) {
        final link = SavedLink(
          title: 'URL Test',
          url: url,
          category: 'Work',
          colorValue: 0xFF6366F1,
          createdAt: DateTime.now(),
        );
        expect(link.url, url);
        expect(link.url.startsWith('http'), true);
      }
    });

    test('SavedLink 카테고리 테스트', () {
      // Given
      final categories = ['Work', 'Personal', 'Shopping', 'Health', 'Study'];

      // When & Then
      for (final category in categories) {
        final link = SavedLink(
          title: 'Category Test',
          url: 'https://test.com',
          category: category,
          colorValue: 0xFF6366F1,
          createdAt: DateTime.now(),
        );
        expect(link.category, category);
      }
    });

    test('SavedLink 색상값 테스트', () {
      // Given
      final colorValues = [
        0xFF6366F1, // 인디고
        0xFF8B5CF6, // 보라색
        0xFFEC4899, // 핑크
        0xFF10B981, // 에메랄드
        0xFFF59E0B, // 주황색
      ];

      // When & Then
      for (final colorValue in colorValues) {
        final link = SavedLink(
          title: 'Color Test',
          url: 'https://test.com',
          category: 'Work',
          colorValue: colorValue,
          createdAt: DateTime.now(),
        );
        expect(link.colorValue, colorValue);
      }
    });

    test('SavedLink 생성 시간 테스트', () {
      // Given
      final beforeCreation = DateTime.now();
      
      // When
      final link = SavedLink(
        title: 'Time Test',
        url: 'https://test.com',
        category: 'Work',
        colorValue: 0xFF6366F1,
        createdAt: DateTime.now(),
      );
      
      final afterCreation = DateTime.now();

      // Then
      expect(link.createdAt.isAfter(beforeCreation) || 
             link.createdAt.isAtSameMomentAs(beforeCreation), true);
      expect(link.createdAt.isBefore(afterCreation) || 
             link.createdAt.isAtSameMomentAs(afterCreation), true);
    });

    test('SavedLink Firebase 문서 ID 설정 테스트', () {
      // Given
      final linkWithoutDocId = SavedLink(
        title: 'No Doc ID',
        url: 'https://test.com',
        category: 'Work',
        colorValue: 0xFF6366F1,
        createdAt: DateTime.now(),
      );

      final linkWithDocId = SavedLink(
        title: 'With Doc ID',
        url: 'https://test.com',
        category: 'Work',
        colorValue: 0xFF6366F1,
        createdAt: DateTime.now(),
        firebaseDocId: 'firebase_doc_123',
      );

      // Then
      expect(linkWithoutDocId.firebaseDocId, isNull);
      expect(linkWithDocId.firebaseDocId, 'firebase_doc_123');
    });
  });
}