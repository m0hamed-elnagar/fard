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
  List<Object> get props => [id, date, missedToday, completedToday, qada, completedQada];
}
