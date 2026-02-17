part of 'audio_bloc.dart';

@freezed
class AudioEvent with _$AudioEvent {
  const factory AudioEvent.play({
    required AyahNumber ayah,
    required String reciterId,
    String? audioUrl,
    @Default(AudioPlayMode.surah) AudioPlayMode mode,
  }) = _Play;
  
  const factory AudioEvent.pause() = _Pause;
  const factory AudioEvent.resume() = _Resume;
  const factory AudioEvent.stop() = _Stop;
  const factory AudioEvent.statusChanged(AudioStatus status) = _StatusChanged;
}
