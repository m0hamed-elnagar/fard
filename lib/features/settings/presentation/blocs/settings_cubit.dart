import 'dart:convert';

import 'package:fard/core/services/location_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/settings_loader.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/azkar/data/azkar_source.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;
  final LocationService _locationService;
  final NotificationService _notificationService;
  final IAzkarSource _azkarRepository;
  final WidgetUpdateService _widgetUpdateService;

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

  SettingsCubit(
    this._prefs,
    this._locationService,
    this._notificationService,
    this._azkarRepository,
    this._widgetUpdateService,
  ) : super(SettingsLoader.loadSettings(_prefs));

  void _saveReminders(List<AzkarReminder> reminders) {
    final String jsonStr = jsonEncode(
      reminders.map((e) => e.toJson()).toList(),
    );
    _prefs.setString(_remindersKey, jsonStr);
  }

  void addReminder(AzkarReminder reminder) {
    final newList = List<AzkarReminder>.from(state.reminders)..add(reminder);
    emit(state.copyWith(reminders: newList));
    _saveReminders(newList);
    _updateReminders();
  }

  void removeReminder(int index) {
    final newList = List<AzkarReminder>.from(state.reminders)..removeAt(index);
    emit(state.copyWith(reminders: newList));
    _saveReminders(newList);
    _updateReminders();
  }

  void updateReminder(int index, AzkarReminder reminder) {
    final newList = List<AzkarReminder>.from(state.reminders);
    newList[index] = reminder;
    emit(state.copyWith(reminders: newList));
    _saveReminders(newList);
    _updateReminders();
  }

  void updateSalaahSettings(SalaahSettings settings) {
    final newList = List<SalaahSettings>.from(state.salaahSettings);
    final index = newList.indexWhere((e) => e.salaah == settings.salaah);
    if (index != -1) {
      newList[index] = settings;
    } else {
      newList.add(settings);
    }
    emit(state.copyWith(salaahSettings: newList));
    _saveSalaahSettings(newList);
    _updateReminders();
  }

  void _saveSalaahSettings(List<SalaahSettings> settings) {
    final String jsonStr = jsonEncode(settings.map((e) => e.toJson()).toList());
    _prefs.setString(_salaahSettingsKey, jsonStr);
    _syncToHomeWidget();
  }

  void toggleReminder(int index) {
    final newList = List<AzkarReminder>.from(state.reminders);
    newList[index] = newList[index].copyWith(
      isEnabled: !newList[index].isEnabled,
    );
    emit(state.copyWith(reminders: newList));
    _saveReminders(newList);
    _updateReminders();
  }

  void updateLocale(Locale locale) {
    _prefs.setString(_localeKey, locale.languageCode);
    emit(state.copyWith(locale: locale));
    _updateReminders();
    _syncToHomeWidget();
  }

  void toggleLocale() {
    final newLocale = state.locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    updateLocale(newLocale);
  }

  Future<void> refreshLocation() async {
    final status = await _locationService.checkLocationStatus();

    if (status != LocationStatus.success) {
      emit(state.copyWith(lastLocationStatus: status));
      // Reset status after a short delay so UI can show/hide dialogs
      Future.delayed(const Duration(seconds: 1), () {
        if (!isClosed) emit(state.copyWith(lastLocationStatus: null));
      });
      return;
    }

    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      final locationData = await _locationService
          .getLocationDataFromCoordinates(
            position.latitude,
            position.longitude,
          );

      await _prefs.setString(_latKey, position.latitude.toString());
      await _prefs.setString(_lonKey, position.longitude.toString());

      String? cityName;
      String? countryCode;
      String method = state.calculationMethod;

      if (locationData != null) {
        cityName = locationData['city'];
        countryCode = locationData['countryCode'];
        if (cityName != null) {
          await _prefs.setString(_cityKey, cityName);
        }

        if (countryCode != null) {
          method = _mapCountryToMethod(countryCode);
          await _prefs.setString(_methodKey, method);

          // Apply Hijri adjustment based on country/region (GPS auto-detect)
          // The hijri_calendar package uses Umm al-Qura calendar
          // Users can manually override in Settings
          final upperCode = countryCode.toUpperCase();
          if (upperCode == 'SA' ||
              upperCode == 'AE' ||
              upperCode == 'QA' ||
              upperCode == 'KW') {
            updateHijriAdjustment(0); // Gulf countries (Umm al-Qura based)
          } else if (upperCode == 'PK' ||
              upperCode == 'IN' ||
              upperCode == 'BD') {
            updateHijriAdjustment(
              1,
            ); // South Asia (local moon sighting may be +1)
          } else {
            // Egypt, Turkey, Iran, and other regions use 0 as default
            updateHijriAdjustment(0);
          }
        }
      }

      emit(
        state.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          cityName: cityName,
          calculationMethod: method,
          lastLocationStatus: LocationStatus.success,
        ),
      );

      // Reset status
      Future.delayed(const Duration(seconds: 1), () {
        if (!isClosed) emit(state.copyWith(lastLocationStatus: null));
      });

      _updateReminders();
      _syncToHomeWidget();
    }
  }

  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  String _mapCountryToMethod(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'EG':
        return 'egyptian';
      case 'SA':
        return 'umm_al_qura';
      case 'AE':
        return 'dubai';
      case 'QA':
        return 'qatar';
      case 'KW':
        return 'kuwait';
      case 'PK':
      case 'IN':
      case 'BD':
        return 'karachi';
      case 'SG':
        return 'singapore';
      case 'TR':
        return 'turkey';
      case 'IR':
        return 'tehran';
      case 'US':
      case 'CA':
        return 'north_america';
      case 'NG':
        return 'muslim_league';
      default:
        return 'muslim_league';
    }
  }

  void updateCalculationMethod(String method) {
    _prefs.setString(_methodKey, method);

    // Default Hijri adjustment based on calculation method
    // The hijri_calendar package uses Umm al-Qura calendar
    // Users can manually override in Settings
    if (method == 'umm_al_qura') {
      updateHijriAdjustment(0); // Saudi Arabia (Umm al-Qura) is baseline
    } else if (method == 'karachi' || method == 'muslim_world_league') {
      // South Asia and Muslim World League regions may need +1
      updateHijriAdjustment(1);
    } else {
      // Egyptian, Dubai, Kuwait, Qatar, and others use 0 as default
      updateHijriAdjustment(0);
    }

    emit(state.copyWith(calculationMethod: method));
    _updateReminders();
    _syncToHomeWidget();
  }

  void updateMadhab(String madhab) {
    _prefs.setString(_madhabKey, madhab);
    emit(state.copyWith(madhab: madhab));
    _updateReminders();
    _syncToHomeWidget();
  }

  void updateMorningAzkarTime(String time) {
    _prefs.setString(_morningAzkarKey, time);
    emit(state.copyWith(morningAzkarTime: time));
    _updateReminders();
  }

  void updateEveningAzkarTime(String time) {
    _prefs.setString(_eveningAzkarKey, time);
    emit(state.copyWith(eveningAzkarTime: time));
    _updateReminders();
  }

  void toggleAfterSalahAzkar() {
    final newValue = !state.isAfterSalahAzkarEnabled;
    _prefs.setBool(_afterSalahAzkarKey, newValue);

    // Update all individual salaah settings to match the global toggle
    final updatedSalaahSettings = state.salaahSettings
        .map((s) => s.copyWith(isAfterSalahAzkarEnabled: newValue))
        .toList();

    _saveSalaahSettings(updatedSalaahSettings);

    emit(
      state.copyWith(
        isAfterSalahAzkarEnabled: newValue,
        salaahSettings: updatedSalaahSettings,
      ),
    );
    _updateReminders();
  }

  void updateAllAzanEnabled(bool enabled) {
    final updated = state.salaahSettings
        .map((s) => s.copyWith(isAzanEnabled: enabled))
        .toList();
    _saveSalaahSettings(updated);
    emit(state.copyWith(salaahSettings: updated));
    _updateReminders();
  }

  void updateAllReminderEnabled(bool enabled) {
    final updated = state.salaahSettings
        .map((s) => s.copyWith(isReminderEnabled: enabled))
        .toList();
    _saveSalaahSettings(updated);
    emit(state.copyWith(salaahSettings: updated));
    _updateReminders();
  }

  void updateAllAzanSound(String? sound) {
    final updated = state.salaahSettings
        .map((s) => s.copyWith(azanSound: sound))
        .toList();
    _saveSalaahSettings(updated);
    emit(state.copyWith(salaahSettings: updated));
    _updateReminders();
  }

  void updateAllReminderMinutes(int minutes) {
    final updated = state.salaahSettings
        .map((s) => s.copyWith(reminderMinutesBefore: minutes))
        .toList();
    _saveSalaahSettings(updated);
    emit(state.copyWith(salaahSettings: updated));
    _updateReminders();
  }

  void updateAllAfterSalahMinutes(int minutes) {
    final updated = state.salaahSettings
        .map((s) => s.copyWith(afterSalaahAzkarMinutes: minutes))
        .toList();
    _saveSalaahSettings(updated);
    emit(state.copyWith(salaahSettings: updated));
    _updateReminders();
  }

  void toggleQadaEnabled() {
    final newValue = !state.isQadaEnabled;
    _prefs.setBool(_qadaKey, newValue);
    emit(state.copyWith(isQadaEnabled: newValue));
  }

  void updateHijriAdjustment(int adjustment) {
    _prefs.setInt(_hijriAdjustmentKey, adjustment);
    emit(state.copyWith(hijriAdjustment: adjustment));
    _syncToHomeWidget();
  }

  Future<void> _updateReminders() async {
    // Run after a very short delay and in background to avoid blocking the main thread during UI transition
    Future.delayed(const Duration(milliseconds: 50), () async {
      try {
        final azkar = await _azkarRepository.getAllAzkar();
        await _notificationService.scheduleAzkarReminders(
          settings: state,
          allAzkar: azkar,
        );
        await _notificationService.schedulePrayerNotifications(settings: state);
      } catch (e) {
        debugPrint('Error updating reminders in background: $e');
      }
    });
  }

  Future<void> initReminders() async {
    try {
      await _updateReminders();
    } catch (e) {
      debugPrint('Error initializing reminders: $e');
    }
  }

  Future<void> _syncToHomeWidget() async {
    try {
      await _widgetUpdateService.updateWidget(state);
    } catch (e) {
      debugPrint('Error syncing to home widget: $e');
    }
  }
}
