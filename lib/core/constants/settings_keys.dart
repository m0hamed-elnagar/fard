/// Centralized constants for all settings storage keys.
///
/// Used by both [SettingsRepositoryImpl] and [SettingsLoader] to eliminate
/// duplication and ensure consistency across the app.
abstract final class SettingsKeys {
  static const String locale = 'locale';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String cityName = 'city_name';
  static const String calculationMethod = 'calculation_method';
  static const String madhab = 'madhab';
  static const String morningAzkarTime = 'morning_azkar_time';
  static const String eveningAzkarTime = 'evening_azkar_time';
  static const String afterSalahAzkarEnabled = 'is_after_salah_azkar_enabled';
  static const String azkarReminders = 'azkar_reminders';
  static const String salaahSettings = 'salaah_settings';
  static const String qadaEnabled = 'is_qada_enabled';
  static const String hijriAdjustment = 'hijri_adjustment';
}
