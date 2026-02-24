import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioPlayerServiceImpl implements AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  final _statusController = StreamController<AudioStatus>.broadcast();
  final _errorController = StreamController<String?>.broadcast();
  AudioPlayMode _currentMode = AudioPlayMode.surah;
  AudioStatus _lastStatus = AudioStatus.idle;

  AudioPlayerServiceImpl() {
    _init();
  }

  void _init() {
    _player.playerStateStream.listen((state) {
      AudioStatus newStatus;
      if (state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering) {
        newStatus = AudioStatus.loading;
      } else if (state.playing) {
        newStatus = AudioStatus.playing;
      } else if (state.processingState == ProcessingState.completed) {
        newStatus = AudioStatus.completed;
      } else if (state.processingState == ProcessingState.idle) {
        newStatus = AudioStatus.idle;
      } else {
        newStatus = AudioStatus.paused;
      }

      if (_lastStatus != newStatus) {
        _lastStatus = newStatus;
        _statusController.add(newStatus);
      }

      // If mode is Ayah and it finished, stop
      if (_currentMode == AudioPlayMode.ayah && 
          state.processingState == ProcessingState.completed) {
        stop();
      }
    }, onError: (e) {
      debugPrint('AudioPlayerService: playerStateStream Error: $e');
      _lastStatus = AudioStatus.error;
      _statusController.add(AudioStatus.error);
      _errorController.add(e.toString());
    });

    _player.playbackEventStream.listen((event) {
       if (event.errorMessage != null) {
          debugPrint('AudioPlayerService: playbackEventStream Error: ${event.errorMessage}');
          _lastStatus = AudioStatus.error;
          _statusController.add(AudioStatus.error);
          _errorController.add(event.errorMessage);
       }
    }, onError: (e) {
       debugPrint('AudioPlayerService: playbackEventStream Stream Error: $e');
       _lastStatus = AudioStatus.error;
       _statusController.add(AudioStatus.error);
       _errorController.add(e.toString());
    });
  }

  Future<String> _getCachePath(String url) async {
    final directory = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${directory.path}/audio_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    
    // Create a safe filename from URL
    final fileName = url.split('/').last.replaceAll(RegExp(r'[^\w\.]'), '_');
    // Ensure the filename is unique to the reciter if possible, but the URL usually contains it
    // For everyayah.com: .../ar.alafasy/001001.mp3
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    String finalFileName = fileName;
    if (segments.length >= 2) {
      finalFileName = '${segments[segments.length - 2]}_$fileName';
    }

    return '${cacheDir.path}/$finalFileName';
  }

  @override
  AudioStatus get currentStatus => _lastStatus;

  @override
  AudioPlayMode get currentMode => _currentMode;

  @override
  Duration get currentPosition => _player.position;

  @override
  Duration? get currentDuration => _player.duration;

  @override
  int? get currentIndex => _player.currentIndex;

  @override
  Future<Result<void>> playStreaming(String url, {AudioPlayMode mode = AudioPlayMode.surah}) async {
    try {
      debugPrint('AudioPlayerService: playStreaming called with url: $url');
      _currentMode = mode;
      
      await _player.stop();
      
      final cachePath = await _getCachePath(url);
      final source = LockCachingAudioSource(
        Uri.parse(url),
        cacheFile: File(cachePath),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36'
        },
        tag: MediaItem(
          id: url,
          album: "Al-Quran",
          title: mode == AudioPlayMode.ayah ? "Quran Ayah" : "Quran Surah",
          artist: "Quran Reciter",
        ),
      );
      
      await _player.setAudioSource(
        source, 
        preload: false,
      );
      _player.play();
      debugPrint('AudioPlayerService: play() called successfully with caching');
      return Result.success(null);
    } catch (e) {
      debugPrint('AudioPlayerService: Error in playStreaming: $e');
      if (_lastStatus != AudioStatus.error) {
        _lastStatus = AudioStatus.error;
        _statusController.add(AudioStatus.error);
      }
      return Result.failure(UnknownFailure("Playback failed: $e"));
    }
  }

  @override
  Future<Result<void>>
  playLocal(String path, {AudioPlayMode mode = AudioPlayMode.surah}) async {
    try {
      debugPrint('AudioPlayerService: playLocal called with path: $path');
      _currentMode = mode;
      await _player.stop();
      final source = AudioSource.file(
        path,
        tag: MediaItem(
          id: path,
          album: "Al-Quran",
          title: "Quran Recitation",
          artist: "Quran Reciter",
        ),
      );
      await _player.setAudioSource(
        source,
      );
      _player.play();
      return Result.success(null);
    } catch (e) {
      debugPrint('AudioPlayerService: Error in playLocal: $e');
      if (_lastStatus != AudioStatus.error) {
        _lastStatus = AudioStatus.error;
        _statusController.add(AudioStatus.error);
      }
      return Result.failure(UnknownFailure("Local playback failed: $e"));
    }
  }

  @override
  Future<Result<void>> playPlaylist(List<String> urls, {int initialIndex = 0, AudioPlayMode mode = AudioPlayMode.surah}) async {
    try {
      debugPrint('AudioPlayerService: playPlaylist called with ${urls.length} urls, start index: $initialIndex');
      _currentMode = mode;
      
      // Stop and clear the current source completely
      await _player.stop();
      
      final sources = <AudioSource>[];
      for (var i = 0; i < urls.length; i++) {
        final url = urls[i];
        final cachePath = await _getCachePath(url);
        sources.add(
          LockCachingAudioSource(
            Uri.parse(url),
            cacheFile: File(cachePath),
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Safari/537.36'
            },
            tag: MediaItem(
              id: url,
              album: "Al-Quran",
              title: "Ayah ${i + 1}",
              artist: "Quran Reciter",
            ),
          )
        );
      }
      
      await _player.setAudioSources(
        sources,
        initialIndex: initialIndex,
        preload: true,
      );
      _player.play();
      debugPrint('AudioPlayerService: playlist play() called successfully with caching');
      return Result.success(null);
    } catch (e) {
      debugPrint('AudioPlayerService: Error in playPlaylist: $e');
      if (_lastStatus != AudioStatus.error) {
        _lastStatus = AudioStatus.error;
        _statusController.add(AudioStatus.error);
      }
      return Result.failure(UnknownFailure("Playlist playback failed: $e"));
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
    try {
      await _player.stop();
      _lastStatus = AudioStatus.idle;
      _statusController.add(AudioStatus.idle);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> seek(Duration position) async {
    await _player.seek(position);
    return Result.success(null);
  }

  @override
  Future<Result<void>> skipToNext() async {
    try {
      if (_player.hasNext) {
        await _player.seekToNext();
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> skipToPrevious() async {
    try {
      if (_player.hasPrevious) {
        await _player.seekToPrevious();
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
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
  Stream<String?> watchError() => _errorController.stream;

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
