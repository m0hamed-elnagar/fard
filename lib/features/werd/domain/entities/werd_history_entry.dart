import 'package:equatable/equatable.dart';
import 'reading_segment.dart';

class WerdHistoryEntry extends Equatable {
  final int totalAyahsRead;
  final int startAbsolute;
  final int endAbsolute;
  final double pagesRead;
  final double juzRead;
  final int segmentCount; // Number of reading segments that day
  final String startSurahName;
  final int startAyahNumber;
  final String endSurahName;
  final int endAyahNumber;
  final String summary;
  final List<ReadingSegment>? sessions; // Actual session data (optional for backward compatibility)

  const WerdHistoryEntry({
    required this.totalAyahsRead,
    required this.startAbsolute,
    required this.endAbsolute,
    required this.pagesRead,
    required this.juzRead,
    this.segmentCount = 1,
    required this.startSurahName,
    required this.startAyahNumber,
    required this.endSurahName,
    required this.endAyahNumber,
    required this.summary,
    this.sessions,
  });

  @override
  List<Object?> get props => [
    totalAyahsRead,
    startAbsolute,
    endAbsolute,
    pagesRead,
    juzRead,
    segmentCount,
    startSurahName,
    startAyahNumber,
    endSurahName,
    endAyahNumber,
    summary,
    sessions,
  ];

  Map<String, dynamic> toJson() => {
    'totalAyahsRead': totalAyahsRead,
    'startAbsolute': startAbsolute,
    'endAbsolute': endAbsolute,
    'pagesRead': pagesRead,
    'juzRead': juzRead,
    'segmentCount': segmentCount,
    'startSurahName': startSurahName,
    'startAyahNumber': startAyahNumber,
    'endSurahName': endSurahName,
    'endAyahNumber': endAyahNumber,
    'summary': summary,
    if (sessions != null) 'sessions': sessions!.map((s) => s.toJson()).toList(),
  };

  factory WerdHistoryEntry.fromJson(Map<String, dynamic> json) {
    final sessionsJson = json['sessions'] as List<dynamic>?;
    final sessions = sessionsJson?.map((s) => ReadingSegment.fromJson(s as Map<String, dynamic>)).toList();

    return WerdHistoryEntry(
      totalAyahsRead: json['totalAyahsRead'] ?? 0,
      startAbsolute: json['startAbsolute'] ?? 0,
      endAbsolute: json['endAbsolute'] ?? 0,
      pagesRead: (json['pagesRead'] as num?)?.toDouble() ?? 0.0,
      juzRead: (json['juzRead'] as num?)?.toDouble() ?? 0.0,
      segmentCount: json['segmentCount'] ?? 1,
      startSurahName: json['startSurahName'] ?? '',
      startAyahNumber: json['startAyahNumber'] ?? 0,
      endSurahName: json['endSurahName'] ?? '',
      endAyahNumber: json['endAyahNumber'] ?? 0,
      summary: json['summary'] ?? '',
      sessions: sessions,
    );
  }
}
