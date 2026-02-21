part of 'audio_bloc.dart';

class AudioState extends Equatable {
  final AudioStatus status;
  final Reciter? currentReciter;
  final int? currentSurah;
  final int? currentAyah;
  final List<Reciter> availableReciters;
  final AudioPlayMode mode;
  final AudioQuality quality;
  final Duration position;
  final Duration duration;
  final double speed;
  final bool isRepeating;
  final bool isBannerVisible;
  final String? error;
  final String? lastErrorMessage;

  const AudioState({
    this.status = AudioStatus.idle,
    this.currentReciter,
    this.currentSurah,
    this.currentAyah,
    this.availableReciters = const [],
    this.mode = AudioPlayMode.ayah,
    this.quality = AudioQuality.medium128,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.isRepeating = false,
    this.isBannerVisible = false,
    this.error,
    this.lastErrorMessage,
  });

  AudioState copyWith({
    AudioStatus? status,
    Reciter? currentReciter,
    int? currentSurah,
    int? currentAyah,
    List<Reciter>? availableReciters,
    AudioPlayMode? mode,
    AudioQuality? quality,
    Duration? position,
    Duration? duration,
    double? speed,
    bool? isRepeating,
    bool? isBannerVisible,
    String? error,
    String? lastErrorMessage,
  }) {
    return AudioState(
      status: status ?? this.status,
      currentReciter: currentReciter ?? this.currentReciter,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyah: currentAyah ?? this.currentAyah,
      availableReciters: availableReciters ?? this.availableReciters,
      mode: mode ?? this.mode,
      quality: quality ?? this.quality,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      isRepeating: isRepeating ?? this.isRepeating,
      isBannerVisible: isBannerVisible ?? this.isBannerVisible,
      error: error ?? this.error,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        currentReciter,
        currentSurah,
        currentAyah,
        availableReciters,
        mode,
        quality,
        position,
        duration,
        speed,
        isRepeating,
        isBannerVisible,
        error,
        lastErrorMessage,
      ];
}

extension AudioStateX on AudioState {
  bool get isPlaying => status == AudioStatus.playing;
  bool get isPaused => status == AudioStatus.paused;
  bool get isLoading => status == AudioStatus.loading;
  bool get isActive => isPlaying || isPaused || isLoading;
  bool get hasError => error != null;
  
  String? get currentPlayingId => 
      currentSurah != null && currentAyah != null 
          ? '${currentSurah}_$currentAyah' 
          : null;
}
