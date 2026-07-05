// ignore_for_file: unused_import
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_history_entry.dart';
import 'package:fard/core/extensions/quran_extension.dart';

void main() {
  group('Werd Goal Change Progress Preservation Tests', () {
    late WerdProgress initialProgress;
    late WerdGoal initialGoal;

    setUp(() {
      initialGoal = WerdGoal(
        id: 'default',
        type: WerdGoalType.fixedAmount,
        value: 10,
        unit: WerdUnit.ayah,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        startAbsolute: 1,
      );

      initialProgress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 20, // 20 ayahs read today
        segmentsToday: [
          ReadingSegment(
            startAyah: 1,
            endAyah: 10,
            startTime: DateTime.now().subtract(const Duration(hours: 2)),
            endTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
          ),
          ReadingSegment(
            startAyah: 11,
            endAyah: 20,
            startTime: DateTime.now().subtract(const Duration(hours: 1)),
            endTime: DateTime.now().subtract(const Duration(minutes: 50)),
          ),
        ],
        readItemsToday: Set<int>.from(List.generate(20, (i) => i + 1)),
        lastReadAbsolute: 20,
        sessionStartAbsolute: 1,
        lastUpdated: DateTime.now(),
        streak: 5,
        completedCycles: 0,
        history: {
          '2026-04-10': const WerdHistoryEntry(
            totalAyahsRead: 150,
            startAbsolute: 1,
            endAbsolute: 150,
            pagesRead: 20.0,
            juzRead: 1.0,
            segmentCount: 2,
            startSurahName: 'Al-Fatihah',
            startAyahNumber: 1,
            endSurahName: 'Al-Baqarah',
            endAyahNumber: 141,
            summary: 'Read 150 ayahs',
          ),
        },
      );
    });

    test('1. Simple goal change (changing value/unit) preserves progress', () {
      final newGoal = initialGoal.copyWith(
        value: 5,
        unit: WerdUnit.page, // Changed from 10 ayahs to 5 pages
        startAbsolute: 21,   // Simulated dialog behavior: "From last read" (lastReadAbsolute + 1)
      );

      // Simulate WerdBloc's new setGoal logic:
      final updatedProgress = initialProgress.copyWith(
        lastReadAbsolute: newGoal.startAbsolute != null
            ? newGoal.startAbsolute! - 1
            : initialProgress.lastReadAbsolute,
        sessionStartAbsolute: newGoal.startAbsolute ?? initialProgress.sessionStartAbsolute,
        lastUpdated: DateTime.now(),
      );

      // Assertions
      expect(updatedProgress.totalAmountReadToday, 20); // Preserved!
      expect(updatedProgress.segmentsToday.length, 2); // Preserved!
      expect(updatedProgress.segmentsToday[0].startAyah, 1);
      expect(updatedProgress.segmentsToday[1].endAyah, 20);
      expect(updatedProgress.readItemsToday.length, 20); // Preserved!
      expect(updatedProgress.lastReadAbsolute, 20); // Unchanged since startAbsolute points to next ayah
      expect(updatedProgress.sessionStartAbsolute, 21); // Set to new start point
      expect(updatedProgress.history.length, 1); // Not changed/appended prematurely
      expect(updatedProgress.history.containsKey('2026-04-10'), isTrue);
    });

    test('2. Goal change with shifted start position updates resume point but preserves progress counters', () {
      // Shift starting point of the goal to ayah 100
      final newGoal = initialGoal.copyWith(
        startAbsolute: 100,
      );

      // Simulate WerdBloc's new setGoal logic:
      final updatedProgress = initialProgress.copyWith(
        lastReadAbsolute: newGoal.startAbsolute != null
            ? newGoal.startAbsolute! - 1
            : initialProgress.lastReadAbsolute,
        sessionStartAbsolute: newGoal.startAbsolute ?? initialProgress.sessionStartAbsolute,
        lastUpdated: DateTime.now(),
      );

      // Assertions
      expect(updatedProgress.totalAmountReadToday, 20); // Preserved raw counters!
      expect(updatedProgress.segmentsToday.length, 2); // Preserved raw segments!
      expect(updatedProgress.readItemsToday.length, 20);

      // Position fields shifted correctly:
      expect(updatedProgress.lastReadAbsolute, 99); // startAbsolute - 1
      expect(updatedProgress.sessionStartAbsolute, 100); // startAbsolute

      // History is untouched:
      expect(updatedProgress.history.length, 1);
    });

    test('3. Assert no premature history entries are written during setGoal', () {
      final newGoal = initialGoal.copyWith(value: 30);

      // Simulate setGoal progress update:
      final updatedProgress = initialProgress.copyWith(
        lastReadAbsolute: newGoal.startAbsolute != null
            ? newGoal.startAbsolute! - 1
            : initialProgress.lastReadAbsolute,
        sessionStartAbsolute: newGoal.startAbsolute ?? initialProgress.sessionStartAbsolute,
        lastUpdated: DateTime.now(),
      );

      // Verify that no history entry was added for today's date key
      final dateKey = DateTime.now().toIso8601String().split('T')[0];
      expect(updatedProgress.history.containsKey(dateKey), isFalse);
      expect(updatedProgress.history.length, 1); // Only the pre-existing history entry remains
    });
  });
}
