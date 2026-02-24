import 'package:hive_ce/hive_ce.dart';

part 'bookmark_entity.g.dart';

@HiveType(typeId: 6)
class BookmarkEntity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int surahNumber;

  @HiveField(2)
  final int ayahNumber;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final String? note;

  BookmarkEntity({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.createdAt,
    this.note,
  });
}
