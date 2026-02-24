// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BookmarkEntityAdapter extends TypeAdapter<BookmarkEntity> {
  @override
  final typeId = 6;

  @override
  BookmarkEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookmarkEntity(
      id: fields[0] as String,
      surahNumber: (fields[1] as num).toInt(),
      ayahNumber: (fields[2] as num).toInt(),
      createdAt: fields[3] as DateTime,
      note: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BookmarkEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.surahNumber)
      ..writeByte(2)
      ..write(obj.ayahNumber)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
