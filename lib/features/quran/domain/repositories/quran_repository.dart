import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/entities/page.dart';
import 'package:fard/features/quran/domain/entities/juz.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:equatable/equatable.dart';

abstract interface class QuranRepository {
  Future<Result<List<Surah>>> getSurahs();
  Future<Result<Surah>> getSurah(SurahNumber number, {String? translation});
  Future<Result<MushafPage>> getPage(int pageNumber, {String? translation});
  Future<Result<Juz>> getJuz(int juzNumber, {String? translation});
  Future<Result<List<SearchResult>>> search(String query);
  Future<Result<List<Translation>>> getAvailableTranslations();
  Stream<Result<LastReadPosition>> watchLastReadPosition();
  Future<Result<void>> updateLastReadPosition(LastReadPosition position);
  Future<Result<String>> getTafsir(int surahNumber, int ayahNumber, {int? tafsirId});
  Stream<double> downloadAllSurahs();
}

class SearchResult extends Equatable {
  final AyahNumber ayahNumber;
  final String text;
  final String? translation;

  const SearchResult({
    required this.ayahNumber,
    required this.text,
    this.translation,
  });

  @override
  List<Object?> get props => [ayahNumber, text, translation];
}

class Translation extends Equatable {
  final String id;
  final String name;
  final String language;

  const Translation({
    required this.id,
    required this.name,
    required this.language,
  });

  @override
  List<Object?> get props => [id, name, language];
}

class LastReadPosition extends Equatable {
  final AyahNumber ayahNumber;
  final DateTime updatedAt;

  const LastReadPosition({
    required this.ayahNumber,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [ayahNumber, updatedAt];
}
