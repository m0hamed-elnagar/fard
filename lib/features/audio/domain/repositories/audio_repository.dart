import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
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
  
  /// Get audio URL for specific ayah
  String getAyahAudioUrl({
    required String reciterId, // e.g., 'ar.alafasy'
    required int surahNumber,
    required int ayahNumber,
    AudioQuality quality = AudioQuality.medium128,
  });
  
  /// Get list of URLs for full surah playback
  Future<Result<List<String>>> getSurahAudioUrls({
    required String reciterId,
    required int surahNumber,
    int? ayahCount,
    AudioQuality quality = AudioQuality.medium128,
  });

  bool shouldPrependBismillah(int surahNumber, String reciterId);

  Future<Result<AudioSource>> getAudioUrl({
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
}

class AudioSource extends Equatable {
  final String url;
  final String? localPath;

  const AudioSource({
    required this.url,
    this.localPath,
  });

  @override
  List<Object?> get props => [url, localPath];
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
