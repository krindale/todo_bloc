/// **TodoItem 데이터 모델**
/// 
/// 할 일 항목의 핵심 데이터 구조를 정의합니다.
/// Hive NoSQL 데이터베이스와 Firebase Firestore 모두에서 사용 가능한
/// 플랫폼 독립적인 모델입니다.
/// 
/// **주요 속성:**
/// - title: 할 일 제목
/// - priority: 우선순위 (High/Medium/Low)
/// - dueDate: 마감일
/// - isCompleted: 완료 상태
/// - category: 카테고리 (Work, Personal, Shopping, Health)
/// - userId: 사용자 ID (Firebase 동기화용)
/// - createdAt: 생성 시간
/// - id: 고유 식별자
/// 
/// **기술적 특징:**
/// - @HiveType: Hive 로컬 데이터베이스 지원
/// - HiveObject 상속: Hive의 CRUD 작업 지원
/// - JSON 직렬화/역직렬화: Firebase 연동
/// - 불변성 고려: 데이터 무결성 보장
/// 
/// **사용 위치:**
/// - Repository 계층에서 데이터 전달
/// - UI 위젯에서 화면 렌더링
/// - Firebase 동기화 시 변환 대상

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'todo_item.g.dart'; // build_runner로 자동 생성

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

  @override
  String toString() {
    return title;
  }
}
