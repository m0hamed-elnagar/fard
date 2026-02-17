import 'package:equatable/equatable.dart';
import 'package:fard/features/quran/domain/entities/ayah.dart';

class MushafPage extends Equatable {
  final int number;
  final List<Ayah> ayahs;
  final int juz;
  final String surahName;

  const MushafPage({
    required this.number,
    required this.ayahs,
    required this.juz,
    required this.surahName,
  });

  @override
  List<Object?> get props => [number, ayahs, juz, surahName];
}
