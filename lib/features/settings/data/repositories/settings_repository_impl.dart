import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/settings_keys.dart';
import '../../../prayer_tracking/domain/salaah.dart';
import '../../domain/azkar_reminder.dart';
import '../../domain/entities/custom_theme.dart';
import '../../domain/prayer_reminder_type.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/salaah_settings.dart';
import '../../../audio/domain/repositories/audio_repository.dart';
import 'settings_storage.dart';

/// Data layer implementation of [SettingsRepository].
///
/// Handles all settings persistence using [SettingsStorage].
/// This class is lightweight, background-safe, and has no dependencies
/// on the presentation layer.
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsStorage _storage;

  SettingsRepositoryImpl(this._storage) {
    _performMigration();
  }

  // ==================== READ OPERATIONS ====================

  @override
  Locale get locale {
    // ENFORCED: Always return Arabic for now as per user request
    return const Locale('ar');
  }

  @override
  double? get latitude => _storage.readDouble(SettingsKeys.latitude);

  @override
  double? get longitude => _storage.readDouble(SettingsKeys.longitude);

  @override
  String? get cityName => _storage.readString(SettingsKeys.cityName);

  @override
  String get calculationMethod => _storage.readString(
    SettingsKeys.calculationMethod,
    defaultValue: 'muslim_league',
  )!;

  @override
  String get madhab =>
      _storage.readString(SettingsKeys.madhab, defaultValue: 'shafi')!;

  @override
  String get morningAzkarTime => _storage.readString(
    SettingsKeys.morningAzkarTime,
    defaultValue: '05:00',
  )!;

  @override
  String get eveningAzkarTime => _storage.readString(
    SettingsKeys.eveningAzkarTime,
    defaultValue: '18:00',
  )!;

  @override
  bool get isAfterSalahAzkarEnabled =>
      _storage.readBool(SettingsKeys.afterSalahAzkarEnabled);

  @override
  List<SalaahSettings> get salaahSettings {
    final defaults = Salaah.values
        .map((s) => SalaahSettings(salaah: s))
        .toList();
    final list = _storage.readJsonList<SalaahSettings>(
      SettingsKeys.salaahSettings,
      (json) => SalaahSettings.fromJson(json),
    );
    return list.isEmpty ? defaults : list;
  }

  @override
  List<AzkarReminder> get reminders {
    final defaults = [
      AzkarReminder(
        category: 'أذكار الصباح',
        time: morningAzkarTime,
        title: 'أذكار الصباح',
      ),
      AzkarReminder(
        category: 'أذكار المساء',
        time: eveningAzkarTime,
        title: 'أذكار المساء',
      ),
    ];
    final list = _storage.readJsonList<AzkarReminder>(
      SettingsKeys.azkarReminders,
      (json) => AzkarReminder.fromJson(json),
    );
    return list.isEmpty ? defaults : list;
  }

  @override
  bool get isQadaEnabled =>
      _storage.readBool(SettingsKeys.qadaEnabled, defaultValue: true);

  @override
  int get hijriAdjustment => _storage.readInt(SettingsKeys.hijriAdjustment);

  @override
  String get themePresetId => _storage.readString(
    SettingsKeys.themePresetId,
    defaultValue: 'emerald',
  )!;

  @override
  Map<String, String>? get customThemeColors {
    final colors = <String, String>{};
    final primary = _storage.readString(SettingsKeys.customPrimaryColor);
    final accent = _storage.readString(SettingsKeys.customAccentColor);
    final background = _storage.readString(SettingsKeys.customBackgroundColor);
    final surface = _storage.readString(SettingsKeys.customSurfaceColor);
    final text = _storage.readString(SettingsKeys.customTextColor);
    final textSecondary = _storage.readString(
      SettingsKeys.customTextSecondaryColor,
    );
    final cardBorder = _storage.readString(SettingsKeys.customCardBorderColor);
    final surfaceLight = _storage.readString(
      SettingsKeys.customSurfaceLightColor,
    );

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

  @override
  List<CustomTheme> get savedCustomThemes {
    final list = _storage.readJsonList<CustomTheme>(
      SettingsKeys.savedCustomThemes,
      (json) => CustomTheme.fromJson(json),
    );
    return list;
  }

  @override
  String? get activeCustomThemeId =>
      _storage.readString(SettingsKeys.activeCustomThemeId);

  @override
  AudioQuality get audioQuality {
    final value = _storage.readString(SettingsKeys.audioQuality);
    if (value == null) return AudioQuality.low64;
    return AudioQuality.values.firstWhere(
      (e) => e.name == value,
      orElse: () => AudioQuality.low64,
    );
  }

  @override
  bool get isAudioPlayerExpanded =>
      _storage.readBool(SettingsKeys.isAudioPlayerExpanded, defaultValue: false);

  // ==================== REMINDERS ====================

  @override
  bool get isSalahReminderEnabled =>
      _storage.readBool(SettingsKeys.isSalahReminderEnabled, defaultValue: false);

  @override
  int get salahReminderOffsetMinutes => _storage.readInt(
    SettingsKeys.salahReminderOffsetMinutes,
    defaultValue: 15,
  );

  @override
  PrayerReminderType get prayerReminderType {
    final value = _storage.readString(SettingsKeys.salahReminderType);
    if (value == null) return PrayerReminderType.after;
    return PrayerReminderType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PrayerReminderType.after,
    );
  }

  @override
  Set<Salaah> get enabledSalahReminders {
    final String? jsonStr =
        _storage.readString(SettingsKeys.enabledSalahReminders);
    if (jsonStr == null) return {};
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded
          .map((name) => Salaah.values.firstWhere(
                (s) => s.name == name,
                orElse: () => Salaah.fajr,
              ))
          .toSet();
    } catch (e) {
      return {};
    }
  }

  @override
  bool get isWerdReminderEnabled =>
      _storage.readBool(SettingsKeys.isWerdReminderEnabled, defaultValue: false);

  @override
  String get werdReminderTime => _storage.readString(
    SettingsKeys.werdReminderTime,
    defaultValue: '20:00',
  )!;

  @override
  bool get isSalawatReminderEnabled =>
      _storage.readBool(SettingsKeys.isSalawatReminderEnabled, defaultValue: false);

  @override
  int get salawatFrequencyHours =>
      _storage.readInt(SettingsKeys.salawatFrequencyHours, defaultValue: 3);

  @override
  String get salawatStartTime => _storage.readString(
    SettingsKeys.salawatStartTime,
    defaultValue: '10:00',
  )!;

  @override
  String get salawatEndTime => _storage.readString(
    SettingsKeys.salawatEndTime,
    defaultValue: '20:00',
  )!;

  // ==================== MIGRATION ====================

  Future<void> _performMigration() async {
    const String migrationKey = 'azan_settings_migration_v1_done';
    if (_storage.readBool(migrationKey)) return;

    try {
      debugPrint('SettingsRepositoryImpl: performing Azan settings migration...');

      // 1. Migrate post-prayer reminders if not already set
      if (!_storage.prefs.containsKey(SettingsKeys.isSalahReminderEnabled)) {
        final currentSalaahSettings = salaahSettings;

        // If any prayer has Azan enabled OR pre-prayer reminder enabled,
        // we'll enable the new unified reminder by default
        // and populate the enabled list with those prayers.
        final enabledPrayers = currentSalaahSettings
            .where((s) => s.isAzanEnabled || s.isReminderEnabled)
            .map((s) => s.salaah)
            .toSet();

        if (enabledPrayers.isNotEmpty) {
          debugPrint(
            'SettingsRepositoryImpl: Migrating ${enabledPrayers.length} prayers to unified reminders',
          );
          await updateSalahReminderEnabled(true);
          await updateEnabledSalahReminders(enabledPrayers);
        }
      }

      await _storage.writeBool(migrationKey, true);
      debugPrint('SettingsRepositoryImpl: Migration completed.');
    } catch (e) {
      debugPrint('SettingsRepositoryImpl: Migration failed: $e');
    }
  }

  // ==================== WRITE OPERATIONS ====================

  @override
  Future<void> updateLocale(Locale locale) async {
    await _storage.writeString(SettingsKeys.locale, locale.languageCode);
  }

  @override
  Future<void> updateLocation({
    double? latitude,
    double? longitude,
    String? cityName,
  }) async {
    if (latitude != null) {
      await _storage.writeDouble(SettingsKeys.latitude, latitude);
    }
    if (longitude != null) {
      await _storage.writeDouble(SettingsKeys.longitude, longitude);
    }
    if (cityName != null) {
      await _storage.writeString(SettingsKeys.cityName, cityName);
    }
  }

  @override
  Future<void> updateCalculationMethod(String method) async {
    await _storage.writeString(SettingsKeys.calculationMethod, method);
  }

  @override
  Future<void> updateMadhab(String madhab) async {
    await _storage.writeString(SettingsKeys.madhab, madhab);
  }

  @override
  Future<void> updateMorningAzkarTime(String time) async {
    await _storage.writeString(SettingsKeys.morningAzkarTime, time);
  }

  @override
  Future<void> updateEveningAzkarTime(String time) async {
    await _storage.writeString(SettingsKeys.eveningAzkarTime, time);
  }

  @override
  Future<void> updateAfterSalahAzkarEnabled(bool enabled) async {
    await _storage.writeBool(SettingsKeys.afterSalahAzkarEnabled, enabled);
  }

  @override
  Future<void> updateSalaahSettings(List<SalaahSettings> settings) async {
    await _storage.writeJsonList<SalaahSettings>(
      SettingsKeys.salaahSettings,
      settings,
      (s) => s.toJson(),
    );
  }

  @override
  Future<void> toggleQadaEnabled() async {
    await _storage.writeBool(SettingsKeys.qadaEnabled, !isQadaEnabled);
  }

  @override
  Future<void> updateHijriAdjustment(int adjustment) async {
    await _storage.writeInt(SettingsKeys.hijriAdjustment, adjustment);
  }

  @override
  Future<void> addReminder(AzkarReminder reminder) async {
    final newList = List<AzkarReminder>.from(reminders)..add(reminder);
    await _saveReminders(newList);
  }

  @override
  Future<void> removeReminder(int index) async {
    final newList = List<AzkarReminder>.from(reminders);
    if (index >= 0 && index < newList.length) {
      newList.removeAt(index);
      await _saveReminders(newList);
    }
  }

  @override
  Future<void> updateReminder(int index, AzkarReminder reminder) async {
    final newList = List<AzkarReminder>.from(reminders);
    if (index >= 0 && index < newList.length) {
      newList[index] = reminder;
      await _saveReminders(newList);
    }
  }

  @override
  Future<void> toggleReminder(int index) async {
    final newList = List<AzkarReminder>.from(reminders);
    if (index >= 0 && index < newList.length) {
      newList[index] = newList[index].copyWith(
        isEnabled: !newList[index].isEnabled,
      );
      await _saveReminders(newList);
    }
  }

  Future<void> _saveReminders(List<AzkarReminder> reminderList) async {
    await _storage.writeJsonList<AzkarReminder>(
      SettingsKeys.azkarReminders,
      reminderList,
      (r) => r.toJson(),
    );
  }

  @override
  Future<void> updateAllAzanEnabled(bool v) async => _saveSalaah(
    salaahSettings.map((s) => s.copyWith(isAzanEnabled: v)).toList(),
  );
  @override
  Future<void> updateAllReminderEnabled(bool v) async => _saveSalaah(
    salaahSettings.map((s) => s.copyWith(isReminderEnabled: v)).toList(),
  );
  @override
  Future<void> updateAllAzanSound(String? v) async =>
      _saveSalaah(salaahSettings.map((s) => s.copyWith(azanSound: v)).toList());
  @override
  Future<void> updateAllReminderMinutes(int v) async => _saveSalaah(
    salaahSettings.map((s) => s.copyWith(reminderMinutesBefore: v)).toList(),
  );
  @override
  Future<void> updateAllAfterSalahMinutes(int v) async => _saveSalaah(
    salaahSettings.map((s) => s.copyWith(afterSalaahAzkarMinutes: v)).toList(),
  );

  Future<void> _saveSalaah(List<SalaahSettings> list) => _storage.writeJsonList(
    SettingsKeys.salaahSettings,
    list,
    (s) => s.toJson(),
  );

  @override
  Future<void> updateThemePreset(String presetId) async {
    await _storage.writeString(SettingsKeys.themePresetId, presetId);
  }

  @override
  Future<void> saveCustomTheme(Map<String, String> colors) async {
    if (colors.containsKey('primary')) {
      await _storage.writeString(
        SettingsKeys.customPrimaryColor,
        colors['primary']!,
      );
    }
    if (colors.containsKey('accent')) {
      await _storage.writeString(
        SettingsKeys.customAccentColor,
        colors['accent']!,
      );
    }
    if (colors.containsKey('background')) {
      await _storage.writeString(
        SettingsKeys.customBackgroundColor,
        colors['background']!,
      );
    }
    if (colors.containsKey('surface')) {
      await _storage.writeString(
        SettingsKeys.customSurfaceColor,
        colors['surface']!,
      );
    }
    if (colors.containsKey('text')) {
      await _storage.writeString(
        SettingsKeys.customTextColor,
        colors['text']!,
      );
    }
    if (colors.containsKey('textSecondary')) {
      await _storage.writeString(
        SettingsKeys.customTextSecondaryColor,
        colors['textSecondary']!,
      );
    }
    if (colors.containsKey('cardBorder')) {
      await _storage.writeString(
        SettingsKeys.customCardBorderColor,
        colors['cardBorder']!,
      );
    }
    if (colors.containsKey('surfaceLight')) {
      await _storage.writeString(
        SettingsKeys.customSurfaceLightColor,
        colors['surfaceLight']!,
      );
    }
  }

  @override
  Future<void> addCustomTheme(CustomTheme theme) async {
    final current = savedCustomThemes;
    final updated = [...current, theme];
    await _storage.writeJsonList<CustomTheme>(
      SettingsKeys.savedCustomThemes,
      updated,
      (t) => t.toJson(),
    );
  }

  @override
  Future<void> updateCustomTheme(String themeId, Map<String, String> colors) async {
    final current = savedCustomThemes;
    final index = current.indexWhere((t) => t.id == themeId);
    if (index == -1) return;
    final updated = [...current];
    updated[index] = updated[index].copyWithColors(colors);
    await _storage.writeJsonList<CustomTheme>(
      SettingsKeys.savedCustomThemes,
      updated,
      (t) => t.toJson(),
    );
  }

  @override
  Future<void> deleteCustomTheme(String themeId) async {
    final current = savedCustomThemes;
    final updated = current.where((t) => t.id != themeId).toList();
    await _storage.writeJsonList<CustomTheme>(
      SettingsKeys.savedCustomThemes,
      updated,
      (t) => t.toJson(),
    );
    // If the deleted theme was active, clear it
    if (activeCustomThemeId == themeId) {
      await _storage.writeString(SettingsKeys.activeCustomThemeId, '');
    }
  }

  @override
  Future<void> setActiveCustomTheme(String? themeId) async {
    await _storage.writeString(
      SettingsKeys.activeCustomThemeId,
      themeId ?? '',
    );
  }

  @override
  Future<void> updateAudioQuality(AudioQuality quality) async {
    await _storage.writeString(SettingsKeys.audioQuality, quality.name);
  }

  @override
  Future<void> updateAudioPlayerExpanded(bool expanded) async {
    await _storage.writeBool(SettingsKeys.isAudioPlayerExpanded, expanded);
  }

  @override
  Future<void> updateSalahReminderEnabled(bool enabled) async {
    await _storage.writeBool(SettingsKeys.isSalahReminderEnabled, enabled);
  }

  @override
  Future<void> updateSalahReminderOffset(int minutes) async {
    await _storage.writeInt(SettingsKeys.salahReminderOffsetMinutes, minutes);
  }

  @override
  Future<void> updatePrayerReminderType(PrayerReminderType type) async {
    await _storage.writeString(SettingsKeys.salahReminderType, type.name);
  }

  @override
  Future<void> updateEnabledSalahReminders(Set<Salaah> enabledSalahs) async {
    await _storage.writeString(
      SettingsKeys.enabledSalahReminders,
      jsonEncode(enabledSalahs.map((s) => s.name).toList()),
    );
  }

  @override
  Future<void> updateWerdReminderEnabled(bool enabled) async {
    await _storage.writeBool(SettingsKeys.isWerdReminderEnabled, enabled);
  }

  @override
  Future<void> updateWerdReminderTime(String time) async {
    await _storage.writeString(SettingsKeys.werdReminderTime, time);
  }

  @override
  Future<void> updateSalawatReminderEnabled(bool enabled) async {
    await _storage.writeBool(SettingsKeys.isSalawatReminderEnabled, enabled);
  }

  @override
  Future<void> updateSalawatFrequency(int hours) async {
    await _storage.writeInt(SettingsKeys.salawatFrequencyHours, hours);
  }

  @override
  Future<void> updateSalawatStartTime(String time) async {
    await _storage.writeString(SettingsKeys.salawatStartTime, time);
  }

  @override
  Future<void> updateSalawatEndTime(String time) async {
    await _storage.writeString(SettingsKeys.salawatEndTime, time);
  }
}
