import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';

class AppBackup {
  final int version;
  final String appVersion;
  final DateTime timestamp;
  final List<DailyRecord> prayerRecords;
  final List<WerdGoal> werdGoals;
  final List<WerdProgress> werdProgress;

  AppBackup({
    required this.version,
    required this.appVersion,
    required this.timestamp,
    required this.prayerRecords,
    required this.werdGoals,
    required this.werdProgress,
  });

  Map<String, dynamic> toJson() => {
    'version': version,
    'appVersion': appVersion,
    'timestamp': timestamp.toIso8601String(),
    'prayerRecords': prayerRecords.map((e) => e.toJson()).toList(),
    'werdGoals': werdGoals.map((e) => e.toJson()).toList(),
    'werdProgress': werdProgress.map((e) => e.toJson()).toList(),
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
    );
  }
}
