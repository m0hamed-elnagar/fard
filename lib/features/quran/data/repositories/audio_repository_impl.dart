import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/entities/reciter.dart';
import 'package:fard/features/quran/domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final http.Client client;

  AudioRepositoryImpl({required this.client});

  static const String _audioBaseUrl = 'https://audio.quran.com/recitations';

  @override
  Future<Result<AudioSource>> getAudioUrl({
    required AyahNumber ayah,
    required String reciterId,
    required AudioQuality quality,
    String? audioUrl,
  }) async {
    final surahStr = ayah.surahNumber.toString().padLeft(3, '0');
    final ayahStr = ayah.ayahNumberInSurah.toString().padLeft(3, '0');
    
    String quranComId = reciterId;
    if (reciterId == 'Alafasy_128kbps') quranComId = '7';
    if (reciterId == 'Abdul_Basit_Murattal_64kbps') quranComId = '1';
    if (reciterId == 'Abdurrahmaan_As-Sudais_192kbps') quranComId = '3';

    // Prioritize provided URL from API
    final url = audioUrl ?? '$_audioBaseUrl/$quranComId/$surahStr$ayahStr.mp3';
    
    // Check local storage
    final localPath = await _getLocalPath(quranComId, surahStr, ayahStr);
    if (await File(localPath).exists()) {
      return Result.success(AudioSource(url: url, localPath: localPath));
    }

    return Result.success(AudioSource(url: url));
  }

  @override
  Future<Result<GaplessAudioSource>> getGaplessSurahAudio(
    SurahNumber surah, 
    String reciterId,
  ) async {
    return Result.failure(const UnknownFailure('Gapless not fully implemented yet'));
  }

  @override
  Future<Result<void>> downloadAudio({
    required AyahNumber ayah,
    required String reciterId,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final surahStr = ayah.surahNumber.toString().padLeft(3, '0');
      final ayahStr = ayah.ayahNumberInSurah.toString().padLeft(3, '0');
      
      final audioResult = await getAudioUrl(
        ayah: ayah, 
        reciterId: reciterId, 
        quality: AudioQuality.medium
      );
      
      if (audioResult.isFailure) return Result.failure(audioResult.failure!);
      final url = audioResult.data!.url;
      
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        String quranComId = reciterId;
        if (reciterId == 'Alafasy_128kbps') quranComId = '7';
        
        final localPath = await _getLocalPath(quranComId, surahStr, ayahStr);
        final file = File(localPath);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
        return Result.success(null);
      } else {
        return Result.failure(ServerFailure('Failed to download audio: ${response.statusCode}'));
      }
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> isAudioDownloaded({
    required AyahNumber ayah,
    required String reciterId,
  }) async {
    final surahStr = ayah.surahNumber.toString().padLeft(3, '0');
    final ayahStr = ayah.ayahNumberInSurah.toString().padLeft(3, '0');
    
    String quranComId = reciterId;
    if (reciterId == 'Alafasy_128kbps') quranComId = '7';
    
    final localPath = await _getLocalPath(quranComId, surahStr, ayahStr);
    return Result.success(await File(localPath).exists());
  }

  @override
  Future<Result<List<Reciter>>> getAvailableReciters() async {
    return Result.success([
      const Reciter(id: '1', name: 'Abdul Basit (Murattal)'),
      const Reciter(id: '7', name: 'Mishary Rashid Alafasy'),
      const Reciter(id: '3', name: 'Abdurrahman As-Sudais'),
    ]);
  }

  Future<String> _getLocalPath(String reciterId, String surah, String ayah) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/audio/$reciterId/$surah$ayah.mp3';
  }
}
