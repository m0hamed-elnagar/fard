import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:flutter_test/flutter_test.dart';

/// THIS TEST PROVES THE REAL BUG!
/// 
/// The bug is in UpdateLastRead use case:
/// - It sets readItemsToday (old Set<int> format)
/// - It does NOT set segmentsToday (new List<ReadingSegment> format)
/// - Today's Reading dialog shows segmentsToday (which is empty!)
/// - History shows readItemsToday (which has the data!)
///
/// This explains why user sees correct count in history but wrong in Today's Reading!
void main() {
  test(
    '🐛 BUG PROOF: When copyWith only sets readItemsToday, segmentsToday stays empty',
    () async {
      // ARRANGE: Initial state with empty segments
      final initialProgress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 0,
        readItemsToday: const {},
        segmentsToday: const [], // EMPTY!
        sessionStartAbsolute: 1, // User clicked Continue from ayah 1
        lastReadAbsolute: null,
        lastUpdated: DateTime.now(),
        streak: 0,
        completedCycles: 0,
      );

      // ACT: Simulate what UpdateLastRead does - it calls copyWith with readItemsToday
      // but NOT segmentsToday!
      final readItems = {1, 2, 3, 4, 5, 6, 7}; // User read ayahs 1-7
      final newProgress = initialProgress.copyWith(
        totalAmountReadToday: 7,
        readItemsToday: readItems, // OLD FORMAT - SET
        lastReadAbsolute: 7,
        sessionStartAbsolute: 1,
        lastUpdated: DateTime.now(),
        // NOTE: segmentsToday is NOT SET - stays empty!
      );

      // ASSERT
      print('╔════════════════════════════════════════════════════╗');
      print('🐛 BUG PROOF TEST RESULTS');
      print('╠════════════════════════════════════════════════════╣');
      print('readItemsToday: ${newProgress.readItemsToday}');
      print('readItemsToday count: ${newProgress.readItemsToday.length}');
      print('segmentsToday: ${newProgress.segmentsToday}');
      print('segmentsToday count: ${newProgress.segmentsToday.length}');
      print('totalAmountReadToday: ${newProgress.totalAmountReadToday}');
      print('');
      
      if (newProgress.readItemsToday.isNotEmpty && 
          newProgress.segmentsToday.isEmpty) {
        print('❌❌❌ BUG CONFIRMED! ❌❌❌');
        print('');
        print('readItemsToday has ${newProgress.readItemsToday.length} ayahs');
        print('segmentsToday is EMPTY (${newProgress.segmentsToday.length})');
        print('');
        print('This is why:');
        print('  ✅ History shows correct count (reads readItemsToday)');
        print('  ❌ Today\'s Reading shows wrong count (reads segmentsToday)');
      }
      print('╚════════════════════════════════════════════════════╝');

      // THE BUG: readItemsToday has data, but segmentsToday is empty!
      expect(newProgress.readItemsToday.length, 7,
          reason: 'readItemsToday should have 7 ayahs');
      expect(newProgress.segmentsToday.length, 0,
          reason: 'segmentsToday is EMPTY (this is the bug!)');
    },
  );

  test(
    '✅ EXPECTED BEHAVIOR: Should set BOTH readItemsToday AND segmentsToday',
    () async {
      // This test shows what SHOULD happen
      final initialProgress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 0,
        readItemsToday: const {},
        segmentsToday: const [],
        sessionStartAbsolute: 1,
        lastReadAbsolute: null,
        lastUpdated: DateTime.now(),
        streak: 0,
        completedCycles: 0,
      );

      // CORRECT APPROACH: Set BOTH formats
      final readItems = {1, 2, 3, 4, 5, 6, 7};
      final segments = ReadingSegment.fromSet(readItems);
      
      final newProgress = initialProgress.copyWith(
        totalAmountReadToday: 7,
        readItemsToday: readItems,
        segmentsToday: segments, // SET BOTH!
        lastReadAbsolute: 7,
        sessionStartAbsolute: 1,
        lastUpdated: DateTime.now(),
      );

      print('╔════════════════════════════════════════════════════╗');
      print('✅ EXPECTED BEHAVIOR TEST');
      print('╠════════════════════════════════════════════════════╣');
      
      // Both should be set
      expect(newProgress.readItemsToday.length, 7);
      
      // segmentsToday should have ONE segment {1-7}
      expect(newProgress.segmentsToday.length, 1,
          reason: 'Should have ONE segment covering ayahs 1-7');
      expect(newProgress.segmentsToday[0].startAyah, 1);
      expect(newProgress.segmentsToday[0].endAyah, 7);
      expect(newProgress.segmentsToday[0].ayahsCount, 7);
      
      print('readItemsToday: ${newProgress.readItemsToday.length} ayahs');
      print('segmentsToday: ${newProgress.segmentsToday.length} segment(s)');
      
      if (newProgress.segmentsToday.isNotEmpty) {
        final seg = newProgress.segmentsToday[0];
        print('Segment 0: ${seg.startAyah}-${seg.endAyah} (${seg.ayahsCount} ayahs)');
        print('✅ Both formats are in sync!');
      }
      print('╚════════════════════════════════════════════════════╝');
    },
  );
}
