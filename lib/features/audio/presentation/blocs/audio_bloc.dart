import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';

part 'audio_event.dart';
part 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioRepository audioRepository;
  final AudioPlayerService playerService;
  
  StreamSubscription? _statusSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _indexSubscription;

  AudioBloc({
    required this.audioRepository,
    required this.playerService,
  }) : super(const AudioState()) {
    
    on<AudioEvent>((event, emit) async {
      debugPrint('AudioBloc: Event received: $event');
      await event.map<Future<void>>(
        loadReciters: (e) => _onLoadReciters(emit),
        selectReciter: (e) => _onSelectReciter(e.reciter, emit),
        playAyah: (e) => _onPlayAyah(e.surahNumber, e.ayahNumber, e.reciter, emit),
        playSurah: (e) => _onPlaySurah(e.surahNumber, e.reciter, e.startAyah, e.ayahCount, emit),
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
        statusChanged: (e) async => _onStatusChanged(e.status, emit),
        lastErrorChanged: (e) async => _onLastErrorChanged(e.error, emit),
        positionChanged: (e) async => _onPositionChanged(e.position, emit),
        durationChanged: (e) async => _onDurationChanged(e.duration, emit),
        indexChanged: (e) async => _onIndexChanged(e.index, emit),
        updateCurrentPosition: (e) async => _onUpdateCurrentPosition(e.surahNumber, e.ayahNumber, emit),
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
    // Try cached first
    final cachedResult = await audioRepository.getCachedReciters();
    if (cachedResult.isSuccess && cachedResult.data!.isNotEmpty) {
      emit(state.copyWith(
        availableReciters: cachedResult.data!,
        currentReciter: cachedResult.data!.firstWhere(
          (r) => r.identifier == 'ar.alafasy', 
          orElse: () => cachedResult.data!.first,
        ),
      ));
    }

    final result = await audioRepository.getAvailableReciters();
    result.fold(
      (failure) {
        if (state.availableReciters.isEmpty) {
          emit(state.copyWith(error: failure.message));
        }
      },
      (reciters) {
        emit(state.copyWith(
          availableReciters: reciters,
          currentReciter: state.currentReciter ?? reciters.firstWhere(
            (r) => r.identifier == 'ar.alafasy', 
            orElse: () => reciters.first,
          ),
          error: null,
        ));
      },
    );
  }

  Future<void> _onSelectReciter(Reciter reciter, Emitter<AudioState> emit) async {
    emit(state.copyWith(currentReciter: reciter));
    await audioRepository.cacheReciters(state.availableReciters);

    // If already playing or paused, restart with new reciter
    if (state.isActive && state.currentSurah != null && state.currentAyah != null) {
      if (state.mode == AudioPlayMode.surah) {
        add(AudioEvent.playSurah(
          surahNumber: state.currentSurah!,
          startAyah: state.currentAyah!,
          reciter: reciter,
        ));
      } else {
        add(AudioEvent.playAyah(
          surahNumber: state.currentSurah!,
          ayahNumber: state.currentAyah!,
          reciter: reciter,
        ));
      }
    }
  }

  Future<void> _onPlayAyah(int surahNumber, int ayahNumber, Reciter? reciter, Emitter<AudioState> emit) async {
    final activeReciter = reciter ?? state.currentReciter;
    if (activeReciter == null) return;

    // Stop existing playback first to ensure a clean state
    await playerService.stop();

    emit(state.copyWith(
      status: AudioStatus.loading,
      currentSurah: surahNumber,
      currentAyah: ayahNumber,
      currentReciter: activeReciter,
      mode: AudioPlayMode.ayah,
      isBannerVisible: true,
      error: null, // Clear previous error
    ));

    final url = audioRepository.getAyahAudioUrl(
      reciterId: activeReciter.identifier,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      quality: state.quality,
    );

    final bool isPrependActive = ayahNumber == 1 && audioRepository.shouldPrependBismillah(surahNumber, activeReciter.identifier);

    final result = isPrependActive 
      ? await playerService.playPlaylist(
          [
            audioRepository.getAyahAudioUrl(
              reciterId: activeReciter.identifier,
              surahNumber: 1,
              ayahNumber: 1,
              quality: state.quality,
            ),
            url,
          ],
          mode: AudioPlayMode.ayah,
        )
      : await playerService.playStreaming(url, mode: AudioPlayMode.ayah);
      
    result.fold(
      (failure) async {
        final errorMessage = failure.message;
        final isPluginError = errorMessage.contains('MissingPluginException');
        
        add(AudioEvent.lastErrorChanged(errorMessage));
        
        // Fallback logic: Try lower quality if possible, unless it's a plugin error
        if (!isPluginError && state.quality == AudioQuality.high192) {
           emit(state.copyWith(error: "192k not available for this reciter. Trying 128k..."));
           add(AudioEvent.changeQuality(AudioQuality.medium128));
        } else if (!isPluginError && state.quality == AudioQuality.medium128) {
           emit(state.copyWith(error: "128k failed. Trying 64k..."));
           add(AudioEvent.changeQuality(AudioQuality.low64));
        } else {
           emit(state.copyWith(
             error: isPluginError ? "Audio plugin missing. Please rebuild the app." : "Playback failed: $errorMessage", 
             status: AudioStatus.error,
           ));
        }
      },
      (_) => null,
    );
  }

  Future<void> _onPlaySurah(int surahNumber, Reciter? reciter, int? startAyah, int? ayahCount, Emitter<AudioState> emit) async {
    final activeReciter = reciter ?? state.currentReciter;
    if (activeReciter == null) return;

    // Stop existing playback first to ensure a clean state
    await playerService.stop();

    emit(state.copyWith(
      status: AudioStatus.loading,
      currentSurah: surahNumber,
      currentAyah: startAyah ?? 1,
      currentReciter: activeReciter,
      mode: AudioPlayMode.surah,
      isBannerVisible: true,
      error: null, // Clear previous error
    ));

    final urlsResult = await audioRepository.getSurahAudioUrls(
      reciterId: activeReciter.identifier,
      surahNumber: surahNumber,
      ayahCount: ayahCount,
      quality: state.quality,
    );

    await urlsResult.fold(
      (failure) async => emit(state.copyWith(error: failure.message, status: AudioStatus.error)),
      (urls) async {
        final bool isPrependActive = audioRepository.shouldPrependBismillah(
          surahNumber, 
          activeReciter.identifier,
        );
        
        int initialIndex = (startAyah ?? 1) - 1;
        if (isPrependActive) {
          // If Bismillah was prepended, index 0 is Bismillah, index 1 is Ayah 1, etc.
          if (startAyah == null || startAyah == 1) {
            initialIndex = 0; // Play Bismillah first
          } else {
            initialIndex = startAyah; // Offset by 1 (e.g. Ayah 2 is now at index 2)
          }
        }

        final result = await playerService.playPlaylist(
          urls, 
          initialIndex: initialIndex,
          mode: AudioPlayMode.surah,
        );
        result.fold(
          (failure) async {
             final errorMessage = failure.message;
             final isPluginError = errorMessage.contains('MissingPluginException');
             
             add(AudioEvent.lastErrorChanged(errorMessage));
             
             // Fallback logic, unless it's a plugin error
             if (!isPluginError && state.quality == AudioQuality.high192) {
                emit(state.copyWith(error: "192k not available. Trying 128k..."));
                add(AudioEvent.changeQuality(AudioQuality.medium128));
             } else if (!isPluginError && state.quality == AudioQuality.medium128) {
                emit(state.copyWith(error: "128k failed. Trying 64k..."));
                add(AudioEvent.changeQuality(AudioQuality.low64));
             } else {
                emit(state.copyWith(
                  error: isPluginError ? "Audio plugin missing. Please rebuild the app." : "Playback failed: $errorMessage", 
                  status: AudioStatus.error,
                ));
             }
          },
          (_) => null,
        );
      },
    );
  }

  Future<void> _onTogglePlayback(Emitter<AudioState> emit) async {
    if (state.isPlaying) {
      await playerService.pause();
    } else if (state.status == AudioStatus.paused) {
      await playerService.resume();
    } else {
      // If idle, completed, or stopped, start fresh
      if (state.currentSurah != null) {
        if (state.mode == AudioPlayMode.surah) {
          add(AudioEvent.playSurah(
            surahNumber: state.currentSurah!,
            startAyah: state.currentAyah ?? 1,
            reciter: state.currentReciter,
          ));
        } else {
          add(AudioEvent.playAyah(
            surahNumber: state.currentSurah!,
            ayahNumber: state.currentAyah ?? 1,
            reciter: state.currentReciter,
          ));
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
    emit(state.copyWith(isBannerVisible: false, error: null, lastErrorMessage: null));
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

  Future<void> _onChangePlaybackMode(AudioPlayMode mode, Emitter<AudioState> emit) async {
    emit(state.copyWith(mode: mode));
    playerService.setMode(mode);
  }

  Future<void> _onChangeQuality(AudioQuality quality, Emitter<AudioState> emit) async {
    emit(state.copyWith(quality: quality));
    
    // Restart if active to apply new quality
    if (state.isActive && state.currentSurah != null && state.currentAyah != null) {
      if (state.mode == AudioPlayMode.surah) {
        add(AudioEvent.playSurah(
          surahNumber: state.currentSurah!,
          startAyah: state.currentAyah!,
          reciter: state.currentReciter,
        ));
      } else {
        add(AudioEvent.playAyah(
          surahNumber: state.currentSurah!,
          ayahNumber: state.currentAyah!,
          reciter: state.currentReciter,
        ));
      }
    }
  }

  void _onStatusChanged(AudioStatus status, Emitter<AudioState> emit) {
    // Only show banner automatically if status changed and it's not idle/stopped
    final shouldShowBanner = status != AudioStatus.idle && status != AudioStatus.stopped && status != state.status;
    
    emit(state.copyWith(
      status: status, 
      error: status == AudioStatus.error ? (state.error ?? "Playback Error") : null,
      lastErrorMessage: status == AudioStatus.error ? state.lastErrorMessage : null,
      isBannerVisible: shouldShowBanner ? true : state.isBannerVisible,
    ));
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

  void _onIndexChanged(int? index, Emitter<AudioState> emit) {
    if (index != null && state.mode == AudioPlayMode.surah && state.currentSurah != null && state.currentReciter != null) {
      final bool isPrependActive = audioRepository.shouldPrependBismillah(
        state.currentSurah!, 
        state.currentReciter!.identifier,
      );
      
      if (isPrependActive) {
        // Index 0 is Bismillah, Index 1 is Ayah 1, etc.
        if (index == 0) {
          emit(state.copyWith(currentAyah: 1)); // Highlight Ayah 1 for Bismillah
        } else {
          emit(state.copyWith(currentAyah: index)); // (Index 1 -> Ayah 1, Index 2 -> Ayah 2)
        }
      } else {
        emit(state.copyWith(currentAyah: index + 1));
      }
    }
  }

  void _onUpdateCurrentPosition(int surahNumber, int? ayahNumber, Emitter<AudioState> emit) {
    // Only update the "current" position in state if we're not actually playing something else.
    // If the player is active, the state should reflect what's actually coming out of the speakers.
    if (state.isActive) {
      return;
    }
    
    if (state.currentSurah == surahNumber && state.currentAyah == ayahNumber) {
      return;
    }
    emit(state.copyWith(
      currentSurah: surahNumber,
      currentAyah: ayahNumber,
    ));
  }

  @override
  Future<void> close() async {
    await _statusSubscription?.cancel();
    await _errorSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _indexSubscription?.cancel();
    // Do not dispose playerService here as it is a singleton injected via DI
    return super.close();
  }
}
