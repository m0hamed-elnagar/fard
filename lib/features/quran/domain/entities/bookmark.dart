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
}
