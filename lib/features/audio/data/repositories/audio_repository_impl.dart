import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/entities/audio_track.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AudioRepository)
class AudioRepositoryImpl implements AudioRepository {
  final http.Client client;

  AudioRepositoryImpl({required this.client});

  static const String _apiBaseUrl = 'https://api.alquran.cloud/v1';
  static const String _audioCdnBaseUrl =
      'https://cdn.islamic.network/quran/audio';
  static const String _recitersCacheKey = 'cached_reciters';

  static const Map<String, Map<int, String>> _everyAyahMapping = {
    'ar.alafasy': {64: 'Alafasy_64kbps', 128: 'Alafasy_128kbps'},
    'ar.husary': {64: 'Husary_64kbps', 128: 'Husary_128kbps'},
    'ar.minshawi': {128: 'Minshawy_Murattal_128kbps'},
    'ar.abdulbasitmurattal': {
      64: 'Abdul_Basit_Murattal_64kbps',
      192: 'Abdul_Basit_Murattal_192kbps',
    },
    'ar.ahmedajamy': {128: 'Ahmed_ibn_Ali_al-Ajamy_128kbps_ketaballah.net'},
    'ar.abdurrahmaansudais': {192: 'Abdurrahmaan_As-Sudais_192kbps'},
    'ar.saoodshuraym': {128: 'Saood_ash-Shuraym_128kbps'},
    'ar.mahermuaiqly': {128: 'MaherAlMuaiqly128kbps'},
    'ar.hudhaify': {128: 'Hudhaify_128kbps'},
    'ar.abdullahbasfar': {
      64: 'Abdullah_Basfar_64kbps',
      192: 'Abdullah_Basfar_192kbps',
    },
    'ar.ghamadi': {
      64: 'Ghamadi_40kbps',
      128: 'Ghamadi_40kbps',
    }, // 40kbps is the only one
    'ar.shatree': {
      64: 'Abu_Bakr_Ash-Shaatree_64kbps',
      128: 'Abu_Bakr_Ash-Shaatree_128kbps',
    },
    'ar.abdulbasitmujawwad': {128: 'Abdul_Basit_Mujawwad_128kbps'},
    'ar.minshawimujawwad': {
      64: 'Minshawy_Mujawwad_64kbps',
      128: 'Minshawy_Mujawwad_192kbps',
      192: 'Minshawy_Mujawwad_192kbps',
    },
    'ar.husarymuallim': {128: 'Husary_Muallim_128kbps'},
    'ar.aymanswayd': {64: 'Ayman_Sowaid_64kbps'},
    'ar.alijaber': {64: 'Ali_Jaber_64kbps'},
    'ar.yasseraldossari': {128: 'Yasser_Ad-Dussary_128kbps'},
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

        // Include all reciters from Al Quran Cloud as we have a CDN fallback for all
        final reciters = editions
            .map(
              (e) => Reciter(
                identifier: e['identifier'],
                name: e['name'],
                englishName: e['englishName'],
                language: e['language'],
                style: e['format'] == 'audio' ? null : e['format'],
              ),
            )
            .toList();

        // Ensure popular reciters that might be missing from API are added
        final requiredReciters = [
          const Reciter(
            identifier: 'ar.alijaber',
            name: 'علي جابر',
            englishName: 'Ali Jaber',
            language: 'ar',
            style: 'Murattal',
          ),
          const Reciter(
            identifier: 'ar.yasseraldossari',
            name: 'ياسر الدوسري',
            englishName: 'Yasser Al-Dosari',
            language: 'ar',
            style: 'Murattal',
          ),
        ];

        for (final required in requiredReciters) {
          if (!reciters.any((r) => r.identifier == required.identifier)) {
            reciters.add(required);
          }
        }

        await cacheReciters(reciters);
        return Result.success(reciters);
      } else {
        return Result.failure(
          ServerFailure('Failed to fetch reciters: ${response.statusCode}'),
        );
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
    7,
    286,
    200,
    176,
    120,
    165,
    206,
    75,
    129,
    109,
    123,
    111,
    43,
    52,
    99,
    128,
    111,
    110,
    98,
    135,
    112,
    78,
    118,
    64,
    77,
    227,
    93,
    88,
    69,
    60,
    34,
    30,
    73,
    54,
    45,
    83,
    182,
    88,
    75,
    85,
    54,
    53,
    89,
    59,
    37,
    35,
    38,
    29,
    18,
    45,
    60,
    49,
    62,
    55,
    78,
    96,
    29,
    22,
    24,
    13,
    14,
    11,
    11,
    18,
    12,
    12,
    30,
    52,
    52,
    44,
    28,
    28,
    20,
    56,
    40,
    31,
    50,
    40,
    46,
    42,
    29,
    19,
    36,
    25,
    22,
    17,
    19,
    26,
    30,
    20,
    15,
    21,
    11,
    8,
    8,
    19,
    5,
    8,
    8,
    11,
    11,
    8,
    3,
    9,
    5,
    4,
    7,
    3,
    6,
    3,
    5,
    4,
    5,
    6,
  ];

  int _getGlobalAyahNumber(int surah, int ayah) {
    int count = 0;
    for (int i = 0; i < surah - 1; i++) {
      count += _ayahCounts[i];
    }
    return count + ayah;
  }

  int _getActualBitrate(String reciterId, AudioQuality requested) {
    final requestedValue = int.tryParse(requested.kbps) ?? 128;
    final bitrates = _everyAyahMapping[reciterId]?.keys.toList();

    if (bitrates != null && bitrates.isNotEmpty) {
      bitrates.sort();
      // Find the best available bitrate that is <= requestedValue
      int best = bitrates.first;
      for (final available in bitrates) {
        if (available <= requestedValue) {
          best = available;
        }
      }
      return best;
    }

    return requestedValue;
  }

  bool _needsBismillahPrepend(int surahNumber, String reciterId) {
    // 1. Surah 1 (Al-Fatihah) and Surah 9 (At-Tawbah) NEVER need prepend.
    // Al-Fatihah's first ayah IS Bismillah. At-Tawbah doesn't have it.
    if (surahNumber == 1 || surahNumber == 9) return false;

    // 2. We prepend Bismillah for all other surahs.
    // Even if some reciters embed it in Ayah 1, playing it again is often preferred
    // to ensure it's always heard clearly at the start of a session.
    return true;
  }

  String _getRemoteAyahUrl({
    required String reciterId,
    required int surahNumber,
    required int ayahNumber,
    AudioQuality quality = AudioQuality.medium128,
  }) {
    final surahStr = surahNumber.toString().padLeft(3, '0');
    final ayahStr = ayahNumber.toString().padLeft(3, '0');

    final actualBitrate = _getActualBitrate(reciterId, quality);
    final mappedFolder = _everyAyahMapping[reciterId]?[actualBitrate];

    // If reciter and bitrate are explicitly mapped for EveryAyah
    if (mappedFolder != null) {
      return 'https://everyayah.com/data/$mappedFolder/$surahStr$ayahStr.mp3';
    }

    // Fallback to Islamic Network CDN for other bitrates or unmapped reciters
    final globalAyahNumber = _getGlobalAyahNumber(surahNumber, ayahNumber);
    return '$_audioCdnBaseUrl/$actualBitrate/$reciterId/$globalAyahNumber.mp3';
  }

  @override
  Future<AudioTrack> getAyahAudioTrack({
    required String reciterId,
    required int surahNumber,
    required int ayahNumber,
    AudioQuality quality = AudioQuality.medium128,
  }) async {
    final remoteUrl = _getRemoteAyahUrl(
      reciterId: reciterId,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      quality: quality,
    );

    final localPath = await _getLocalPath(reciterId, surahNumber, ayahNumber);

    final isDownloaded = await File(localPath).exists();

    return AudioTrack(
      remoteUrl: remoteUrl,
      localPath: localPath,
      isDownloaded: isDownloaded,
    );
  }

  @override
  Future<Result<List<AudioTrack>>> getSurahAudioTracks({
    required String reciterId,
    required int surahNumber,
    int? ayahCount,
    AudioQuality quality = AudioQuality.medium128,
  }) async {
    int count = ayahCount ?? 0;

    if (count == 0) {
      try {
        final response = await client.get(
          Uri.parse('$_apiBaseUrl/surah/$surahNumber'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          count = data['data']['numberOfAyahs'] as int;
        } else {
          return Result.failure(
            ServerFailure('Failed to fetch surah info: ${response.statusCode}'),
          );
        }
      } catch (e) {
        return Result.failure(UnknownFailure(e.toString()));
      }
    }

    final tracks = <Future<AudioTrack>>[];

    // Prepend Bismillah (1:1) if needed for this surah and reciter
    if (_needsBismillahPrepend(surahNumber, reciterId)) {
      tracks.add(
        getAyahAudioTrack(
          reciterId: reciterId,
          surahNumber: 1,
          ayahNumber: 1,
          quality: quality,
        ),
      );
    }

    tracks.addAll(
      List.generate(
        count,
        (i) => getAyahAudioTrack(
          reciterId: reciterId,
          surahNumber: surahNumber,
          ayahNumber: i + 1,
          quality: quality,
        ),
      ),
    );

    try {
      final resolvedTracks = await Future.wait(tracks);
      return Result.success(resolvedTracks);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  bool shouldPrependBismillah(int surahNumber, String reciterId) {
    return _needsBismillahPrepend(surahNumber, reciterId);
  }

  @override
  Future<Result<AudioTrack>> getAudioUrl({
    required AyahNumber ayah,
    required String reciterId,
    required AudioQuality quality,
    String? audioUrl,
  }) async {
    // Legacy method mapped to new implementation
    try {
      final track = await getAyahAudioTrack(
        reciterId: reciterId,
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumberInSurah,
        quality: quality,
      );
      return Result.success(track);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<GaplessAudioSource>> getGaplessSurahAudio(
    SurahNumber surah,
    String reciterId,
  ) async {
    // Al Quran Cloud doesn't strictly have a gapless single-file API like Quran.com,
    // but we can use ConcatenatingAudioSource in the player.
    return Result.failure(
      const UnknownFailure('Use ConcatenatingAudioSource for gapless playback'),
    );
  }

  @override
  Future<Result<void>> downloadAudio({
    required AyahNumber ayah,
    required String reciterId,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final track = await getAyahAudioTrack(
        reciterId: reciterId,
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumberInSurah,
        quality: AudioQuality.medium128,
      );

      final response = await client.get(Uri.parse(track.remoteUrl));
      if (response.statusCode == 200) {
        final file = File(track.localPath);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(response.bodyBytes);
        return Result.success(null);
      } else {
        return Result.failure(
          ServerFailure('Failed to download audio: ${response.statusCode}'),
        );
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
    final localPath = await _getLocalPath(
      reciterId,
      ayah.surahNumber,
      ayah.ayahNumberInSurah,
    );
    return Result.success(await File(localPath).exists());
  }

  @override
  Future<void> cacheReciters(List<Reciter> reciters) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = reciters
        .map(
          (r) => {
            'identifier': r.identifier,
            'name': r.name,
            'englishName': r.englishName,
            'language': r.language,
            'style': r.style,
          },
        )
        .toList();
    await prefs.setString(_recitersCacheKey, json.encode(jsonList));
  }

  @override
  Future<Result<List<Reciter>>> getCachedReciters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_recitersCacheKey);
      List<Reciter> reciters = [];
      if (cachedJson != null) {
        final List<dynamic> decoded = json.decode(cachedJson);
        reciters = decoded
            .map(
              (e) => Reciter(
                identifier: e['identifier'],
                name: e['name'],
                englishName: e['englishName'],
                language: e['language'],
                style: e['style'],
              ),
            )
            .toList();
      }

      // Ensure popular reciters that might be missing from cache are added
      final requiredReciters = [
        const Reciter(
          identifier: 'ar.alijaber',
          name: 'علي جابر',
          englishName: 'Ali Jaber',
          language: 'ar',
        ),
        const Reciter(
          identifier: 'ar.yasseraldossari',
          name: 'ياسر الدوسري',
          englishName: 'Yasser Al-Dosari',
          language: 'ar',
        ),
      ];

      for (final required in requiredReciters) {
        if (!reciters.any((r) => r.identifier == required.identifier)) {
          reciters.add(required);
        }
      }

      return Result.success(reciters);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  static const String _reciterDataCacheKey = 'cached_reciter_data';

  @override
  Future<void> cacheReciterData(
    Map<String, double> progress,
    Map<String, int> sizes,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {'progress': progress, 'sizes': sizes};
    await prefs.setString(_reciterDataCacheKey, json.encode(data));
  }

  @override
  Future<ReciterData> getCachedReciterData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_reciterDataCacheKey);
      if (jsonString != null) {
        final Map<String, dynamic> data = json.decode(jsonString);
        return ReciterData(
          progress: Map<String, double>.from(data['progress'] ?? {}),
          sizes: Map<String, int>.from(data['sizes'] ?? {}),
        );
      }
    } catch (e) {
      // Ignore errors and return empty
    }
    return const ReciterData(progress: {}, sizes: {});
  }

  @override
  int getAyahCount(int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) return 0;
    return _ayahCounts[surahNumber - 1];
  }

  Future<String> _getLocalPath(String reciterId, int surah, int ayah) async {
    final directory = await getApplicationDocumentsDirectory();
    final surahStr = surah.toString().padLeft(3, '0');
    final ayahStr = ayah.toString().padLeft(3, '0');
    return '${directory.path}/audio/$reciterId/$surahStr$ayahStr.mp3';
  }
}
