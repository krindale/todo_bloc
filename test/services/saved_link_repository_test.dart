import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_bloc/model/saved_link.dart';
import 'package:todo_bloc/services/saved_link_repository.dart';

void main() {
  group('SavedLinkRepository 테스트', () {
    late SavedLinkRepository repository;
    late Box<SavedLink> testBox;

    setUpAll(() async {
      // 테스트용 Hive 초기화
      await Hive.initFlutter();
      Hive.registerAdapter(SavedLinkAdapter());
    });

    setUp(() async {
      // 각 테스트마다 새로운 저장소와 박스 생성
      repository = SavedLinkRepository();
      await repository.init();
    });

    tearDown(() async {
      // 테스트 후 데이터 정리
      await repository.clear();
    });

    tearDownAll(() async {
      // 모든 테스트 완료 후 Hive 정리
      await Hive.deleteFromDisk();
    });

    test('저장소 초기화 테스트', () async {
      final newRepository = SavedLinkRepository();
      await newRepository.init();
      
      expect(newRepository.length, equals(0));
    });

    test('링크 추가 테스트', () async {
      final testLink = SavedLink(
        title: 'Flutter Documentation',
        url: 'https://flutter.dev',
        category: 'Technology',
        colorValue: Colors.blue.value.toUnsigned(32),
        createdAt: DateTime.now(),
      );

      await repository.addLink(testLink);
      
      expect(repository.length, equals(1));
      
      final links = repository.getAllLinks();
      expect(links.length, equals(1));
      expect(links.first.title, equals('Flutter Documentation'));
      expect(links.first.url, equals('https://flutter.dev'));
    });

    test('여러 링크 추가 및 최신순 정렬 테스트', () async {
      final now = DateTime.now();
      final link1 = SavedLink(
        title: 'First Link',
        url: 'https://first.com',
        category: 'Technology',
        colorValue: Colors.blue.value.toUnsigned(32),
        createdAt: now,
      );

      final link2 = SavedLink(
        title: 'Second Link',
        url: 'https://second.com', 
        category: 'Education',
        colorValue: Colors.green.value.toUnsigned(32),
        createdAt: now.add(const Duration(minutes: 1)),
      );

      final link3 = SavedLink(
        title: 'Third Link',
        url: 'https://third.com',
        category: 'Entertainment',
        colorValue: Colors.red.value.toUnsigned(32),
        createdAt: now.add(const Duration(minutes: 2)),
      );

      await repository.addLink(link1);
      await repository.addLink(link2);
      await repository.addLink(link3);

      final links = repository.getAllLinks();
      expect(links.length, equals(3));
      
      // 최신순으로 정렬되어 있는지 확인
      expect(links[0].title, equals('Third Link'));
      expect(links[1].title, equals('Second Link'));
      expect(links[2].title, equals('First Link'));
    });

    test('링크 삭제 테스트', () async {
      final testLink = SavedLink(
        title: 'Test Link',
        url: 'https://test.com',
        category: 'Test',
        colorValue: Colors.blue.value.toUnsigned(32),
        createdAt: DateTime.now(),
      );

      await repository.addLink(testLink);
      expect(repository.length, equals(1));

      await repository.deleteLink(testLink);
      expect(repository.length, equals(0));
      
      final links = repository.getAllLinks();
      expect(links.isEmpty, isTrue);
    });

    test('특정 인덱스의 링크 가져오기 테스트', () async {
      final testLink = SavedLink(
        title: 'Test Link',
        url: 'https://test.com',
        category: 'Test',
        colorValue: Colors.blue.value.toUnsigned(32),
        createdAt: DateTime.now(),
      );

      await repository.addLink(testLink);
      
      final retrievedLink = repository.getAt(0);
      expect(retrievedLink, isNotNull);
      expect(retrievedLink!.title, equals('Test Link'));
    });

    test('존재하지 않는 인덱스 접근 테스트', () {
      final retrievedLink = repository.getAt(999);
      expect(retrievedLink, isNull);
    });

    test('모든 링크 삭제 테스트', () async {
      final link1 = SavedLink(
        title: 'Link 1',
        url: 'https://link1.com',
        category: 'Test',
        colorValue: Colors.blue.value.toUnsigned(32),
        createdAt: DateTime.now(),
      );

      final link2 = SavedLink(
        title: 'Link 2',
        url: 'https://link2.com',
        category: 'Test',
        colorValue: Colors.red.value.toUnsigned(32),
        createdAt: DateTime.now(),
      );

      await repository.addLink(link1);
      await repository.addLink(link2);
      expect(repository.length, equals(2));

      await repository.clear();
      expect(repository.length, equals(0));
      expect(repository.getAllLinks().isEmpty, isTrue);
    });

    test('링크 업데이트 테스트', () async {
      final originalLink = SavedLink(
        title: 'Original Title',
        url: 'https://original.com',
        category: 'Technology',
        colorValue: Colors.blue.value.toUnsigned(32),
        createdAt: DateTime.now(),
      );

      await repository.addLink(originalLink);
      
      final updatedLink = SavedLink(
        title: 'Updated Title',
        url: 'https://updated.com',
        category: 'Education',
        colorValue: Colors.green.value.toUnsigned(32),
        createdAt: DateTime.now(),
      );

      await repository.updateLink(0, updatedLink);
      
      final retrievedLink = repository.getAt(0);
      expect(retrievedLink!.title, equals('Updated Title'));
      expect(retrievedLink.url, equals('https://updated.com'));
      expect(retrievedLink.category, equals('Education'));
    });

    test('초기화되지 않은 저장소 접근 예외 테스트', () {
      final uninitializedRepository = SavedLinkRepository();
      
      expect(() => uninitializedRepository.getAllLinks(), 
             throwsA(isA<Exception>()));
      expect(() => uninitializedRepository.length, 
             throwsA(isA<Exception>()));
    });

    test('대량 데이터 처리 성능 테스트', () async {
      const int linkCount = 100;
      final links = <SavedLink>[];

      // 100개의 링크 생성
      for (int i = 0; i < linkCount; i++) {
        links.add(SavedLink(
          title: 'Link $i',
          url: 'https://link$i.com',
          category: 'Test',
          colorValue: Colors.blue.value.toUnsigned(32),
          createdAt: DateTime.now().add(Duration(seconds: i)),
        ));
      }

      // 모든 링크 추가
      for (final link in links) {
        await repository.addLink(link);
      }

      expect(repository.length, equals(linkCount));
      
      final retrievedLinks = repository.getAllLinks();
      expect(retrievedLinks.length, equals(linkCount));
      
      // 최신순 정렬 확인 (마지막에 추가된 것이 첫 번째)
      expect(retrievedLinks.first.title, equals('Link ${linkCount - 1}'));
      expect(retrievedLinks.last.title, equals('Link 0'));
    });
  });
}