import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';

class AppBackup {
  final int version;
  final String appVersion;
  final DateTime timestamp;
  final List<DailyRecord> prayerRecords;
  final List<WerdGoal> werdGoals;
  final List<WerdProgress> werdProgress;
  final Map<String, dynamic> preferences;
  final Map<String, int> tasbihHistory;
  final Map<String, int> tasbihProgress;
  final Map<String, String> tasbihPreferredDuas;
  final Map<String, int> azkarProgress;
  final List<Bookmark> bookmarks;

  AppBackup({
    required this.version,
    required this.appVersion,
    required this.timestamp,
    required this.prayerRecords,
    required this.werdGoals,
    required this.werdProgress,
    this.preferences = const {},
    this.tasbihHistory = const {},
    this.tasbihProgress = const {},
    this.tasbihPreferredDuas = const {},
    this.azkarProgress = const {},
    this.bookmarks = const [],
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'appVersion': appVersion,
        'timestamp': timestamp.toIso8601String(),
        'prayerRecords': prayerRecords.map((e) => e.toJson()).toList(),
        'werdGoals': werdGoals.map((e) => e.toJson()).toList(),
        'werdProgress': werdProgress.map((e) => e.toJson()).toList(),
        'preferences': preferences,
        'tasbihHistory': tasbihHistory,
        'tasbihProgress': tasbihProgress,
        'tasbihPreferredDuas': tasbihPreferredDuas,
        'azkarProgress': azkarProgress,
        'bookmarks': bookmarks.map((e) => e.toJson()).toList(),
      };

  factory AppBackup.fromJson(Map<String, dynamic> json) {
    return AppBackup(
      version: json['version'],
      appVersion: json['appVersion'] ?? 'unknown',
      timestamp: DateTime.parse(json['timestamp']),
      prayerRecords: (json['prayerRecords'] as List)
          .map((e) => DailyRecord.fromJson(e))
          .toList(),
      werdGoals: (json['werdGoals'] as List)
          .map((e) => WerdGoal.fromJson(e))
          .toList(),
      werdProgress: (json['werdProgress'] as List)
          .map((e) => WerdProgress.fromJson(e))
          .toList(),
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
      tasbihHistory: Map<String, int>.from(json['tasbihHistory'] ?? {}),
      tasbihProgress: Map<String, int>.from(json['tasbihProgress'] ?? {}),
      tasbihPreferredDuas:
          Map<String, String>.from(json['tasbihPreferredDuas'] ?? {}),
      azkarProgress: Map<String, int>.from(json['azkarProgress'] ?? {}),
      bookmarks: (json['bookmarks'] as List?)
              ?.map((e) => Bookmark.fromJson(e))
              .toList() ??
          [],
    );
  }
}
