/// **Todo 도메인 엔터티**
/// 
/// 클린 아키텍처의 핵심 도메인 엔터티로, 비즈니스 로직만 포함하고
/// 외부 프레임워크나 데이터베이스에 의존하지 않습니다.
/// 
/// **특징:**
/// - 불변성(Immutability) 보장
/// - 순수한 비즈니스 로직만 포함
/// - 외부 의존성 없음 (No Flutter, No Hive, No Firebase)
/// - 풍부한 도메인 모델(Rich Domain Model)

import 'package:equatable/equatable.dart';

/// Todo 항목의 우선순위
enum TodoPriority {
  high('High'),
  medium('Medium'),
  low('Low');

  const TodoPriority(this.displayName);
  final String displayName;

  static TodoPriority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return TodoPriority.high;
      case 'medium':
        return TodoPriority.medium;
      case 'low':
        return TodoPriority.low;
      default:
        return TodoPriority.medium;
    }
  }
}

/// Todo 항목의 카테고리
enum TodoCategory {
  work('업무', '작업'),
  personal('개인', '일반'),
  health('건강', '건강'),
  study('학습', '공부'),
  lifestyle('생활', '라이프스타일'),
  finance('재정', '돈');

  const TodoCategory(this.displayName, this.keyword);
  final String displayName;
  final String keyword;

  static TodoCategory fromString(String? category) {
    if (category == null) return TodoCategory.personal;
    
    switch (category.toLowerCase()) {
      case '업무':
      case 'work':
        return TodoCategory.work;
      case '건강':
      case 'health':
        return TodoCategory.health;
      case '학습':
      case 'study':
        return TodoCategory.study;
      case '생활':
      case 'lifestyle':
        return TodoCategory.lifestyle;
      case '재정':
      case 'finance':
        return TodoCategory.finance;
      default:
        return TodoCategory.personal;
    }
  }
}

/// Todo 도메인 엔터티
class TodoEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final TodoPriority priority;
  final DateTime dueDate;
  final bool isCompleted;
  final TodoCategory category;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? alarmTime;
  final bool hasAlarm;

  const TodoEntity({
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
  });

  /// 완료 처리
  TodoEntity markCompleted() {
    if (isCompleted) return this;
    
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  /// 완료 해제
  TodoEntity markIncomplete() {
    if (!isCompleted) return this;
    
    return copyWith(
      isCompleted: false,
      completedAt: null,
    );
  }

  /// 우선순위 변경
  TodoEntity changePriority(TodoPriority newPriority) {
    return copyWith(priority: newPriority);
  }

  /// 카테고리 변경
  TodoEntity changeCategory(TodoCategory newCategory) {
    return copyWith(category: newCategory);
  }

  /// 알람 설정
  TodoEntity setAlarm(DateTime alarmTime) {
    return copyWith(
      alarmTime: alarmTime,
      hasAlarm: true,
    );
  }

  /// 알람 해제
  TodoEntity clearAlarm() {
    return copyWith(
      alarmTime: null,
      hasAlarm: false,
    );
  }

  /// 마감일이 지났는지 확인
  bool get isOverdue {
    if (isCompleted) return false;
    return DateTime.now().isAfter(dueDate);
  }

  /// 오늘이 마감일인지 확인
  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return today.isAtSameMomentAs(dueDay);
  }

  /// 알람이 설정되었고 아직 울리지 않았는지 확인
  bool get shouldNotify {
    if (!hasAlarm || alarmTime == null || isCompleted) return false;
    final now = DateTime.now();
    return now.isAfter(alarmTime!) && !isCompleted;
  }

  /// 복사본 생성 (불변성 보장)
  TodoEntity copyWith({
    String? id,
    String? title,
    String? description,
    TodoPriority? priority,
    DateTime? dueDate,
    bool? isCompleted,
    TodoCategory? category,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? alarmTime,
    bool? hasAlarm,
  }) {
    return TodoEntity(
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
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        priority,
        dueDate,
        isCompleted,
        category,
        createdAt,
        completedAt,
        alarmTime,
        hasAlarm,
      ];

  @override
  String toString() {
    return 'TodoEntity(id: $id, title: $title, priority: $priority, '
           'isCompleted: $isCompleted, category: $category)';
  }
}