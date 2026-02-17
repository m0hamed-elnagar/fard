// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayah_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AyahEntityAdapter extends TypeAdapter<AyahEntity> {
  @override
  final typeId = 2;

  @override
  AyahEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AyahEntity(
      surahNumber: (fields[0] as num).toInt(),
      ayahNumber: (fields[1] as num).toInt(),
      uthmaniText: fields[2] as String,
      translation: fields[3] as String?,
      page: (fields[4] as num).toInt(),
      juz: (fields[5] as num).toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, AyahEntity obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.surahNumber)
      ..writeByte(1)
      ..write(obj.ayahNumber)
      ..writeByte(2)
      ..write(obj.uthmaniText)
      ..writeByte(3)
      ..write(obj.translation)
      ..writeByte(4)
      ..write(obj.page)
      ..writeByte(5)
      ..write(obj.juz);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
