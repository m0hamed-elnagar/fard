// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadEntryAdapter extends TypeAdapter<DownloadEntry> {
  @override
  final typeId = 8;

  @override
  DownloadEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadEntry(
      fileId: fields[0] as String,
      relativePath: fields[1] as String,
      contentType: fields[2] as String,
      url: fields[3] as String,
      checksum: fields[4] as String?,
      expectedSize: (fields[5] as num).toInt(),
      downloadedBytes: fields[6] == null ? 0 : (fields[6] as num).toInt(),
      status: fields[7] as DownloadStatus,
      updatedAt: fields[8] as DateTime,
      errorMessage: fields[9] as String?,
      attemptCount: fields[10] == null ? 0 : (fields[10] as num).toInt(),
      reciterId: fields[11] as String?,
      surahNumber: (fields[12] as num?)?.toInt(),
      ayahNumber: (fields[13] as num?)?.toInt(),
    );
  }

  @override
  void write(BinaryWriter writer, DownloadEntry obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.fileId)
      ..writeByte(1)
      ..write(obj.relativePath)
      ..writeByte(2)
      ..write(obj.contentType)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.checksum)
      ..writeByte(5)
      ..write(obj.expectedSize)
      ..writeByte(6)
      ..write(obj.downloadedBytes)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.errorMessage)
      ..writeByte(10)
      ..write(obj.attemptCount)
      ..writeByte(11)
      ..write(obj.reciterId)
      ..writeByte(12)
      ..write(obj.surahNumber)
      ..writeByte(13)
      ..write(obj.ayahNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DownloadStatusAdapter extends TypeAdapter<DownloadStatus> {
  @override
  final typeId = 7;

  @override
  DownloadStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DownloadStatus.pending;
      case 1:
        return DownloadStatus.downloading;
      case 2:
        return DownloadStatus.completed;
      case 3:
        return DownloadStatus.failed;
      case 4:
        return DownloadStatus.paused;
      default:
        return DownloadStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, DownloadStatus obj) {
    switch (obj) {
      case DownloadStatus.pending:
        writer.writeByte(0);
      case DownloadStatus.downloading:
        writer.writeByte(1);
      case DownloadStatus.completed:
        writer.writeByte(2);
      case DownloadStatus.failed:
        writer.writeByte(3);
      case DownloadStatus.paused:
        writer.writeByte(4);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
