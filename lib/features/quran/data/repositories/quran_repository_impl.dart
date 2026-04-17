import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/entities/page.dart';
import 'package:fard/features/quran/domain/entities/juz.dart';
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:fard/features/quran/data/datasources/remote/quran_remote_source.dart';
import 'package:fard/features/quran/data/datasources/local/quran_local_source.dart';
import 'package:fard/features/quran/presentation/utils/quran_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:injectable/injectable.dart';

@LazySingleton(as: QuranRepository)
class QuranRepositoryImpl implements QuranRepository {
  final QuranRemoteSource remoteSource;
  final QuranLocalSource localSource;
  final SharedPreferences sharedPreferences;

  final _lastReadController =
      StreamController<Result<LastReadPosition>>.broadcast();
  static const String _lastReadKey = 'last_read_position';
  static const String _separatorKey = 'reader_separator_choice';
  static const String _textScaleKey = 'reader_text_scale';
  static const String _fontFamilyKey = 'reader_font_family';

  QuranRepositoryImpl({
    required this.remoteSource,
    required this.localSource,
    required this.sharedPreferences,
  }) {
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
      final cached = await localSource.getCachedSurahs();
      if (cached.isNotEmpty) {
        _refreshSurahs();
        return Result.success(cached);
      }
      final surahModels = await remoteSource.getAllSurahs();
      final surahs = surahModels.map((m) => m.toDomain()).toList();
      await localSource.cacheSurahs(surahs);
      return Result.success(surahs);
    } catch (e) {
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
  Future<Result<Surah>> getSurah(
    SurahNumber number, {
    String? translation,
  }) async {
    try {
      final cached = await localSource.getCachedSurahDetail(number.value);
      if (cached != null &&
          cached.ayahs.isNotEmpty &&
          cached.ayahs.length == cached.numberOfAyahs) {
        return Result.success(cached);
      }
      final surahModel = await remoteSource.getSurahDetail(number.value);
      final verses = await remoteSource.getSurahVerses(number.value);
      final sortedAyahs = verses.map((v) => v.toDomain(number.value)).toList()
        ..sort(
          (a, b) =>
              a.number.ayahNumberInSurah.compareTo(b.number.ayahNumberInSurah),
        );
      final surah = surahModel.toDomain().copyWith(ayahs: sortedAyahs);
      await localSource.cacheSurahDetail(surah);
      return Result.success(surah);
    } catch (e) {
      return Result.failure(const UnknownFailure());
    }
  }

  @override
  Future<Result<MushafPage>> getPage(
    int pageNumber, {
    String? translation,
  }) async {
    return Result.failure(const UnknownFailure('Not implemented'));
  }

  @override
  Future<Result<Juz>> getJuz(int juzNumber, {String? translation}) async {
    return Result.failure(const UnknownFailure('Not implemented'));
  }

  @override
  Future<Result<List<SearchResult>>> search(String query) async {
    return Result.failure(const UnknownFailure('Not implemented'));
  }

  @override
  Future<Result<List<Translation>>> getAvailableTranslations() async {
    return Result.failure(const UnknownFailure('Not implemented'));
  }

  @override
  Stream<Result<LastReadPosition>> watchLastReadPosition() {
    final current = _getCachedLastRead();
    if (current != null) {
      Timer.run(() => _lastReadController.add(Result.success(current)));
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
  Future<int> getReaderSeparator() async {
    return sharedPreferences.getInt(_separatorKey) ?? 0;
  }

  @override
  Future<void> updateReaderSeparator(int separatorIndex) async {
    await sharedPreferences.setInt(_separatorKey, separatorIndex);
  }

  @override
  Future<double> getTextScale() async {
    return sharedPreferences.getDouble(_textScaleKey) ?? 1.0;
  }

  @override
  Future<void> updateTextScale(double scale) async {
    await sharedPreferences.setDouble(_textScaleKey, scale);
  }

  @override
  Future<String> getFontFamily() async {
    final saved = sharedPreferences.getString(_fontFamilyKey) ?? QuranFonts.defaultFont;
    // Validate against whitelist - auto-fix any invalid stored values
    return QuranFonts.safeFont(saved);
  }

  @override
  Future<void> updateFontFamily(String fontFamily) async {
    await sharedPreferences.setString(_fontFamilyKey, fontFamily);
  }

  @override
  Future<Result<String>> getTafsir(
    int surahNumber,
    int ayahNumber, {
    int? tafsirId,
  }) async {
    try {
      final tafsir = await remoteSource.getTafsir(
        surahNumber,
        ayahNumber,
        tafsirId: tafsirId ?? 16,
      );
      return Result.success(tafsir);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  bool _isTextDownloadCancelled = false;

  @override
  Stream<double> downloadAllSurahs() async* {
    _isTextDownloadCancelled = false;
    try {
      // Step 1: Ensure we have the basic list of surahs
      final surahsResult = await getSurahs();
      if (!surahsResult.isSuccess) {
        yield 0.0;
        return;
      }

      final surahs = surahsResult.data!;
      int totalSurahs = surahs.length;

      // Step 2: Calculate initial progress and track what's downloaded
      int downloaded = 0;
      List<bool> isDownloaded = List.filled(totalSurahs + 1, false);
      for (int i = 1; i <= totalSurahs; i++) {
        final cached = await localSource.getCachedSurahDetail(i);
        if (cached != null &&
            cached.ayahs.isNotEmpty &&
            cached.ayahs.length == cached.numberOfAyahs) {
          downloaded++;
          isDownloaded[i] = true;
        }
      }
      yield downloaded / totalSurahs;

      if (downloaded == totalSurahs) {
        yield 1.0;
        return;
      }

      // Step 3: Download missing surahs
      for (int i = 1; i <= totalSurahs; i++) {
        if (_isTextDownloadCancelled) {
          yield downloaded / totalSurahs;
          return;
        }
        if (isDownloaded[i]) continue;

        final surahNum = SurahNumber.create(i).data!;
        final result = await getSurah(surahNum);
        if (result.isSuccess) {
          downloaded++;
          yield downloaded / totalSurahs;
        }
      }

      yield 1.0;
    } catch (_) {
      yield 0.0;
    }
  }

  @override
  Future<void> cancelTextDownload() async {
    _isTextDownloadCancelled = true;
  }

  @override
  Future<double> getTextDownloadProgress() async {
    try {
      int totalSurahs = 114;
      int downloaded = 0;
      for (int i = 1; i <= totalSurahs; i++) {
        final cached = await localSource.getCachedSurahDetail(i);
        if (cached != null &&
            cached.ayahs.isNotEmpty &&
            cached.ayahs.length == cached.numberOfAyahs) {
          downloaded++;
        }
      }
      return downloaded / totalSurahs;
    } catch (_) {
      return 0.0;
    }
  }
}
