import 'dart:async';
import 'dart:io';

import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/models/download_entry.dart';
import 'package:fard/core/services/download/download_manifest_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/utils/file_download_utils.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quran/quran.dart' as quran;

@LazySingleton(as: AudioDownloadService)
class AudioDownloadServiceImpl implements AudioDownloadService {
  final AudioRepository _audioRepository;
  final http.Client _client;
  final NotificationService _notificationService;
  final SettingsRepository _settingsRepository;
  final DownloadManifestService _manifestService;

  final _progressController = StreamController<DownloadProgress>.broadcast();
  // Track cancel tokens or flags per reciter
  final Map<String, bool> _cancellationFlags = {};
  // Track active downloads: "reciterId_surahNumber"
  final Set<String> _activeDownloads = {};

  AudioDownloadServiceImpl(
    this._audioRepository,
    this._client,
    this._notificationService,
    this._settingsRepository,
    this._manifestService,
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

    final quality = _settingsRepository.audioQuality;

    try {
      // 1. Handle Bismillah as a silent dependency
      final needsBismillah = _audioRepository.shouldPrependBismillah(
        surahNumber,
        reciterId,
      );

      if (needsBismillah) {
        final bismillahTrack = await _audioRepository.getBismillahTrack(
          reciterId: reciterId,
          quality: quality,
        );

        if (!await File(bismillahTrack.localPath).exists()) {
          int retries = 3;
          bool bismillahSuccess = false;
          while (retries > 0 && !bismillahSuccess) {
            if (_cancellationFlags[reciterId] == true) return;
            try {
              final response = await _client
                  .get(Uri.parse(bismillahTrack.remoteUrl))
                  .timeout(const Duration(seconds: 15));
              if (response.statusCode == 200) {
                await FileDownloadUtils.atomicWriteFile(
                  bytes: response.bodyBytes,
                  finalPath: bismillahTrack.localPath,
                  fileType: 'audio',
                );
                bismillahSuccess = true;
              } else {
                retries--;
              }
            } catch (e) {
              retries--;
              await Future.delayed(const Duration(milliseconds: 500));
            }
          }
        }
      }

      // 2. Download surah ayahs
      final entries = await _manifestService.getEntriesBySurah(reciterId, surahNumber);
      
      if (entries.isEmpty) {
        // Initial sync to populate manifest if empty
        await _syncManifestForSurah(reciterId, surahNumber);
      }

      final updatedEntries = await _manifestService.getEntriesBySurah(reciterId, surahNumber);
      final totalFiles = updatedEntries.length;

      if (totalFiles == 0) {
        _activeDownloads.remove(downloadKey);
        _emitProgress(reciterId, surahNumber, 0, 0, isCompleted: true);
        return;
      }

      // Identify missing or incomplete tracks
      int downloadedCount = 0;
      final List<DownloadEntry> pendingEntries = [];

      for (final entry in updatedEntries) {
        if (entry.status == DownloadStatus.completed) {
          downloadedCount++;
        } else {
          pendingEntries.add(entry);
        }
      }

      if (downloadedCount == totalFiles) {
        _activeDownloads.remove(downloadKey);
        _emitProgress(
          reciterId,
          surahNumber,
          totalFiles,
          totalFiles,
          isCompleted: true,
        );
        return;
      }

      // Start from what we have
      _emitProgress(reciterId, surahNumber, totalFiles, downloadedCount);

      const int batchSize = 5;
      for (int i = 0; i < pendingEntries.length; i += batchSize) {
        await Future.delayed(Duration.zero);

        if (_cancellationFlags[reciterId] == true) {
          _activeDownloads.remove(downloadKey);
          _emitError(
            reciterId,
            surahNumber,
            "Cancelled",
            total: totalFiles,
            downloaded: downloadedCount,
          );
          final directory = await getApplicationSupportDirectory();
          await FileDownloadUtils.pruneTempFiles('${directory.path}/audio/$reciterId');
          return;
        }

        final end = (i + batchSize < pendingEntries.length)
            ? i + batchSize
            : pendingEntries.length;
        final batch = pendingEntries.sublist(i, end);

        await Future.wait(
          batch.map((entry) async {
            int retries = 3;
            bool success = false;

            while (retries > 0 && !success) {
              if (_cancellationFlags[reciterId] == true) return;

              try {
                // Update status to downloading
                await _manifestService.upsertEntry(entry.copyWith(
                  status: DownloadStatus.downloading,
                  updatedAt: DateTime.now(),
                ));

                final directory = await getApplicationSupportDirectory();
                final finalPath = '${directory.path}/audio/${entry.relativePath}';
                final file = File(finalPath);
                
                final Map<String, String> headers = {};
                int startByte = 0;
                
                if (await file.exists() && entry.downloadedBytes > 0) {
                  startByte = await file.length();
                  if (startByte > 0) {
                    headers['Range'] = 'bytes=$startByte-';
                  }
                }

                final response = await _client
                    .get(Uri.parse(entry.url), headers: headers)
                    .timeout(const Duration(seconds: 25));

                if (_cancellationFlags[reciterId] == true) return;

                if (response.statusCode == 200 || response.statusCode == 206) {
                  final isPartial = response.statusCode == 206;
                  
                  if (isPartial) {
                    await FileDownloadUtils.appendToFile(
                      bytes: response.bodyBytes,
                      path: finalPath,
                    );
                  } else {
                    await FileDownloadUtils.atomicWriteFile(
                      bytes: response.bodyBytes,
                      finalPath: finalPath,
                      fileType: 'audio',
                    );
                  }

                  // Get total size from headers if possible
                  int totalSize = entry.expectedSize;
                  if (isPartial) {
                    // Content-Range: bytes 200-1000/1001
                    final contentRange = response.headers['content-range'];
                    if (contentRange != null) {
                      final parts = contentRange.split('/');
                      if (parts.length > 1) {
                        totalSize = int.tryParse(parts[1]) ?? totalSize;
                      }
                    }
                  } else {
                    totalSize = response.contentLength ?? response.bodyBytes.length;
                  }

                  final currentSize = isPartial ? (startByte + response.bodyBytes.length) : response.bodyBytes.length;
                  final isDone = currentSize >= totalSize;

                  // Update manifest
                  await _manifestService.upsertEntry(entry.copyWith(
                    status: isDone ? DownloadStatus.completed : DownloadStatus.downloading,
                    downloadedBytes: currentSize,
                    expectedSize: totalSize,
                    updatedAt: DateTime.now(),
                  ));

                  if (isDone) {
                    success = true;
                    downloadedCount++;
                    _emitProgress(
                      reciterId,
                      surahNumber,
                      totalFiles,
                      downloadedCount,
                      currentFileUrl: entry.url,
                    );
                  }
                } else {
                  retries--;
                  if (retries == 0) {
                    await _manifestService.upsertEntry(entry.copyWith(
                      status: DownloadStatus.failed,
                      errorMessage: 'Status code: ${response.statusCode}',
                      updatedAt: DateTime.now(),
                      attemptCount: entry.attemptCount + 1,
                    ));
                  }
                  if (retries > 0) await Future.delayed(const Duration(milliseconds: 1000));
                }
              } catch (e) {
                retries--;
                if (retries == 0) {
                  await _manifestService.upsertEntry(entry.copyWith(
                    status: DownloadStatus.failed,
                    errorMessage: e.toString(),
                    updatedAt: DateTime.now(),
                    attemptCount: entry.attemptCount + 1,
                  ));
                }
                if (retries > 0) await Future.delayed(const Duration(milliseconds: 1500));
              }
            }
          }),
        );
      }

      // 3. Final Verification
      final finalEntries = await _manifestService.getEntriesBySurah(reciterId, surahNumber);
      int verifiedCount = 0;
      final List<DownloadEntry> finalMissing = [];
      for (final e in finalEntries) {
        if (e.status == DownloadStatus.completed) {
          verifiedCount++;
        } else {
          finalMissing.add(e);
        }
      }

      // If just a few missing, try one last time sequentially with longer timeout
      if (finalMissing.isNotEmpty && finalMissing.length <= 5) {
        for (final entry in finalMissing) {
          if (_cancellationFlags[reciterId] == true) break;
          try {
            final response = await _client
                .get(Uri.parse(entry.url))
                .timeout(const Duration(seconds: 40));
            if (response.statusCode == 200) {
              final directory = await getApplicationSupportDirectory();
              final finalPath = '${directory.path}/audio/${entry.relativePath}';
              
              await FileDownloadUtils.atomicWriteFile(
                bytes: response.bodyBytes,
                finalPath: finalPath,
                fileType: 'audio',
              );
              
              await _manifestService.upsertEntry(entry.copyWith(
                status: DownloadStatus.completed,
                downloadedBytes: response.bodyBytes.length,
                expectedSize: response.bodyBytes.length,
                updatedAt: DateTime.now(),
              ));

              verifiedCount++;
              _emitProgress(reciterId, surahNumber, totalFiles, verifiedCount);
            }
          } catch (_) {}
        }
      }

      _activeDownloads.remove(downloadKey);

      if (verifiedCount == totalFiles) {
        _emitProgress(
          reciterId,
          surahNumber,
          totalFiles,
          totalFiles,
          isCompleted: true,
        );
      } else if (verifiedCount > 0) {
        // Emit progress at current count even if incomplete, to let UI reflect reality
        _emitProgress(reciterId, surahNumber, totalFiles, verifiedCount);
        _emitError(
          reciterId,
          surahNumber,
          "Completed with ${totalFiles - verifiedCount} missing ayahs. Please retry.",
          total: totalFiles,
          downloaded: verifiedCount,
        );
      } else {
        _emitError(
          reciterId,
          surahNumber,
          "Failed to download ayahs. Please retry.",
          total: totalFiles,
          downloaded: verifiedCount,
        );
      }
    } catch (e) {
      _activeDownloads.remove(downloadKey);
      _emitError(reciterId, surahNumber, e.toString(), total: _audioRepository.getAyahCount(surahNumber));
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
  Future<void> cancelAllDownloads() async {
    for (final key in _cancellationFlags.keys) {
      _cancellationFlags[key] = true;
    }
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
        // ALWAYS protect Bismillah file (001001.mp3) during Surah deletion
        // because almost every Surah (2-114) depends on it for the "prepend" logic.
        // It will only be removed if the entire reciter is deleted via deleteReciter().
        if (track.localPath.endsWith('001001.mp3')) {
          continue;
        }

        final file = File(track.localPath);
        if (await file.exists()) {
          await file.delete();
        }
      }
      
      // Clear manifest entries for this surah
      await _manifestService.deleteEntriesBySurah(reciterId, surahNumber);
    }
  }

  @override
  Future<void> deleteReciter({required String reciterId}) async {
    final directory = await getApplicationSupportDirectory();
    final reciterDir = Directory('${directory.path}/audio/$reciterId');
    if (await reciterDir.exists()) {
      await reciterDir.delete(recursive: true);
    }
    
    // Clear manifest entries for this reciter
    await _manifestService.deleteEntriesByReciter(reciterId);
  }

  @override
  Future<SurahDownloadStatus> getSurahStatus({
    required String reciterId,
    required int surahNumber,
  }) async {
    final entries = await _manifestService.getEntriesBySurah(reciterId, surahNumber);

    if (entries.isEmpty) {
      // Manifest is empty for this surah, sync from disk (lazy indexing)
      return _syncManifestForSurah(reciterId, surahNumber);
    }

    int downloaded = 0;
    int size = 0;

    for (final entry in entries) {
      if (entry.status == DownloadStatus.completed) {
        downloaded++;
        size += entry.expectedSize;
      }
    }

    final isDownloading = _activeDownloads.contains(
      '${reciterId}_$surahNumber',
    );
    final isStopping = isDownloading && _cancellationFlags[reciterId] == true;

    return SurahDownloadStatus(
      isDownloaded: downloaded == entries.length && entries.isNotEmpty,
      isDownloading: isDownloading && !isStopping,
      isStopping: isStopping,
      sizeInBytes: size,
      downloadedAyahs: downloaded,
      totalAyahs: entries.length,
    );
  }

  Future<SurahDownloadStatus> _syncManifestForSurah(
    String reciterId,
    int surahNumber,
  ) async {
    final quality = _settingsRepository.audioQuality;
    final tracksResult = await _audioRepository.getSurahAudioTracks(
      reciterId: reciterId,
      surahNumber: surahNumber,
      ayahCount: _audioRepository.getAyahCount(surahNumber),
      quality: quality,
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
    int downloadedCount = 0;
    int totalSize = 0;

    for (int i = 0; i < tracks.length; i++) {
      final track = tracks[i];
      final ayahNumber = i + 1;
      final isValid = await FileDownloadUtils.isValidAudioFile(track.localPath);
      final actualSize = await FileDownloadUtils.getExistingFileSizeBytes(track.localPath);

      // Status logic:
      // If isValid is true, it means it's complete (passed syncword check).
      // If actualSize > 0 but not isValid, it's a partial download.
      final DownloadStatus status;
      if (isValid) {
        status = DownloadStatus.completed;
      } else if (actualSize > 0) {
        status = DownloadStatus.paused; // Resumable state
      } else {
        status = DownloadStatus.pending;
      }

      final entry = DownloadEntry(
        fileId: 'audio_${reciterId}_${surahNumber}_$ayahNumber',
        relativePath: track.localPath.split('audio/').last,
        contentType: 'audio',
        url: track.remoteUrl,
        // If completed, we know the size. Otherwise, set to 0 to be updated during download.
        expectedSize: isValid ? actualSize : 0,
        downloadedBytes: actualSize,
        status: status,
        updatedAt: DateTime.now(),
        reciterId: reciterId,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
      );

      await _manifestService.upsertEntry(entry);

      if (isValid) {
        downloadedCount++;
        totalSize += actualSize;
      }
    }

    return SurahDownloadStatus(
      isDownloaded: downloadedCount == tracks.length && tracks.isNotEmpty,
      isDownloading: _activeDownloads.contains('${reciterId}_$surahNumber'),
      sizeInBytes: totalSize,
      downloadedAyahs: downloadedCount,
      totalAyahs: tracks.length,
    );
  }

  @override
  Future<double> getReciterDownloadPercentage(String reciterId) async {
    try {
      final directory = await getApplicationSupportDirectory();
      final reciterDir = Directory('${directory.path}/audio/$reciterId');

      if (!await reciterDir.exists()) return 0.0;

      final files = await reciterDir.list().length;
      // Total ayahs in Quran is exactly 6236.
      // Since we reuse Surah 1 Ayah 1 (001001.mp3) as the Bismillah for all other surahs,
      // the total number of unique files is exactly 6236.
      const totalPossibleFiles = 6236;

      return (files / totalPossibleFiles).clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  @override
  Future<int> getReciterDownloadedSize(String reciterId) async {
    try {
      final directory = await getApplicationSupportDirectory();
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
    final entries = await _manifestService.getEntriesByReciter(reciterId);

    if (entries.isEmpty) {
      // If manifest is empty, return initial state. 
      // We don't want to sync all 114 surahs here as it would be too slow.
      // Syncing will happen lazily when surah status is requested or download starts.
      return const ReciterDownloadStatus(
        downloadedSurahs: 0,
        totalSurahs: 114,
        totalSizeInBytes: 0,
      );
    }

    int downloadedSurahs = 0;
    int totalSize = 0;

    // Group by surah to count completed ones
    final Map<int, bool> surahStatus = {};
    for (final entry in entries) {
      if (entry.surahNumber == null) continue;
      
      final currentStatus = surahStatus[entry.surahNumber!] ?? true;
      surahStatus[entry.surahNumber!] = currentStatus && (entry.status == DownloadStatus.completed);
      
      if (entry.status == DownloadStatus.completed) {
        totalSize += entry.expectedSize;
      }
    }

    downloadedSurahs = surahStatus.values.where((completed) => completed).length;

    return ReciterDownloadStatus(
      downloadedSurahs: downloadedSurahs,
      totalSurahs: 114,
      totalSizeInBytes: totalSize,
    );
  }

  @override
  Future<List<Reciter>> getRecitersWithDownloadedSurah(int surahNumber) async {
    final allEntries = await _manifestService.getEntriesByContentType('audio');
    final reciterIds = allEntries
        .where((e) => e.surahNumber == surahNumber && e.status == DownloadStatus.completed)
        .map((e) => e.reciterId)
        .whereType<String>()
        .toSet();

    if (reciterIds.isEmpty) return [];

    final recitersResult = await _audioRepository.getCachedReciters();
    if (recitersResult.isFailure) return [];

    final Map<String, List<int>> reciterStatus = {};
    for (final entry in allEntries) {
      if (entry.surahNumber != surahNumber || entry.reciterId == null) continue;
      
      final list = reciterStatus.putIfAbsent(entry.reciterId!, () => []);
      if (entry.status == DownloadStatus.completed) {
        list.add(entry.ayahNumber ?? 0);
      }
    }

    final availableReciters = <Reciter>[];
    for (final id in reciterIds) {
      final reciter = recitersResult.data!.firstWhere((r) => r.identifier == id, orElse: () => const Reciter(identifier: '', name: '', englishName: '', language: ''));
      if (reciter.identifier.isEmpty) continue;

      final downloadedAyahs = reciterStatus[id] ?? [];
      final totalAyahs = _audioRepository.getAyahCount(surahNumber);
      
      if (downloadedAyahs.length >= totalAyahs) {
        availableReciters.add(reciter);
      }
    }

    return availableReciters;
  }

  @override
  Future<Set<int>> getDownloadedSurahIdsForReciter(String reciterId) async {
    final entries = await _manifestService.getEntriesByReciter(reciterId);
    if (entries.isEmpty) return {};

    final Map<int, Set<int>> surahAyahs = {};
    for (final entry in entries) {
      if (entry.surahNumber == null || entry.ayahNumber == null) continue;
      if (entry.status == DownloadStatus.completed) {
        surahAyahs.putIfAbsent(entry.surahNumber!, () => {}).add(entry.ayahNumber!);
      }
    }

    final downloadedSurahs = <int>{};
    surahAyahs.forEach((surahNum, ayahs) {
      final total = _audioRepository.getAyahCount(surahNum);
      if (ayahs.length >= total) {
        downloadedSurahs.add(surahNum);
      }
    });

    return downloadedSurahs;
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
