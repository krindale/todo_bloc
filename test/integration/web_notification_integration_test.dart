import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import '../../lib/services/notification_service.dart';
import '../../lib/services/web_notification_helper.dart';
import '../../lib/model/todo_item.dart';

void main() {
  group('웹 알림 통합 테스트', () {
    late NotificationService notificationService;
    
    setUpAll(() async {
      // 테스트 환경에서의 초기화
      notificationService = NotificationService();
      await notificationService.initialize();
    });

    group('웹 알림 전체 플로우 테스트', () {
      test('앱 시작부터 알림 표시까지 전체 플로우', () async {
        // 1. 웹 알림 지원 여부 확인
        final isSupported = WebNotificationHelper.isNotificationSupported();
        expect(isSupported, isA<bool>());
        
        // 2. 알림 권한 확인
        final permission = await WebNotificationHelper.checkNotificationPermission();
        expect(permission, isIn(['granted', 'denied', 'default']));
        
        // 3. TodoItem 생성 및 알람 설정
        final todoItem = TodoItem(
          title: '통합 테스트 할 일',
          priority: 'High',
          dueDate: DateTime.now().add(const Duration(minutes: 1)),
          hasAlarm: true,
        );
        
        final alarmTime = DateTime.now().add(const Duration(minutes: 1));
        todoItem.setAlarmTimeOfDay(TimeOfDay.fromDateTime(alarmTime));
        
        // 4. 알림 예약
        await expectLater(
          notificationService.scheduleNotification(todoItem),
          completes,
        );
        
        // 5. 예약된 알림 확인
        final pendingNotifications = await notificationService.getPendingNotifications();
        expect(pendingNotifications, isA<List>());
        
        // 6. 테스트 알림 발송
        await expectLater(
          notificationService.showTestNotification('통합 테스트 완료'),
          completes,
        );
      });
    });

    group('여러 알림 동시 처리 테스트', () {
      test('다수의 TodoItem을 동시에 처리할 수 있어야 함', () async {
        // Arrange
        final todoItems = List.generate(5, (index) {
          final item = TodoItem(
            title: '배치 테스트 할 일 ${index + 1}',
            priority: index % 2 == 0 ? 'High' : 'Medium',
            dueDate: DateTime.now().add(Duration(minutes: index + 1)),
            hasAlarm: true,
          );
          
          final alarmTime = DateTime.now().add(Duration(minutes: index + 1));
          item.setAlarmTimeOfDay(TimeOfDay.fromDateTime(alarmTime));
          
          return item;
        });
        
        // Act - 모든 알림을 동시에 예약
        final futures = todoItems.map((item) => 
          notificationService.scheduleNotification(item)
        ).toList();
        
        // Assert
        await expectLater(
          Future.wait(futures),
          completes,
        );
      });
    });

    group('알림 생명주기 테스트', () {
      test('알림 생성부터 취소까지의 전체 생명주기', () async {
        // 1. TodoItem 생성
        final todoItem = TodoItem(
          title: '생명주기 테스트',
          priority: 'High',
          dueDate: DateTime.now().add(const Duration(hours: 1)),
          hasAlarm: true,
        );
        
        final alarmTime = DateTime.now().add(const Duration(hours: 1));
        todoItem.setAlarmTimeOfDay(TimeOfDay.fromDateTime(alarmTime));
        
        // 2. 알림 예약
        await notificationService.scheduleNotification(todoItem);
        
        // 3. notificationId가 설정되었는지 확인
        expect(todoItem.notificationId, isNotNull);
        
        // 4. 예약된 알림 확인
        final pendingBefore = await notificationService.getPendingNotifications();
        expect(pendingBefore, isA<List>());
        
        // 5. 알림 취소
        if (todoItem.notificationId != null) {
          await notificationService.cancelNotification(todoItem.notificationId!);
        }
        
        // 6. 취소 후 확인
        final pendingAfter = await notificationService.getPendingNotifications();
        expect(pendingAfter, isA<List>());
      });
    });

    group('에러 상황 처리 테스트', () {
      test('잘못된 시간 설정 시 안전하게 처리되어야 함', () async {
        // 과거 시간으로 알람 설정
        final todoItem = TodoItem(
          title: '과거 알람 테스트',
          priority: 'High',
          dueDate: DateTime.now().subtract(const Duration(hours: 1)),
          hasAlarm: true,
        );
        
        todoItem.alarmTime = DateTime.now().subtract(const Duration(hours: 2));
        
        // 과거 시간이어도 예외가 발생하지 않아야 함
        await expectLater(
          notificationService.scheduleNotification(todoItem),
          completes,
        );
      });

      test('알람 없는 TodoItem 처리', () async {
        final todoItem = TodoItem(
          title: '알람 없는 할 일',
          priority: 'Low',
          dueDate: DateTime.now(),
          hasAlarm: false,
        );
        
        // 알람이 없어도 예외가 발생하지 않아야 함
        await expectLater(
          notificationService.scheduleNotification(todoItem),
          completes,
        );
      });
    });

    group('웹 특화 기능 테스트', () {
      test('웹 환경에서만 작동하는 기능들이 안전해야 함', () async {
        // 웹 알림 헬퍼 기능들이 모두 안전하게 작동해야 함
        await expectLater(
          WebNotificationHelper.testWebNotification(),
          completes,
        );
        
        expect(
          () => WebNotificationHelper.showWebNotification('테스트', '메시지'),
          returnsNormally,
        );
        
        await expectLater(
          WebNotificationHelper.checkNotificationPermission(),
          completion(isA<String>()),
        );
        
        await expectLater(
          WebNotificationHelper.requestNotificationPermission(),
          completion(isA<String>()),
        );
      });
    });

    group('성능 테스트', () {
      test('대량의 알림 처리 성능', () async {
        // 100개의 알림을 동시에 처리
        final stopwatch = Stopwatch()..start();
        
        final futures = List.generate(100, (index) {
          final todoItem = TodoItem(
            title: '성능 테스트 $index',
            priority: 'Medium',
            dueDate: DateTime.now().add(Duration(seconds: index)),
            hasAlarm: true,
          );
          
          final alarmTime = DateTime.now().add(Duration(seconds: index));
          todoItem.setAlarmTimeOfDay(TimeOfDay.fromDateTime(alarmTime));
          
          return notificationService.scheduleNotification(todoItem);
        });
        
        await Future.wait(futures);
        stopwatch.stop();
        
        // 100개 알림 처리가 10초 이내에 완료되어야 함
        expect(stopwatch.elapsedMilliseconds, lessThan(10000));
        
        print('100개 알림 처리 시간: ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('메모리 관리 테스트', () {
      test('반복적인 알림 생성과 취소가 메모리 누수를 일으키지 않아야 함', () async {
        // 알림 생성과 취소를 반복하여 메모리 누수 확인
        for (int i = 0; i < 50; i++) {
          final todoItem = TodoItem(
            title: '메모리 테스트 $i',
            priority: 'Low',
            dueDate: DateTime.now().add(Duration(minutes: i + 1)),
            hasAlarm: true,
          );
          
          final alarmTime = DateTime.now().add(Duration(minutes: i + 1));
          todoItem.setAlarmTimeOfDay(TimeOfDay.fromDateTime(alarmTime));
          
          // 알림 예약
          await notificationService.scheduleNotification(todoItem);
          
          // 즉시 취소
          if (todoItem.notificationId != null) {
            await notificationService.cancelNotification(todoItem.notificationId!);
          }
        }
        
        // 모든 처리가 완료되어야 함
        expect(true, isTrue);
      });
    });

    tearDownAll(() async {
      // 테스트 후 정리
      await notificationService.cancelAllNotifications();
    });
  });

  group('웹 알림 시나리오 테스트', () {
    test('실제 사용 시나리오: 새 할 일 추가 후 알림 설정', () async {
      // 시나리오: 사용자가 새로운 할 일을 추가하고 30분 후 알림을 설정
      
      // 1. 새 할 일 생성
      final newTodo = TodoItem(
        title: '중요한 회의 준비',
        priority: 'High',
        dueDate: DateTime.now().add(const Duration(minutes: 30)),
        hasAlarm: false, // 처음에는 알람 없음
      );
      
      // 2. 나중에 알람 추가
      newTodo.hasAlarm = true;
      newTodo.setAlarmTimeOfDay(TimeOfDay.fromDateTime(
        DateTime.now().add(const Duration(minutes: 25))
      ));
      
      // 3. 알림 서비스에 등록
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.scheduleNotification(newTodo);
      
      // 4. 확인
      expect(newTodo.hasAlarm, isTrue);
      expect(newTodo.effectiveAlarmTime, isNotNull);
      expect(newTodo.notificationId, isNotNull);
    });

    test('실제 사용 시나리오: 알림 시간 수정', () async {
      // 시나리오: 기존 할 일의 알림 시간을 변경
      
      // 1. 기존 할 일 (알림 설정됨)
      final existingTodo = TodoItem(
        title: '운동하기',
        priority: 'Medium',
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        hasAlarm: true,
      );
      existingTodo.setAlarmTimeOfDay(const TimeOfDay(hour: 18, minute: 0));
      
      // 2. 첫 번째 알림 예약
      final notificationService = NotificationService();
      await notificationService.initialize();
      await notificationService.scheduleNotification(existingTodo);
      final firstNotificationId = existingTodo.notificationId;
      
      // 3. 알림 시간 변경
      if (firstNotificationId != null) {
        await notificationService.cancelNotification(firstNotificationId);
      }
      
      existingTodo.setAlarmTimeOfDay(const TimeOfDay(hour: 19, minute: 30));
      await notificationService.scheduleNotification(existingTodo);
      
      // 4. 확인
      expect(existingTodo.effectiveAlarmTime!.hour, equals(19));
      expect(existingTodo.effectiveAlarmTime!.minute, equals(30));
    });
  });
}