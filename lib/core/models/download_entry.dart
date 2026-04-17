import 'package:hive_ce/hive_ce.dart';

part 'download_entry.g.dart';

@HiveType(typeId: 7)
enum DownloadStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  downloading,
  @HiveField(2)
  completed,
  @HiveField(3)
  failed,
  @HiveField(4)
  paused,
}

@HiveType(typeId: 8)
class DownloadEntry extends HiveObject {
  @HiveField(0)
  final String fileId;

  @HiveField(1)
  final String relativePath;

  @HiveField(2)
  final String contentType; // "audio" | "mushaf_page" | "azan_voice"

  @HiveField(3)
  final String url;

  @HiveField(4)
  final String? checksum;

  @HiveField(5)
  final int expectedSize;

  @HiveField(6)
  final int downloadedBytes;

  @HiveField(7)
  final DownloadStatus status;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final String? errorMessage;

  @HiveField(10)
  final int attemptCount;

  @HiveField(11)
  final String? reciterId; // For audio content

  @HiveField(12)
  final int? surahNumber;

  @HiveField(13)
  final int? ayahNumber;

  DownloadEntry({
    required this.fileId,
    required this.relativePath,
    required this.contentType,
    required this.url,
    this.checksum,
    required this.expectedSize,
    this.downloadedBytes = 0,
    required this.status,
    required this.updatedAt,
    this.errorMessage,
    this.attemptCount = 0,
    this.reciterId,
    this.surahNumber,
    this.ayahNumber,
  });

  DownloadEntry copyWith({
    String? relativePath,
    String? contentType,
    String? url,
    String? checksum,
    int? expectedSize,
    int? downloadedBytes,
    DownloadStatus? status,
    DateTime? updatedAt,
    String? errorMessage,
    int? attemptCount,
    String? reciterId,
    int? surahNumber,
    int? ayahNumber,
  }) {
    return DownloadEntry(
      fileId: fileId,
      relativePath: relativePath ?? this.relativePath,
      contentType: contentType ?? this.contentType,
      url: url ?? this.url,
      checksum: checksum ?? this.checksum,
      expectedSize: expectedSize ?? this.expectedSize,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      attemptCount: attemptCount ?? this.attemptCount,
      reciterId: reciterId ?? this.reciterId,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
    );
  }
}
