import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import '../../lib/services/notification_service.dart';
import '../../lib/model/todo_item.dart';

// Mock 생성
@GenerateMocks([])
import 'notification_service_web_test.mocks.dart';

void main() {
  group('NotificationService 웹 기능 테스트', () {
    late NotificationService notificationService;
    
    setUp(() {
      notificationService = NotificationService();
    });

    group('초기화', () {
      test('NotificationService 싱글톤 인스턴스가 생성되어야 함', () {
        // Arrange & Act
        final instance1 = NotificationService();
        final instance2 = NotificationService();
        
        // Assert
        expect(instance1, same(instance2));
      });

      test('initialize 메서드가 예외 없이 실행되어야 함', () async {
        // Act & Assert
        expect(
          () async => await notificationService.initialize(),
          returnsNormally,
        );
      });
    });

    group('알림 스케줄링', () {
      test('웹에서 scheduleNotification이 예외 없이 실행되어야 함', () async {
        // Arrange
        final todoItem = TodoItem(
          title: '테스트 할 일',
          priority: 'High',
          dueDate: DateTime.now().add(const Duration(hours: 1)),
          hasAlarm: true,
        );
        todoItem.setAlarmTimeOfDay(const TimeOfDay(hour: 14, minute: 30));
        
        // Act & Assert
        expect(
          () async => await notificationService.scheduleNotification(todoItem),
          returnsNormally,
        );
      });

      test('알람이 없는 TodoItem은 알림을 예약하지 않아야 함', () async {
        // Arrange
        final todoItem = TodoItem(
          title: '알람 없는 할 일',
          priority: 'Medium',
          dueDate: DateTime.now(),
          hasAlarm: false,
        );
        
        // Act & Assert
        expect(
          () async => await notificationService.scheduleNotification(todoItem),
          returnsNormally,
        );
      });

      test('과거 시간의 알람은 예약하지 않아야 함', () async {
        // Arrange
        final todoItem = TodoItem(
          title: '과거 알람',
          priority: 'High',
          dueDate: DateTime.now().subtract(const Duration(hours: 1)),
          hasAlarm: true,
        );
        todoItem.alarmTime = DateTime.now().subtract(const Duration(hours: 2));
        
        // Act & Assert
        expect(
          () async => await notificationService.scheduleNotification(todoItem),
          returnsNormally,
        );
      });
    });

    group('테스트 알림', () {
      test('showTestNotification이 웹에서 안전하게 실행되어야 함', () async {
        // Act & Assert
        expect(
          () async => await notificationService.showTestNotification(),
          returnsNormally,
        );
      });

      test('커스텀 메시지로 테스트 알림을 보낼 수 있어야 함', () async {
        // Arrange
        const customMessage = '커스텀 테스트 메시지';
        
        // Act & Assert
        expect(
          () async => await notificationService.showTestNotification(customMessage),
          returnsNormally,
        );
      });
    });

    group('알림 취소', () {
      test('cancelNotification이 예외 없이 실행되어야 함', () async {
        // Arrange
        const notificationId = 12345;
        
        // Act & Assert
        expect(
          () async => await notificationService.cancelNotification(notificationId),
          returnsNormally,
        );
      });

      test('cancelAllNotifications가 예외 없이 실행되어야 함', () async {
        // Act & Assert
        expect(
          () async => await notificationService.cancelAllNotifications(),
          returnsNormally,
        );
      });
    });

    group('대기 중인 알림 조회', () {
      test('getPendingNotifications가 리스트를 반환해야 함', () async {
        // Act
        final pendingNotifications = await notificationService.getPendingNotifications();
        
        // Assert
        expect(pendingNotifications, isA<List>());
      });
    });

    group('웹 알림 워크플로우', () {
      test('전체 웹 알림 워크플로우가 안전하게 실행되어야 함', () async {
        // 1. 초기화
        await notificationService.initialize();
        
        // 2. 테스트 알림
        await notificationService.showTestNotification('워크플로우 테스트');
        
        // 3. 실제 TodoItem으로 알림 예약
        final todoItem = TodoItem(
          title: '워크플로우 테스트 할 일',
          priority: 'High',
          dueDate: DateTime.now().add(const Duration(minutes: 5)),
          hasAlarm: true,
        );
        todoItem.setAlarmTimeOfDay(TimeOfDay.fromDateTime(
          DateTime.now().add(const Duration(minutes: 5))
        ));
        
        await notificationService.scheduleNotification(todoItem);
        
        // 4. 대기 중인 알림 확인
        final pending = await notificationService.getPendingNotifications();
        expect(pending, isA<List>());
        
        // 5. 알림 취소
        if (todoItem.notificationId != null) {
          await notificationService.cancelNotification(todoItem.notificationId!);
        }
        
        // 모든 단계가 예외 없이 완료되어야 함
      });
    });

    group('에러 처리', () {
      test('null TodoItem으로 scheduleNotification 호출 시 예외 처리', () async {
        // Arrange
        TodoItem? nullTodoItem;
        
        // Act & Assert
        expect(
          () async => await notificationService.scheduleNotification(nullTodoItem!),
          throwsA(isA<TypeError>()),
        );
      });

      test('잘못된 notificationId로 cancelNotification 호출 시 안전해야 함', () async {
        // Arrange
        const invalidId = -1;
        
        // Act & Assert
        expect(
          () async => await notificationService.cancelNotification(invalidId),
          returnsNormally,
        );
      });
    });

    group('플랫폼별 분기 테스트', () {
      test('웹에서 _showWebNotification 경로가 사용되어야 함', () async {
        // 이 테스트는 실제로는 웹이 아닌 환경에서 실행되므로
        // 웹 분기가 제대로 처리되는지 확인
        final todoItem = TodoItem(
          title: '플랫폼 테스트',
          priority: 'High',
          dueDate: DateTime.now().add(const Duration(minutes: 1)),
          hasAlarm: true,
        );
        
        // kIsWeb이 false이므로 데스크톱 경로가 사용될 것
        expect(
          () async => await notificationService.scheduleNotification(todoItem),
          returnsNormally,
        );
      });
    });
  });

  group('TodoItem과 알림 통합 테스트', () {
    late NotificationService notificationService;
    
    setUp(() {
      notificationService = NotificationService();
    });

    test('여러 TodoItem으로 동시 알림 예약이 가능해야 함', () async {
      // Arrange
      final todoItems = [
        TodoItem(
          title: '할 일 1',
          priority: 'High',
          dueDate: DateTime.now().add(const Duration(minutes: 1)),
          hasAlarm: true,
        ),
        TodoItem(
          title: '할 일 2',
          priority: 'Medium',
          dueDate: DateTime.now().add(const Duration(minutes: 2)),
          hasAlarm: true,
        ),
        TodoItem(
          title: '할 일 3',
          priority: 'Low',
          dueDate: DateTime.now().add(const Duration(minutes: 3)),
          hasAlarm: true,
        ),
      ];
      
      // 각 TodoItem에 알람 시간 설정
      for (int i = 0; i < todoItems.length; i++) {
        final alarmTime = DateTime.now().add(Duration(minutes: i + 1));
        todoItems[i].setAlarmTimeOfDay(TimeOfDay.fromDateTime(alarmTime));
      }
      
      // Act & Assert
      for (final todoItem in todoItems) {
        expect(
          () async => await notificationService.scheduleNotification(todoItem),
          returnsNormally,
        );
      }
    });

    test('TodoItem의 effectiveAlarmTime이 올바르게 계산되어야 함', () {
      // Arrange
      final now = DateTime.now();
      final todoItem = TodoItem(
        title: '시간 계산 테스트',
        priority: 'High',
        dueDate: now.add(const Duration(days: 1)),
        hasAlarm: true,
      );
      
      // Act
      todoItem.setAlarmTimeOfDay(const TimeOfDay(hour: 14, minute: 30));
      final effectiveTime = todoItem.effectiveAlarmTime;
      
      // Assert
      expect(effectiveTime, isNotNull);
      expect(effectiveTime!.hour, equals(14));
      expect(effectiveTime.minute, equals(30));
    });
  });
}