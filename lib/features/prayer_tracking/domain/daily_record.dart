import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';

@immutable
final class DailyRecord extends Equatable {
  final String id;
  final DateTime date;
  final Set<Salaah> missedToday;
  final Map<Salaah, MissedCounter> qada;
  const DailyRecord({
    required this.id,
    required this.date,
    required this.missedToday,
    required this.qada,
  });
  @override
  List<Object> get props => [id, date, missedToday, qada];
}
