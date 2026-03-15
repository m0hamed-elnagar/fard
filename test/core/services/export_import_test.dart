import 'dart:convert';
import 'package:fard/core/services/app_backup_dto.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/werd_history_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppBackup DTO Serialization Tests', () {
    test('Should survive full round-trip serialization with complex data', () {
      // 1. Prepare complex data
      final prayerRecords = [
        DailyRecord(
          id: '2024-01-01',
          date: DateTime(2024, 1, 1),
          missedToday: {Salaah.fajr, Salaah.asr},
          completedToday: {Salaah.dhuhr, Salaah.maghrib, Salaah.isha},
          qada: {
            Salaah.fajr: const MissedCounter(10),
            Salaah.dhuhr: const MissedCounter(5),
          },
          completedQada: {
            Salaah.fajr: 2,
          },
        ),
      ];

      final werdGoals = [
        WerdGoal(
          id: 'goal-1',
          type: WerdGoalType.fixedAmount,
          value: 10,
          unit: WerdUnit.page,
          startDate: DateTime(2024, 1, 1),
          category: WerdCategory.quran,
          startAbsolute: 1,
        ),
      ];

      final werdProgress = [
        WerdProgress(
          goalId: 'goal-1',
          totalAmountReadToday: 5,
          readItemsToday: {1, 2, 3},
          lastReadAbsolute: 3,
          lastUpdated: DateTime(2024, 1, 1),
          streak: 5,
          history: {
            '2024-01-01': const WerdHistoryEntry(
              totalAyahsRead: 5,
              startAbsolute: 1,
              endAbsolute: 5,
              pagesRead: 1.0,
              juzRead: 0.1,
              startSurahName: 'Al-Baqarah',
              startAyahNumber: 1,
              endSurahName: 'Al-Baqarah',
              endAyahNumber: 5,
              summary: 'Read 5 ayahs',
            ),
          },
        ),
      ];

      final originalBackup = AppBackup(
        version: 1,
        appVersion: '1.3.0',
        timestamp: DateTime(2024, 1, 1),
        prayerRecords: prayerRecords,
        werdGoals: werdGoals,
        werdProgress: werdProgress,
      );

      // 2. Serialize to JSON
      final jsonMap = originalBackup.toJson();
      final jsonString = json.encode(jsonMap);

      // 3. Deserialize back
      final decodedMap = json.decode(jsonString);
      final restoredBackup = AppBackup.fromJson(decodedMap);

      // 4. Assertions
      expect(restoredBackup.version, originalBackup.version);
      expect(restoredBackup.appVersion, originalBackup.appVersion);
      
      // Prayer Records Check
      expect(restoredBackup.prayerRecords.length, originalBackup.prayerRecords.length);
      expect(restoredBackup.prayerRecords.first.id, originalBackup.prayerRecords.first.id);
      expect(restoredBackup.prayerRecords.first.missedToday, originalBackup.prayerRecords.first.missedToday);
      expect(restoredBackup.prayerRecords.first.qada[Salaah.fajr]?.value, originalBackup.prayerRecords.first.qada[Salaah.fajr]?.value);
      expect(restoredBackup.prayerRecords.first.completedQada[Salaah.fajr], originalBackup.prayerRecords.first.completedQada[Salaah.fajr]);

      // Werd Goals Check
      expect(restoredBackup.werdGoals.length, originalBackup.werdGoals.length);
      expect(restoredBackup.werdGoals.first.id, originalBackup.werdGoals.first.id);
      expect(restoredBackup.werdGoals.first.type, originalBackup.werdGoals.first.type);
      expect(restoredBackup.werdGoals.first.value, originalBackup.werdGoals.first.value);

      // Werd Progress Check
      expect(restoredBackup.werdProgress.length, originalBackup.werdProgress.length);
      expect(restoredBackup.werdProgress.first.goalId, originalBackup.werdProgress.first.goalId);
      expect(restoredBackup.werdProgress.first.readItemsToday, originalBackup.werdProgress.first.readItemsToday);
      expect(restoredBackup.werdProgress.first.history['2024-01-01']?.totalAyahsRead, 5);
      expect(restoredBackup.werdProgress.first.history['2024-01-01']?.startSurahName, 'Al-Baqarah');
    });

    test('Should handle newer backup version error', () {
      final jsonData = {
        'version': 99, // Future version
        'appVersion': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'prayerRecords': [],
        'werdGoals': [],
        'werdProgress': [],
      };

      final backup = AppBackup.fromJson(jsonData);
      expect(backup.version, 99);
      // The logic to throw exception should be in ExportImportService
    });
  });
}
