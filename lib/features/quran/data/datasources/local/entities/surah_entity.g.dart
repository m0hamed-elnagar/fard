// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surah_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurahEntityAdapter extends TypeAdapter<SurahEntity> {
  @override
  final typeId = 1;

  @override
  SurahEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurahEntity(
      number: (fields[0] as num).toInt(),
      name: fields[1] as String,
      englishName: fields[2] as String?,
      englishNameTranslation: fields[3] as String?,
      numberOfAyahs: (fields[4] as num).toInt(),
      revelationType: fields[5] as String,
      ayahs: (fields[6] as List).cast<AyahEntity>(),
    );
  }

  @override
  void write(BinaryWriter writer, SurahEntity obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.englishName)
      ..writeByte(3)
      ..write(obj.englishNameTranslation)
      ..writeByte(4)
      ..write(obj.numberOfAyahs)
      ..writeByte(5)
      ..write(obj.revelationType)
      ..writeByte(6)
      ..write(obj.ayahs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurahEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
