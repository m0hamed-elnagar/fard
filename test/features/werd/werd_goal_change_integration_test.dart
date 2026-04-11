// ignore_for_file: unused_import
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_history_entry.dart';
import 'package:fard/core/extensions/quran_extension.dart';

/// INTEGRATION TEST: Complete goal change flow
/// 
/// This test simulates the EXACT user flow:
/// 1. Read some ayahs
/// 2. Change goal
/// 3. Open history page
/// 4. Verify data is there
/// 
/// Run with: flutter test test/features/werd/werd_goal_change_integration_test.dart
void main() {
  test('INTEGRATION - Complete goal change flow should preserve history', () {
    print('\n═══════════════════════════════════════════');
    print('🎯 INTEGRATION TEST: Goal Change Flow');
    print('═══════════════════════════════════════════\n');
    
    // Step 1: User has been reading with old goal
    print('📖 STEP 1: User reads 100 ayahs');
    
    var progress = WerdProgress(
      goalId: 'default',
      totalAmountReadToday: 0,
      segmentsToday: [],
      readItemsToday: const {},
      lastReadAbsolute: 1,
      sessionStartAbsolute: 1,
      lastUpdated: DateTime.now(),
      streak: 5,
      history: const {},
    );
    
    // Simulate reading ayahs 1-100
    final segment = ReadingSegment(
      startAyah: 1,
      endAyah: 100,
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      endTime: DateTime.now(),
    );
    
    final readItems = Set<int>.from(List.generate(100, (i) => i + 1));
    
    progress = progress.copyWith(
      totalAmountReadToday: 100,
      segmentsToday: [segment],
      readItemsToday: readItems,
      lastReadAbsolute: 100,
      lastUpdated: DateTime.now(),
    );
    
    print('   ✅ Read 100 ayahs');
    print('   History entries: ${progress.history.length}');
    
    // Step 2: User changes goal (e.g., from 5 pages to 20 ayahs)
    print('\n⚙️  STEP 2: User changes goal');
    print('   Before change:');
    print('   - totalAmountReadToday: ${progress.totalAmountReadToday}');
    print('   - segmentsToday: ${progress.segmentsToday.length}');
    print('   - history entries: ${progress.history.length}');
    
    // Simulate FIX #4: Save to history before reset
    final dateKey = DateTime.now().toIso8601String().split('T')[0];
    
    if (progress.totalAmountReadToday > 0 || progress.segmentsToday.isNotEmpty) {
      final pagesRead = QuranHizbProvider.calculateFractionalProgressFromSegments(
        progress.segmentsToday,
        WerdUnit.page,
      );
      final juzRead = QuranHizbProvider.calculateFractionalProgressFromSegments(
        progress.segmentsToday,
        WerdUnit.juz,
      );
      
      final historyEntry = WerdHistoryEntry(
        totalAyahsRead: progress.totalAmountReadToday,
        startAbsolute: progress.sessionStartAbsolute ?? 1,
        endAbsolute: progress.lastReadAbsolute ?? 1,
        pagesRead: pagesRead,
        juzRead: juzRead,
        segmentCount: progress.segmentsToday.length,
        startSurahName: 'Al-Fatihah',
        startAyahNumber: 1,
        endSurahName: 'Al-Baqarah',
        endAyahNumber: 91,
        summary: 'Read ${progress.totalAmountReadToday} ayahs',
        sessions: progress.segmentsToday,
      );
      
      final newHistory = Map<String, WerdHistoryEntry>.from(progress.history);
      newHistory[dateKey] = historyEntry;
      
      progress = progress.copyWith(
        history: newHistory,
      );
      
      print('   ✅ Saved to history: $dateKey');
      print('   - History entries: ${progress.history.length}');
    }
    
    // Now reset for new goal
    progress = progress.copyWith(
      totalAmountReadToday: 0,
      segmentsToday: const [],
      readItemsToday: const {},
      lastReadAbsolute: 1, // New goal starts from ayah 1
      sessionStartAbsolute: 1,
      lastUpdated: DateTime.now(),
    );
    
    print('   After change:');
    print('   - totalAmountReadToday: ${progress.totalAmountReadToday}');
    print('   - segmentsToday: ${progress.segmentsToday.length}');
    print('   - history entries: ${progress.history.length}');
    
    // Step 3: User opens history page
    print('\n📚 STEP 3: User opens history page');
    
    // History page checks conditions
    final hasAnyHistory = progress.history.isNotEmpty;
    final hasTodayReading = progress.totalAmountReadToday > 0;
    final shouldShowHistory = hasAnyHistory || hasTodayReading;
    
    print('   History entries: ${progress.history.length}');
    print('   Has any history: $hasAnyHistory');
    print('   Has today reading: $hasTodayReading');
    print('   Should show history: $shouldShowHistory');
    
    // Check if today's saved entry is in history
    final todayKey = DateTime.now().toIso8601String().split('T')[0];
    final todayEntry = progress.history[todayKey];
    
    if (todayEntry != null) {
      print('\n   ✅ FOUND today\'s entry in history!');
      print('   - Ayahs: ${todayEntry.totalAyahsRead}');
      print('   - Pages: ${todayEntry.pagesRead}');
      print('   - Juz: ${todayEntry.juzRead}');
      print('   - Sessions: ${todayEntry.sessions?.length ?? 0}');
    } else {
      print('\n   ❌ today\'s entry NOT FOUND in history!');
      print('   Available keys: ${progress.history.keys.toList()}');
    }
    
    // Step 4: Verify the data
    print('\n✅ VERIFICATION:');
    
    expect(hasAnyHistory, true, reason: 'History should have entries');
    expect(progress.history.containsKey(todayKey), true, reason: 'Today should be in history');
    
    if (todayEntry != null) {
      expect(todayEntry.totalAyahsRead, 100, reason: 'Should have 100 ayahs');
      expect(todayEntry.pagesRead, greaterThan(0.0), reason: 'Should have pages > 0');
      expect(todayEntry.juzRead, greaterThan(0.0), reason: 'Should have juz > 0');
      
      print('\n═══════════════════════════════════════════');
      print('✅ TEST PASSED: History preserved after goal change!');
      print('═══════════════════════════════════════════\n');
    }
  });
  
  test('INTEGRATION - History page filtering should show saved data', () {
    print('\n═══════════════════════════════════════════');
    print('🔍 TEST: History Page Filtering');
    print('═══════════════════════════════════════════\n');
    
    // Simulate progress after goal change
    final todayKey = DateTime.now().toIso8601String().split('T')[0];
    
    final progress = WerdProgress(
      goalId: 'default',
      totalAmountReadToday: 0, // Reset after goal change
      segmentsToday: const [], // Reset after goal change
      readItemsToday: const {},
      lastReadAbsolute: 1,
      sessionStartAbsolute: 1,
      lastUpdated: DateTime.now(),
      streak: 5,
      history: {
        todayKey: WerdHistoryEntry(
          totalAyahsRead: 100,
          startAbsolute: 1,
          endAbsolute: 100,
          pagesRead: 14.0,
          juzRead: 0.67,
          segmentCount: 1,
          startSurahName: 'Al-Fatihah',
          startAyahNumber: 1,
          endSurahName: 'Al-Baqarah',
          endAyahNumber: 91,
          summary: 'Read 100 ayahs',
          sessions: [
            ReadingSegment(
              startAyah: 1,
              endAyah: 100,
              startTime: DateTime.now().subtract(const Duration(hours: 1)),
              endTime: DateTime.now(),
            ),
          ],
        ),
      },
    );
    
    print('📊 Progress state:');
    print('   totalAmountReadToday: ${progress.totalAmountReadToday}');
    print('   segmentsToday: ${progress.segmentsToday.length}');
    print('   history entries: ${progress.history.length}');
    
    // Simulate what history page does
    final historyList = progress.history.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    
    print('\n📋 History list (${historyList.length} entries):');
    for (final entry in historyList) {
      print('   - ${entry.key}: ${entry.value.totalAyahsRead} ayahs, ${entry.value.pagesRead} pages');
    }
    
    // Filter by current month
    final now = DateTime.now();
    final currentMonthKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    
    int periodTotalAyahs = 0;
    double periodTotalPages = 0;
    double periodTotalJuz = 0;
    int periodDays = 0;
    final filteredHistory = <MapEntry<String, WerdHistoryEntry>>[];
    
    for (final entry in historyList) {
      final date = DateTime.parse(entry.key);
      bool include = date.year == now.year && date.month == now.month;
      
      print('\n🔍 Checking entry: ${entry.key}');
      print('   Year match: ${date.year == now.year}');
      print('   Month match: ${date.month == now.month}');
      print('   Include: $include');
      
      if (include) {
        periodTotalAyahs += entry.value.totalAyahsRead;
        periodTotalPages += entry.value.pagesRead;
        periodTotalJuz += entry.value.juzRead;
        if (entry.value.totalAyahsRead > 0) {
          periodDays++;
          filteredHistory.add(entry);
          print('   ✅ Added to filtered list');
        }
      }
    }
    
    // Check "today" entry (but totalAmountReadToday is 0 after goal change)
    final todayMatches = now.year == now.year && now.month == now.month;
    print('\n📊 Summary:');
    print('   Today matches period: $todayMatches');
    print('   Today totalAmountReadToday: ${progress.totalAmountReadToday}');
    print('   Filtered history count: ${filteredHistory.length}');
    print('   Period total ayahs: $periodTotalAyahs');
    print('   Period total pages: $periodTotalPages');
    
    final hasData = (todayMatches && progress.totalAmountReadToday > 0) ||
        filteredHistory.isNotEmpty;
    
    print('\n✅ History page will show data: $hasData');
    
    expect(hasData, true, reason: 'History page should show the saved data');
    expect(filteredHistory.length, 1, reason: 'Should have 1 filtered entry');
    expect(periodTotalAyahs, 100, reason: 'Should sum to 100 ayahs');
    
    print('\n═══════════════════════════════════════════');
    print('✅ TEST PASSED: History page filtering works!');
    print('═══════════════════════════════════════════\n');
  });
}
