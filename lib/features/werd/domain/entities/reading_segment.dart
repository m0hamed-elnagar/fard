import 'package:equatable/equatable.dart';

class ReadingSegment extends Equatable {
  final int startAyah; // Absolute ayah number
  final int endAyah; // Absolute ayah number
  final DateTime? startTime; // When session started
  final DateTime? endTime; // When session ended

  const ReadingSegment({
    required this.startAyah,
    required this.endAyah,
    this.startTime,
    this.endTime,
  });

  /// Number of ayahs in this segment (inclusive)
  int get ayahsCount => endAyah - startAyah + 1;

  /// Get formatted start time (e.g., "9:00 AM")
  String get formattedStartTime {
    if (startTime == null) return '';
    final hour = startTime!.hour > 12 ? startTime!.hour - 12 : startTime!.hour;
    final minute = startTime!.minute.toString().padLeft(2, '0');
    final period = startTime!.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Get formatted end time (e.g., "9:15 AM")
  String get formattedEndTime {
    if (endTime == null) return '';
    final hour = endTime!.hour > 12 ? endTime!.hour - 12 : endTime!.hour;
    final minute = endTime!.minute.toString().padLeft(2, '0');
    final period = endTime!.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Get session duration in minutes
  int? get durationMinutes {
    if (startTime == null || endTime == null) return null;
    return endTime!.difference(startTime!).inMinutes;
  }

  /// Create a new segment with start time
  ReadingSegment startSession({int? startAyahOverride}) {
    return ReadingSegment(
      startAyah: startAyahOverride ?? startAyah,
      endAyah: startAyahOverride ?? startAyah,
      startTime: DateTime.now(),
    );
  }

  /// End this session
  ReadingSegment endSession() {
    return copyWith(endTime: DateTime.now());
  }

  /// Extend this segment to include new ayah
  ReadingSegment extend(int newEndAyah) {
    return copyWith(
      endAyah: newEndAyah,
      endTime: DateTime.now(),
    );
  }

  ReadingSegment copyWith({
    int? startAyah,
    int? endAyah,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return ReadingSegment(
      startAyah: startAyah ?? this.startAyah,
      endAyah: endAyah ?? this.endAyah,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  /// Merges adjacent or overlapping segments
  /// {1,5} + {6,10} → {1,10} (adjacent)
  /// {1,8} + {5,10} → {1,10} (overlapping)
  /// {1,5} + {10,15} → stays separate (gap)
  /// Merges timestamps: earliest startTime, latest endTime
  static List<ReadingSegment> mergeSegments(List<ReadingSegment> segments) {
    if (segments.isEmpty) return [];
    if (segments.length == 1) return segments;

    // Sort by startAyah
    final sorted = List<ReadingSegment>.from(segments)
      ..sort((a, b) => a.startAyah.compareTo(b.startAyah));

    final merged = <ReadingSegment>[sorted.first];

    for (int i = 1; i < sorted.length; i++) {
      final current = sorted[i];
      final last = merged.last;

      // Check if segments overlap or are adjacent (gap of 1)
      if (current.startAyah <= last.endAyah + 1) {
        // Merge them, taking the larger endAyah and merging timestamps
        final newEnd = current.endAyah > last.endAyah
            ? current.endAyah
            : last.endAyah;
        final newStartTime = last.startTime ?? current.startTime;
        final newEndTime = current.endTime ?? last.endTime;
        merged[merged.length - 1] = ReadingSegment(
          startAyah: last.startAyah,
          endAyah: newEnd,
          startTime: newStartTime,
          endTime: newEndTime,
        );
      } else {
        // No overlap, add as new segment
        merged.add(current);
      }
    }

    return merged;
  }

  /// Merges segments but respects session boundaries
  /// Sessions that have ended (endTime != null) should NOT merge with new sessions
  /// This allows multiple separate sessions per day
  static List<ReadingSegment> mergeSegmentsWithSessionAwareness(List<ReadingSegment> segments) {
    if (segments.isEmpty) return [];
    if (segments.length == 1) return segments;

    // Sort by startTime, then by startAyah
    final sorted = List<ReadingSegment>.from(segments)
      ..sort((a, b) {
        if (a.startTime != null && b.startTime != null) {
          final timeCompare = a.startTime!.compareTo(b.startTime!);
          if (timeCompare != 0) return timeCompare;
        }
        return a.startAyah.compareTo(b.startAyah);
      });

    final merged = <ReadingSegment>[sorted.first];

    for (int i = 1; i < sorted.length; i++) {
      final current = sorted[i];
      final last = merged.last;

      // Only merge if:
      // 1. Last session is still active (endTime == null)
      // 2. Segments are adjacent or overlapping (not a big gap)
      // 3. Current segment doesn't have a significantly different startTime
      final isLastActive = last.endTime == null;
      final isAdjacent = current.startAyah <= last.endAyah + 1;
      final isOverlapping = current.startAyah <= last.endAyah;
      
      // Check if segments are from the same time period (within 5 minutes)
      // Exception: If the previous segment is still active (endTime == null), 
      // we allow merging regardless of time to support long reading sessions.
      bool isSameTimePeriod = true;
      if (last.startTime != null && current.startTime != null && last.endTime != null) {
        final timeDiff = current.startTime!.difference(last.startTime!).inMinutes.abs();
        isSameTimePeriod = timeDiff <= 5;
      }

      if (isLastActive && (isAdjacent || isOverlapping) && isSameTimePeriod) {
        // Same active session - merge them
        final newEnd = current.endAyah > last.endAyah
            ? current.endAyah
            : last.endAyah;
        final newStartTime = last.startTime ?? current.startTime;
        final newEndTime = current.endTime ?? last.endTime;
        merged[merged.length - 1] = ReadingSegment(
          startAyah: last.startAyah,
          endAyah: newEnd,
          startTime: newStartTime,
          endTime: newEndTime,
        );
      } else {
        // Different session, gap, or time mismatch - keep separate
        merged.add(current);
      }
    }

    return merged;
  }

  /// Convert a Set<int> of individual ayahs to segments
  /// {1,2,3,100,101} → [{1,3}, {100,101}]
  /// Note: Creates session timestamps for new segments
  static List<ReadingSegment> fromSet(Set<int> ayahs) {
    if (ayahs.isEmpty) return [];

    final sorted = ayahs.toList()..sort();
    final segments = <ReadingSegment>[];
    int start = sorted.first;
    int end = sorted.first;
    final sessionStart = DateTime.now();

    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] == end + 1) {
        // Continue current segment
        end = sorted[i];
      } else {
        // Start new segment
        segments.add(ReadingSegment(
          startAyah: start, 
          endAyah: end,
          startTime: sessionStart,
          endTime: null,
        ));
        start = sorted[i];
        end = sorted[i];
      }
    }
    segments.add(ReadingSegment(
      startAyah: start, 
      endAyah: end,
      startTime: sessionStart,
      endTime: null,
    ));

    return segments;
  }

  Map<String, dynamic> toJson() => {
        'startAyah': startAyah,
        'endAyah': endAyah,
        'startTime': startTime?.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
      };

  factory ReadingSegment.fromJson(Map<String, dynamic> json) =>
      ReadingSegment(
        startAyah: json['startAyah'] as int,
        endAyah: json['endAyah'] as int,
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'] as String)
            : null,
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
      );

  @override
  List<Object?> get props => [startAyah, endAyah, startTime, endTime];

  @override
  String toString() => 'ReadingSegment($startAyah-$endAyah, ${startTime?.toLocal()} to ${endTime?.toLocal()})';
}
