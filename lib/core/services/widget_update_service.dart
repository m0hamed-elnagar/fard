import 'dart:convert';

import 'package:fard/core/constants/calculation_contract.dart';
import 'package:fard/core/extensions/hijri_extension.dart';
import 'package:fard/core/models/widget_data_model.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/utils/widget_prayer_calculator.dart';
import 'package:fard/core/utils/widget_theme_resolver.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:home_widget/home_widget.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class WidgetUpdateService {
  static const platform = MethodChannel(CalculationContract.channelName);
  final PrayerTimeService _prayerTimeService;
  final SharedPreferences _prefs;
  final SettingsRepository _settingsProvider;

  DateTime? _lastUpdate;

  WidgetUpdateService(
    this._prayerTimeService,
    this._prefs,
    this._settingsProvider,
  );

  Future<void> updateWidget() async {
    final now = DateTime.now();
    
    // Reduced throttling for better responsiveness during theme changes
    if (_lastUpdate != null && now.difference(_lastUpdate!) < const Duration(milliseconds: 500)) {
      debugPrint('WidgetUpdateService: Throttling update - too soon since last update');
      return;
    }

    try {
      await _performUpdate(now);
      _lastUpdate = DateTime.now();
    } catch (e) {
      debugPrint('WidgetUpdateService: Error during update: $e');
    }
  }

  Future<void> _performUpdate(DateTime now) async {
    if (_settingsProvider.latitude == null ||
        _settingsProvider.longitude == null) {
      debugPrint('WidgetUpdateService: Cannot update - missing location');
      return;
    }

    debugPrint('WidgetUpdateService: Starting update at $now');

    final prayerTimes = _prayerTimeService.getPrayerTimes(
      latitude: _settingsProvider.latitude!,
      longitude: _settingsProvider.longitude!,
      method: _settingsProvider.calculationMethod,
      madhab: _settingsProvider.madhab,
      date: now,
    );

    final hijriDate = HijriCalendar.fromDate(
      now.add(Duration(days: _settingsProvider.hijriAdjustment)),
    );

    final lang = _settingsProvider.locale.languageCode;
    final sunrise = DateFormat('h:mm a', lang).format(prayerTimes.sunrise);
    final dayOfWeek = DateFormat('EEEE', lang).format(now);
    final isRtl = lang == 'ar';

    // Use WidgetPrayerCalculator
    final nextPrayer = WidgetPrayerCalculator.calculateNextPrayer(
      now: now,
      prayerTimes: prayerTimes,
      prayerTimeService: _prayerTimeService,
      latitude: _settingsProvider.latitude!,
      longitude: _settingsProvider.longitude!,
      method: _settingsProvider.calculationMethod,
      madhab: _settingsProvider.madhab,
      lang: lang,
    );

    // Use WidgetThemeResolver
    final targetBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final themeColors = WidgetThemeResolver.resolve(
      themePresetId: _settingsProvider.themePresetId,
      customColors: _settingsProvider.customThemeColors,
      brightness: targetBrightness,
    );

    final data = WidgetDataModel(
      gregorianDate: DateFormat('d MMMM yyyy', lang).format(now),
      hijriDate: hijriDate.toVisualString(lang),
      dayOfWeek: dayOfWeek,
      sunrise: sunrise,
      isRtl: isRtl,
      nextPrayerName: nextPrayer.name,
      nextPrayerTime: nextPrayer.time.millisecondsSinceEpoch,
      lastUpdated: now.millisecondsSinceEpoch,
      primaryColorHex: themeColors.primary,
      accentColorHex: themeColors.accent,
      backgroundColorHex: themeColors.background,
      surfaceColorHex: themeColors.surface,
      textColorHex: themeColors.text,
      textSecondaryColorHex: themeColors.textSecondary,
      prayers: [
        WidgetPrayerCalculator.createItem('fajr', prayerTimes.fajr, lang),
        WidgetPrayerCalculator.createItem('dhuhr', prayerTimes.dhuhr, lang),
        WidgetPrayerCalculator.createItem('asr', prayerTimes.asr, lang),
        WidgetPrayerCalculator.createItem('maghrib', prayerTimes.maghrib, lang),
        WidgetPrayerCalculator.createItem('isha', prayerTimes.isha, lang),
      ],
    );

    final jsonData = jsonEncode(data.toJson());
    final key = '${CalculationContract.prefPrefix}prayer_data';

    try {
      await HomeWidget.saveWidgetData(key, jsonData);
      await _prefs.setString(key, jsonData);
      
      final hijriKey = '${CalculationContract.prefPrefix}hijri_date_cache';
      await _prefs.setString(hijriKey, data.hijriDate);
      await HomeWidget.saveWidgetData('${CalculationContract.prefPrefix}hijri_date', data.hijriDate);
      
      await _syncNative(jsonData);
      
      await HomeWidget.updateWidget(name: 'PrayerWidget', androidName: 'PrayerWidget');
      await HomeWidget.updateWidget(name: 'NextPrayerCountdownWidget', androidName: 'NextPrayerCountdownWidget');
    } catch (e) {
      debugPrint('WidgetUpdateService: Error during update: $e');
    }

    debugPrint('WidgetUpdateService: Update complete!');
  }

  Future<void> _syncNative(String prayerDataJson) async {
    try {
      final jsonMap = jsonDecode(prayerDataJson) as Map<String, dynamic>;
      final now = DateTime.now();
      final prayerTimes = _prayerTimeService.getPrayerTimes(
        latitude: _settingsProvider.latitude!,
        longitude: _settingsProvider.longitude!,
        method: _settingsProvider.calculationMethod,
        madhab: _settingsProvider.madhab,
        date: now,
      );

      await platform.invokeMethod('settingsChanged', {
        'calculation_method': _mapMethodToContract(
          _settingsProvider.calculationMethod,
        ),
        'latitude': _settingsProvider.latitude,
        'longitude': _settingsProvider.longitude,
        'madhab':
            _settingsProvider.madhab == 'hanafi'
                ? CalculationContract.madhabHanafi
                : CalculationContract.madhabShafi,
        'locale': _settingsProvider.locale.languageCode,
        'prayer_data': prayerDataJson,
        'hijri_date': _prefs.getString('flutter.hijri_date_cache') ?? '',
        'colors': {
          'primary': jsonMap['primaryColorHex'],
          'accent': jsonMap['accentColorHex'],
          'background': jsonMap['backgroundColorHex'],
          'surface': jsonMap['surfaceColorHex'],
          'text': jsonMap['textColorHex'],
          'text_secondary': jsonMap['textSecondaryColorHex'],
        },
        'prayer_times': {
          'fajr': prayerTimes.fajr.millisecondsSinceEpoch,
          'dhuhr': prayerTimes.dhuhr.millisecondsSinceEpoch,
          'asr': prayerTimes.asr.millisecondsSinceEpoch,
          'maghrib': prayerTimes.maghrib.millisecondsSinceEpoch,
          'isha': prayerTimes.isha.millisecondsSinceEpoch,
        },
      });
    } catch (e) {
      debugPrint('Error syncing native in WidgetUpdateService: $e');
    }
  }

  int _mapMethodToContract(String method) {
    switch (method) {
      case 'muslim_league': return CalculationContract.methodMuslimWorldLeague;
      case 'egyptian': return CalculationContract.methodEgyptian;
      case 'karachi': return CalculationContract.methodKarachi;
      case 'umm_al_qura': return CalculationContract.methodUmmAlQura;
      case 'dubai': return CalculationContract.methodDubai;
      case 'moonsighting_committee': return CalculationContract.methodMoonSightingCommittee;
      case 'north_america': return CalculationContract.methodNorthAmerica;
      case 'kuwait': return CalculationContract.methodKuwait;
      case 'qatar': return CalculationContract.methodQatar;
      case 'singapore': return CalculationContract.methodSingapore;
      case 'tehran': return CalculationContract.methodTehran;
      case 'turkey': return CalculationContract.methodTurkey;
      default: return CalculationContract.methodMuslimWorldLeague;
    }
  }

  // Native theme management methods retained as they are orchestration, not logic
  Future<Map<String, String>?> getWidgetTheme() async {
    try {
      const channel = MethodChannel('com.qada.fard/widget_theme');
      return await channel.invokeMapMethod<String, String>('getWidgetTheme');
    } catch (e) {
      debugPrint('WidgetUpdateService: Error getting widget theme: $e');
      return null;
    }
  }

  Future<void> applyWidgetTheme(Map<String, String> themeMap) async {
    try {
      const channel = MethodChannel('com.qada.fard/widget_theme');
      await channel.invokeMethod('applyWidgetTheme', themeMap);
    } catch (e) {
      debugPrint('WidgetUpdateService: Error applying widget theme: $e');
      rethrow;
    }
  }

  Future<void> clearWidgetTheme() async {
    try {
      const channel = MethodChannel('com.qada.fard/widget_theme');
      await channel.invokeMethod('clearWidgetTheme');
    } catch (e) {
      debugPrint('WidgetUpdateService: Error clearing widget theme: $e');
      rethrow;
    }
  }
}
