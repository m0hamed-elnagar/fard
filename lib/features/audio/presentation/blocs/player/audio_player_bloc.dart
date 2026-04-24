import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/entities/audio_track.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:quran/quran.dart' as quran;

part 'audio_player_event.dart';
part 'audio_player_state.dart';

@injectable
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioRepository audioRepository;
  final AudioPlayerService playerService;
  final SettingsRepository settingsRepository;

  StreamSubscription? _statusSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _indexSubscription;

  AudioPlayerBloc({
    required this.audioRepository,
    required this.playerService,
    required this.settingsRepository,
  }) : super(AudioPlayerState(isPlayerExpanded: settingsRepository.isAudioPlayerExpanded)) {
    on<PlayAyah>(_onPlayAyah);
    on<PlaySurah>(_onPlaySurah);
    on<TogglePlayback>(_onTogglePlayback);
    on<Pause>(_onPause);
    on<Resume>(_onResume);
    on<Stop>(_onStop);
    on<SeekTo>(_onSeekTo);
    on<SkipToNext>(_onSkipToNext);
    on<SkipToPrevious>(_onSkipToPrevious);
    on<ChangeSpeed>(_onChangeSpeed);
    on<ToggleRepeat>(_onToggleRepeat);
    on<ChangePlaybackMode>(_onChangePlaybackMode);
    on<ChangeQuality>(_onChangeQuality);
    on<ChangeReciter>(_onChangeReciter);
    on<HideBanner>(_onHideBanner);
    on<ShowBanner>(_onShowBanner);
    on<TogglePlayerExpanded>(_onTogglePlayerExpanded);
    on<StatusChanged>(_onStatusChanged);
    on<LastErrorChanged>(_onLastErrorChanged);
    on<PositionChanged>(_onPositionChanged);
    on<DurationChanged>(_onDurationChanged);
    on<IndexChanged>(_onIndexChanged);
    on<UpdateCurrentPosition>(_onUpdateCurrentPosition);

    _statusSubscription = playerService.watchStatus().listen((status) {
      add(StatusChanged(status));
    });

    _errorSubscription = playerService.watchError().listen((error) {
      add(LastErrorChanged(error));
    });

    _positionSubscription = playerService.watchPosition().listen((position) {
      add(PositionChanged(position));
    });

    _durationSubscription = playerService.watchDuration().listen((duration) {
      if (duration != null) {
        add(DurationChanged(duration));
      }
    });

    _indexSubscription = playerService.watchCurrentIndex().listen((index) {
      add(IndexChanged(index));
    });

    // Initialize with current state
    if (playerService.currentStatus != AudioStatus.idle) {
      add(StatusChanged(playerService.currentStatus));
      add(ChangePlaybackMode(playerService.currentMode));
      add(PositionChanged(playerService.currentPosition));
      if (playerService.currentDuration != null) {
        add(DurationChanged(playerService.currentDuration!));
      }
      if (playerService.currentIndex != null) {
        add(IndexChanged(playerService.currentIndex));
      }
    }
  }

  Future<void> _onPlayAyah(
    PlayAyah event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final activeReciter = event.reciter ?? state.currentReciter;
    if (activeReciter == null) return;

    await playerService.stop();

    emit(
      state.copyWith(
        status: AudioStatus.loading,
        currentSurah: event.surahNumber,
        currentAyah: event.ayahNumber,
        currentReciter: activeReciter,
        mode: AudioPlayMode.ayah,
        isBannerVisible: true,
        error: null,
        lastErrorMessage: null,
      ),
    );

    final track = await audioRepository.getAyahAudioTrack(
      reciterId: activeReciter.identifier,
      surahNumber: event.surahNumber,
      ayahNumber: event.ayahNumber,
      quality: state.quality,
    );

    final bool isPrependActive =
        event.ayahNumber == 1 &&
        audioRepository.shouldPrependBismillah(
          event.surahNumber,
          activeReciter.identifier,
        );

    final currentLanguage = settingsRepository.locale.languageCode;
    final isArabic = currentLanguage == 'ar';

    final surahName = isArabic
        ? quran.getSurahNameArabic(event.surahNumber)
        : quran.getSurahName(event.surahNumber);
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
                'title': '$surahLabel $surahName: $ayahLabel ${event.ayahNumber}',
                'artist': reciterName,
                'album': surahName,
              },
            ],
          )
        : await playerService.playStreaming(
            track,
            mode: AudioPlayMode.ayah,
            metadata: {
              'title': '$surahLabel $surahName: $ayahLabel ${event.ayahNumber}',
              'artist': reciterName,
              'album': surahName,
            },
          );

    result.fold((failure) async {
      final errorMessage = failure.message;
      final isPluginError = errorMessage.contains('MissingPluginException');

      add(LastErrorChanged(errorMessage));

      if (!isPluginError && state.quality == AudioQuality.high192) {
        emit(
          state.copyWith(
            error: "192k not available for this reciter. Trying 128k...",
          ),
        );
        add(ChangeQuality(AudioQuality.medium128));
      } else if (!isPluginError && state.quality == AudioQuality.medium128) {
        emit(state.copyWith(error: "128k failed. Trying 64k..."));
        add(ChangeQuality(AudioQuality.low64));
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
    PlaySurah event,
    Emitter<AudioPlayerState> emit,
  ) async {
    final activeReciter = event.reciter ?? state.currentReciter;
    if (activeReciter == null) return;

    await playerService.stop();

    emit(
      state.copyWith(
        status: AudioStatus.loading,
        currentSurah: event.surahNumber,
        currentAyah: event.startAyah ?? 1,
        currentReciter: activeReciter,
        mode: AudioPlayMode.surah,
        isBannerVisible: true,
        error: null,
        lastErrorMessage: null,
      ),
    );

    final tracksResult = await audioRepository.getSurahAudioTracks(
      reciterId: activeReciter.identifier,
      surahNumber: event.surahNumber,
      ayahCount: event.ayahCount,
      quality: state.quality,
    );

    await tracksResult.fold(
      (failure) async => emit(
        state.copyWith(error: failure.message, status: AudioStatus.error),
      ),
      (verses) async {
        final bool isPrependActive = audioRepository.shouldPrependBismillah(
          event.surahNumber,
          activeReciter.identifier,
        );

        final tracks = <AudioTrack>[];
        if (isPrependActive) {
          final bismillah = await audioRepository.getBismillahTrack(
            reciterId: activeReciter.identifier,
            quality: state.quality,
          );
          tracks.add(bismillah);
        }
        tracks.addAll(verses);

        int initialIndex = (event.startAyah ?? 1) - 1;
        if (isPrependActive) {
          initialIndex = (event.startAyah == null || event.startAyah == 1) ? 0 : event.startAyah!;
        }

        final currentLanguage = settingsRepository.locale.languageCode;
        final isArabic = currentLanguage == 'ar';

        final surahName = isArabic
            ? quran.getSurahNameArabic(event.surahNumber)
            : quran.getSurahName(event.surahNumber);
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

          add(LastErrorChanged(errorMessage));

          if (!isPluginError && state.quality == AudioQuality.high192) {
            emit(state.copyWith(error: "192k not available. Trying 128k..."));
            add(ChangeQuality(AudioQuality.medium128));
          } else if (!isPluginError &&
              state.quality == AudioQuality.medium128) {
            emit(state.copyWith(error: "128k failed. Trying 64k..."));
            add(ChangeQuality(AudioQuality.low64));
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

  Future<void> _onTogglePlayback(TogglePlayback event, Emitter<AudioPlayerState> emit) async {
    if (state.isPlaying) {
      await playerService.pause();
    } else if (state.status == AudioStatus.paused) {
      await playerService.resume();
    } else {
      if (state.currentSurah != null) {
        if (state.mode == AudioPlayMode.surah) {
          add(
            PlaySurah(
              surahNumber: state.currentSurah!,
              startAyah: state.currentAyah ?? 1,
              reciter: state.currentReciter,
            ),
          );
        } else {
          add(
            PlayAyah(
              surahNumber: state.currentSurah!,
              ayahNumber: state.currentAyah ?? 1,
              reciter: state.currentReciter,
            ),
          );
        }
      }
    }
  }

  Future<void> _onPause(Pause event, Emitter<AudioPlayerState> emit) async {
    await playerService.pause();
  }

  Future<void> _onResume(Resume event, Emitter<AudioPlayerState> emit) async {
    await playerService.resume();
  }

  Future<void> _onStop(Stop event, Emitter<AudioPlayerState> emit) async {
    await playerService.stop();
    emit(state.copyWith(isBannerVisible: false, error: null));
  }

  Future<void> _onSeekTo(SeekTo event, Emitter<AudioPlayerState> emit) async {
    await playerService.seek(event.position);
  }

  Future<void> _onSkipToNext(SkipToNext event, Emitter<AudioPlayerState> emit) async {
    await playerService.skipToNext();
  }

  Future<void> _onSkipToPrevious(SkipToPrevious event, Emitter<AudioPlayerState> emit) async {
    await playerService.skipToPrevious();
  }

  Future<void> _onHideBanner(HideBanner event, Emitter<AudioPlayerState> emit) async {
    emit(
      state.copyWith(
        isBannerVisible: false,
        isPlayerExpanded: false,
        error: null,
        lastErrorMessage: null,
      ),
    );
  }

  Future<void> _onShowBanner(ShowBanner event, Emitter<AudioPlayerState> emit) async {
    emit(state.copyWith(isBannerVisible: true));
  }

  Future<void> _onTogglePlayerExpanded(TogglePlayerExpanded event, Emitter<AudioPlayerState> emit) async {
    final newValue = !state.isPlayerExpanded;
    emit(state.copyWith(isPlayerExpanded: newValue));
    await settingsRepository.updateAudioPlayerExpanded(newValue);
  }


  Future<void> _onChangeSpeed(ChangeSpeed event, Emitter<AudioPlayerState> emit) async {
    emit(state.copyWith(speed: event.speed));
    await playerService.setSpeed(event.speed);
  }

  Future<void> _onToggleRepeat(ToggleRepeat event, Emitter<AudioPlayerState> emit) async {
    final newValue = !state.isRepeating;
    emit(state.copyWith(isRepeating: newValue));
    await playerService.setLoopMode(newValue);
  }

  Future<void> _onChangePlaybackMode(
    ChangePlaybackMode event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(state.copyWith(mode: event.mode));
    playerService.setMode(event.mode);
  }

  Future<void> _onChangeQuality(
    ChangeQuality event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(state.copyWith(quality: event.quality));

    if (state.isActive &&
        state.currentSurah != null &&
        state.currentAyah != null) {
      if (state.mode == AudioPlayMode.surah) {
        add(
          PlaySurah(
            surahNumber: state.currentSurah!,
            startAyah: state.currentAyah!,
            reciter: state.currentReciter,
          ),
        );
      } else {
        add(
          PlayAyah(
            surahNumber: state.currentSurah!,
            ayahNumber: state.currentAyah!,
            reciter: state.currentReciter,
          ),
        );
      }
    }
  }

  Future<void> _onChangeReciter(
    ChangeReciter event,
    Emitter<AudioPlayerState> emit,
  ) async {
    emit(state.copyWith(currentReciter: event.reciter));

    if (state.isActive &&
        state.currentSurah != null &&
        state.currentAyah != null) {
      if (state.mode == AudioPlayMode.surah) {
        add(
          PlaySurah(
            surahNumber: state.currentSurah!,
            startAyah: state.currentAyah!,
            reciter: event.reciter,
          ),
        );
      } else {
        add(
          PlayAyah(
            surahNumber: state.currentSurah!,
            ayahNumber: state.currentAyah!,
            reciter: event.reciter,
          ),
        );
      }
    }
  }

  void _onStatusChanged(StatusChanged event, Emitter<AudioPlayerState> emit) {
    final shouldShowBanner =
        event.status != AudioStatus.idle &&
        event.status != AudioStatus.stopped &&
        event.status != state.status;

    emit(
      state.copyWith(
        status: event.status,
        error: event.status == AudioStatus.error
            ? (state.error ?? "Playback Error")
            : null,
        lastErrorMessage: event.status == AudioStatus.error
            ? state.lastErrorMessage
            : null,
        isBannerVisible: shouldShowBanner ? true : state.isBannerVisible,
      ),
    );
  }

  void _onLastErrorChanged(LastErrorChanged event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(lastErrorMessage: event.error));
  }

  void _onPositionChanged(PositionChanged event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(position: event.position));
  }

  void _onDurationChanged(DurationChanged event, Emitter<AudioPlayerState> emit) {
    emit(state.copyWith(duration: event.duration));
  }

  void _onIndexChanged(IndexChanged event, Emitter<AudioPlayerState> emit) {
    if (event.index != null &&
        state.mode == AudioPlayMode.surah &&
        state.currentSurah != null &&
        state.currentReciter != null) {
      final bool isPrependActive = audioRepository.shouldPrependBismillah(
        state.currentSurah!,
        state.currentReciter!.identifier,
      );

      if (isPrependActive) {
        if (event.index == 0) {
          emit(state.copyWith(currentAyah: 1));
        } else {
          emit(state.copyWith(currentAyah: event.index));
        }
      } else {
        emit(state.copyWith(currentAyah: event.index! + 1));
      }
    }
  }

  void _onUpdateCurrentPosition(
    UpdateCurrentPosition event,
    Emitter<AudioPlayerState> emit,
  ) {
    if (state.isActive) {
      return;
    }

    if (state.currentSurah == event.surahNumber && state.currentAyah == event.ayahNumber) {
      return;
    }
    emit(state.copyWith(currentSurah: event.surahNumber, currentAyah: event.ayahNumber));
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
