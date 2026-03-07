import 'package:equatable/equatable.dart';

class WerdProgress extends Equatable {
  final String goalId;
  final int totalAmountReadToday;
  final Set<int> readItemsToday; // Items (ayahs/counts/etc) read TODAY (absolute indices)
  final int? lastReadAbsolute;
  final int? sessionStartAbsolute;
  final DateTime lastUpdated;
  final int streak;
  final Map<String, int> history; // ISO date string -> amount read

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
    'history': history,
  };

  factory WerdProgress.fromJson(Map<String, dynamic> json) {
    return WerdProgress(
      goalId: json['goalId'] ?? 'default',
      totalAmountReadToday: json['totalAmountReadToday'] ?? 0,
      readItemsToday: Set<int>.from(json['readItemsToday'] ?? []),
      lastReadAbsolute: json['lastReadAbsolute'],
      sessionStartAbsolute: json['sessionStartAbsolute'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
      streak: json['streak'] ?? 0,
      history: Map<String, int>.from(json['history'] ?? {}),
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
    Map<String, int>? history,
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
