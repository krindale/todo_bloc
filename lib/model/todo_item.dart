import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'todo_item.g.dart'; // 자동 생성 파일

@HiveType(typeId: 0)
class TodoItem extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String priority;

  @HiveField(2)
  DateTime dueDate;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  String? category;

  @HiveField(5)
  String? firebaseDocId; // Firebase 문서 ID 추적용

  @HiveField(6)
  DateTime? alarmTime; // 알람 설정 시간 (듀데이트와 조합하여 사용)

  @HiveField(7)
  bool hasAlarm; // 알람 설정 여부

  @HiveField(8)
  int? notificationId; // 로컬 알림 ID

  TodoItem({
    required this.title,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
    this.category,
    this.firebaseDocId,
    this.alarmTime,
    this.hasAlarm = false,
    this.notificationId,
  });

  /// 듀데이트와 알람 시간을 조합하여 실제 알람 DateTime 반환
  DateTime? get effectiveAlarmTime {
    if (!hasAlarm || alarmTime == null) return null;
    
    // alarmTime에서 시간과 분을 가져와서 dueDate의 날짜와 조합
    return DateTime(
      dueDate.year,
      dueDate.month, 
      dueDate.day,
      alarmTime!.hour,
      alarmTime!.minute,
    );
  }

  /// 시간만 설정할 수 있도록 TimeOfDay를 받아서 alarmTime 업데이트
  void setAlarmTimeOfDay(TimeOfDay timeOfDay) {
    alarmTime = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
      timeOfDay.hour,
      timeOfDay.minute,
    );
    hasAlarm = true;
  }

  /// 알람 해제
  void clearAlarm() {
    alarmTime = null;
    hasAlarm = false;
  }

  /// 듀데이트 변경 시 알람 시간 업데이트
  void updateDueDateAndAlarm(DateTime newDueDate) {
    if (hasAlarm && alarmTime != null) {
      // 기존 알람의 시간과 분을 유지하면서 새 날짜로 업데이트
      final oldTime = TimeOfDay.fromDateTime(alarmTime!);
      alarmTime = DateTime(
        newDueDate.year,
        newDueDate.month,
        newDueDate.day,
        oldTime.hour,
        oldTime.minute,
      );
    }
    dueDate = newDueDate;
  }
}
