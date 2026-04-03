import 'dart:convert';
import 'package:fard/features/werd/data/repositories/werd_repository_impl.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/werd_history_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quran/quran.dart' as quran;

void main() {
  late WerdRepositoryImpl repository;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    repository = WerdRepositoryImpl(sharedPreferences);
  });

  group('WerdHistoryEnhancement', () {
    test('should populate detailed history on day rollover', () async {
      // 1. Arrange: Save progress from yesterday
      // Absolute ayah 1 = Al-Fatiha 1
      // Absolute ayah 10 = Al-Baqarah 3
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 10,
        readItemsToday: Set<int>.from(List.generate(10, (i) => i + 1)),
        lastReadAbsolute: 10,
        sessionStartAbsolute: 1,
        lastUpdated: yesterday,
        streak: 1,
        history: {},
      );

      await sharedPreferences.setString(
        'werd_progress_default',
        json.encode(progress.toJson()),
      );

      // 2. Act: Get progress today (this triggers the rollover logic)
      final result = await repository.getProgress();
      final updatedProgress = result.fold((_) => null, (p) => p)!;

      // 3. Assert
      final dateKey =
          "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

      expect(updatedProgress.history.containsKey(dateKey), isTrue);

      final entry = updatedProgress.history[dateKey]!;
      expect(entry.totalAyahsRead, 10);
      expect(entry.startAbsolute, 1);
      expect(entry.endAbsolute, 10);
      expect(entry.startSurahName, quran.getSurahName(1)); // Al-Fatiha
      expect(entry.startAyahNumber, 1);
      expect(entry.endSurahName, quran.getSurahName(2)); // Al-Baqarah
      expect(entry.endAyahNumber, 3);

      // Verification of fractional progress
      // 10 ayahs is less than 1 page and less than 1 juz
      expect(entry.pagesRead, greaterThan(0));
      expect(entry.juzRead, greaterThan(0));

      expect(entry.summary, contains("Read 10 ayahs"));
      expect(entry.summary, contains(quran.getSurahName(1)));
      expect(entry.summary, contains(quran.getSurahName(2)));
    });

    test(
      'should maintain backward compatibility with old integer history',
      () async {
        final yesterdayKey = "2024-01-01";
        final jsonString = json.encode({
          'goalId': 'default',
          'totalAmountReadToday': 0,
          'lastReadAbsolute': 10,
          'sessionStartAbsolute': 1,
          'lastUpdated': DateTime.now().toIso8601String(),
          'streak': 1,
          'history': {
            yesterdayKey: 50, // Old format: date -> int
          },
        });

        final progress = WerdProgress.fromJson(json.decode(jsonString));

        expect(progress.history[yesterdayKey], isA<WerdHistoryEntry>());
        expect(progress.history[yesterdayKey]!.totalAyahsRead, 50);
        expect(
          progress.history[yesterdayKey]!.summary,
          contains("Read 50 ayahs"),
        );
      },
    );
  });
}
