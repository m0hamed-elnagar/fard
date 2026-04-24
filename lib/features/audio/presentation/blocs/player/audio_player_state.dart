part of 'audio_player_bloc.dart';

class AudioPlayerState extends Equatable {
  final AudioStatus status;
  final Reciter? currentReciter;
  final int? currentSurah;
  final int? currentAyah;
  final AudioPlayMode mode;
  final AudioQuality quality;
  final Duration position;
  final Duration duration;
  final double speed;
  final bool isRepeating;
  final bool isBannerVisible;
  final bool isPlayerExpanded;
  final String? error;
  final String? lastErrorMessage;

  const AudioPlayerState({
    this.status = AudioStatus.idle,
    this.currentReciter,
    this.currentSurah,
    this.currentAyah,
    this.mode = AudioPlayMode.ayah,
    this.quality = AudioQuality.medium128,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.isRepeating = false,
    this.isBannerVisible = false,
    this.isPlayerExpanded = false,
    this.error,
    this.lastErrorMessage,
  });

  AudioPlayerState copyWith({
    AudioStatus? status,
    Object? currentReciter = _sentinel,
    Object? currentSurah = _sentinel,
    Object? currentAyah = _sentinel,
    AudioPlayMode? mode,
    AudioQuality? quality,
    Duration? position,
    Duration? duration,
    double? speed,
    bool? isRepeating,
    bool? isBannerVisible,
    bool? isPlayerExpanded,
    Object? error = _sentinel,
    Object? lastErrorMessage = _sentinel,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      currentReciter: currentReciter == _sentinel
          ? this.currentReciter
          : currentReciter as Reciter?,
      currentSurah: currentSurah == _sentinel
          ? this.currentSurah
          : currentSurah as int?,
      currentAyah: currentAyah == _sentinel
          ? this.currentAyah
          : currentAyah as int?,
      mode: mode ?? this.mode,
      quality: quality ?? this.quality,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      isRepeating: isRepeating ?? this.isRepeating,
      isBannerVisible: isBannerVisible ?? this.isBannerVisible,
      isPlayerExpanded: isPlayerExpanded ?? this.isPlayerExpanded,
      error: error == _sentinel ? this.error : error as String?,
      lastErrorMessage: lastErrorMessage == _sentinel
          ? this.lastErrorMessage
          : lastErrorMessage as String?,
    );
  }

  static const _sentinel = Object();

  @override
  List<Object?> get props => [
    status,
    currentReciter,
    currentSurah,
    currentAyah,
    mode,
    quality,
    position,
    duration,
    speed,
    isRepeating,
    isBannerVisible,
    isPlayerExpanded,
    error,
    lastErrorMessage,
  ];
}

extension AudioPlayerStateX on AudioPlayerState {
  bool get isPlaying => status == AudioStatus.playing;
  bool get isPaused => status == AudioStatus.paused;
  bool get isLoading => status == AudioStatus.loading;
  bool get isActive => isPlaying || isPaused || isLoading;
  bool get hasError => error != null;

  String? get currentPlayingId => currentSurah != null && currentAyah != null
      ? '${currentSurah}_$currentAyah'
      : null;
}
