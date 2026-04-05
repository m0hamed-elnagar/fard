import 'package:flutter/material.dart';

import '../../domain/azkar_reminder.dart';
import '../../domain/salaah_settings.dart';

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
}
