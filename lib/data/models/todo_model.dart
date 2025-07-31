/// **Todo 데이터 모델**
/// 
/// 도메인 엔터티와 외부 데이터 소스 간의 변환을 담당하는 데이터 모델입니다.
/// JSON 직렬화/역직렬화와 Hive 어댑터 기능을 포함합니다.

import 'package:hive/hive.dart';
import '../../domain/entities/todo_entity.dart';

part 'todo_model.g.dart'; // build_runner로 자동 생성

@HiveType(typeId: 0)
class TodoModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String priority; // enum을 String으로 저장

  @HiveField(4)
  final DateTime dueDate;

  @HiveField(5)
  final bool isCompleted;

  @HiveField(6)
  final String category; // enum을 String으로 저장

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? completedAt;

  @HiveField(9)
  final DateTime? alarmTime;

  @HiveField(10)
  final bool hasAlarm;

  @HiveField(11)
  final String? firebaseDocId; // Firebase 문서 ID (동기화용)

  @HiveField(12)
  final int? notificationId; // 로컬 알림 ID

  TodoModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
    required this.category,
    required this.createdAt,
    this.completedAt,
    this.alarmTime,
    this.hasAlarm = false,
    this.firebaseDocId,
    this.notificationId,
  });

  /// 도메인 엔터티로 변환
  TodoEntity toEntity() {
    return TodoEntity(
      id: id,
      title: title,
      description: description,
      priority: TodoPriority.fromString(priority),
      dueDate: dueDate,
      isCompleted: isCompleted,
      category: TodoCategory.fromString(category),
      createdAt: createdAt,
      completedAt: completedAt,
      alarmTime: alarmTime,
      hasAlarm: hasAlarm,
    );
  }

  /// 도메인 엔터티에서 생성
  factory TodoModel.fromEntity(TodoEntity entity, {
    String? firebaseDocId,
    int? notificationId,
  }) {
    return TodoModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      priority: entity.priority.displayName,
      dueDate: entity.dueDate,
      isCompleted: entity.isCompleted,
      category: entity.category.displayName,
      createdAt: entity.createdAt,
      completedAt: entity.completedAt,
      alarmTime: entity.alarmTime,
      hasAlarm: entity.hasAlarm,
      firebaseDocId: firebaseDocId,
      notificationId: notificationId,
    );
  }

  /// JSON에서 생성 (Firebase용)
  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      priority: json['priority'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      isCompleted: json['isCompleted'] as bool,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      alarmTime: json['alarmTime'] != null
          ? DateTime.parse(json['alarmTime'] as String)
          : null,
      hasAlarm: json['hasAlarm'] as bool? ?? false,
      firebaseDocId: json['firebaseDocId'] as String?,
      notificationId: json['notificationId'] as int?,
    );
  }

  /// JSON으로 변환 (Firebase용)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'dueDate': dueDate.toIso8601String(),
      'isCompleted': isCompleted,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'alarmTime': alarmTime?.toIso8601String(),
      'hasAlarm': hasAlarm,
      'firebaseDocId': firebaseDocId,
      'notificationId': notificationId,
    };
  }

  /// Firestore 문서에서 생성
  factory TodoModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return TodoModel(
      id: data['id'] as String,
      title: data['title'] as String,
      description: data['description'] as String? ?? '',
      priority: data['priority'] as String,
      dueDate: (data['dueDate'] as dynamic).toDate(),
      isCompleted: data['isCompleted'] as bool,
      category: data['category'] as String,
      createdAt: (data['createdAt'] as dynamic).toDate(),
      completedAt: data['completedAt'] != null
          ? (data['completedAt'] as dynamic).toDate()
          : null,
      alarmTime: data['alarmTime'] != null
          ? (data['alarmTime'] as dynamic).toDate()
          : null,
      hasAlarm: data['hasAlarm'] as bool? ?? false,
      firebaseDocId: docId,
      notificationId: data['notificationId'] as int?,
    );
  }

  /// Firestore용 데이터로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'dueDate': dueDate,
      'isCompleted': isCompleted,
      'category': category,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'alarmTime': alarmTime,
      'hasAlarm': hasAlarm,
      'notificationId': notificationId,
    };
  }

  /// 복사본 생성
  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    bool? isCompleted,
    String? category,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? alarmTime,
    bool? hasAlarm,
    String? firebaseDocId,
    int? notificationId,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      alarmTime: alarmTime ?? this.alarmTime,
      hasAlarm: hasAlarm ?? this.hasAlarm,
      firebaseDocId: firebaseDocId ?? this.firebaseDocId,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  @override
  String toString() {
    return 'TodoModel(id: $id, title: $title, priority: $priority, '
           'isCompleted: $isCompleted, category: $category)';
  }
}