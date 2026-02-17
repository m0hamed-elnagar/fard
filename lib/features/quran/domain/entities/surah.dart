import 'package:equatable/equatable.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';
import 'package:fard/features/quran/domain/value_objects/surah_number.dart';

class Surah extends Equatable {
  final SurahNumber number;
  final String name;
  final String? englishName;
  final String? englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;
  final int? revelationOrder;
  final List<Ayah> ayahs;

  const Surah({
    required this.number,
    required this.name,
    this.englishName,
    this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    this.revelationOrder,
    required this.ayahs,
  });

  Surah copyWith({
    SurahNumber? number,
    String? name,
    String? englishName,
    String? englishNameTranslation,
    int? numberOfAyahs,
    String? revelationType,
    int? revelationOrder,
    List<Ayah>? ayahs,
  }) {
    return Surah(
      number: number ?? this.number,
      name: name ?? this.name,
      englishName: englishName ?? this.englishName,
      englishNameTranslation: englishNameTranslation ?? this.englishNameTranslation,
      numberOfAyahs: numberOfAyahs ?? this.numberOfAyahs,
      revelationType: revelationType ?? this.revelationType,
      revelationOrder: revelationOrder ?? this.revelationOrder,
      ayahs: ayahs ?? this.ayahs,
    );
  }

  @override
  List<Object?> get props => [
        number,
        name,
        englishName,
        englishNameTranslation,
        numberOfAyahs,
        revelationType,
        revelationOrder,
        ayahs,
      ];
}
