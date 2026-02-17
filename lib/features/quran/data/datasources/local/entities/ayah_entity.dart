import 'package:hive_ce/hive_ce.dart';

part 'ayah_entity.g.dart';

@HiveType(typeId: 2)
class AyahEntity {
  @HiveField(0)
  final int surahNumber;
  @HiveField(1)
  final int ayahNumber;
  @HiveField(2)
  final String uthmaniText;
  @HiveField(3)
  final String? translation;
  @HiveField(4)
  final int page;
  @HiveField(5)
  final int juz;

  const AyahEntity({
    required this.surahNumber,
    required this.ayahNumber,
    required this.uthmaniText,
    this.translation,
    required this.page,
    required this.juz,
  });
}
