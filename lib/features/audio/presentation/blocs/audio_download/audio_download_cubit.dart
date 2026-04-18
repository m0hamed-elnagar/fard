import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:fard/features/audio/presentation/blocs/audio_download/audio_download_state.dart';

@injectable
class AudioDownloadCubit extends Cubit<AudioDownloadState> {
  final AudioDownloadService _downloadService;
  StreamSubscription? _progressSubscription;

  AudioDownloadCubit(this._downloadService)
    : super(const AudioDownloadState()) {
    _progressSubscription = _downloadService.progressStream.listen(_onProgress);
  }

  int _currentLoadId = 0;

  void init(Reciter reciter) {
    _currentLoadId++;
    emit(
      state.copyWith(
        isLoading: true,
        activeReciterId:
            reciter.identifier, // Tracks which reciter page is open
      ),
    );
    _loadStatuses(reciter, _currentLoadId);
  }

  Future<void> _loadStatuses(Reciter reciter, int loadId) async {
    final statuses = <int, SurahDownloadStatus>{};

    // Load in chunks to avoid UI jank
    const int chunkSize = 20;
    for (int i = 1; i <= 114; i += chunkSize) {
      if (loadId != _currentLoadId) return;

      final futures = <Future<void>>[];
      for (int j = 0; j < chunkSize && (i + j) <= 114; j++) {
        final surahNum = i + j;
        futures.add(() async {
          final status = await _downloadService.getSurahStatus(
            reciterId: reciter.identifier,
            surahNumber: surahNum,
          );
          statuses[surahNum] = status;
        }());
      }
      await Future.wait(futures);

      if (loadId != _currentLoadId) return;

      // Merge carefully: don't overwrite "Downloading" or "Stopping" states
      // if they were set by optimistic updates or progress events while we were loading
      final currentStatuses = Map<int, SurahDownloadStatus>.from(
        state.surahStatuses,
      );
      statuses.forEach((key, newStatus) {
        final existing = currentStatuses[key];
        if (existing == null ||
            (!existing.isDownloading && !existing.isStopping)) {
          currentStatuses[key] = newStatus;
        }
      });

      emit(state.copyWith(surahStatuses: currentStatuses));
    }

    if (loadId == _currentLoadId) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> downloadSurah(Reciter reciter, int surahNumber) async {
    // Optimistic update
    final currentStatus = state.surahStatuses[surahNumber];
    if (currentStatus != null) {
      final newStatuses = Map<int, SurahDownloadStatus>.from(
        state.surahStatuses,
      );
      newStatuses[surahNumber] = currentStatus.copyWith(
        isDownloading: true,
        isStopping: false,
      );
      emit(state.copyWith(surahStatuses: newStatuses));
    }

    await _downloadService.downloadSurah(
      reciter: reciter,
      surahNumber: surahNumber,
    );
  }

  Future<void> downloadReciter(Reciter reciter) async {
    // Optimistic update for all surahs
    final newStatuses = Map<int, SurahDownloadStatus>.from(state.surahStatuses);
    bool changed = false;
    for (int i = 1; i <= 114; i++) {
      final s = newStatuses[i];
      if (s != null && !s.isDownloaded && !s.isDownloading) {
        newStatuses[i] = s.copyWith(isDownloading: true, isStopping: false);
        changed = true;
      }
    }
    if (changed) emit(state.copyWith(surahStatuses: newStatuses));

    await _downloadService.downloadReciter(reciter: reciter);
  }

  Future<void> cancelDownload(Reciter reciter, int? surahNumber) async {
    // Optimistic "Stopping" state
    final newStatuses = Map<int, SurahDownloadStatus>.from(state.surahStatuses);
    bool changed = false;
    
    if (surahNumber != null) {
      final s = newStatuses[surahNumber];
      if (s != null && s.isDownloading) {
        newStatuses[surahNumber] = s.copyWith(isStopping: true);
        changed = true;
      }
    } else {
      for (int i = 1; i <= 114; i++) {
        final s = newStatuses[i];
        if (s != null && s.isDownloading) {
          newStatuses[i] = s.copyWith(isStopping: true);
          changed = true;
        }
      }
    }
    
    if (changed) emit(state.copyWith(surahStatuses: newStatuses));

    await _downloadService.cancelDownload(reciter.identifier, surahNumber);

    // Refresh to ensure final states are correct after service stops
    _currentLoadId++;
    await _loadStatuses(reciter, _currentLoadId);
  }

  Future<void> deleteSurah(Reciter reciter, int surahNumber) async {
    await _downloadService.deleteSurah(
      reciterId: reciter.identifier,
      surahNumber: surahNumber,
    );
    // Reload status for this surah
    final status = await _downloadService.getSurahStatus(
      reciterId: reciter.identifier,
      surahNumber: surahNumber,
    );
    final newStatuses = Map<int, SurahDownloadStatus>.from(state.surahStatuses);
    newStatuses[surahNumber] = status;
    emit(state.copyWith(surahStatuses: newStatuses));
  }

  Future<void> deleteReciter(Reciter reciter) async {
    emit(state.copyWith(isLoading: true));
    await _downloadService.deleteReciter(reciterId: reciter.identifier);
    // Reload all
    _currentLoadId++;
    await _loadStatuses(reciter, _currentLoadId);
  }

  void _onProgress(DownloadProgress progress) {
    if (state.activeReciterId == progress.reciterId) {
      final surahNum = progress.surahNumber;

      if (surahNum != null) {
        final newStatuses = Map<int, SurahDownloadStatus>.from(
          state.surahStatuses,
        );
        final current = newStatuses[surahNum];

        final size = current?.sizeInBytes ?? 0;
        final total = progress.totalFiles;

        // Preserve isStopping state if it was set optimistically or by a previous event
        // But clear it if we just received a completion or an error (which happens when stopped)
        final isStopping =
            (current?.isStopping ?? false) &&
            !progress.isCompleted &&
            progress.error == null;

        newStatuses[surahNum] = SurahDownloadStatus(
          isDownloaded: progress.isCompleted,
          isDownloading:
              !progress.isCompleted && progress.error == null && !isStopping,
          isStopping: isStopping,
          sizeInBytes: size,
          downloadedAyahs: progress.downloadedFiles,
          totalAyahs: total,
        );

        emit(
          state.copyWith(
            surahStatuses: newStatuses,
            activeSurahNumber: surahNum,
            progress: progress.percentage,
          ),
        );
      }
    }
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}
