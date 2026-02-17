part of 'audio_bloc.dart';

@freezed
class AudioState with _$AudioState {
  const factory AudioState.initial() = _Initial;
  const factory AudioState.loading() = _Loading;
  const factory AudioState.loaded({
    required AudioStatus status,
  }) = _Loaded;
  const factory AudioState.error(String message) = _Error;
}
