import 'package:hive/hive.dart';
import 'todo_item.dart';

class TodoItemCompatibleAdapter extends TypeAdapter<TodoItem> {
  @override
  final int typeId = 0;

  @override
  TodoItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return TodoItem(
      title: fields[0] as String,
      priority: fields[1] as String,
      dueDate: fields[2] as DateTime,
      isCompleted: fields[3] as bool,
      category: fields[4] as String?,
      firebaseDocId: fields[5] as String?,
      alarmTime: fields[6] as DateTime?,
      hasAlarm: fields[7] as bool? ?? false, // null-safe 처리
      notificationId: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TodoItem obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.priority)
      ..writeByte(2)
      ..write(obj.dueDate)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.firebaseDocId)
      ..writeByte(6)
      ..write(obj.alarmTime)
      ..writeByte(7)
      ..write(obj.hasAlarm)
      ..writeByte(8)
      ..write(obj.notificationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoItemCompatibleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}