import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/entities/audio_track.dart';
import 'package:equatable/equatable.dart';

enum AudioQuality {
  low64('64'),
  medium128('128'),
  high192('192');
  
  final String kbps;
  const AudioQuality(this.kbps);
}

abstract interface class AudioRepository {
  /// Fetch all available audio reciters from Al Quran Cloud
  Future<Result<List<Reciter>>> getAvailableReciters();
  
  /// Get audio track for specific ayah (includes URL and local path)
  Future<AudioTrack> getAyahAudioTrack({
    required String reciterId,
    required int surahNumber,
    required int ayahNumber,
    AudioQuality quality = AudioQuality.medium128,
  });
  
  /// Get list of tracks for full surah playback
  Future<Result<List<AudioTrack>>> getSurahAudioTracks({
    required String reciterId,
    required int surahNumber,
    int? ayahCount,
    AudioQuality quality = AudioQuality.medium128,
  });

  bool shouldPrependBismillah(int surahNumber, String reciterId);

  // Deprecated: Use getAyahAudioTrack instead
  Future<Result<AudioTrack>> getAudioUrl({
    required AyahNumber ayah,
    required String reciterId,
    required AudioQuality quality,
    String? audioUrl,
  });
  
  Future<Result<GaplessAudioSource>> getGaplessSurahAudio(
    SurahNumber surah, 
    String reciterId,
  );
  
  Future<Result<void>> downloadAudio({
    required AyahNumber ayah,
    required String reciterId,
    void Function(double progress)? onProgress,
  });
  
  Future<Result<bool>> isAudioDownloaded({
    required AyahNumber ayah,
    required String reciterId,
  });
  
  /// Cache reciter list locally
  Future<void> cacheReciters(List<Reciter> reciters);
  
  /// Get cached reciters
  Future<Result<List<Reciter>>> getCachedReciters();

  /// Cache reciter progress and sizes
  Future<void> cacheReciterData(Map<String, double> progress, Map<String, int> sizes);
  
  /// Get cached reciter progress and sizes
  Future<ReciterData> getCachedReciterData();
  
  /// Get number of ayahs in a surah (from local constant)
  int getAyahCount(int surahNumber);
}

class ReciterData {
  final Map<String, double> progress;
  final Map<String, int> sizes;

  const ReciterData({required this.progress, required this.sizes});
}

class GaplessAudioSource extends Equatable {
  final String baseUrl;
  final List<AyahTiming> timings;

  const GaplessAudioSource({
    required this.baseUrl,
    required this.timings,
  });

  @override
  List<Object?> get props => [baseUrl, timings];
}

class AyahTiming extends Equatable {
  final AyahNumber ayahNumber;
  final Duration start;
  final Duration end;

  const AyahTiming({
    required this.ayahNumber,
    required this.start,
    required this.end,
  });

  @override
  List<Object?> get props => [ayahNumber, start, end];
}
