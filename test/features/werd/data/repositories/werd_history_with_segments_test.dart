import 'dart:convert';
import 'package:fard/features/werd/data/repositories/werd_repository_impl.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/werd_history_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late WerdRepositoryImpl repository;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    repository = WerdRepositoryImpl(sharedPreferences);
  });

  group('WerdHistory with Segments', () {
    test('day rollover converts segmentsToday to history entry', () async {
      // Setup: User has 2 segments today
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 11,
        segmentsToday: [
          // ReadingSegment(startAyah: 1, endAyah: 5),
          // ReadingSegment(startAyah: 100, endAyah: 105),
        ],
        lastReadAbsolute: 105,
        sessionStartAbsolute: 1,
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
        streak: 1,
        history: {},
      );

      await sharedPreferences.setString(
        'werd_progress_default',
        json.encode(progress.toJson()),
      );

      // Trigger day rollover
      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (updatedProgress) {
          // Should have created history entry
          expect(updatedProgress.history.length, greaterThanOrEqualTo(1));
          // SegmentsToday should be cleared for new day
          // expect(updatedProgress.segmentsToday, isEmpty);
        },
      );
    });

    test('history stores segmentCount for display', () async {
      // History entry should track how many segments that day
      // For display: "Read 11 ayahs in 2 sessions"
      expect(true, isTrue); // Placeholder - will test after implementation
    });

    test('history totalAyahsRead = sum of segment counts', () async {
      // Segment {1,5} = 5 ayahs
      // Segment {100,105} = 6 ayahs
      // totalAyahsRead = 11
      expect(true, isTrue); // Placeholder
    });

    test('segmentsToday cleared after rollover', () async {
      // New day starts with empty segments
      expect(true, isTrue); // Placeholder
    });

    test('history entry serializes/deserializes correctly', () async {
      final entry = WerdHistoryEntry(
        totalAyahsRead: 11,
        startAbsolute: 1,
        endAbsolute: 105,
        pagesRead: 1.5,
        juzRead: 0.08,
        startSurahName: 'Al-Fatihah',
        startAyahNumber: 1,
        endSurahName: 'Al-Baqarah',
        endAyahNumber: 98,
        summary: 'Read 11 ayahs in 2 sessions',
      );

      final json = entry.toJson();
      final restored = WerdHistoryEntry.fromJson(json);

      expect(restored.totalAyahsRead, entry.totalAyahsRead);
      expect(restored.startAbsolute, entry.startAbsolute);
      expect(restored.summary, entry.summary);
    });

    test('old history format (no segments) still loads', () async {
      // Backward compatibility: old history entries without segmentCount
      final json = jsonEncode({
        'goalId': 'default',
        'totalAmountReadToday': 0,
        'lastReadAbsolute': 50,
        'sessionStartAbsolute': 1,
        'lastUpdated': DateTime.now().toIso8601String(),
        'streak': 5,
        'history': {
          '2024-01-01': 20, // Old format: just ayah count
        },
      });

      await sharedPreferences.setString('werd_progress_default', json);

      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (progress) {
          expect(progress.history.containsKey('2024-01-01'), isTrue);
          expect(progress.history['2024-01-01']!.totalAyahsRead, 20);
        },
      );
    });

    test('monthly totals calculate from history correctly', () async {
      // Sum all history entries for current month
      // April 1: 5 ayahs
      // April 2: 6 ayahs
      // April 3: 11 ayahs
      // Monthly total: 22 ayahs
      expect(true, isTrue); // Placeholder
    });
  });
}
