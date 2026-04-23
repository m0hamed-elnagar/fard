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
  static const String themePresetId = 'theme_preset_id';
  static const String customPrimaryColor = 'custom_primary_color';
  static const String customAccentColor = 'custom_accent_color';
  static const String customBackgroundColor = 'custom_background_color';
  static const String customSurfaceColor = 'custom_surface_color';
  static const String customTextColor = 'custom_text_color';
  static const String customTextSecondaryColor =
      'custom_text_secondary_color';
  static const String customCardBorderColor = 'custom_card_border_color';
  static const String customSurfaceLightColor = 'custom_surface_light_color';
  static const String savedCustomThemes = 'saved_custom_themes';
  static const String activeCustomThemeId = 'active_custom_theme_id';
  static const String audioQuality = 'audio_quality';
  static const String isAudioPlayerExpanded = 'is_audio_player_expanded';
}
