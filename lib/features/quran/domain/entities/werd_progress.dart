import 'package:equatable/equatable.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';

class WerdProgress extends Equatable {
  final int totalAyahsReadToday;
  final AyahNumber? lastReadAyah;
  final int? lastReadAbsolute;
  final DateTime lastUpdated;
  final int streak;

  const WerdProgress({
    required this.totalAyahsReadToday,
    this.lastReadAyah,
    this.lastReadAbsolute,
    required this.lastUpdated,
    required this.streak,
  });

  @override
  List<Object?> get props => [
    totalAyahsReadToday, 
    lastReadAyah, 
    lastReadAbsolute, 
    lastUpdated, 
    streak
  ];

  Map<String, dynamic> toJson() => {
    'totalAyahsReadToday': totalAyahsReadToday,
    'lastReadAyahSurah': lastReadAyah?.surahNumber,
    'lastReadAyahNumber': lastReadAyah?.ayahNumberInSurah,
    'lastReadAbsolute': lastReadAbsolute,
    'lastUpdated': lastUpdated.toIso8601String(),
    'streak': streak,
  };

  factory WerdProgress.fromJson(Map<String, dynamic> json) {
    AyahNumber? ayah;
    if (json['lastReadAyahSurah'] != null && json['lastReadAyahNumber'] != null) {
      ayah = AyahNumber.create(
        surahNumber: json['lastReadAyahSurah'],
        ayahNumberInSurah: json['lastReadAyahNumber'],
      ).data;
    }

    return WerdProgress(
      totalAyahsReadToday: json['totalAyahsReadToday'] ?? 0,
      lastReadAyah: ayah,
      lastReadAbsolute: json['lastReadAbsolute'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      streak: json['streak'] ?? 0,
    );
  }
}
