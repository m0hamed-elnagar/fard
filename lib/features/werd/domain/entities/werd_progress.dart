import 'package:equatable/equatable.dart';
import 'werd_history_entry.dart';

class WerdProgress extends Equatable {
  final String goalId;
  final int totalAmountReadToday;
  final Set<int>
  readItemsToday; // Items (ayahs/counts/etc) read TODAY (absolute indices)
  final int? lastReadAbsolute;
  final int? sessionStartAbsolute;
  final DateTime lastUpdated;
  final int streak;
  final Map<String, WerdHistoryEntry> history; // ISO date string -> entry

  const WerdProgress({
    required this.goalId,
    required this.totalAmountReadToday,
    this.readItemsToday = const {},
    this.lastReadAbsolute,
    this.sessionStartAbsolute,
    required this.lastUpdated,
    required this.streak,
    this.history = const {},
  });

  @override
  List<Object?> get props => [
    goalId,
    totalAmountReadToday,
    readItemsToday,
    lastReadAbsolute,
    sessionStartAbsolute,
    lastUpdated,
    streak,
    history,
  ];

  Map<String, dynamic> toJson() => {
    'goalId': goalId,
    'totalAmountReadToday': totalAmountReadToday,
    'readItemsToday': readItemsToday.toList(),
    'lastReadAbsolute': lastReadAbsolute,
    'sessionStartAbsolute': sessionStartAbsolute,
    'lastUpdated': lastUpdated.toIso8601String(),
    'streak': streak,
    'history': history.map((key, value) => MapEntry(key, value.toJson())),
  };

  factory WerdProgress.fromJson(Map<String, dynamic> json) {
    final rawHistory = json['history'] as Map<String, dynamic>? ?? {};
    final history = rawHistory.map((key, value) {
      if (value is int) {
        // Backward compatibility for old simple amount history
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

    return WerdProgress(
      goalId: json['goalId'] ?? 'default',
      totalAmountReadToday: json['totalAmountReadToday'] ?? 0,
      readItemsToday: Set<int>.from(json['readItemsToday'] ?? []),
      lastReadAbsolute: json['lastReadAbsolute'],
      sessionStartAbsolute: json['sessionStartAbsolute'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      streak: json['streak'] ?? 0,
      history: history,
    );
  }

  WerdProgress copyWith({
    String? goalId,
    int? totalAmountReadToday,
    Set<int>? readItemsToday,
    int? lastReadAbsolute,
    int? sessionStartAbsolute,
    DateTime? lastUpdated,
    int? streak,
    Map<String, WerdHistoryEntry>? history,
  }) {
    return WerdProgress(
      goalId: goalId ?? this.goalId,
      totalAmountReadToday: totalAmountReadToday ?? this.totalAmountReadToday,
      readItemsToday: readItemsToday ?? this.readItemsToday,
      lastReadAbsolute: lastReadAbsolute ?? this.lastReadAbsolute,
      sessionStartAbsolute: sessionStartAbsolute ?? this.sessionStartAbsolute,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      streak: streak ?? this.streak,
      history: history ?? this.history,
    );
  }
}
