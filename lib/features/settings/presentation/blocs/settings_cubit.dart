import 'dart:convert';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/core/services/location_service.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences _prefs;
  final LocationService _locationService;
  final NotificationService _notificationService;
  final AzkarRepository _azkarRepository;

  static const String _localeKey = 'locale';
  static const String _latKey = 'latitude';
  static const String _lonKey = 'longitude';
  static const String _cityKey = 'city_name';
  static const String _methodKey = 'calculation_method';
  static const String _madhabKey = 'madhab';
  static const String _morningAzkarKey = 'morning_azkar_time';
  static const String _eveningAzkarKey = 'evening_azkar_time';
  static const String _remindersKey = 'azkar_reminders';
  static const String _salaahSettingsKey = 'salaah_settings';

  SettingsCubit(
    this._prefs, 
    this._locationService, 
    this._notificationService, 
    this._azkarRepository,
  ) : super(SettingsState(
          locale: Locale(_prefs.getString(_localeKey) ?? 'ar'),
          latitude: _prefs.getDouble(_latKey),
          longitude: _prefs.getDouble(_lonKey),
          cityName: _prefs.getString(_cityKey),
          calculationMethod: _prefs.getString(_methodKey) ?? 'muslim_league',
          madhab: _prefs.getString(_madhabKey) ?? 'shafi',
          morningAzkarTime: _prefs.getString(_morningAzkarKey) ?? '05:00',
          eveningAzkarTime: _prefs.getString(_eveningAzkarKey) ?? '18:00',
          reminders: _loadReminders(_prefs, _prefs.getString(_morningAzkarKey) ?? '05:00', _prefs.getString(_eveningAzkarKey) ?? '18:00'),
          salaahSettings: _loadSalaahSettings(_prefs),
        ));

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

  void _saveReminders(List<AzkarReminder> reminders) {
    final String jsonStr = jsonEncode(reminders.map((e) => e.toJson()).toList());
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
  }

  void toggleReminder(int index) {
    final newList = List<AzkarReminder>.from(state.reminders);
    newList[index] = newList[index].copyWith(isEnabled: !newList[index].isEnabled);
    emit(state.copyWith(reminders: newList));
    _saveReminders(newList);
    _updateReminders();
  }

  void updateLocale(Locale locale) {
    _prefs.setString(_localeKey, locale.languageCode);
    emit(state.copyWith(locale: locale));
    _updateReminders();
  }

  void toggleLocale() {
    final newLocale = state.locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    updateLocale(newLocale);
  }

  Future<void> refreshLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      final locationData = await _locationService.getLocationDataFromCoordinates(
        position.latitude,
        position.longitude,
      );
      
      await _prefs.setDouble(_latKey, position.latitude);
      await _prefs.setDouble(_lonKey, position.longitude);
      
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
        }
      }

      emit(state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: cityName,
        calculationMethod: method,
      ));
      _updateReminders();
    }
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
      default:
        return 'muslim_league';
    }
  }

  void updateCalculationMethod(String method) {
    _prefs.setString(_methodKey, method);
    emit(state.copyWith(calculationMethod: method));
    _updateReminders();
  }

  void updateMadhab(String madhab) {
    _prefs.setString(_madhabKey, madhab);
    emit(state.copyWith(madhab: madhab));
    _updateReminders();
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

  Future<void> _updateReminders() async {
    final azkar = await _azkarRepository.getAllAzkar();
    await _notificationService.scheduleAzkarReminders(settings: state, allAzkar: azkar);
    await _notificationService.schedulePrayerNotifications(settings: state);
  }

  Future<void> initReminders() async {
    try {
      await _updateReminders();
    } catch (e) {
      debugPrint('Error initializing reminders: $e');
    }
  }
}
