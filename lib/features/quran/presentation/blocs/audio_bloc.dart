import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fard/features/quran/domain/repositories/audio_player_service.dart';
import 'package:fard/features/quran/domain/repositories/audio_repository.dart';
import 'package:fard/features/quran/domain/entities/reciter.dart';

part 'audio_event.dart';
part 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioRepository audioRepository;
  final AudioPlayerService playerService;
  
  StreamSubscription? _statusSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _indexSubscription;

  AudioBloc({
    required this.audioRepository,
    required this.playerService,
  }) : super(const AudioState()) {
    
    _statusSubscription = playerService.watchStatus().listen((status) {
      add(AudioEvent.statusChanged(status));
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

        on<AudioEvent>((event, emit) async {
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
        changeSpeed: (e) => _onChangeSpeed(e.speed, emit),
        toggleRepeat: (e) => _onToggleRepeat(emit),
        changePlaybackMode: (e) => _onChangePlaybackMode(e.mode, emit),
        statusChanged: (e) async => _onStatusChanged(e.status, emit),
        positionChanged: (e) async => _onPositionChanged(e.position, emit),
        durationChanged: (e) async => _onDurationChanged(e.duration, emit),
        indexChanged: (e) async => _onIndexChanged(e.index, emit),
        updateCurrentPosition: (e) async => _onUpdateCurrentPosition(e.surahNumber, e.ayahNumber, emit),
      );
    });

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

    emit(state.copyWith(
      status: AudioStatus.loading,
      currentSurah: surahNumber,
      currentAyah: ayahNumber,
      currentReciter: activeReciter,
      mode: AudioPlayMode.ayah,
    ));

    final url = audioRepository.getAyahAudioUrl(
      reciterId: activeReciter.identifier,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );

    final result = await playerService.playStreaming(url, mode: AudioPlayMode.ayah);
    result.fold(
      (failure) => emit(state.copyWith(error: failure.message, status: AudioStatus.error)),
      (_) => null,
    );
  }

  Future<void> _onPlaySurah(int surahNumber, Reciter? reciter, int? startAyah, int? ayahCount, Emitter<AudioState> emit) async {
    final activeReciter = reciter ?? state.currentReciter;
    if (activeReciter == null) return;

    emit(state.copyWith(
      status: AudioStatus.loading,
      currentSurah: surahNumber,
      currentAyah: startAyah ?? 1,
      currentReciter: activeReciter,
      mode: AudioPlayMode.surah,
    ));

    final urlsResult = await audioRepository.getSurahAudioUrls(
      reciterId: activeReciter.identifier,
      surahNumber: surahNumber,
      ayahCount: ayahCount,
    );

    await urlsResult.fold(
      (failure) async => emit(state.copyWith(error: failure.message, status: AudioStatus.error)),
      (urls) async {
        final result = await playerService.playPlaylist(
          urls, 
          initialIndex: (startAyah ?? 1) - 1,
          mode: AudioPlayMode.surah,
        );
        result.fold(
          (failure) => emit(state.copyWith(error: failure.message, status: AudioStatus.error)),
          (_) => null,
        );
      },
    );
  }

  Future<void> _onTogglePlayback(Emitter<AudioState> emit) async {
    if (state.isPlaying) {
      await playerService.pause();
    } else {
      if (state.status == AudioStatus.idle || state.status == AudioStatus.completed) {
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
        } else {
          await playerService.resume();
        }
      } else {
        await playerService.resume();
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
  }

  Future<void> _onSeekTo(Duration position, Emitter<AudioState> emit) async {
    await playerService.seek(position);
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

  void _onStatusChanged(AudioStatus status, Emitter<AudioState> emit) {
    emit(state.copyWith(status: status, error: status == AudioStatus.error ? "Playback Error" : null));
  }

  void _onPositionChanged(Duration position, Emitter<AudioState> emit) {
    emit(state.copyWith(position: position));
  }

  void _onDurationChanged(Duration duration, Emitter<AudioState> emit) {
    emit(state.copyWith(duration: duration));
  }

  void _onIndexChanged(int? index, Emitter<AudioState> emit) {
    if (index != null && state.mode == AudioPlayMode.surah) {
      emit(state.copyWith(currentAyah: index + 1));
    }
  }

  void _onUpdateCurrentPosition(int surahNumber, int? ayahNumber, Emitter<AudioState> emit) {
    emit(state.copyWith(
      currentSurah: surahNumber,
      currentAyah: ayahNumber,
    ));
  }

  @override
  Future<void> close() async {
    await _statusSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _indexSubscription?.cancel();
    await playerService.dispose();
    return super.close();
  }
}
