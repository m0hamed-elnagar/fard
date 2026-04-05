import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/entities/audio_track.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:quran/quran.dart' as quran;

part 'audio_event.dart';
part 'audio_state.dart';

@injectable
class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioRepository audioRepository;
  final AudioPlayerService playerService;
  final AudioDownloadService downloadService;
  final SettingsRepository settingsRepository;

  StreamSubscription? _statusSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _indexSubscription;

  AudioBloc({
    required this.audioRepository,
    required this.playerService,
    required this.downloadService,
    required this.settingsRepository,
  }) : super(const AudioState()) {
    on<AudioEvent>((event, emit) async {
      debugPrint('AudioBloc: Event received: $event');
      await event.map<Future<void>>(
        loadReciters: (e) => _onLoadReciters(emit),
        selectReciter: (e) => _onSelectReciter(e.reciter, emit),
        playAyah: (e) =>
            _onPlayAyah(e.surahNumber, e.ayahNumber, e.reciter, emit),
        playSurah: (e) => _onPlaySurah(
          e.surahNumber,
          e.reciter,
          e.startAyah,
          e.ayahCount,
          emit,
        ),
        togglePlayback: (e) => _onTogglePlayback(emit),
        pause: (e) => _onPause(emit),
        resume: (e) => _onResume(emit),
        stop: (e) => _onStop(emit),
        seekTo: (e) => _onSeekTo(e.position, emit),
        skipToNext: (e) => _onSkipToNext(emit),
        skipToPrevious: (e) => _onSkipToPrevious(emit),
        changeSpeed: (e) => _onChangeSpeed(e.speed, emit),
        toggleRepeat: (e) => _onToggleRepeat(emit),
        changePlaybackMode: (e) => _onChangePlaybackMode(e.mode, emit),
        changeQuality: (e) => _onChangeQuality(e.quality, emit),
        hideBanner: (e) => _onHideBanner(emit),
        showBanner: (e) => _onShowBanner(emit),
        statusChanged: (e) async => _onStatusChanged(e.status, emit),
        lastErrorChanged: (e) async => _onLastErrorChanged(e.error, emit),
        positionChanged: (e) async => _onPositionChanged(e.position, emit),
        durationChanged: (e) async => _onDurationChanged(e.duration, emit),
        indexChanged: (e) async => _onIndexChanged(index: e.index, emit: emit),
        updateCurrentPosition: (e) async =>
            _onUpdateCurrentPosition(e.surahNumber, e.ayahNumber, emit),
        refreshReciterStatuses: (e) => _onLoadReciters(emit),
      );
    });

    _statusSubscription = playerService.watchStatus().listen((status) {
      add(AudioEvent.statusChanged(status));
    });

    _errorSubscription = playerService.watchError().listen((error) {
      add(AudioEvent.lastErrorChanged(error));
    });

    _positionSubscription = playerService.watchPosition().listen((position) {
      add(AudioEvent.positionChanged(position));
    });

    _durationSubscription = playerService.watchDuration().listen((duration) {
      if (duration != null) {
        add(AudioEvent.durationChanged(duration));
      }
    });

    _indexSubscription = playerService.watchCurrentIndex().listen((index) {
      add(AudioEvent.indexChanged(index));
    });

    // Initialize with current state
    if (playerService.currentStatus != AudioStatus.idle) {
      add(AudioEvent.statusChanged(playerService.currentStatus));
      add(AudioEvent.changePlaybackMode(playerService.currentMode));
      add(AudioEvent.positionChanged(playerService.currentPosition));
      if (playerService.currentDuration != null) {
        add(AudioEvent.durationChanged(playerService.currentDuration!));
      }
      if (playerService.currentIndex != null) {
        add(AudioEvent.indexChanged(playerService.currentIndex));
      }
    }

    // Initial load
    add(AudioEvent.loadReciters());
  }

  Future<void> _onLoadReciters(Emitter<AudioState> emit) async {
    // 1. Helper to sort and emit
    void emitSorted(
      List<Reciter> reciters,
      Map<String, double> progress,
      Map<String, int> sizes,
    ) {
      final sortedReciters = List<Reciter>.from(reciters);
      sortedReciters.sort((a, b) {
        final pA = progress[a.identifier] ?? 0.0;
        final pB = progress[b.identifier] ?? 0.0;
        if (pB != pA) return pB.compareTo(pA);
        return a.englishName.compareTo(b.englishName);
      });

      emit(
        state.copyWith(
          availableReciters: sortedReciters,
          reciterDownloadProgress: progress,
          reciterDownloadSizes: sizes,
          currentReciter: state.currentReciter ?? sortedReciters.firstOrNull,
          error: null,
        ),
      );
    }

    // 2. Load cached reciters AND data immediately
    final cachedRecitersResult = await audioRepository.getCachedReciters();
    final cachedData = await audioRepository.getCachedReciterData();

    List<Reciter> currentReciters = [];

    if (cachedRecitersResult.isSuccess &&
        cachedRecitersResult.data!.isNotEmpty) {
      currentReciters = cachedRecitersResult.data!;
      emitSorted(currentReciters, cachedData.progress, cachedData.sizes);
    }

    // 3. Fetch fresh reciters list
    final freshRecitersResult = await audioRepository.getAvailableReciters();
    freshRecitersResult.fold(
      (failure) {
        if (state.availableReciters.isEmpty) {
          emit(state.copyWith(error: failure.message));
        }
      },
      (reciters) {
        currentReciters = reciters;
        // Don't emit yet, wait for data check
      },
    );

    if (currentReciters.isEmpty) return;

    // 4. Calculate fresh data in background
    final freshProgress = <String, double>{};
    final freshSizes = <String, int>{};

    await Future.wait(
      currentReciters.map((r) async {
        freshProgress[r.identifier] = await downloadService
            .getReciterDownloadPercentage(r.identifier);
        freshSizes[r.identifier] = await downloadService
            .getReciterDownloadedSize(r.identifier);
      }),
    );

    // 5. Check if data changed
    bool hasChanged = false;

    // Check lengths
    if (freshProgress.length != cachedData.progress.length ||
        freshSizes.length != cachedData.sizes.length) {
      hasChanged = true;
    } else {
      // Check values
      for (final id in freshProgress.keys) {
        if ((freshProgress[id] ?? 0) != (cachedData.progress[id] ?? 0) ||
            (freshSizes[id] ?? 0) != (cachedData.sizes[id] ?? 0)) {
          hasChanged = true;
          break;
        }
      }
    }

    // 6. Only re-emit if data changed
    if (hasChanged) {
      await audioRepository.cacheReciterData(freshProgress, freshSizes);
      emitSorted(currentReciters, freshProgress, freshSizes);
    } else if (state.availableReciters.length != currentReciters.length) {
      // Also re-emit if only the list of reciters changed (e.g. new ones added)
      // but their download data is effectively 0 for the new ones
      emitSorted(currentReciters, freshProgress, freshSizes);
    }
  }

  Future<void> _onSelectReciter(
    Reciter reciter,
    Emitter<AudioState> emit,
  ) async {
    emit(state.copyWith(currentReciter: reciter));
    await audioRepository.cacheReciters(state.availableReciters);

    // If already playing or paused, restart with new reciter
    if (state.isActive &&
        state.currentSurah != null &&
        state.currentAyah != null) {
      if (state.mode == AudioPlayMode.surah) {
        add(
          AudioEvent.playSurah(
            surahNumber: state.currentSurah!,
            startAyah: state.currentAyah!,
            reciter: reciter,
          ),
        );
      } else {
        add(
          AudioEvent.playAyah(
            surahNumber: state.currentSurah!,
            ayahNumber: state.currentAyah!,
            reciter: reciter,
          ),
        );
      }
    }
  }

  Future<void> _onPlayAyah(
    int surahNumber,
    int ayahNumber,
    Reciter? reciter,
    Emitter<AudioState> emit,
  ) async {
    final activeReciter = reciter ?? state.currentReciter;
    if (activeReciter == null) return;

    // Stop existing playback first to ensure a clean state
    await playerService.stop();

    emit(
      state.copyWith(
        status: AudioStatus.loading,
        currentSurah: surahNumber,
        currentAyah: ayahNumber,
        currentReciter: activeReciter,
        mode: AudioPlayMode.ayah,
        isBannerVisible: true,
        error: null,
        lastErrorMessage: null,
      ),
    );

    final track = await audioRepository.getAyahAudioTrack(
      reciterId: activeReciter.identifier,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      quality: state.quality,
    );

    final bool isPrependActive =
        ayahNumber == 1 &&
        audioRepository.shouldPrependBismillah(
          surahNumber,
          activeReciter.identifier,
        );

    final currentLanguage = settingsRepository.locale.languageCode;
    final isArabic = currentLanguage == 'ar';

    final surahName = isArabic
        ? quran.getSurahNameArabic(surahNumber)
        : quran.getSurahName(surahNumber);
    final reciterName = isArabic
        ? activeReciter.name
        : activeReciter.englishName;
    final ayahLabel = isArabic ? "الآية" : "Ayah";
    final bismillahLabel = isArabic ? "بسم الله الرحمن الرحيم" : "Bismillah";
    final surahLabel = isArabic ? "سورة" : "Surah";

    AudioTrack? bismillahTrack;
    if (isPrependActive) {
      bismillahTrack = await audioRepository.getAyahAudioTrack(
        reciterId: activeReciter.identifier,
        surahNumber: 1,
        ayahNumber: 1,
        quality: state.quality,
      );
    }

    final result = isPrependActive && bismillahTrack != null
        ? await playerService.playPlaylist(
            [bismillahTrack, track],
            mode: AudioPlayMode.ayah,
            metadataList: [
              {
                'title': '$surahLabel $surahName: $bismillahLabel',
                'artist': reciterName,
                'album': surahName,
              },
              {
                'title': '$surahLabel $surahName: $ayahLabel $ayahNumber',
                'artist': reciterName,
                'album': surahName,
              },
            ],
          )
        : await playerService.playStreaming(
            track,
            mode: AudioPlayMode.ayah,
            metadata: {
              'title': '$surahLabel $surahName: $ayahLabel $ayahNumber',
              'artist': reciterName,
              'album': surahName,
            },
          );

    result.fold((failure) async {
      final errorMessage = failure.message;
      final isPluginError = errorMessage.contains('MissingPluginException');

      add(AudioEvent.lastErrorChanged(errorMessage));

      if (!isPluginError && state.quality == AudioQuality.high192) {
        emit(
          state.copyWith(
            error: "192k not available for this reciter. Trying 128k...",
          ),
        );
        add(AudioEvent.changeQuality(AudioQuality.medium128));
      } else if (!isPluginError && state.quality == AudioQuality.medium128) {
        emit(state.copyWith(error: "128k failed. Trying 64k..."));
        add(AudioEvent.changeQuality(AudioQuality.low64));
      } else {
        emit(
          state.copyWith(
            error: isPluginError
                ? "Audio plugin missing. Please rebuild the app."
                : "Playback failed: $errorMessage",
            status: AudioStatus.error,
          ),
        );
      }
    }, (_) => null);
  }

  Future<void> _onPlaySurah(
    int surahNumber,
    Reciter? reciter,
    int? startAyah,
    int? ayahCount,
    Emitter<AudioState> emit,
  ) async {
    final activeReciter = reciter ?? state.currentReciter;
    if (activeReciter == null) return;

    await playerService.stop();

    emit(
      state.copyWith(
        status: AudioStatus.loading,
        currentSurah: surahNumber,
        currentAyah: startAyah ?? 1,
        currentReciter: activeReciter,
        mode: AudioPlayMode.surah,
        isBannerVisible: true,
        error: null,
        lastErrorMessage: null,
      ),
    );

    final tracksResult = await audioRepository.getSurahAudioTracks(
      reciterId: activeReciter.identifier,
      surahNumber: surahNumber,
      ayahCount: ayahCount,
      quality: state.quality,
    );

    await tracksResult.fold(
      (failure) async => emit(
        state.copyWith(error: failure.message, status: AudioStatus.error),
      ),
      (tracks) async {
        final bool isPrependActive = audioRepository.shouldPrependBismillah(
          surahNumber,
          activeReciter.identifier,
        );

        int initialIndex = (startAyah ?? 1) - 1;
        if (isPrependActive) {
          if (startAyah == null || startAyah == 1) {
            initialIndex = 0;
          } else {
            initialIndex = startAyah;
          }
        }

        final currentLanguage = settingsRepository.locale.languageCode;
        final isArabic = currentLanguage == 'ar';

        final surahName = isArabic
            ? quran.getSurahNameArabic(surahNumber)
            : quran.getSurahName(surahNumber);
        final reciterName = isArabic
            ? activeReciter.name
            : activeReciter.englishName;
        final ayahLabel = isArabic ? "الآية" : "Ayah";
        final bismillahLabel = isArabic
            ? "بسم الله الرحمن الرحيم"
            : "Bismillah";
        final surahLabel = isArabic ? "سورة" : "Surah";

        final metadataList = <Map<String, dynamic>>[];
        for (var i = 0; i < tracks.length; i++) {
          if (isPrependActive && i == 0) {
            metadataList.add({
              'title': '$surahLabel $surahName: $bismillahLabel',
              'artist': reciterName,
              'album': surahName,
            });
          } else {
            final displayAyah = isPrependActive ? i : i + 1;
            metadataList.add({
              'title': '$surahLabel $surahName: $ayahLabel $displayAyah',
              'artist': reciterName,
              'album': surahName,
            });
          }
        }

        final result = await playerService.playPlaylist(
          tracks,
          initialIndex: initialIndex,
          mode: AudioPlayMode.surah,
          metadataList: metadataList,
        );
        result.fold((failure) async {
          final errorMessage = failure.message;
          final isPluginError = errorMessage.contains('MissingPluginException');

          add(AudioEvent.lastErrorChanged(errorMessage));

          if (!isPluginError && state.quality == AudioQuality.high192) {
            emit(state.copyWith(error: "192k not available. Trying 128k..."));
            add(AudioEvent.changeQuality(AudioQuality.medium128));
          } else if (!isPluginError &&
              state.quality == AudioQuality.medium128) {
            emit(state.copyWith(error: "128k failed. Trying 64k..."));
            add(AudioEvent.changeQuality(AudioQuality.low64));
          } else {
            emit(
              state.copyWith(
                error: isPluginError
                    ? "Audio plugin missing. Please rebuild the app."
                    : "Playback failed: $errorMessage",
                status: AudioStatus.error,
              ),
            );
          }
        }, (_) => null);
      },
    );
  }

  Future<void> _onTogglePlayback(Emitter<AudioState> emit) async {
    if (state.isPlaying) {
      await playerService.pause();
    } else if (state.status == AudioStatus.paused) {
      await playerService.resume();
    } else {
      if (state.currentSurah != null) {
        if (state.mode == AudioPlayMode.surah) {
          add(
            AudioEvent.playSurah(
              surahNumber: state.currentSurah!,
              startAyah: state.currentAyah ?? 1,
              reciter: state.currentReciter,
            ),
          );
        } else {
          add(
            AudioEvent.playAyah(
              surahNumber: state.currentSurah!,
              ayahNumber: state.currentAyah ?? 1,
              reciter: state.currentReciter,
            ),
          );
        }
      }
    }
  }

  Future<void> _onPause(Emitter<AudioState> emit) async {
    await playerService.pause();
  }

  Future<void> _onResume(Emitter<AudioState> emit) async {
    await playerService.resume();
  }

  Future<void> _onStop(Emitter<AudioState> emit) async {
    await playerService.stop();
    emit(state.copyWith(isBannerVisible: false, error: null));
  }

  Future<void> _onSeekTo(Duration position, Emitter<AudioState> emit) async {
    await playerService.seek(position);
  }

  Future<void> _onSkipToNext(Emitter<AudioState> emit) async {
    await playerService.skipToNext();
  }

  Future<void> _onSkipToPrevious(Emitter<AudioState> emit) async {
    await playerService.skipToPrevious();
  }

  Future<void> _onHideBanner(Emitter<AudioState> emit) async {
    emit(
      state.copyWith(
        isBannerVisible: false,
        error: null,
        lastErrorMessage: null,
      ),
    );
  }

  Future<void> _onShowBanner(Emitter<AudioState> emit) async {
    emit(state.copyWith(isBannerVisible: true));
  }

  Future<void> _onChangeSpeed(double speed, Emitter<AudioState> emit) async {
    emit(state.copyWith(speed: speed));
    await playerService.setSpeed(speed);
  }

  Future<void> _onToggleRepeat(Emitter<AudioState> emit) async {
    final newValue = !state.isRepeating;
    emit(state.copyWith(isRepeating: newValue));
    await playerService.setLoopMode(newValue);
  }

  Future<void> _onChangePlaybackMode(
    AudioPlayMode mode,
    Emitter<AudioState> emit,
  ) async {
    emit(state.copyWith(mode: mode));
    playerService.setMode(mode);
  }

  Future<void> _onChangeQuality(
    AudioQuality quality,
    Emitter<AudioState> emit,
  ) async {
    emit(state.copyWith(quality: quality));

    if (state.isActive &&
        state.currentSurah != null &&
        state.currentAyah != null) {
      if (state.mode == AudioPlayMode.surah) {
        add(
          AudioEvent.playSurah(
            surahNumber: state.currentSurah!,
            startAyah: state.currentAyah!,
            reciter: state.currentReciter,
          ),
        );
      } else {
        add(
          AudioEvent.playAyah(
            surahNumber: state.currentSurah!,
            ayahNumber: state.currentAyah!,
            reciter: state.currentReciter,
          ),
        );
      }
    }
  }

  void _onStatusChanged(AudioStatus status, Emitter<AudioState> emit) {
    final shouldShowBanner =
        status != AudioStatus.idle &&
        status != AudioStatus.stopped &&
        status != state.status;

    emit(
      state.copyWith(
        status: status,
        error: status == AudioStatus.error
            ? (state.error ?? "Playback Error")
            : null,
        lastErrorMessage: status == AudioStatus.error
            ? state.lastErrorMessage
            : null,
        isBannerVisible: shouldShowBanner ? true : state.isBannerVisible,
      ),
    );
  }

  void _onLastErrorChanged(String? error, Emitter<AudioState> emit) {
    emit(state.copyWith(lastErrorMessage: error));
  }

  void _onPositionChanged(Duration position, Emitter<AudioState> emit) {
    emit(state.copyWith(position: position));
  }

  void _onDurationChanged(Duration duration, Emitter<AudioState> emit) {
    emit(state.copyWith(duration: duration));
  }

  void _onIndexChanged({int? index, required Emitter<AudioState> emit}) {
    if (index != null &&
        state.mode == AudioPlayMode.surah &&
        state.currentSurah != null &&
        state.currentReciter != null) {
      final bool isPrependActive = audioRepository.shouldPrependBismillah(
        state.currentSurah!,
        state.currentReciter!.identifier,
      );

      if (isPrependActive) {
        if (index == 0) {
          emit(state.copyWith(currentAyah: 1));
        } else {
          emit(state.copyWith(currentAyah: index));
        }
      } else {
        emit(state.copyWith(currentAyah: index + 1));
      }
    }
  }

  void _onUpdateCurrentPosition(
    int surahNumber,
    int? ayahNumber,
    Emitter<AudioState> emit,
  ) {
    if (state.isActive) {
      return;
    }

    if (state.currentSurah == surahNumber && state.currentAyah == ayahNumber) {
      return;
    }
    emit(state.copyWith(currentSurah: surahNumber, currentAyah: ayahNumber));
  }

  @override
  Future<void> close() async {
    await _statusSubscription?.cancel();
    await _errorSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _indexSubscription?.cancel();
    return super.close();
  }
}
