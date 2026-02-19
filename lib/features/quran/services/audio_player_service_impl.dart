import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/repositories/audio_player_service.dart';
import 'dart:async';

class AudioPlayerServiceImpl implements AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  final _statusController = StreamController<AudioStatus>.broadcast();
  AudioPlayMode _currentMode = AudioPlayMode.surah;

  AudioPlayerServiceImpl() {
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        _statusController.add(AudioStatus.loading);
      } else if (state.playing) {
        _statusController.add(AudioStatus.playing);
      } else if (state.processingState == ProcessingState.completed) {
        _statusController.add(AudioStatus.completed);
      } else if (state.processingState == ProcessingState.idle) {
        _statusController.add(AudioStatus.idle);
      } else {
        _statusController.add(AudioStatus.paused);
      }

      // If mode is Ayah and it finished, stop
      if (_currentMode == AudioPlayMode.ayah && 
          state.processingState == ProcessingState.completed) {
        stop();
      }
    }, onError: (e) {
      _statusController.add(AudioStatus.error);
    });

    _player.playbackEventStream.listen((event) {}, onError: (e) {
       _statusController.add(AudioStatus.error);
    });
  }

  @override
  Future<Result<void>> playStreaming(String url, {AudioPlayMode mode = AudioPlayMode.surah}) async {
    try {
      _currentMode = mode;
      final source = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(
          id: url,
          title: "Quran Ayah",
          album: "Al Quran Cloud",
        ),
      );
      await _player.setAudioSource(source);
      _player.play();
      return Result.success(null);
    } catch (e) {
      _statusController.add(AudioStatus.error);
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>>
  playLocal(String path, {AudioPlayMode mode = AudioPlayMode.surah}) async {
    try {
      _currentMode = mode;
      final source = AudioSource.file(
        path,
        tag: MediaItem(
          id: path,
          title: "Quran Ayah (Downloaded)",
          album: "Al Quran Cloud",
        ),
      );
      await _player.setAudioSource(source);
      _player.play();
      return Result.success(null);
    } catch (e) {
      _statusController.add(AudioStatus.error);
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> playPlaylist(List<String> urls, {int initialIndex = 0, AudioPlayMode mode = AudioPlayMode.surah}) async {
    try {
      _currentMode = mode;
      final sources = urls.asMap().entries.map((entry) {
        return AudioSource.uri(
          Uri.parse(entry.value),
          tag: MediaItem(
            id: entry.value,
            title: "Ayah ${entry.key + 1}",
            album: "Al Quran Cloud",
          ),
        );
      }).toList();
      
      await _player.setAudioSources(sources, initialIndex: initialIndex);
      _player.play();
      return Result.success(null);
    } catch (e) {
      _statusController.add(AudioStatus.error);
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> pause() async {
    await _player.pause();
    return Result.success(null);
  }

  @override
  Future<Result<void>> resume() async {
    _player.play();
    return Result.success(null);
  }

  @override
  Future<Result<void>> stop() async {
    await _player.stop();
    return Result.success(null);
  }

  @override
  Future<Result<void>> seek(Duration position) async {
    await _player.seek(position);
    return Result.success(null);
  }

  @override
  Future<Result<void>> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    return Result.success(null);
  }

  @override
  Future<Result<void>> setLoopMode(bool enabled) async {
    await _player.setLoopMode(enabled ? LoopMode.one : LoopMode.off);
    return Result.success(null);
  }

  @override
  void setMode(AudioPlayMode mode) {
    _currentMode = mode;
  }

  @override
  Stream<AudioStatus> watchStatus() => _statusController.stream;

  @override
  Stream<Duration> watchPosition() => _player.positionStream;

  @override
  Stream<Duration?> watchDuration() => _player.durationStream;

  @override
  Stream<int?> watchCurrentIndex() => _player.currentIndexStream;

  @override
  Future<void> dispose() async {
    await _player.dispose();
    _statusController.close();
  }
}
