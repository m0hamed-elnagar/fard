import 'package:fard/core/errors/failure.dart';

enum AudioPlayMode {
  ayah,
  surah,
}

abstract interface class AudioPlayerService {
  Future<Result<void>> playStreaming(String url, {AudioPlayMode mode = AudioPlayMode.surah});
  Future<Result<void>> playLocal(String path, {AudioPlayMode mode = AudioPlayMode.surah});
  Future<Result<void>> pause();
  Future<Result<void>> resume();
  Future<Result<void>> stop();
  Stream<AudioStatus> watchStatus();
}

enum AudioStatus {
  idle,
  loading,
  playing,
  paused,
  stopped,
  completed,
  error,
}
