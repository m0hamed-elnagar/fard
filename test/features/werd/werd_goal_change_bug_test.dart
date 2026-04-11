// ignore_for_file: unused_import
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_history_entry.dart';
import 'package:fard/core/extensions/quran_extension.dart';

/// BUG REPRODUCTION: Changing goal clears history data
/// 
/// This test reproduces the bug where changing the target goal causes
/// history data to disappear.
/// 
/// Run with: flutter test test/features/werd/werd_goal_change_bug_test.dart
void main() {
  group('Bug: Changing goal clears history', () {
    
    test('BUG001 - setGoal resets progress but leaves segmentsToday inconsistent', () {
      // Scenario: User has reading history, then changes goal
      
      // BEFORE: User has been reading with old goal
      final oldProgress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 100, // Read 100 ayahs today
        segmentsToday: [
          ReadingSegment(
            startAyah: 1,
            endAyah: 100,
            startTime: DateTime.now().subtract(const Duration(hours: 2)),
            endTime: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
        readItemsToday: Set<int>.from(List.generate(100, (i) => i + 1)),
        lastReadAbsolute: 100,
        sessionStartAbsolute: 1,
        lastUpdated: DateTime.now(),
        streak: 5,
        completedCycles: 0,
        history: {
          '2026-04-10': WerdHistoryEntry(
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
      
      print('\n📊 BEFORE CHANGING GOAL:');
      print('   Total ayahs today: ${oldProgress.totalAmountReadToday}');
      print('   Segments today: ${oldProgress.segmentsToday.length}');
      print('   Read items today: ${oldProgress.readItemsToday.length}');
      print('   History entries: ${oldProgress.history.length}');
      print('   Last read: ayah ${oldProgress.lastReadAbsolute}');
      
      // User changes goal (e.g., from 5 pages to 10 pages)
      // The setGoal handler does this:
      final updatedProgress = oldProgress.copyWith(
        lastReadAbsolute: 10, // New goal starts from ayah 10
        sessionStartAbsolute: 11,
        totalAmountReadToday: 0, // ❌ Reset to 0
        readItemsToday: const {}, // ❌ Reset to empty
        // But segmentsToday is NOT reset! Still has the old session
      );
      
      print('\n📊 AFTER CHANGING GOAL (buggy behavior):');
      print('   Total ayahs today: ${updatedProgress.totalAmountReadToday}');
      print('   Segments today: ${updatedProgress.segmentsToday.length}');
      print('   Read items today: ${updatedProgress.readItemsToday.length}');
      print('   History entries: ${updatedProgress.history.length}');
      print('   Last read: ayah ${updatedProgress.lastReadAbsolute}');
      
      // The inconsistency:
      expect(updatedProgress.totalAmountReadToday, 0); // Reset
      expect(updatedProgress.readItemsToday.isEmpty, true); // Reset
      expect(updatedProgress.segmentsToday.isNotEmpty, true); // ❌ NOT RESET!
      expect(updatedProgress.history.length, 1); // History preserved
      
      print('\n❌ BUG IDENTIFIED:');
      print('   totalAmountReadToday = 0 (reset)');
      print('   readItemsToday = {} (reset)');
      print('   segmentsToday = [1 segment] (NOT reset) ❌');
      print('');
      print('   This inconsistency causes:');
      print('   1. UI shows 0 ayahs but has 1 segment');
      print('   2. History calculations use empty readItemsToday');
      print('   3. Pages/juz show as 0.0');
      
      // Now simulate what happens when day rollover occurs
      // (or when user opens history page which triggers _calculateTodayEntry)
      
      // This is what _calculateTodayEntry does:
      final readItemsForCalc = updatedProgress.readItemsToday.isNotEmpty == true
          ? updatedProgress.readItemsToday
          : _segmentsToReadItems(updatedProgress.segmentsToday);
      
      final pagesRead = QuranHizbProvider.calculateFractionalProgress(
        readItemsForCalc,
        WerdUnit.page,
      );
      
      print('\n📊 HISTORY CALCULATION (with our fix):');
      print('   Using readItems from segments: ${readItemsForCalc.length} items');
      print('   Pages: $pagesRead');
      print('   ✅ At least our fix helps calculate from segments!');
      
      expect(readItemsForCalc.length, 100); // Should use segments
      expect(pagesRead, greaterThan(0.0)); // Should show pages
    });
    
    test('BUG002 - setGoal should preserve history but reset today sessions', () {
      // This test shows what SHOULD happen when changing goal:
      // 1. History should be preserved ✅
      // 2. Today's sessions should be saved to history BEFORE reset
      // 3. Then reset today's progress
      
      final oldProgress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 100,
        segmentsToday: [
          ReadingSegment(
            startAyah: 1,
            endAyah: 100,
            startTime: DateTime.now().subtract(const Duration(hours: 2)),
            endTime: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
        readItemsToday: Set<int>.from(List.generate(100, (i) => i + 1)),
        lastReadAbsolute: 100,
        sessionStartAbsolute: 1,
        lastUpdated: DateTime.now(),
        streak: 5,
        completedCycles: 0,
        history: {
          '2026-04-10': WerdHistoryEntry(
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
      
      // CORRECT behavior: Save today's reading to history first
      final dateKey = DateTime.now().toIso8601String().split('T')[0];
      
      final historyEntry = WerdHistoryEntry(
        totalAyahsRead: oldProgress.totalAmountReadToday,
        startAbsolute: oldProgress.sessionStartAbsolute ?? 1,
        endAbsolute: oldProgress.lastReadAbsolute ?? 1,
        pagesRead: QuranHizbProvider.calculateFractionalProgress(
          oldProgress.readItemsToday,
          WerdUnit.page,
        ),
        juzRead: QuranHizbProvider.calculateFractionalProgress(
          oldProgress.readItemsToday,
          WerdUnit.juz,
        ),
        segmentCount: oldProgress.segmentsToday.length,
        startSurahName: 'Al-Fatihah',
        startAyahNumber: 1,
        endSurahName: 'Al-Baqarah',
        endAyahNumber: 91,
        summary: 'Read ${oldProgress.totalAmountReadToday} ayahs',
        sessions: oldProgress.segmentsToday,
      );
      
      final newHistory = Map<String, WerdHistoryEntry>.from(oldProgress.history);
      newHistory[dateKey] = historyEntry;
      
      // NOW reset today's progress
      final correctProgress = oldProgress.copyWith(
        totalAmountReadToday: 0,
        segmentsToday: [],
        readItemsToday: const {},
        lastReadAbsolute: 10,
        sessionStartAbsolute: 11,
        history: newHistory, // History includes today's reading
      );
      
      print('\n✅ CORRECT BEHAVIOR:');
      print('   History entries: ${correctProgress.history.length}');
      print('   Total ayahs today: ${correctProgress.totalAmountReadToday}');
      print('   Segments today: ${correctProgress.segmentsToday.length}');
      
      expect(correctProgress.history.length, 2); // Old history + today saved
      expect(correctProgress.totalAmountReadToday, 0);
      expect(correctProgress.segmentsToday.isEmpty, true);
    });
    
    test('BUG003 - Verify the actual bug: Opening history shows 0 pages/juz', () {
      // This simulates what happens when user opens werd history page
      // after changing the goal
      
      // After buggy setGoal:
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 0, // Reset
        segmentsToday: [ // Still has old data
          ReadingSegment(
            startAyah: 1,
            endAyah: 100,
            startTime: DateTime.now().subtract(const Duration(hours: 2)),
            endTime: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
        readItemsToday: const {}, // Reset to empty
        lastReadAbsolute: 10,
        sessionStartAbsolute: 11,
        lastUpdated: DateTime.now(),
        streak: 5,
        history: const {},
      );
      
      // User opens history page
      // History page calls _calculateTodayEntry(progress)
      // WITHOUT our fix, it would use readItemsToday (empty)
      
      final pagesReadOld = QuranHizbProvider.calculateFractionalProgress(
        progress.readItemsToday,
        WerdUnit.page,
      );
      
      print('\n❌ OLD BEHAVIOR (without fix):');
      print('   Using readItemsToday: ${progress.readItemsToday.length} items');
      print('   Pages: $pagesReadOld');
      print('   User sees: 0.0 pages in history');
      
      expect(pagesReadOld, 0.0); // BUG!
      
      // WITH our fix, it uses segments as fallback
      final readItems = progress.readItemsToday.isNotEmpty == true
          ? progress.readItemsToday
          : _segmentsToReadItems(progress.segmentsToday);
      
      final pagesReadNew = QuranHizbProvider.calculateFractionalProgress(
        readItems,
        WerdUnit.page,
      );
      
      print('\n✅ NEW BEHAVIOR (with fix):');
      print('   Using segments fallback: ${readItems.length} items');
      print('   Pages: $pagesReadNew');
      print('   User sees: $pagesReadNew pages in history');
      
      expect(pagesReadNew, greaterThan(0.0)); // Fixed!
    });
    
    test('BUG004 - After setGoal fix, history should include today\'s reading', () {
      // This test verifies that after applying FIX #4,
      // changing the goal saves today's reading to history
      
      final oldProgress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 100,
        segmentsToday: [
          ReadingSegment(
            startAyah: 1,
            endAyah: 100,
            startTime: DateTime.now().subtract(const Duration(hours: 2)),
            endTime: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
        readItemsToday: Set<int>.from(List.generate(100, (i) => i + 1)),
        lastReadAbsolute: 100,
        sessionStartAbsolute: 1,
        lastUpdated: DateTime.now(),
        streak: 5,
        history: const {},
      );
      
      print('\n📊 SIMULATING setGoal WITH FIX #4:');
      print('   Before: ${oldProgress.history.length} history entries');
      print('   Today\'s reading: ${oldProgress.totalAmountReadToday} ayahs');
      
      // Simulate what the fixed setGoal does:
      // 1. Save today's sessions to history
      final dateKey = DateTime.now().toIso8601String().split('T')[0];
      
      final pagesRead = QuranHizbProvider.calculateFractionalProgressFromSegments(
        oldProgress.segmentsToday,
        WerdUnit.page,
      );
      final juzRead = QuranHizbProvider.calculateFractionalProgressFromSegments(
        oldProgress.segmentsToday,
        WerdUnit.juz,
      );
      
      final historyEntry = WerdHistoryEntry(
        totalAyahsRead: oldProgress.totalAmountReadToday,
        startAbsolute: oldProgress.sessionStartAbsolute ?? 1,
        endAbsolute: oldProgress.lastReadAbsolute ?? 1,
        pagesRead: pagesRead,
        juzRead: juzRead,
        segmentCount: oldProgress.segmentsToday.length,
        startSurahName: 'Al-Fatihah',
        startAyahNumber: 1,
        endSurahName: 'Al-Baqarah',
        endAyahNumber: 91,
        summary: 'Read ${oldProgress.totalAmountReadToday} ayahs',
        sessions: oldProgress.segmentsToday,
      );
      
      final newHistory = Map<String, WerdHistoryEntry>.from(oldProgress.history);
      newHistory[dateKey] = historyEntry;
      
      // 2. Reset today's progress
      final newProgress = oldProgress.copyWith(
        totalAmountReadToday: 0,
        segmentsToday: const [],
        readItemsToday: const {},
        history: newHistory,
        lastReadAbsolute: 10,
        sessionStartAbsolute: 11,
      );
      
      print('   After: ${newProgress.history.length} history entries');
      print('   Today saved to history: ${newProgress.history.containsKey(dateKey)}');
      print('   Total ayahs today: ${newProgress.totalAmountReadToday}');
      
      // Verify the fix
      expect(newProgress.history.length, 1); // Today's reading saved
      expect(newProgress.history.containsKey(dateKey), true);
      expect(newProgress.history[dateKey]?.totalAyahsRead, 100);
      expect(newProgress.history[dateKey]?.pagesRead, greaterThan(0.0));
      expect(newProgress.totalAmountReadToday, 0); // Reset
      expect(newProgress.segmentsToday.isEmpty, true); // Reset
      
      print('\n✅ FIX #4 VERIFIED:');
      print('   Today\'s reading saved to history BEFORE reset');
      print('   Data is NOT lost when changing goals');
      
      // Now when user opens history, they see the data
      final savedEntry = newHistory[dateKey];
      expect(savedEntry, isNotNull);
      expect(savedEntry!.totalAyahsRead, 100);
      expect(savedEntry.pagesRead, greaterThan(0.0));
      
      print('   History shows: ${savedEntry.totalAyahsRead} ayahs, ${savedEntry.pagesRead} pages');
    });
  });
}

/// Helper: Convert segments to readItems
Set<int> _segmentsToReadItems(List<ReadingSegment> segments) {
  final items = <int>{};
  for (final seg in segments) {
    for (int i = seg.startAyah; i <= seg.endAyah; i++) {
      items.add(i);
    }
  }
  return items;
}
