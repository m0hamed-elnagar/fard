import 'package:equatable/equatable.dart';
import 'werd_history_entry.dart';
import 'reading_segment.dart';

/// Daily session tracking - ONE session per day
/// Simple: tracks when you started, where you stopped, and total for the day
class WerdProgress extends Equatable {
  final String goalId;
  final int totalAmountReadToday;
  
  // DAILY SESSION TRACKING (simplified)
  final DateTime? sessionStartTime;    // When you clicked Continue
  final DateTime? sessionEndTime;      // When you went back
  final int? firstAyahToday;           // First ayah you started at
  final int? lastAyahToday;            // Last ayah you read to
  
  // Kept for backward compatibility
  final Set<int> readItemsToday;
  final List<ReadingSegment> segmentsToday;
  final int? lastReadAbsolute;
  final int? sessionStartAbsolute;
  final DateTime lastUpdated;
  final int streak;
  final int completedCycles;
  final Map<String, WerdHistoryEntry> history;

  const WerdProgress({
    required this.goalId,
    required this.totalAmountReadToday,
    // Daily session fields
    this.sessionStartTime,
    this.sessionEndTime,
    this.firstAyahToday,
    this.lastAyahToday,
    // Backward compatibility
    this.readItemsToday = const {},
    this.segmentsToday = const [],
    this.lastReadAbsolute,
    this.sessionStartAbsolute,
    required this.lastUpdated,
    required this.streak,
    this.completedCycles = 0,
    this.history = const {},
  });

  /// Cumulative total ayahs including completed cycles
  int get cumulativeTotalAyahs => (completedCycles * 6236) + totalAmountReadToday;

  /// Session duration
  Duration? get sessionDuration {
    if (sessionStartTime == null) return null;
    final end = sessionEndTime ?? DateTime.now();
    return end.difference(sessionStartTime!);
  }

  @override
  List<Object?> get props => [
    goalId,
    totalAmountReadToday,
    sessionStartTime,
    sessionEndTime,
    firstAyahToday,
    lastAyahToday,
    readItemsToday,
    segmentsToday,
    lastReadAbsolute,
    sessionStartAbsolute,
    lastUpdated,
    streak,
    completedCycles,
    history,
  ];

  Map<String, dynamic> toJson() => {
    'goalId': goalId,
    'totalAmountReadToday': totalAmountReadToday,
    // Daily session fields
    'sessionStartTime': sessionStartTime?.toIso8601String(),
    'sessionEndTime': sessionEndTime?.toIso8601String(),
    'firstAyahToday': firstAyahToday,
    'lastAyahToday': lastAyahToday,
    // Backward compatibility
    'readItemsToday': readItemsToday.toList(),
    'segmentsToday': segmentsToday.map((s) => s.toJson()).toList(),
    'lastReadAbsolute': lastReadAbsolute,
    'sessionStartAbsolute': sessionStartAbsolute,
    'lastUpdated': lastUpdated.toIso8601String(),
    'streak': streak,
    'completedCycles': completedCycles,
    'history': history.map((key, value) => MapEntry(key, value.toJson())),
  };

  factory WerdProgress.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'] as Map<String, dynamic>? ?? {};
    final history = rawHistory.map((key, value) {
      if (value is int) {
        return MapEntry(
          key,
          WerdHistoryEntry(
            totalAyahsRead: value,
            startAbsolute: 0,
            endAbsolute: 0,
            pagesRead: 0.0,
            juzRead: 0.0,
            startSurahName: '',
            startAyahNumber: 0,
            endSurahName: '',
            endAyahNumber: 0,
            summary: 'Read $value ayahs',
          ),
        );
      } else {
        return MapEntry(
          key,
          WerdHistoryEntry.fromJson(value as Map<String, dynamic>),
        );
      }
    });

    // Migration: Convert old segments to daily session
    List<ReadingSegment> segmentsToday = const [];
    int? firstAyahToday;
    int? lastAyahToday;
    DateTime? sessionStartTime;
    DateTime? sessionEndTime;

    if (json['segmentsToday'] != null) {
      segmentsToday = (json['segmentsToday'] as List)
          .map((s) => ReadingSegment.fromJson(s as Map<String, dynamic>))
          .toList();
      
      // Extract daily session from segments
      if (segmentsToday.isNotEmpty) {
        firstAyahToday = segmentsToday.first.startAyah;
        lastAyahToday = segmentsToday.last.endAyah;
        sessionStartTime = segmentsToday.first.startTime;
        sessionEndTime = segmentsToday.last.endTime;
      }
    } else if (json['readItemsToday'] != null) {
      final oldItems = Set<int>.from(json['readItemsToday'] as List);
      segmentsToday = ReadingSegment.fromSet(oldItems);
    }

    return WerdProgress(
      goalId: json['goalId'] ?? 'default',
      totalAmountReadToday: json['totalAmountReadToday'] ?? 0,
      // Daily session fields
      sessionStartTime: json['sessionStartTime'] != null 
          ? DateTime.parse(json['sessionStartTime']) 
          : sessionStartTime,
      sessionEndTime: json['sessionEndTime'] != null 
          ? DateTime.parse(json['sessionEndTime']) 
          : sessionEndTime,
      firstAyahToday: json['firstAyahToday'] ?? firstAyahToday,
      lastAyahToday: json['lastAyahToday'] ?? lastAyahToday,
      // Backward compatibility
      readItemsToday: Set<int>.from(json['readItemsToday'] ?? []),
      segmentsToday: segmentsToday,
      lastReadAbsolute: json['lastReadAbsolute'],
      sessionStartAbsolute: json['sessionStartAbsolute'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      streak: json['streak'] ?? 0,
      completedCycles: json['completedCycles'] ?? 0,
      history: history,
    );
  }

  WerdProgress copyWith({
    String? goalId,
    int? totalAmountReadToday,
    DateTime? sessionStartTime,
    DateTime? sessionEndTime,
    int? firstAyahToday,
    int? lastAyahToday,
    Set<int>? readItemsToday,
    List<ReadingSegment>? segmentsToday,
    int? lastReadAbsolute,
    int? sessionStartAbsolute,
    DateTime? lastUpdated,
    int? streak,
    int? completedCycles,
    Map<String, WerdHistoryEntry>? history,
  }) {
    return WerdProgress(
      goalId: goalId ?? this.goalId,
      totalAmountReadToday: totalAmountReadToday ?? this.totalAmountReadToday,
      sessionStartTime: sessionStartTime,
      sessionEndTime: sessionEndTime,
      firstAyahToday: firstAyahToday,
      lastAyahToday: lastAyahToday,
      readItemsToday: readItemsToday ?? this.readItemsToday,
      segmentsToday: segmentsToday ?? this.segmentsToday,
      lastReadAbsolute: lastReadAbsolute ?? this.lastReadAbsolute,
      sessionStartAbsolute: sessionStartAbsolute ?? this.sessionStartAbsolute,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      streak: streak ?? this.streak,
      completedCycles: completedCycles ?? this.completedCycles,
      history: history ?? this.history,
    );
  }
}
