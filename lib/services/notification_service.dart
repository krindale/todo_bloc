import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../model/todo_item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    // 타임존 데이터 초기화
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const linuxSettings = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 알림 권한 요청
    if (!kIsWeb) {
      await _requestPermissions();
    }

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
    }

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // 필요시 특정 화면으로 이동하는 로직 추가
  }

  Future<void> scheduleNotification(TodoItem todoItem) async {
    if (!_initialized) await initialize();
    
    final effectiveAlarmTime = todoItem.effectiveAlarmTime;
    if (effectiveAlarmTime == null || !todoItem.hasAlarm) return;

    final scheduledTime = tz.TZDateTime.from(effectiveAlarmTime, tz.local);
    
    // 현재 시간보다 이전이면 알림을 설정하지 않음
    if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint('알람 시간이 과거입니다: ${todoItem.title}');
      return;
    }

    final notificationId = todoItem.notificationId ?? DateTime.now().millisecondsSinceEpoch.remainder(100000);
    
    const androidDetails = AndroidNotificationDetails(
      'todo_alarm_channel',
      'Todo 알람',
      channelDescription: 'Todo 항목에 대한 알람',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const linuxDetails = LinuxNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      linux: linuxDetails,
    );

    await _notifications.zonedSchedule(
      notificationId,
      '할 일 알림',
      todoItem.title,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: todoItem.title,
    );

    // notificationId가 없다면 설정
    if (todoItem.notificationId == null) {
      todoItem.notificationId = notificationId;
    }

    debugPrint('알림 예약됨: ${todoItem.title} at $scheduledTime');
  }

  Future<void> cancelNotification(int notificationId) async {
    if (!_initialized) await initialize();
    
    await _notifications.cancel(notificationId);
    debugPrint('알림 취소됨: $notificationId');
  }

  Future<void> cancelAllNotifications() async {
    if (!_initialized) await initialize();
    
    await _notifications.cancelAll();
    debugPrint('모든 알림 취소됨');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) await initialize();
    
    return await _notifications.pendingNotificationRequests();
  }
}