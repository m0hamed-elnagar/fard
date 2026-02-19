// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyRecordEntityAdapter extends TypeAdapter<DailyRecordEntity> {
  @override
  final typeId = 0;

  @override
  DailyRecordEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyRecordEntity(
      id: fields[0] as String,
      dateMillis: (fields[1] as num).toInt(),
      missedIndices: (fields[2] as List).cast<int>(),
      qadaValues: (fields[3] as Map).cast<int, int>(),
      completedIndices: (fields[4] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, DailyRecordEntity obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dateMillis)
      ..writeByte(2)
      ..write(obj.missedIndices)
      ..writeByte(3)
      ..write(obj.qadaValues)
      ..writeByte(4)
      ..write(obj.completedIndices);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
