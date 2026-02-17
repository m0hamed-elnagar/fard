import 'package:json_annotation/json_annotation.dart';
import 'package:fard/features/quran/domain/entities/surah.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';
import 'package:fard/features/quran/data/models/ayah_model.dart';

part 'surah_model.g.dart';

@JsonSerializable()
class SurahModel {
  final int id;
  @JsonKey(name: 'name_arabic')
  final String name;
  @JsonKey(name: 'name_simple')
  final String? englishName;
  @JsonKey(name: 'translated_name')
  final Map<String, dynamic>? translatedName;
  @JsonKey(name: 'verses_count')
  final int numberOfAyahs;
  @JsonKey(name: 'revelation_place')
  final String revelationType;
  @JsonKey(name: 'revelation_order')
  final int? revelationOrder;
  final List<AyahModel>? verses;

  const SurahModel({
    required this.id,
    required this.name,
    this.englishName,
    this.translatedName,
    required this.numberOfAyahs,
    required this.revelationType,
    this.revelationOrder,
    this.verses,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) => _$SurahModelFromJson(json);
  Map<String, dynamic> toJson() => _$SurahModelToJson(this);

  Surah toDomain() {
    final surahNumberResult = SurahNumber.create(id);
    return Surah(
      number: surahNumberResult.data!,
      name: name,
      englishName: englishName,
      englishNameTranslation: translatedName?['name'] as String?,
      numberOfAyahs: numberOfAyahs,
      revelationType: revelationType,
      revelationOrder: revelationOrder,
      ayahs: verses?.map((v) => v.toDomain(id)).toList() ?? [],
    );
  }
}
