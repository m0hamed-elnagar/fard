import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';

class SettingsLoader {
  static const String _localeKey = 'locale';
  static const String _latKey = 'latitude';
  static const String _lonKey = 'longitude';
  static const String _cityKey = 'city_name';
  static const String _methodKey = 'calculation_method';
  static const String _madhabKey = 'madhab';
  static const String _morningAzkarKey = 'morning_azkar_time';
  static const String _eveningAzkarKey = 'evening_azkar_time';
  static const String _afterSalahAzkarKey = 'is_after_salah_azkar_enabled';
  static const String _remindersKey = 'azkar_reminders';
  static const String _salaahSettingsKey = 'salaah_settings';
  static const String _qadaKey = 'is_qada_enabled';
  static const String _hijriAdjustmentKey = 'hijri_adjustment';

  static SettingsState loadSettings(SharedPreferences prefs) {
    return SettingsState(
      locale: Locale(prefs.getString(_localeKey) ?? 'ar'),
      latitude: prefs.getDouble(_latKey),
      longitude: prefs.getDouble(_lonKey),
      cityName: prefs.getString(_cityKey),
      calculationMethod: prefs.getString(_methodKey) ?? 'muslim_league',
      madhab: prefs.getString(_madhabKey) ?? 'shafi',
      morningAzkarTime: prefs.getString(_morningAzkarKey) ?? '05:00',
      eveningAzkarTime: prefs.getString(_eveningAzkarKey) ?? '18:00',
      isAfterSalahAzkarEnabled: prefs.getBool(_afterSalahAzkarKey) ?? false,
      isQadaEnabled: prefs.getBool(_qadaKey) ?? true,
      hijriAdjustment: prefs.getInt(_hijriAdjustmentKey) ?? 0,
      reminders: _loadReminders(prefs, prefs.getString(_morningAzkarKey) ?? '05:00', prefs.getString(_eveningAzkarKey) ?? '18:00'),
      salaahSettings: _loadSalaahSettings(prefs),
    );
  }

  static List<SalaahSettings> _loadSalaahSettings(SharedPreferences prefs) {
    final String? jsonStr = prefs.getString(_salaahSettingsKey);
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

  static List<AzkarReminder> _loadReminders(SharedPreferences prefs, String morningTime, String eveningTime) {
    final String? jsonStr = prefs.getString(_remindersKey);
    if (jsonStr == null) {
      return [
        AzkarReminder(category: 'أذكار الصباح', time: morningTime, title: 'أذكار الصباح'),
        AzkarReminder(category: 'أذكار المساء', time: eveningTime, title: 'أذكار المساء'),
      ];
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((e) => AzkarReminder.fromJson(e)).toList();
    } catch (_) {
      return [
        AzkarReminder(category: 'أذكار الصباح', time: morningTime, title: 'أذكار الصباح'),
        AzkarReminder(category: 'أذكار المساء', time: eveningTime, title: 'أذكار المساء'),
      ];
    }
  }
}
