import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';

@immutable
final class DailyRecord extends Equatable {
  final String id;
  final DateTime date;
  final Set<Salaah> missedToday;
  final Set<Salaah> completedToday;
  final Map<Salaah, MissedCounter> qada;
  final Map<Salaah, int> completedQada;
  const DailyRecord({
    required this.id,
    required this.date,
    required this.missedToday,
    required this.completedToday,
    required this.qada,
    this.completedQada = const {},
  });

  DailyRecord copyWith({
    String? id,
    DateTime? date,
    Set<Salaah>? missedToday,
    Set<Salaah>? completedToday,
    Map<Salaah, MissedCounter>? qada,
    Map<Salaah, int>? completedQada,
  }) {
    return DailyRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      missedToday: missedToday ?? this.missedToday,
      completedToday: completedToday ?? this.completedToday,
      qada: qada ?? this.qada,
      completedQada: completedQada ?? this.completedQada,
    );
  }

  @override
  List<Object> get props => [
    id,
    date,
    missedToday,
    completedToday,
    qada,
    completedQada,
  ];

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'missedToday': missedToday.map((s) => s.index).toList(),
    'completedToday': completedToday.map((s) => s.index).toList(),
    'qada': qada.map((k, v) => MapEntry(k.index.toString(), v.value)),
    'completedQada': completedQada.map(
      (k, v) => MapEntry(k.index.toString(), v),
    ),
  };

  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      missedToday: (json['missedToday'] as List)
          .map((i) => Salaah.values[i as int])
          .toSet(),
      completedToday: (json['completedToday'] as List)
          .map((i) => Salaah.values[i as int])
          .toSet(),
      qada: (json['qada'] as Map).map(
        (k, v) => MapEntry(
          Salaah.values[int.parse(k as String)],
          MissedCounter(v as int),
        ),
      ),
      completedQada: (json['completedQada'] as Map).map(
        (k, v) => MapEntry(Salaah.values[int.parse(k as String)], v as int),
      ),
    );
  }
}
