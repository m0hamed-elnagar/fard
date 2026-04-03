import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import 'package:quran/quran.dart' as quran;

@LazySingleton(as: AudioDownloadService)
class AudioDownloadServiceImpl implements AudioDownloadService {
  final AudioRepository _audioRepository;
  final http.Client _client;
  final NotificationService _notificationService;

  final _progressController = StreamController<DownloadProgress>.broadcast();
  // Track cancel tokens or flags per reciter
  final Map<String, bool> _cancellationFlags = {};
  // Track active downloads: "reciterId_surahNumber"
  final Set<String> _activeDownloads = {};

  AudioDownloadServiceImpl(
    this._audioRepository,
    this._client,
    this._notificationService,
  );

  NotificationService get _notifications => _notificationService;

  @override
  Stream<DownloadProgress> get progressStream => _progressController.stream;

  @override
  Future<void> downloadSurah({
    required Reciter reciter,
    required int surahNumber,
  }) async {
    final reciterId = reciter.identifier;
    final downloadKey = '${reciterId}_$surahNumber';

    if (_activeDownloads.contains(downloadKey)) return;

    _cancellationFlags[reciterId] = false;
    _activeDownloads.add(downloadKey);

    try {
      final tracksResult = await _audioRepository.getSurahAudioTracks(
        reciterId: reciterId,
        surahNumber: surahNumber,
        ayahCount: _audioRepository.getAyahCount(surahNumber),
      );

      if (tracksResult.isFailure) {
        _emitError(
          reciterId,
          surahNumber,
          tracksResult.failure?.message ?? "Failed to get tracks",
        );
        return;
      }

      final tracks = tracksResult.data!;
      final totalFiles = tracks.length;

      // Real-time count of files on disk
      int currentlyOnDisk = 0;
      for (final t in tracks) {
        if (await File(t.localPath).exists()) currentlyOnDisk++;
      }

      if (currentlyOnDisk == totalFiles) {
        _emitProgress(
          reciterId,
          surahNumber,
          totalFiles,
          totalFiles,
          isCompleted: true,
        );
        return;
      }

      _emitProgress(reciterId, surahNumber, totalFiles, currentlyOnDisk);

      const int batchSize = 5;
      for (int i = 0; i < tracks.length; i += batchSize) {
        // Yield to event loop to check cancellation flag more effectively
        await Future.delayed(Duration.zero);

        if (_cancellationFlags[reciterId] == true) {
          _activeDownloads.remove(downloadKey);
          _emitError(
            reciterId,
            surahNumber,
            "Cancelled",
            total: totalFiles,
            downloaded: currentlyOnDisk,
          );
          return;
        }

        final end = (i + batchSize < tracks.length)
            ? i + batchSize
            : tracks.length;
        final batch = tracks.sublist(i, end);

        await Future.wait(
          batch.map((track) async {
            if (!await File(track.localPath).exists()) {
              int retries = 3;
              bool success = false;

              while (retries > 0 && !success) {
                if (_cancellationFlags[reciterId] == true) return;

                try {
                  final response = await _client
                      .get(Uri.parse(track.remoteUrl))
                      .timeout(const Duration(seconds: 15));

                  if (_cancellationFlags[reciterId] == true) return;

                  if (response.statusCode == 200) {
                    final file = File(track.localPath);
                    await file.parent.create(recursive: true);

                    if (_cancellationFlags[reciterId] == true) return;
                    await file.writeAsBytes(response.bodyBytes);

                    success = true;
                    currentlyOnDisk++;
                    _emitProgress(
                      reciterId,
                      surahNumber,
                      totalFiles,
                      currentlyOnDisk,
                      currentFileUrl: track.remoteUrl,
                    );
                  } else {
                    retries--;
                    if (retries == 0) {
                      debugPrint(
                        "Failed download after retries: ${track.remoteUrl}",
                      );
                    }
                  }
                } catch (e) {
                  retries--;
                  if (retries == 0) {
                    debugPrint("Error downloading ${track.remoteUrl}: $e");
                  }
                  await Future.delayed(
                    const Duration(milliseconds: 500),
                  ); // Backoff
                }
              }
            }
          }),
        );
      }

      // Final verification before marking complete
      int finalCount = 0;
      for (final t in tracks) {
        if (await File(t.localPath).exists()) finalCount++;
      }

      final isAllDone = finalCount == totalFiles;

      // CRITICAL: Remove from active downloads BEFORE emitting final progress
      // so that any status checks (getSurahStatus) see it as finished.
      _activeDownloads.remove(downloadKey);

      _emitProgress(
        reciterId,
        surahNumber,
        totalFiles,
        finalCount,
        isCompleted: isAllDone,
      );
    } catch (e) {
      _activeDownloads.remove(downloadKey);
      _emitError(reciterId, surahNumber, e.toString());
    }
  }

  @override
  Future<void> downloadReciter({required Reciter reciter}) async {
    final reciterId = reciter.identifier;
    _cancellationFlags[reciterId] = false;

    for (int i = 1; i <= 114; i++) {
      if (_cancellationFlags[reciterId] == true) break;
      await downloadSurah(reciter: reciter, surahNumber: i);
    }
  }

  @override
  Future<void> cancelDownload(String reciterId) async {
    _cancellationFlags[reciterId] = true;
  }

  @override
  Future<void> deleteSurah({
    required String reciterId,
    required int surahNumber,
  }) async {
    final tracksResult = await _audioRepository.getSurahAudioTracks(
      reciterId: reciterId,
      surahNumber: surahNumber,
      ayahCount: _audioRepository.getAyahCount(surahNumber),
    );

    if (tracksResult.isSuccess) {
      for (final track in tracksResult.data!) {
        // Protect Bismillah file (001001.mp3) unless it's Surah 1 being deleted
        // because almost every Surah depends on it for the "prepend" logic.
        if (surahNumber != 1 && track.localPath.endsWith('001001.mp3')) {
          continue;
        }

        final file = File(track.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
    }
  }

  @override
  Future<void> deleteReciter({required String reciterId}) async {
    final directory = await getApplicationDocumentsDirectory();
    final reciterDir = Directory('${directory.path}/audio/$reciterId');
    if (await reciterDir.exists()) {
      await reciterDir.delete(recursive: true);
    }
  }

  @override
  Future<SurahDownloadStatus> getSurahStatus({
    required String reciterId,
    required int surahNumber,
  }) async {
    final tracksResult = await _audioRepository.getSurahAudioTracks(
      reciterId: reciterId,
      surahNumber: surahNumber,
      ayahCount: _audioRepository.getAyahCount(surahNumber),
    );

    if (tracksResult.isFailure) {
      return SurahDownloadStatus(
        isDownloaded: false,
        isDownloading: false,
        sizeInBytes: 0,
        downloadedAyahs: 0,
        totalAyahs: 0,
      );
    }

    final tracks = tracksResult.data!;
    int downloaded = 0;
    int size = 0;

    for (final track in tracks) {
      final file = File(track.localPath);
      if (await file.exists()) {
        downloaded++;
        size += await file.length();
      }
    }

    // If none downloaded, provide estimate for UI
    if (size == 0) {
      size = tracks.length * 250 * 1024;
    }

    final isDownloading = _activeDownloads.contains(
      '${reciterId}_$surahNumber',
    );
    final isStopping = isDownloading && _cancellationFlags[reciterId] == true;

    return SurahDownloadStatus(
      isDownloaded: downloaded == tracks.length && tracks.isNotEmpty,
      isDownloading: isDownloading && !isStopping,
      isStopping: isStopping,
      sizeInBytes: size,
      downloadedAyahs: downloaded,
      totalAyahs: tracks.length,
    );
  }

  @override
  Future<double> getReciterDownloadPercentage(String reciterId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final reciterDir = Directory('${directory.path}/audio/$reciterId');

      if (!await reciterDir.exists()) return 0.0;

      final files = await reciterDir.list().length;
      // Approximate total ayahs in Quran + Bismillahs is around 6300-6400
      const totalPossibleFiles = 6348;

      return (files / totalPossibleFiles).clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<int> getReciterDownloadedSize(String reciterId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final reciterDir = Directory('${directory.path}/audio/$reciterId');

      if (!await reciterDir.exists()) return 0;

      int totalSize = 0;
      await for (final file in reciterDir.list(recursive: false)) {
        if (file is File) {
          totalSize += await file.length();
        }
      }
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<ReciterDownloadStatus> getReciterStatus({
    required String reciterId,
  }) async {
    // Checking 6000 files is slow.
    // Optimization: Check directory size and file count?
    final directory = await getApplicationDocumentsDirectory();
    final reciterDir = Directory('${directory.path}/audio/$reciterId');

    if (await reciterDir.exists()) {
      // Only count files, approximate
      // This is a heavy operation if many files.
      // Let's just return what we can easily get.
      // Or rely on a separate metadata file for fast lookup in future improvements.
      // For now, return 0 or implement a lighter check.
    }

    return ReciterDownloadStatus(
      downloadedSurahs: 0, // Placeholder
      totalSurahs: 114,
      totalSizeInBytes: 0,
    );
  }

  void _emitProgress(
    String reciterId,
    int? surahNumber,
    int total,
    int downloaded, {
    String? currentFileUrl,
    bool isCompleted = false,
  }) {
    _progressController.add(
      DownloadProgress(
        reciterId: reciterId,
        surahNumber: surahNumber,
        totalFiles: total,
        downloadedFiles: downloaded,
        currentFileUrl: currentFileUrl,
        isCompleted: isCompleted,
      ),
    );

    // Show notification
    if (total > 0) {
      final l10n = lookupAppLocalizations(getIt<SettingsCubit>().state.locale);
      final id = _getNotificationId(reciterId, surahNumber);

      String title;
      if (surahNumber != null) {
        final isArabic =
            getIt<SettingsCubit>().state.locale.languageCode == 'ar';
        final surahName = isArabic
            ? quran.getSurahNameArabic(surahNumber)
            : quran.getSurahName(surahNumber);
        title = l10n.downloadingSurah(surahName);
      } else {
        title = l10n.downloadingReciter(reciterId);
      }

      final body = isCompleted
          ? l10n.downloadComplete
          : l10n.filesCount(downloaded, total);

      _notifications.showDownloadProgress(
        id: id,
        title: title,
        body: body,
        progress: downloaded,
        maxProgress: total,
        isCompleted: isCompleted,
      );
    }
  }

  void _emitError(
    String reciterId,
    int? surahNumber,
    String error, {
    int total = 0,
    int downloaded = 0,
  }) {
    // Try to get last known progress for this surah to avoid UI flickering to 0
    _progressController.add(
      DownloadProgress(
        reciterId: reciterId,
        surahNumber: surahNumber,
        totalFiles: total,
        downloadedFiles: downloaded,
        error: error,
      ),
    );

    final l10n = lookupAppLocalizations(getIt<SettingsCubit>().state.locale);
    final id = _getNotificationId(reciterId, surahNumber);

    String title;
    if (surahNumber != null) {
      final isArabic = getIt<SettingsCubit>().state.locale.languageCode == 'ar';
      final surahName = isArabic
          ? quran.getSurahNameArabic(surahNumber)
          : quran.getSurahName(surahNumber);
      title = '${l10n.downloadError}: $surahName';
    } else {
      title = l10n.downloadError;
    }

    _notifications.showDownloadProgress(
      id: id,
      title: title,
      body: error,
      progress: 0,
      maxProgress: 100,
      isCompleted: true,
    );
  }

  int _getNotificationId(String reciterId, int? surahNumber) {
    // Return a fixed ID so that download notifications update each other as requested.
    // Audio downloads will use ID 888.
    return 888;
  }
}
