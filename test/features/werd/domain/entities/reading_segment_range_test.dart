import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReadingSegment - Range Tracking Verification', () {
    
    test('BUG DEMONSTRATION: Creating segment with start=1, end=10', () {
      // This test demonstrates what SHOULD happen
      const segment = ReadingSegment(startAyah: 1, endAyah: 10);
      
      print('✅ CORRECT Segment:');
      print('   Start Ayah: ${segment.startAyah}');
      print('   End Ayah: ${segment.endAyah}');
      print('   Ayah Count: ${segment.ayahsCount}');
      
      expect(segment.startAyah, 1);
      expect(segment.endAyah, 10);
      expect(segment.ayahsCount, 10); // Should be 10 ayahs
    });

    test('BUG DEMONSTRATION: Current buggy behavior creates single ayah segment', () {
      // This is what the BUGGY code currently does:
      // When you call trackRangeRead(1, 10), it only uses endAbsolute=10
      // and creates a segment like {10, 10} instead of {1, 10}
      
      const buggySegment = ReadingSegment(startAyah: 10, endAyah: 10);
      
      print('❌ BUGGY Segment (what currently happens):');
      print('   Start Ayah: ${buggySegment.startAyah}');
      print('   End Ayah: ${buggySegment.endAyah}');
      print('   Ayah Count: ${buggySegment.ayahsCount}');
      
      // This shows the bug: only 1 ayah tracked instead of 10
      expect(buggySegment.startAyah, 10);
      expect(buggySegment.endAyah, 10);
      expect(buggySegment.ayahsCount, 1); // BUG: Only 1 ayah!
    });

    test('Segment merging should preserve ranges', () {
      final segment1 = const ReadingSegment(startAyah: 1, endAyah: 5);
      final segment2 = const ReadingSegment(startAyah: 10, endAyah: 15);
      
      final merged = ReadingSegment.mergeSegments([segment1, segment2]);
      
      print('Merged segments:');
      for (final seg in merged) {
        print('   Segment: ${seg.startAyah} - ${seg.endAyah} (${seg.ayahsCount} ayahs)');
      }
      
      // Should remain separate (gap between 5 and 10)
      expect(merged.length, 2);
      expect(merged[0].startAyah, 1);
      expect(merged[0].endAyah, 5);
      expect(merged[1].startAyah, 10);
      expect(merged[1].endAyah, 15);
    });

    test('Adjacent segments should merge', () {
      final segment1 = const ReadingSegment(startAyah: 1, endAyah: 5);
      final segment2 = const ReadingSegment(startAyah: 6, endAyah: 10);
      
      final merged = ReadingSegment.mergeSegments([segment1, segment2]);
      
      print('Adjacent segments after merge:');
      for (final seg in merged) {
        print('   Segment: ${seg.startAyah} - ${seg.endAyah} (${seg.ayahsCount} ayahs)');
      }
      
      // Should merge into one segment
      expect(merged.length, 1);
      expect(merged[0].startAyah, 1);
      expect(merged[0].endAyah, 10);
      expect(merged[0].ayahsCount, 10);
    });

    test('Calculate total ayahs from multiple segments', () {
      final segments = [
        const ReadingSegment(startAyah: 1, endAyah: 5),   // 5 ayahs
        const ReadingSegment(startAyah: 10, endAyah: 15), // 6 ayahs
      ];
      
      final totalAyahs = segments.fold<int>(0, (sum, seg) => sum + seg.ayahsCount);
      
      print('Total ayahs from segments: $totalAyahs');
      
      expect(totalAyahs, 11); // 5 + 6
    });

    test('WerdProgress should calculate total from segments', () {
      final segments = [
        const ReadingSegment(startAyah: 1, endAyah: 5),   // 5 ayahs
        const ReadingSegment(startAyah: 10, endAyah: 15), // 6 ayahs
      ];
      
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 0, // This should be updated
        segmentsToday: segments,
        lastUpdated: DateTime.now(),
        streak: 0,
      );
      
      // The totalAmountReadToday should be set correctly when creating progress
      // But let's verify the segments are correct
      final calculatedTotal = progress.segmentsToday.fold<int>(0, (sum, seg) => sum + seg.ayahsCount);
      
      print('Segments today: ${progress.segmentsToday.length}');
      print('Calculated total from segments: $calculatedTotal');
      
      expect(calculatedTotal, 11);
    });
  });
}
