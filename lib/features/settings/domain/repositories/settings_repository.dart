import 'package:flutter/material.dart';

import '../../domain/azkar_reminder.dart';
import '../../domain/entities/custom_theme.dart';
import '../../domain/salaah_settings.dart';
import '../../../audio/domain/repositories/audio_repository.dart';
import '../../../prayer_tracking/domain/salaah.dart';
import '../prayer_reminder_type.dart';

/// Repository interface for managing app settings persistence.
///
/// This interface provides a clean separation between settings storage
/// and business logic. It lives in the Domain layer and should be
/// implemented in the Data layer.
///
/// Core services (NotificationService, WidgetUpdateService, etc.) depend
/// on this interface rather than presentation-layer BLoCs.
abstract interface class SettingsRepository {
  // ==================== READ OPERATIONS ====================

  /// The app's current locale
  Locale get locale;

  /// Latitude for prayer time calculations
  double? get latitude;

  /// Longitude for prayer time calculations
  double? get longitude;

  /// City name for display
  String? get cityName;

  /// Prayer calculation method (e.g., 'muslim_league', 'umm_al_qura')
  String get calculationMethod;

  /// Madhab for Asr calculation ('shafi' or 'hanafi')
  String get madhab;

  /// Morning Azkar time in HH:mm format
  String get morningAzkarTime;

  /// Evening Azkar time in HH:mm format
  String get eveningAzkarTime;

  /// Whether after-salah Azkar is globally enabled
  bool get isAfterSalahAzkarEnabled;

  /// Individual prayer settings
  List<SalaahSettings> get salaahSettings;

  /// Custom Azkar reminders
  List<AzkarReminder> get reminders;

  /// Whether Qada tracking is enabled
  bool get isQadaEnabled;

  /// Hijri calendar adjustment in days
  int get hijriAdjustment;

  /// Selected theme preset ID
  String get themePresetId;

  /// Custom theme colors (if using custom theme)
  Map<String, String>? get customThemeColors;

  /// List of user-saved custom themes
  List<CustomTheme> get savedCustomThemes;

  /// Currently active custom theme ID (null if using a preset)
  String? get activeCustomThemeId;

  /// Preferred audio quality
  AudioQuality get audioQuality;

  /// Whether the audio player is expanded
  bool get isAudioPlayerExpanded;

  // ==================== REMINDERS ====================

  /// Whether post-prayer reminders are globally enabled
  bool get isSalahReminderEnabled;

  /// Minutes after Azan for post-prayer reminder
  int get salahReminderOffsetMinutes;

  /// Type of prayer reminder (before/after)
  PrayerReminderType get prayerReminderType;

  /// Set of prayers that have reminders enabled
  Set<Salaah> get enabledSalahReminders;

  /// Whether daily Werd reminder is enabled
  bool get isWerdReminderEnabled;

  /// Daily Werd reminder time (HH:mm)
  String get werdReminderTime;

  /// Whether periodic Salawat reminder is enabled
  bool get isSalawatReminderEnabled;

  /// Frequency of Salawat reminder in hours
  int get salawatFrequencyHours;

  /// Start time for Salawat reminders (HH:mm)
  String get salawatStartTime;

  /// End time for Salawat reminders (HH:mm)
  String get salawatEndTime;

  // ==================== WRITE OPERATIONS ====================

  /// Update the app locale
  Future<void> updateLocale(Locale locale);

  /// Update latitude and longitude
  Future<void> updateLocation({
    double? latitude,
    double? longitude,
    String? cityName,
  });

  /// Update prayer calculation method
  Future<void> updateCalculationMethod(String method);

  /// Update madhab
  Future<void> updateMadhab(String madhab);

  /// Update morning Azkar time
  Future<void> updateMorningAzkarTime(String time);

  /// Update evening Azkar time
  Future<void> updateEveningAzkarTime(String time);

  /// Update after-salah Azkar enabled flag (single key persistence only)
  Future<void> updateAfterSalahAzkarEnabled(bool enabled);

  /// Update individual prayer settings
  Future<void> updateSalaahSettings(List<SalaahSettings> settings);

  /// Toggle Qada tracking
  Future<void> toggleQadaEnabled();

  /// Update Hijri adjustment
  Future<void> updateHijriAdjustment(int adjustment);

  /// Add a new Azkar reminder
  Future<void> addReminder(AzkarReminder reminder);

  /// Remove an Azkar reminder by index
  Future<void> removeReminder(int index);

  /// Update an Azkar reminder
  Future<void> updateReminder(int index, AzkarReminder reminder);

  /// Toggle an Azkar reminder's enabled state
  Future<void> toggleReminder(int index);

  /// Bulk update all prayer azan enabled state
  Future<void> updateAllAzanEnabled(bool enabled);

  /// Bulk update all prayer reminder enabled state
  Future<void> updateAllReminderEnabled(bool enabled);

  /// Bulk update all prayer azan sound
  Future<void> updateAllAzanSound(String? sound);

  /// Bulk update all prayer reminder minutes
  Future<void> updateAllReminderMinutes(int minutes);

  /// Bulk update all prayer after-salah azkar minutes
  Future<void> updateAllAfterSalahMinutes(int minutes);

  /// Update theme preset
  Future<void> updateThemePreset(String presetId);

  /// Save custom theme colors
  Future<void> saveCustomTheme(Map<String, String> colors);

  /// Add a new custom theme to the saved list
  Future<void> addCustomTheme(CustomTheme theme);

  /// Update an existing custom theme
  Future<void> updateCustomTheme(String themeId, Map<String, String> colors);

  /// Delete a custom theme by ID
  Future<void> deleteCustomTheme(String themeId);

  /// Set active custom theme ID
  Future<void> setActiveCustomTheme(String? themeId);

  /// Update preferred audio quality
  Future<void> updateAudioQuality(AudioQuality quality);

  /// Update whether the audio player is expanded
  Future<void> updateAudioPlayerExpanded(bool expanded);

  /// Update post-prayer reminders enabled state
  Future<void> updateSalahReminderEnabled(bool enabled);

  /// Update post-prayer reminder offset minutes
  Future<void> updateSalahReminderOffset(int minutes);

  /// Update prayer reminder type
  Future<void> updatePrayerReminderType(PrayerReminderType type);

  /// Update the list of enabled post-prayer reminders
  Future<void> updateEnabledSalahReminders(Set<Salaah> enabledSalahs);

  /// Update Werd reminder enabled state
  Future<void> updateWerdReminderEnabled(bool enabled);

  /// Update Werd reminder time
  Future<void> updateWerdReminderTime(String time);

  /// Update periodic Salawat reminder enabled state
  Future<void> updateSalawatReminderEnabled(bool enabled);

  /// Update Salawat reminder frequency
  Future<void> updateSalawatFrequency(int hours);

  /// Update Salawat reminder start time
  Future<void> updateSalawatStartTime(String time);

  /// Update Salawat reminder end time
  Future<void> updateSalawatEndTime(String time);

  // ==================== BACKUP / RESTORE ====================

  /// Get all settings as a key-value map for backup
  Map<String, dynamic> getAllSettings();

  /// Import all settings from a map
  Future<void> importSettings(Map<String, dynamic> settings);
}

