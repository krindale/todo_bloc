// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_link.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SavedLinkAdapter extends TypeAdapter<SavedLink> {
  @override
  final int typeId = 1;

  @override
  SavedLink read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SavedLink(
      title: fields[0] as String,
      url: fields[1] as String,
      category: fields[2] as String,
      colorValue: fields[3] as int,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SavedLink obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SavedLinkAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
