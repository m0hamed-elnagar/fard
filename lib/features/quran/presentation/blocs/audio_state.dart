part of 'audio_bloc.dart';

class AudioState extends Equatable {
  final AudioStatus status;
  final Reciter? currentReciter;
  final int? currentSurah;
  final int? currentAyah;
  final List<Reciter> availableReciters;
  final AudioPlayMode mode;
  final Duration position;
  final Duration duration;
  final double speed;
  final bool isRepeating;
  final String? error;

  const AudioState({
    this.status = AudioStatus.idle,
    this.currentReciter,
    this.currentSurah,
    this.currentAyah,
    this.availableReciters = const [],
    this.mode = AudioPlayMode.ayah,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.speed = 1.0,
    this.isRepeating = false,
    this.error,
  });

  AudioState copyWith({
    AudioStatus? status,
    Reciter? currentReciter,
    int? currentSurah,
    int? currentAyah,
    List<Reciter>? availableReciters,
    AudioPlayMode? mode,
    Duration? position,
    Duration? duration,
    double? speed,
    bool? isRepeating,
    String? error,
  }) {
    return AudioState(
      status: status ?? this.status,
      currentReciter: currentReciter ?? this.currentReciter,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyah: currentAyah ?? this.currentAyah,
      availableReciters: availableReciters ?? this.availableReciters,
      mode: mode ?? this.mode,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      speed: speed ?? this.speed,
      isRepeating: isRepeating ?? this.isRepeating,
      error: error ?? this.error,
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
        position,
        duration,
        speed,
        isRepeating,
        error,
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
