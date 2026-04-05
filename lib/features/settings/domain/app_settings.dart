import 'package:flutter/material.dart';

import 'azkar_reminder.dart';
import 'salaah_settings.dart';

/// Immutable domain-level settings object.
///
/// This is a simple data class that can be safely imported
/// in background isolates without depending on presentation-layer types.
class AppSettings {
  final Locale locale;
  final double? latitude;
  final double? longitude;
  final String? cityName;
  final String calculationMethod;
  final String madhab;
  final String morningAzkarTime;
  final String eveningAzkarTime;
  final bool isAfterSalahAzkarEnabled;
  final List<AzkarReminder> reminders;
  final List<SalaahSettings> salaahSettings;
  final bool isQadaEnabled;
  final int hijriAdjustment;

  const AppSettings({
    required this.locale,
    this.latitude,
    this.longitude,
    this.cityName,
    this.calculationMethod = 'muslim_league',
    this.madhab = 'shafi',
    this.morningAzkarTime = '05:00',
    this.eveningAzkarTime = '18:00',
    this.isAfterSalahAzkarEnabled = false,
    this.reminders = const [],
    this.salaahSettings = const [],
    this.isQadaEnabled = true,
    this.hijriAdjustment = 0,
  });
}
