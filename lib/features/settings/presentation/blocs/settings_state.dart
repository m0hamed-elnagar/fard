import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/azkar_reminder.dart';
import '../../domain/entities/custom_theme.dart';
import '../../domain/salaah_settings.dart';
import '../../../audio/domain/repositories/audio_repository.dart';

part 'settings_state.freezed.dart';

@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState({
    required Locale locale,
    double? latitude,
    double? longitude,
    String? cityName,
    @Default('muslim_league') String calculationMethod,
    @Default('shafi') String madhab,
    @Default('05:00') String morningAzkarTime,
    @Default('18:00') String eveningAzkarTime,
    @Default(false) bool isAfterSalahAzkarEnabled,
    @Default([]) List<AzkarReminder> reminders,
    @Default([]) List<SalaahSettings> salaahSettings,
    @Default(false) bool isAzanVoiceDownloading,
    @Default(true) bool isQadaEnabled,
    @Default(0) int hijriAdjustment,
    @Default('emerald') String themePresetId,
    Map<String, String>? customThemeColors,
    @Default([]) List<CustomTheme> savedCustomThemes,
    String? activeCustomThemeId,
    @Default(null) LocationStatus? lastLocationStatus,
    @Default(AudioQuality.low64) AudioQuality audioQuality,
    @Default(false) bool isAudioPlayerExpanded,

    // Reminders
    @Default(false) bool isSalahReminderEnabled,
    @Default(15) int salahReminderOffsetMinutes,
    @Default([]) List<String> enabledSalahReminders,
    @Default(false) bool isWerdReminderEnabled,
    @Default('20:00') String werdReminderTime,
    @Default(false) bool isSalawatReminderEnabled,
    @Default(3) int salawatFrequencyHours,
    @Default('10:00') String salawatStartTime,
    @Default('20:00') String salawatEndTime,
  }) = _SettingsState;
}
