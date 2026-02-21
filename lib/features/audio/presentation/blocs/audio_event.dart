part of 'audio_bloc.dart';

abstract class AudioEvent extends Equatable {
  const AudioEvent();

  @override
  List<Object?> get props => [];

  // Factory-like methods for convenience
  static AudioEvent loadReciters() => const LoadReciters();
  static AudioEvent selectReciter(Reciter reciter) => SelectReciter(reciter);
  static AudioEvent playAyah({required int surahNumber, required int ayahNumber, Reciter? reciter}) =>
      PlayAyah(surahNumber: surahNumber, ayahNumber: ayahNumber, reciter: reciter);
  static AudioEvent playSurah({required int surahNumber, Reciter? reciter, int? startAyah, int? ayahCount}) =>
      PlaySurah(surahNumber: surahNumber, reciter: reciter, startAyah: startAyah, ayahCount: ayahCount);
  static AudioEvent togglePlayback() => const TogglePlayback();
  static AudioEvent pause() => const Pause();
  static AudioEvent resume() => const Resume();
  static AudioEvent stop() => const Stop();
  static AudioEvent seekTo(Duration position) => SeekTo(position);
  static AudioEvent skipToNext() => const SkipToNext();
  static AudioEvent skipToPrevious() => const SkipToPrevious();
  static AudioEvent changeSpeed(double speed) => ChangeSpeed(speed);
  static AudioEvent toggleRepeat() => const ToggleRepeat();
  static AudioEvent changePlaybackMode(AudioPlayMode mode) => ChangePlaybackMode(mode);
  static AudioEvent changeQuality(AudioQuality quality) => ChangeQuality(quality);
  static AudioEvent hideBanner() => const HideBanner();
  static AudioEvent statusChanged(AudioStatus status) => StatusChanged(status);
  static AudioEvent lastErrorChanged(String? error) => LastErrorChanged(error);
  static AudioEvent positionChanged(Duration position) => PositionChanged(position);
  static AudioEvent durationChanged(Duration duration) => DurationChanged(duration);
  static AudioEvent indexChanged(int? index) => IndexChanged(index);
  static AudioEvent updateCurrentPosition({required int surahNumber, int? ayahNumber}) =>
      UpdateCurrentPosition(surahNumber: surahNumber, ayahNumber: ayahNumber);
}

class UpdateCurrentPosition extends AudioEvent {
  final int surahNumber;
  final int? ayahNumber;
  const UpdateCurrentPosition({required this.surahNumber, this.ayahNumber});
  @override
  List<Object?> get props => [surahNumber, ayahNumber];
}

class LoadReciters extends AudioEvent {
  const LoadReciters();
}

class SelectReciter extends AudioEvent {
  final Reciter reciter;
  const SelectReciter(this.reciter);
  @override
  List<Object?> get props => [reciter];
}

class PlayAyah extends AudioEvent {
  final int surahNumber;
  final int ayahNumber;
  final Reciter? reciter;
  const PlayAyah({required this.surahNumber, required this.ayahNumber, this.reciter});
  @override
  List<Object?> get props => [surahNumber, ayahNumber, reciter];
}

class PlaySurah extends AudioEvent {
  final int surahNumber;
  final Reciter? reciter;
  final int? startAyah;
  final int? ayahCount;
  const PlaySurah({required this.surahNumber, this.reciter, this.startAyah, this.ayahCount});
  @override
  List<Object?> get props => [surahNumber, reciter, startAyah, ayahCount];
}

class TogglePlayback extends AudioEvent {
  const TogglePlayback();
}

class Pause extends AudioEvent {
  const Pause();
}

class Resume extends AudioEvent {
  const Resume();
}

class Stop extends AudioEvent {
  const Stop();
}

class SeekTo extends AudioEvent {
  final Duration position;
  const SeekTo(this.position);
  @override
  List<Object?> get props => [position];
}

class SkipToNext extends AudioEvent {
  const SkipToNext();
}

class SkipToPrevious extends AudioEvent {
  const SkipToPrevious();
}

class ChangeSpeed extends AudioEvent {
  final double speed;
  const ChangeSpeed(this.speed);
  @override
  List<Object?> get props => [speed];
}

class ToggleRepeat extends AudioEvent {
  const ToggleRepeat();
}

class ChangePlaybackMode extends AudioEvent {
  final AudioPlayMode mode;
  const ChangePlaybackMode(this.mode);
  @override
  List<Object?> get props => [mode];
}

class ChangeQuality extends AudioEvent {
  final AudioQuality quality;
  const ChangeQuality(this.quality);
  @override
  List<Object?> get props => [quality];
}

class HideBanner extends AudioEvent {
  const HideBanner();
}

class StatusChanged extends AudioEvent {
  final AudioStatus status;
  const StatusChanged(this.status);
  @override
  List<Object?> get props => [status];
}

class LastErrorChanged extends AudioEvent {
  final String? error;
  const LastErrorChanged(this.error);
  @override
  List<Object?> get props => [error];
}

class PositionChanged extends AudioEvent {
  final Duration position;
  const PositionChanged(this.position);
  @override
  List<Object?> get props => [position];
}

class DurationChanged extends AudioEvent {
  final Duration duration;
  const DurationChanged(this.duration);
  @override
  List<Object?> get props => [duration];
}

class IndexChanged extends AudioEvent {
  final int? index;
  const IndexChanged(this.index);
  @override
  List<Object?> get props => [index];
}

extension AudioEventMapper on AudioEvent {
  R map<R>({
    required R Function(LoadReciters) loadReciters,
    required R Function(SelectReciter) selectReciter,
    required R Function(PlayAyah) playAyah,
    required R Function(PlaySurah) playSurah,
    required R Function(TogglePlayback) togglePlayback,
    required R Function(Pause) pause,
    required R Function(Resume) resume,
    required R Function(Stop) stop,
    required R Function(SeekTo) seekTo,
    required R Function(SkipToNext) skipToNext,
    required R Function(SkipToPrevious) skipToPrevious,
    required R Function(ChangeSpeed) changeSpeed,
    required R Function(ToggleRepeat) toggleRepeat,
    required R Function(ChangePlaybackMode) changePlaybackMode,
    required R Function(ChangeQuality) changeQuality,
    required R Function(HideBanner) hideBanner,
    required R Function(StatusChanged) statusChanged,
    required R Function(LastErrorChanged) lastErrorChanged,
    required R Function(PositionChanged) positionChanged,
    required R Function(DurationChanged) durationChanged,
    required R Function(IndexChanged) indexChanged,
    required R Function(UpdateCurrentPosition) updateCurrentPosition,
  }) {
    final event = this;
    if (event is LoadReciters) return loadReciters(event);
    if (event is SelectReciter) return selectReciter(event);
    if (event is PlayAyah) return playAyah(event);
    if (event is PlaySurah) return playSurah(event);
    if (event is TogglePlayback) return togglePlayback(event);
    if (event is Pause) return pause(event);
    if (event is Resume) return resume(event);
    if (event is Stop) return stop(event);
    if (event is SeekTo) return seekTo(event);
    if (event is SkipToNext) return skipToNext(event);
    if (event is SkipToPrevious) return skipToPrevious(event);
    if (event is ChangeSpeed) return changeSpeed(event);
    if (event is ToggleRepeat) return toggleRepeat(event);
    if (event is ChangePlaybackMode) return changePlaybackMode(event);
    if (event is ChangeQuality) return changeQuality(event);
    if (event is HideBanner) return hideBanner(event);
    if (event is StatusChanged) return statusChanged(event);
    if (event is LastErrorChanged) return lastErrorChanged(event);
    if (event is PositionChanged) return positionChanged(event);
    if (event is DurationChanged) return durationChanged(event);
    if (event is IndexChanged) return indexChanged(event);
    if (event is UpdateCurrentPosition) return updateCurrentPosition(event);
    throw Exception('Unknown AudioEvent: $this');
  }
}
