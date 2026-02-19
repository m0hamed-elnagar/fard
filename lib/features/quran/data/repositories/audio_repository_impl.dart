import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/entities/reciter.dart';
import 'package:fard/features/quran/domain/repositories/audio_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioRepositoryImpl implements AudioRepository {
  final http.Client client;

  AudioRepositoryImpl({required this.client});

  static const String _apiBaseUrl = 'https://api.alquran.cloud/v1';
  static const String _audioCdnBaseUrl = 'https://cdn.islamic.network/quran/audio';
  static const String _recitersCacheKey = 'cached_reciters';

  static const Map<String, String> _reciterEveryAyahMap = {
    'ar.alafasy': 'Alafasy_128kbps',
    'ar.husary': 'Husary_128kbps',
    'ar.minshawi': 'Minshawy_Murattal_128kbps',
    'ar.abdulbasitmurattal': 'Abdul_Basit_Murattal_192kbps',
    'ar.ahmedajamy': 'Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net',
    'ar.abdurrahmaansudais': 'Abdurrahmaan_As-Sudais_192kbps',
    'ar.saoodshuraym': 'Saood_ash-Shuraym_128kbps',
    'ar.mahermuaiqly': 'MaherAlMuaiqly128kbps',
    'ar.hudhaify': 'Hudhaify_128kbps',
    'ar.abdullahbasfar': 'Abdullah_Basfar_192kbps',
  };

  @override
  Future<Result<List<Reciter>>> getAvailableReciters() async {
    try {
      final response = await client.get(
        Uri.parse('$_apiBaseUrl/edition?format=audio&language=ar'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> editions = data['data'];
        
        // Only include reciters that we have mapped to reliable sources (EveryAyah)
        final reciters = editions
            .where((e) => _reciterEveryAyahMap.containsKey(e['identifier']))
            .map((e) => Reciter(
          identifier: e['identifier'],
          name: e['name'],
          englishName: e['englishName'],
          language: e['language'],
          style: e['format'] == 'audio' ? null : e['format'],
        )).toList();
        
        await cacheReciters(reciters);
        return Result.success(reciters);
      } else {
        return Result.failure(ServerFailure('Failed to fetch reciters: ${response.statusCode}'));
      }
    } catch (e) {
      // Try to return cached if available
      final cached = await getCachedReciters();
      if (cached.isSuccess && cached.data!.isNotEmpty) {
        return cached;
      }
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  static const List<int> _ayahCounts = [
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128,
    111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73,
    54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60,
    49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52,
    44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19,
    26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3,
    6, 3, 5, 4, 5, 6
  ];

  int _getGlobalAyahNumber(int surah, int ayah) {
    int count = 0;
    for (int i = 0; i < surah - 1; i++) {
      count += _ayahCounts[i];
    }
    return count + ayah;
  }

  @override
  String getAyahAudioUrl({
    required String reciterId,
    required int surahNumber,
    required int ayahNumber,
    AudioQuality quality = AudioQuality.high128,
  }) {
    final surahStr = surahNumber.toString().padLeft(3, '0');
    final ayahStr = ayahNumber.toString().padLeft(3, '0');
    
    if (_reciterEveryAyahMap.containsKey(reciterId)) {
      return 'https://everyayah.com/data/${_reciterEveryAyahMap[reciterId]}/$surahStr$ayahStr.mp3';
    }

    final globalAyahNumber = _getGlobalAyahNumber(surahNumber, ayahNumber);
    return '$_audioCdnBaseUrl/${quality.kbps}/$reciterId/$globalAyahNumber.mp3';
  }

  @override
  Future<Result<List<String>>> getSurahAudioUrls({
    required String reciterId,
    required int surahNumber,
    int? ayahCount,
    AudioQuality quality = AudioQuality.high128,
  }) async {
    int count = ayahCount ?? 0;
    
    if (count == 0) {
      try {
        final response = await client.get(Uri.parse('$_apiBaseUrl/surah/$surahNumber'));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          count = data['data']['numberOfAyahs'] as int;
        } else {
          return Result.failure(ServerFailure('Failed to fetch surah info: ${response.statusCode}'));
        }
      } catch (e) {
        return Result.failure(UnknownFailure(e.toString()));
      }
    }

    final urls = List.generate(
      count, 
      (i) => getAyahAudioUrl(
        reciterId: reciterId, 
        surahNumber: surahNumber, 
        ayahNumber: i + 1,
        quality: quality,
      )
    );
    return Result.success(urls);
  }

  @override
  Future<Result<AudioSource>> getAudioUrl({
    required AyahNumber ayah,
    required String reciterId,
    required AudioQuality quality,
    String? audioUrl,
  }) async {
    final url = audioUrl ?? getAyahAudioUrl(
      reciterId: reciterId, 
      surahNumber: ayah.surahNumber, 
      ayahNumber: ayah.ayahNumberInSurah,
      quality: quality,
    );
    
    // Check local storage
    final localPath = await _getLocalPath(reciterId, ayah.surahNumber.toString(), ayah.ayahNumberInSurah.toString());
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
    // Al Quran Cloud doesn't strictly have a gapless single-file API like Quran.com,
    // but we can use ConcatenatingAudioSource in the player.
    return Result.failure(const UnknownFailure('Use ConcatenatingAudioSource for gapless playback'));
  }

  @override
  Future<Result<void>> downloadAudio({
    required AyahNumber ayah,
    required String reciterId,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final audioResult = await getAudioUrl(
        ayah: ayah, 
        reciterId: reciterId, 
        quality: AudioQuality.high128,
      );
      
      if (audioResult.isFailure) return Result.failure(audioResult.failure!);
      final url = audioResult.data!.url;
      
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final localPath = await _getLocalPath(reciterId, ayah.surahNumber.toString(), ayah.ayahNumberInSurah.toString());
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
    final localPath = await _getLocalPath(reciterId, ayah.surahNumber.toString(), ayah.ayahNumberInSurah.toString());
    return Result.success(await File(localPath).exists());
  }

  @override
  Future<void> cacheReciters(List<Reciter> reciters) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = reciters.map((r) => {
      'identifier': r.identifier,
      'name': r.name,
      'englishName': r.englishName,
      'language': r.language,
      'style': r.style,
    }).toList();
    await prefs.setString(_recitersCacheKey, json.encode(jsonList));
  }

  @override
  Future<Result<List<Reciter>>> getCachedReciters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_recitersCacheKey);
      if (cachedJson != null) {
        final List<dynamic> decoded = json.decode(cachedJson);
        final reciters = decoded.map((e) => Reciter(
          identifier: e['identifier'],
          name: e['name'],
          englishName: e['englishName'],
          language: e['language'],
          style: e['style'],
        )).toList();
        return Result.success(reciters);
      }
      return Result.success([]);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  Future<String> _getLocalPath(String reciterId, String surah, String ayah) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/audio/$reciterId/$surah$ayah.mp3';
  }
}
