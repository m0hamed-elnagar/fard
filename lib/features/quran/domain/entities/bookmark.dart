import 'package:equatable/equatable.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';

class Bookmark extends Equatable {
  final String id;
  final AyahNumber ayahNumber;
  final DateTime createdAt;
  final String? note;

  const Bookmark({
    required this.id,
    required this.ayahNumber,
    required this.createdAt,
    this.note,
  });

  @override
  List<Object?> get props => [id, ayahNumber, createdAt, note];

  Map<String, dynamic> toJson() => {
        'id': id,
        'surahNumber': ayahNumber.surahNumber,
        'ayahNumber': ayahNumber.ayahNumberInSurah,
        'createdAt': createdAt.toIso8601String(),
        'note': note,
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'],
      ayahNumber: AyahNumber.create(
        surahNumber: json['surahNumber'],
        ayahNumberInSurah: json['ayahNumber'],
      ).data!,
      createdAt: DateTime.parse(json['createdAt']),
      note: json['note'],
    );
  }
}
