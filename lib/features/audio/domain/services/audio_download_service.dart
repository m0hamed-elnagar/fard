import 'package:fard/features/audio/domain/entities/reciter.dart';

abstract interface class AudioDownloadService {
  /// Stream of download progress events
  Stream<DownloadProgress> get progressStream;

  /// Download a specific Surah
  Future<void> downloadSurah({
    required Reciter reciter,
    required int surahNumber,
  });

  /// Download all Surahs for a Reciter
  Future<void> downloadReciter({required Reciter reciter});

  /// Cancel ongoing downloads for a reciter
  Future<void> cancelDownload(String reciterId);

  /// Delete downloaded files for a Surah
  Future<void> deleteSurah({
    required String reciterId,
    required int surahNumber,
  });

  /// Delete all downloaded files for a Reciter
  Future<void> deleteReciter({required String reciterId});

  /// Get status for a Surah
  Future<SurahDownloadStatus> getSurahStatus({
    required String reciterId,
    required int surahNumber,
  });

  /// Get status for a Reciter (summary)
  Future<ReciterDownloadStatus> getReciterStatus({required String reciterId});

  /// Get approximate percentage of downloaded ayahs for a reciter
  Future<double> getReciterDownloadPercentage(String reciterId);

  /// Get total size in bytes of downloaded audio for a reciter
  Future<int> getReciterDownloadedSize(String reciterId);
}

class DownloadProgress {
  final String reciterId;
  final int? surahNumber; // Null if downloading full reciter (maybe)
  final int totalFiles;
  final int downloadedFiles;
  final String? currentFileUrl;
  final bool isCompleted;
  final String? error;

  const DownloadProgress({
    required this.reciterId,
    this.surahNumber,
    required this.totalFiles,
    required this.downloadedFiles,
    this.currentFileUrl,
    this.isCompleted = false,
    this.error,
  });

  double get percentage => totalFiles > 0 ? downloadedFiles / totalFiles : 0.0;
}

class SurahDownloadStatus {
  final bool isDownloaded;
  final bool isDownloading;
  final bool isStopping; // Added for optimistic UI
  final int sizeInBytes; // Estimated or actual
  final int downloadedAyahs;
  final int totalAyahs;

  const SurahDownloadStatus({
    required this.isDownloaded,
    required this.isDownloading,
    this.isStopping = false,
    required this.sizeInBytes,
    required this.downloadedAyahs,
    required this.totalAyahs,
  });

  SurahDownloadStatus copyWith({
    bool? isDownloaded,
    bool? isDownloading,
    bool? isStopping,
    int? sizeInBytes,
    int? downloadedAyahs,
    int? totalAyahs,
  }) {
    return SurahDownloadStatus(
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isDownloading: isDownloading ?? this.isDownloading,
      isStopping: isStopping ?? this.isStopping,
      sizeInBytes: sizeInBytes ?? this.sizeInBytes,
      downloadedAyahs: downloadedAyahs ?? this.downloadedAyahs,
      totalAyahs: totalAyahs ?? this.totalAyahs,
    );
  }
}

class ReciterDownloadStatus {
  final int downloadedSurahs;
  final int totalSurahs;
  final int totalSizeInBytes;

  const ReciterDownloadStatus({
    required this.downloadedSurahs,
    required this.totalSurahs,
    required this.totalSizeInBytes,
  });
}
