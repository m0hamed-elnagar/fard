import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/settings_keys.dart';
import '../../../prayer_tracking/domain/salaah.dart';
import '../../domain/azkar_reminder.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/salaah_settings.dart';
import 'settings_storage.dart';

/// Data layer implementation of [SettingsRepository].
///
/// Handles all settings persistence using [SettingsStorage].
/// This class is lightweight, background-safe, and has no dependencies
/// on the presentation layer.
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsStorage _storage;

  SettingsRepositoryImpl(this._storage);

  // ==================== READ OPERATIONS ====================

  @override
  Locale get locale {
    final code = _storage.readString(SettingsKeys.locale, defaultValue: 'ar')!;
    return Locale(code);
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
}
