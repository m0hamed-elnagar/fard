import 'package:hive_ce/hive_ce.dart';
import 'ayah_entity.dart';

part 'surah_entity.g.dart';

@HiveType(typeId: 1)
class SurahEntity {
  @HiveField(0)
  final int number;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String? englishName;
  @HiveField(3)
  final String? englishNameTranslation;
  @HiveField(4)
  final int numberOfAyahs;
  @HiveField(5)
  final String revelationType;
  @HiveField(6)
  final List<AyahEntity> ayahs;

  const SurahEntity({
    required this.number,
    required this.name,
    this.englishName,
    this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
    required this.ayahs,
  });
}
