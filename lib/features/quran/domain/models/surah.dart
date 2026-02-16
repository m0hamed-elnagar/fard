import 'package:freezed_annotation/freezed_annotation.dart';
import 'ayah.dart';

part 'surah.freezed.dart';
part 'surah.g.dart';

@freezed
sealed class Surah with _$Surah {
  const factory Surah({
    required int number,
    required String name,
    required String englishName,
    required String englishNameTranslation,
    required int numberOfAyahs,
    required String revelationType,
  }) = _Surah;

  factory Surah.fromJson(Map<String, dynamic> json) => _$SurahFromJson(json);
}

@freezed
sealed class SurahDetail with _$SurahDetail {
  const factory SurahDetail({
    required int number,
    required String name,
    required String englishName,
    required String englishNameTranslation,
    required String revelationType,
    required int numberOfAyahs,
    required List<Ayah> ayahs,
  }) = _SurahDetail;

  factory SurahDetail.fromJson(Map<String, dynamic> json) => _$SurahDetailFromJson(json);
}
