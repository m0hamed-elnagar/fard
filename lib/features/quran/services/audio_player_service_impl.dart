import 'package:just_audio/just_audio.dart';
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
  }

  @override
  Future<Result<void>> playStreaming(String url, {AudioPlayMode mode = AudioPlayMode.surah}) async {
    try {
      _currentMode = mode;
      await _player.setUrl(url).catchError((err) {
        _statusController.add(AudioStatus.error);
        throw err;
      });
      _player.play();
      return Result.success(null);
    } catch (e) {
      _statusController.add(AudioStatus.error);
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> playLocal(String path, {AudioPlayMode mode = AudioPlayMode.surah}) async {
    try {
      _currentMode = mode;
      await _player.setFilePath(path);
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
  Stream<AudioStatus> watchStatus() => _statusController.stream;

  void dispose() {
    _player.dispose();
    _statusController.close();
  }
}
