part of 'audio_player_bloc.dart';

abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayAyah extends AudioPlayerEvent {
  final int surahNumber;
  final int ayahNumber;
  final Reciter? reciter;
  const PlayAyah({
    required this.surahNumber,
    required this.ayahNumber,
    this.reciter,
  });
  @override
  List<Object?> get props => [surahNumber, ayahNumber, reciter];
}

class PlaySurah extends AudioPlayerEvent {
  final int surahNumber;
  final Reciter? reciter;
  final int? startAyah;
  final int? ayahCount;
  const PlaySurah({
    required this.surahNumber,
    this.reciter,
    this.startAyah,
    this.ayahCount,
  });
  @override
  List<Object?> get props => [surahNumber, reciter, startAyah, ayahCount];
}

class TogglePlayback extends AudioPlayerEvent {
  const TogglePlayback();
}

class Pause extends AudioPlayerEvent {
  const Pause();
}

class Resume extends AudioPlayerEvent {
  const Resume();
}

class Stop extends AudioPlayerEvent {
  const Stop();
}

class SeekTo extends AudioPlayerEvent {
  final Duration position;
  const SeekTo(this.position);
  @override
  List<Object?> get props => [position];
}

class SkipToNext extends AudioPlayerEvent {
  const SkipToNext();
}

class SkipToPrevious extends AudioPlayerEvent {
  const SkipToPrevious();
}

class ChangeSpeed extends AudioPlayerEvent {
  final double speed;
  const ChangeSpeed(this.speed);
  @override
  List<Object?> get props => [speed];
}

class ToggleRepeat extends AudioPlayerEvent {
  const ToggleRepeat();
}

class ChangePlaybackMode extends AudioPlayerEvent {
  final AudioPlayMode mode;
  const ChangePlaybackMode(this.mode);
  @override
  List<Object?> get props => [mode];
}

class ChangeQuality extends AudioPlayerEvent {
  final AudioQuality quality;
  const ChangeQuality(this.quality);
  @override
  List<Object?> get props => [quality];
}

class ChangeReciter extends AudioPlayerEvent {
  final Reciter reciter;
  const ChangeReciter(this.reciter);
  @override
  List<Object?> get props => [reciter];
}

class HideBanner extends AudioPlayerEvent {
  const HideBanner();
}

class ShowBanner extends AudioPlayerEvent {
  const ShowBanner();
}

class TogglePlayerExpanded extends AudioPlayerEvent {
  const TogglePlayerExpanded();
}

class StatusChanged extends AudioPlayerEvent {
  final AudioStatus status;
  const StatusChanged(this.status);
  @override
  List<Object?> get props => [status];
}

class LastErrorChanged extends AudioPlayerEvent {
  final String? error;
  const LastErrorChanged(this.error);
  @override
  List<Object?> get props => [error];
}

class PositionChanged extends AudioPlayerEvent {
  final Duration position;
  const PositionChanged(this.position);
  @override
  List<Object?> get props => [position];
}

class DurationChanged extends AudioPlayerEvent {
  final Duration duration;
  const DurationChanged(this.duration);
  @override
  List<Object?> get props => [duration];
}

class IndexChanged extends AudioPlayerEvent {
  final int? index;
  const IndexChanged(this.index);
  @override
  List<Object?> get props => [index];
}

class UpdateCurrentPosition extends AudioPlayerEvent {
  final int surahNumber;
  final int? ayahNumber;
  const UpdateCurrentPosition({required this.surahNumber, this.ayahNumber});
  @override
  List<Object?> get props => [surahNumber, ayahNumber];
}
