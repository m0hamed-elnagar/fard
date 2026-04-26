import 'dart:convert';
import 'package:fard/core/services/app_backup_dto.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/werd_history_entry.dart';
import 'package:fard/features/quran/domain/entities/bookmark.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
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
          completedQada: {Salaah.fajr: 2},
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

      final bookmarks = [
        Bookmark(
          id: 'b1',
          ayahNumber: AyahNumber.create(
            surahNumber: 1,
            ayahNumberInSurah: 1,
          ).data!,
          createdAt: DateTime(2024, 1, 1),
          note: 'First Ayah',
        ),
      ];

      final originalBackup = AppBackup(
        version: 2,
        appVersion: '1.4.0',
        timestamp: DateTime(2024, 1, 1),
        prayerRecords: prayerRecords,
        werdGoals: werdGoals,
        werdProgress: werdProgress,
        preferences: {'theme': 'dark', 'font_size': 16},
        tasbihHistory: {'dhikr1': 500},
        tasbihProgress: {'cat1': 11},
        tasbihPreferredDuas: {'cat1': 'dua1'},
        bookmarks: bookmarks,
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
      expect(
        restoredBackup.prayerRecords.length,
        originalBackup.prayerRecords.length,
      );
      expect(
        restoredBackup.prayerRecords.first.id,
        originalBackup.prayerRecords.first.id,
      );
      expect(
        restoredBackup.prayerRecords.first.missedToday,
        originalBackup.prayerRecords.first.missedToday,
      );

      // Werd Goals Check
      expect(restoredBackup.werdGoals.length, originalBackup.werdGoals.length);
      expect(
        restoredBackup.werdGoals.first.id,
        originalBackup.werdGoals.first.id,
      );

      // New Fields Check
      expect(restoredBackup.preferences['theme'], 'dark');
      expect(restoredBackup.preferences['font_size'], 16);
      expect(restoredBackup.tasbihHistory['dhikr1'], 500);
      expect(restoredBackup.tasbihProgress['cat1'], 11);
      expect(restoredBackup.tasbihPreferredDuas['cat1'], 'dua1');
      expect(restoredBackup.bookmarks.length, 1);
      expect(restoredBackup.bookmarks.first.note, 'First Ayah');
      expect(restoredBackup.bookmarks.first.ayahNumber.surahNumber, 1);
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

    test('Should handle missing new fields in v1 backup (backward compatibility)',
        () {
      final jsonData = {
        'version': 1,
        'appVersion': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'prayerRecords': [],
        'werdGoals': [],
        'werdProgress': [],
      };

      final backup = AppBackup.fromJson(jsonData);
      expect(backup.preferences, isEmpty);
      expect(backup.tasbihHistory, isEmpty);
      expect(backup.tasbihProgress, isEmpty);
      expect(backup.tasbihPreferredDuas, isEmpty);
      expect(backup.bookmarks, isEmpty);
    });
  });
}
