import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/core/constants/settings_keys.dart';
import 'package:fard/features/settings/domain/app_settings.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';

/// Static utility class for loading settings from SharedPreferences.
/// This is only used during app initialization to create the initial settings.
class SettingsLoader {
  static AppSettings loadSettings(SharedPreferences prefs) {
    final latStr = prefs.get(SettingsKeys.latitude)?.toString();
    final lonStr = prefs.get(SettingsKeys.longitude)?.toString();

    final audioQualityStr = prefs.getString(SettingsKeys.audioQuality);
    final audioQuality = AudioQuality.values.firstWhere(
      (e) => e.name == audioQualityStr,
      orElse: () => AudioQuality.low64,
    );

    return AppSettings(
      locale: Locale(prefs.getString(SettingsKeys.locale) ?? 'ar'),
      latitude: latStr != null ? double.tryParse(latStr) : null,
      longitude: lonStr != null ? double.tryParse(lonStr) : null,
      cityName: prefs.getString(SettingsKeys.cityName),
      calculationMethod:
          prefs.getString(SettingsKeys.calculationMethod) ?? 'muslim_league',
      madhab: prefs.getString(SettingsKeys.madhab) ?? 'shafi',
      morningAzkarTime:
          prefs.getString(SettingsKeys.morningAzkarTime) ?? '05:00',
      eveningAzkarTime:
          prefs.getString(SettingsKeys.eveningAzkarTime) ?? '18:00',
      isAfterSalahAzkarEnabled:
          prefs.getBool(SettingsKeys.afterSalahAzkarEnabled) ?? false,
      isQadaEnabled: prefs.getBool(SettingsKeys.qadaEnabled) ?? true,
      hijriAdjustment: prefs.getInt(SettingsKeys.hijriAdjustment) ?? 0,
      themePresetId: prefs.getString(SettingsKeys.themePresetId) ?? 'emerald',
      customThemeColors: _loadCustomThemeColors(prefs),
      reminders: _loadReminders(
        prefs,
        prefs.getString(SettingsKeys.morningAzkarTime) ?? '05:00',
        prefs.getString(SettingsKeys.eveningAzkarTime) ?? '18:00',
      ),
      salaahSettings: _loadSalaahSettings(prefs),
      audioQuality: audioQuality,
      isAudioPlayerExpanded:
          prefs.getBool(SettingsKeys.isAudioPlayerExpanded) ?? false,
    );
  }

  static List<SalaahSettings> _loadSalaahSettings(SharedPreferences prefs) {
    final String? jsonStr = prefs.getString(SettingsKeys.salaahSettings);
    if (jsonStr == null) {
      return Salaah.values.map((s) => SalaahSettings(salaah: s)).toList();
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => SalaahSettings.fromJson(e)).toList();
    } catch (_) {
      return Salaah.values.map((s) => SalaahSettings(salaah: s)).toList();
    }
  }

  static List<AzkarReminder> _loadReminders(
    SharedPreferences prefs,
    String morningTime,
    String eveningTime,
  ) {
    final String? jsonStr = prefs.getString(SettingsKeys.azkarReminders);
    if (jsonStr == null) {
      return [
        AzkarReminder(
          category: 'أذكار الصباح',
          time: morningTime,
          title: 'أذكار الصباح',
        ),
        AzkarReminder(
          category: 'أذكار المساء',
          time: eveningTime,
          title: 'أذكار المساء',
        ),
      ];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => AzkarReminder.fromJson(e)).toList();
    } catch (_) {
      return [
        AzkarReminder(
          category: 'أذكار الصباح',
          time: morningTime,
          title: 'أذكار الصباح',
        ),
        AzkarReminder(
          category: 'أذكار المساء',
          time: eveningTime,
          title: 'أذكار المساء',
        ),
      ];
    }
  }

  static Map<String, String>? _loadCustomThemeColors(SharedPreferences prefs) {
    final primary = prefs.getString(SettingsKeys.customPrimaryColor);
    final accent = prefs.getString(SettingsKeys.customAccentColor);
    final background = prefs.getString(SettingsKeys.customBackgroundColor);
    final surface = prefs.getString(SettingsKeys.customSurfaceColor);
    final text = prefs.getString(SettingsKeys.customTextColor);
    final textSecondary = prefs.getString(SettingsKeys.customTextSecondaryColor);
    final cardBorder = prefs.getString(SettingsKeys.customCardBorderColor);
    final surfaceLight = prefs.getString(SettingsKeys.customSurfaceLightColor);

    final colors = <String, String>{};
    if (primary != null) colors['primary'] = primary;
    if (accent != null) colors['accent'] = accent;
    if (background != null) colors['background'] = background;
    if (surface != null) colors['surface'] = surface;
    if (text != null) colors['text'] = text;
    if (textSecondary != null) colors['textSecondary'] = textSecondary;
    if (cardBorder != null) colors['cardBorder'] = cardBorder;
    if (surfaceLight != null) colors['surfaceLight'] = surfaceLight;

    return colors.isEmpty ? null : colors;
  }
}
