import 'package:hive/hive.dart';

part 'todo_item.g.dart'; // 자동 생성 파일

@HiveType(typeId: 0) // Hive에 저장할 타입 ID 설정
class TodoItem extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String priority;

  @HiveField(2)
  DateTime dueDate;

  @HiveField(3)
  bool isCompleted;

  TodoItem({
    required this.title,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  });
}
