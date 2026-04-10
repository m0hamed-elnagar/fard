import 'package:flutter_test/flutter_test.dart';

// NOTE: This test file tests ReadingSegment which will be created during implementation.
// These tests are written FIRST (TDD) and will initially fail until ReadingSegment is implemented.

// Temporary stub for compilation - will be replaced with real import after implementation
// import 'package:fard/features/werd/domain/entities/reading_segment.dart';

// Temporary stub class for compilation - REMOVE after real ReadingSegment is created
class ReadingSegment {
  final int startAyah;
  final int endAyah;

  const ReadingSegment({required this.startAyah, required this.endAyah});

  int get ayahsCount => endAyah - startAyah + 1;

  static List<ReadingSegment> mergeSegments(List<ReadingSegment> segments) {
    if (segments.isEmpty) return [];
    final sorted = List<ReadingSegment>.from(segments)
      ..sort((a, b) => a.startAyah.compareTo(b.startAyah));
    final merged = <ReadingSegment>[sorted.first];
    for (int i = 1; i < sorted.length; i++) {
      final last = merged.last;
      final current = sorted[i];
      if (current.startAyah <= last.endAyah + 1) {
        merged[merged.length - 1] = ReadingSegment(
          startAyah: last.startAyah,
          endAyah: current.endAyah > last.endAyah ? current.endAyah : last.endAyah,
        );
      } else {
        merged.add(current);
      }
    }
    return merged;
  }

  Map<String, dynamic> toJson() => {'startAyah': startAyah, 'endAyah': endAyah};

  factory ReadingSegment.fromJson(Map<String, dynamic> json) =>
      ReadingSegment(startAyah: json['startAyah'], endAyah: json['endAyah']);

  @override
  String toString() => 'ReadingSegment{$startAyah-$endAyah}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReadingSegment &&
          runtimeType == other.runtimeType &&
          startAyah == other.startAyah &&
          endAyah == other.endAyah;

  @override
  int get hashCode => startAyah.hashCode ^ endAyah.hashCode;
}

void main() {
  group('ReadingSegment Basic Properties', () {
    test('single ayah segment (start == end) has count of 1', () {
      const segment = ReadingSegment(startAyah: 100, endAyah: 100);
      expect(segment.ayahsCount, 1);
    });

    test('range segment calculates correct count', () {
      const segment = ReadingSegment(startAyah: 5, endAyah: 10);
      expect(segment.ayahsCount, 6); // 5,6,7,8,9,10
    });

    test('large range segment calculates correctly', () {
      const segment = ReadingSegment(startAyah: 1, endAyah: 100);
      expect(segment.ayahsCount, 100);
    });

    test('end of Quran segment', () {
      const segment = ReadingSegment(startAyah: 6230, endAyah: 6236);
      expect(segment.ayahsCount, 7);
    });
  });

  group('ReadingSegment Merge Logic', () {
    test('adjacent segments merge: {1,5} + {6,10} → {1,10}', () {
      final segments = const [
        ReadingSegment(startAyah: 1, endAyah: 5),
        ReadingSegment(startAyah: 6, endAyah: 10),
      ];
      final merged = ReadingSegment.mergeSegments(segments);
      expect(merged.length, 1);
      expect(merged.first, const ReadingSegment(startAyah: 1, endAyah: 10));
    });

    test('overlapping segments merge: {1,8} + {5,10} → {1,10}', () {
      final segments = const [
        ReadingSegment(startAyah: 1, endAyah: 8),
        ReadingSegment(startAyah: 5, endAyah: 10),
      ];
      final merged = ReadingSegment.mergeSegments(segments);
      expect(merged.length, 1);
      expect(merged.first, const ReadingSegment(startAyah: 1, endAyah: 10));
    });

    test('segments with gap stay separate: {1,5} + {10,15}', () {
      final segments = const [
        ReadingSegment(startAyah: 1, endAyah: 5),
        ReadingSegment(startAyah: 10, endAyah: 15),
      ];
      final merged = ReadingSegment.mergeSegments(segments);
      expect(merged.length, 2);
      expect(merged[0], const ReadingSegment(startAyah: 1, endAyah: 5));
      expect(merged[1], const ReadingSegment(startAyah: 10, endAyah: 15));
    });

    test('multiple segments merge correctly: {1,3}, {5,7}, {8,10} → {1,3}, {5,10}', () {
      final segments = const [
        ReadingSegment(startAyah: 1, endAyah: 3),
        ReadingSegment(startAyah: 5, endAyah: 7),
        ReadingSegment(startAyah: 8, endAyah: 10),
      ];
      final merged = ReadingSegment.mergeSegments(segments);
      expect(merged.length, 2);
      expect(merged[0], const ReadingSegment(startAyah: 1, endAyah: 3));
      expect(merged[1], const ReadingSegment(startAyah: 5, endAyah: 10));
    });

    test('merge handles unsorted input', () {
      final segments = const [
        ReadingSegment(startAyah: 10, endAyah: 15),
        ReadingSegment(startAyah: 1, endAyah: 5),
        ReadingSegment(startAyah: 6, endAyah: 8),
      ];
      final merged = ReadingSegment.mergeSegments(segments);
      expect(merged.length, 2);
      expect(merged[0], const ReadingSegment(startAyah: 1, endAyah: 8));
      expect(merged[1], const ReadingSegment(startAyah: 10, endAyah: 15));
    });

    test('merge with empty list returns empty', () {
      final merged = ReadingSegment.mergeSegments([]);
      expect(merged, isEmpty);
    });

    test('merge with single segment returns unchanged', () {
      final segments = const [ReadingSegment(startAyah: 5, endAyah: 10)];
      final merged = ReadingSegment.mergeSegments(segments);
      expect(merged.length, 1);
      expect(merged.first, const ReadingSegment(startAyah: 5, endAyah: 10));
    });

    test('nested segment absorbs into larger: {1,10} + {3,7} → {1,10}', () {
      final segments = const [
        ReadingSegment(startAyah: 1, endAyah: 10),
        ReadingSegment(startAyah: 3, endAyah: 7),
      ];
      final merged = ReadingSegment.mergeSegments(segments);
      expect(merged.length, 1);
      expect(merged.first, const ReadingSegment(startAyah: 1, endAyah: 10));
    });
  });

  group('ReadingSegment Serialization', () {
    test('toJson produces correct map', () {
      const segment = ReadingSegment(startAyah: 50, endAyah: 100);
      final json = segment.toJson();
      expect(json['startAyah'], 50);
      expect(json['endAyah'], 100);
      expect(json.length, 2);
    });

    test('fromJson reconstructs segment correctly', () {
      final json = {'startAyah': 50, 'endAyah': 100};
      final segment = ReadingSegment.fromJson(json);
      expect(segment.startAyah, 50);
      expect(segment.endAyah, 100);
      expect(segment.ayahsCount, 51);
    });

    test('round-trip serialization/deserialization', () {
      const original = ReadingSegment(startAyah: 1, endAyah: 6236);
      final json = original.toJson();
      final restored = ReadingSegment.fromJson(json);
      expect(restored, original);
    });
  });
}
