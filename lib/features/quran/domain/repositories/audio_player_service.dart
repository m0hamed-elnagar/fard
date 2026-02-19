import 'package:fard/core/errors/failure.dart';

enum AudioPlayMode {
  ayah,
  surah,
}

abstract interface class AudioPlayerService {
  Future<Result<void>> playStreaming(String url, {AudioPlayMode mode = AudioPlayMode.ayah});
  Future<Result<void>>
  playLocal(String path, {AudioPlayMode mode = AudioPlayMode.ayah});
  Future<Result<void>> playPlaylist(List<String> urls, {int initialIndex = 0, AudioPlayMode mode = AudioPlayMode.ayah});
  
  Future<Result<void>> pause();
  Future<Result<void>> resume();
  Future<Result<void>> stop();
  Future<Result<void>> seek(Duration position);
  Future<Result<void>> setSpeed(double speed);
  Future<Result<void>> setLoopMode(bool enabled);
  void setMode(AudioPlayMode mode);
  
  Stream<AudioStatus> watchStatus();
  Stream<Duration> watchPosition();
  Stream<Duration?> watchDuration();
  Stream<int?> watchCurrentIndex();
  
  Future<void> dispose();
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
