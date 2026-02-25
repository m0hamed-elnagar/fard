import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/entities/page.dart';
import 'package:fard/features/quran/domain/entities/juz.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/data/datasources/remote/quran_remote_source.dart';
import 'package:fard/features/quran/data/datasources/local/quran_local_source.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class QuranRepositoryImpl implements QuranRepository {
  final QuranRemoteSource remoteSource;
  final QuranLocalSource localSource;
  final SharedPreferences sharedPreferences;

  final _lastReadController = StreamController<Result<LastReadPosition>>.broadcast();
  static const String _lastReadKey = 'last_read_position';

  QuranRepositoryImpl({
    required this.remoteSource,
    required this.localSource,
    required this.sharedPreferences,
  }) {
    // Emit initial value
    final initial = _getCachedLastRead();
    if (initial != null) {
      _lastReadController.add(Result.success(initial));
    }
  }

  LastReadPosition? _getCachedLastRead() {
    final jsonStr = sharedPreferences.getString(_lastReadKey);
    if (jsonStr == null) return null;
    try {
      final Map<String, dynamic> data = json.decode(jsonStr);
      return LastReadPosition(
        ayahNumber: AyahNumber.create(
          surahNumber: data['surah'],
          ayahNumberInSurah: data['ayah'],
        ).data!,
        updatedAt: DateTime.parse(data['updatedAt']),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<List<Surah>>> getSurahs() async {
    try {
      debugPrint('Repository: getSurahs called');
      // Try local first
      final cached = await localSource.getCachedSurahs();
      if (cached.isNotEmpty) {
        debugPrint('Repository: Found ${cached.length} cached surahs');
        // Optionally refresh in background
        _refreshSurahs();
        return Result.success(cached);
      }

      debugPrint('Repository: Fetching surahs from remote');
      final surahModels = await remoteSource.getAllSurahs();
      debugPrint('Repository: Fetched ${surahModels.length} surahs from remote');
      final surahs = surahModels.map((m) => m.toDomain()).toList();
      
      // Cache
      await localSource.cacheSurahs(surahs);
      debugPrint('Repository: Cached surahs');
      
      return Result.success(surahs);
    } on ServerFailure catch (e) {
      debugPrint('Repository: ServerFailure in getSurahs: ${e.message}');
      return Result.failure(e);
    } catch (e, stack) {
      debugPrint('Repository: Unknown error in getSurahs: $e');
      debugPrint(stack.toString());
      return Result.failure(const UnknownFailure());
    }
  }

  Future<void> _refreshSurahs() async {
    try {
      final surahModels = await remoteSource.getAllSurahs();
      final surahs = surahModels.map((m) => m.toDomain()).toList();
      await localSource.cacheSurahs(surahs);
    } catch (_) {}
  }

  @override
  Future<Result<Surah>> getSurah(SurahNumber number, {String? translation}) async {
    try {
      // Try local first
      final cached = await localSource.getCachedSurahDetail(number.value);
      if (cached != null && 
          cached.ayahs.isNotEmpty && 
          cached.ayahs.length == cached.numberOfAyahs &&
          cached.ayahs.first.audioUrl != null) {
        debugPrint('Found complete cached surah with audio: ${number.value}');
        return Result.success(cached);
      }

      debugPrint('Fetching surah detail for: ${number.value} (Cache incomplete, missing audio or missing)');
      final surahModel = await remoteSource.getSurahDetail(number.value);
      debugPrint('Fetching verses for: ${number.value}');
      final verses = await remoteSource.getSurahVerses(number.value);
      
      // Combine them
      final sortedAyahs = verses.map((v) => v.toDomain(number.value)).toList()
        ..sort((a, b) => a.number.ayahNumberInSurah.compareTo(b.number.ayahNumberInSurah));

      final surah = surahModel.toDomain().copyWith(
        ayahs: sortedAyahs,
      );
      
      // Cache
      await localSource.cacheSurahDetail(surah);
      
      return Result.success(surah);
    } on ServerFailure catch (e) {
      debugPrint('ServerFailure in getSurah: ${e.message}');
      return Result.failure(e);
    } catch (e, stack) {
      debugPrint('Unknown error in getSurah: $e');
      debugPrint(stack.toString());
      return Result.failure(const UnknownFailure());
    }
  }


  @override
  Future<Result<MushafPage>> getPage(int pageNumber, {String? translation}) async {
    // Implementation for getting page
    return Result.failure(const UnknownFailure('Not implemented yet'));
  }

  @override
  Future<Result<Juz>> getJuz(int juzNumber, {String? translation}) async {
     return Result.failure(const UnknownFailure('Not implemented yet'));
  }

  @override
  Future<Result<List<SearchResult>>> search(String query) async {
     return Result.failure(const UnknownFailure('Not implemented yet'));
  }

  @override
  Future<Result<List<Translation>>> getAvailableTranslations() async {
     return Result.failure(const UnknownFailure('Not implemented yet'));
  }

  @override
  Stream<Result<LastReadPosition>> watchLastReadPosition() {
    // Start with current value
    final current = _getCachedLastRead();
    if (current != null) {
      Timer.run(() => _lastReadController.add(Result.success(current)));
    } else {
      Timer.run(() => _lastReadController.add(Result.failure(const CacheFailure('No last read position found'))));
    }
    return _lastReadController.stream;
  }

  @override
  Future<Result<void>> updateLastReadPosition(LastReadPosition position) async {
    try {
      final jsonStr = json.encode({
        'surah': position.ayahNumber.surahNumber,
        'ayah': position.ayahNumber.ayahNumberInSurah,
        'updatedAt': position.updatedAt.toIso8601String(),
      });
      await sharedPreferences.setString(_lastReadKey, jsonStr);
      _lastReadController.add(Result.success(position));
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<String>> getTafsir(int surahNumber, int ayahNumber, {int? tafsirId}) async {
    try {
      final tafsir = await remoteSource.getTafsir(surahNumber, ayahNumber, tafsirId: tafsirId ?? 16);
      return Result.success(tafsir);
    } on ServerFailure catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }
}
