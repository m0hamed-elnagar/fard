import 'package:flutter/material.dart';

import 'azkar_reminder.dart';
import 'salaah_settings.dart';
import '../../audio/domain/repositories/audio_repository.dart';

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
  final String themePresetId;
  final Map<String, String>? customThemeColors;
  final AudioQuality audioQuality;
  final bool isAudioPlayerExpanded;

  // Reminders
  final bool isSalahReminderEnabled;
  final int salahReminderOffsetMinutes;
  final List<String> enabledSalahReminders;
  final bool isWerdReminderEnabled;
  final String werdReminderTime;
  final bool isSalawatReminderEnabled;
  final int salawatFrequencyHours;
  final String salawatStartTime;
  final String salawatEndTime;

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
    this.themePresetId = 'emerald',
    this.customThemeColors,
    this.audioQuality = AudioQuality.low64,
    this.isAudioPlayerExpanded = false,
    this.isSalahReminderEnabled = false,
    this.salahReminderOffsetMinutes = 15,
    this.enabledSalahReminders = const [],
    this.isWerdReminderEnabled = false,
    this.werdReminderTime = '20:00',
    this.isSalawatReminderEnabled = false,
    this.salawatFrequencyHours = 3,
    this.salawatStartTime = '10:00',
    this.salawatEndTime = '20:00',
  });
}
