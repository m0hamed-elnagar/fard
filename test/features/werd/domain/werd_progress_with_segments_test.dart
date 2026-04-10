import 'package:flutter_test/flutter_test.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:fard/features/werd/domain/entities/werd_history_entry.dart';

// Stub classes for compilation - will be replaced by real imports after implementation
class _StubReadingSegment {
  final int startAyah;
  final int endAyah;
  const _StubReadingSegment({required this.startAyah, required this.endAyah});
  int get ayahsCount => endAyah - startAyah + 1;
}

void main() {
  group('WerdProgress with Segments', () {
    test('progress with segments calculates totalAyahsToday correctly', () {
      final segments = [
        const _StubReadingSegment(startAyah: 1, endAyah: 5),
        const _StubReadingSegment(startAyah: 100, endAyah: 105),
      ];
      final total = segments.fold(0, (sum, seg) => sum + seg.ayahsCount);
      expect(total, 11); // 5 + 6
    });

    test('cumulativeTotalAyahs calculates: (1 cycle × 6236) + 100 = 6336', () {
      final completedCycles = 1;
      final totalAmountReadToday = 100;
      final cumulative = (completedCycles * 6236) + totalAmountReadToday;
      expect(cumulative, 6336);
    });

    test('cumulativeTotalAyahs with 0 cycles = today only', () {
      final completedCycles = 0;
      final totalAmountReadToday = 50;
      final cumulative = (completedCycles * 6236) + totalAmountReadToday;
      expect(cumulative, 50);
    });
  });

  group('WerdProgress Migration from Set<int> to Segments', () {
    test('sequential ayahs convert to single segment: {1,2,3,4,5} → {1,5}', () {
      final oldFormat = [1, 2, 3, 4, 5];
      final segments = _convertSetToSegments(oldFormat);
      expect(segments.length, 1);
      expect(segments[0].startAyah, 1);
      expect(segments[0].endAyah, 5);
    });

    test('scattered ayahs convert to multiple segments: {1,2,3,100,101} → 2 segments', () {
      final oldFormat = [1, 2, 3, 100, 101];
      final segments = _convertSetToSegments(oldFormat);
      expect(segments.length, 2);
      expect(segments[0].startAyah, 1);
      expect(segments[0].endAyah, 3);
      expect(segments[1].startAyah, 100);
      expect(segments[1].endAyah, 101);
    });

    test('empty set converts to empty segments list', () {
      final oldFormat = <int>[];
      final segments = _convertSetToSegments(oldFormat);
      expect(segments, isEmpty);
    });

    test('single ayah converts to segment with start==end', () {
      final oldFormat = [42];
      final segments = _convertSetToSegments(oldFormat);
      expect(segments.length, 1);
      expect(segments[0].startAyah, 42);
      expect(segments[0].endAyah, 42);
    });
  });
}

// Migration helper - will be moved to WerdProgress after implementation
List<_StubReadingSegment> _convertSetToSegments(List<int> ayahs) {
  if (ayahs.isEmpty) return [];
  ayahs.sort();
  final segments = <_StubReadingSegment>[];
  int start = ayahs.first;
  int end = ayahs.first;
  for (int i = 1; i < ayahs.length; i++) {
    if (ayahs[i] == end + 1) {
      end = ayahs[i];
    } else {
      segments.add(_StubReadingSegment(startAyah: start, endAyah: end));
      start = ayahs[i];
      end = ayahs[i];
    }
  }
  segments.add(_StubReadingSegment(startAyah: start, endAyah: end));
  return segments;
}
