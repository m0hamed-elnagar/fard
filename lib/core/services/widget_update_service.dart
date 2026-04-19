import 'dart:convert';

import 'package:fard/core/constants/calculation_contract.dart';
import 'package:fard/core/extensions/hijri_extension.dart';
import 'package:fard/core/models/widget_data_model.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/theme/theme_presets.dart';
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

  WidgetUpdateService(
    this._prayerTimeService,
    this._prefs,
    this._settingsProvider,
  );

  Future<void> updateWidget() async {
    if (_settingsProvider.latitude == null ||
        _settingsProvider.longitude == null) {
      debugPrint('WidgetUpdateService: Cannot update - missing location');
      return;
    }

    final now = DateTime.now();
    debugPrint('WidgetUpdateService: Starting update at $now');

    final prayerTimes = _prayerTimeService.getPrayerTimes(
      latitude: _settingsProvider.latitude!,
      longitude: _settingsProvider.longitude!,
      method: _settingsProvider.calculationMethod,
      madhab: _settingsProvider.madhab,
      date: now,
    );

    debugPrint(
      'WidgetUpdateService: Calculated prayer times - Fajr: ${prayerTimes.fajr}, Dhuhr: ${prayerTimes.dhuhr}, Asr: ${prayerTimes.asr}, Maghrib: ${prayerTimes.maghrib}, Isha: ${prayerTimes.isha}',
    );

    // Consistent with app's Hijri adjustment logic
    final hijriDate = HijriCalendar.fromDate(
      now.add(Duration(days: _settingsProvider.hijriAdjustment)),
    );

    final lang = _settingsProvider.locale.languageCode;
    final sunrise = DateFormat.jm(lang).format(prayerTimes.sunrise);
    final dayOfWeek = DateFormat('EEEE', lang).format(now);
    final isRtl = lang == 'ar';

    // Calculate Next Prayer
    String nextPrayerName = _getPrayerName('fajr', lang);
    DateTime nextPrayerTime = prayerTimes.fajr;

    if (now.isBefore(prayerTimes.fajr)) {
      nextPrayerName = _getPrayerName('fajr', lang);
      nextPrayerTime = prayerTimes.fajr;
    } else if (now.isBefore(prayerTimes.dhuhr)) {
      nextPrayerName = _getPrayerName('dhuhr', lang);
      nextPrayerTime = prayerTimes.dhuhr;
    } else if (now.isBefore(prayerTimes.asr)) {
      nextPrayerName = _getPrayerName('asr', lang);
      nextPrayerTime = prayerTimes.asr;
    } else if (now.isBefore(prayerTimes.maghrib)) {
      nextPrayerName = _getPrayerName('maghrib', lang);
      nextPrayerTime = prayerTimes.maghrib;
    } else if (now.isBefore(prayerTimes.isha)) {
      nextPrayerName = _getPrayerName('isha', lang);
      nextPrayerTime = prayerTimes.isha;
    } else {
      // After Isha - calculate tomorrow's Fajr
      final tomorrowPrayerTimes = _prayerTimeService.getPrayerTimes(
        latitude: _settingsProvider.latitude!,
        longitude: _settingsProvider.longitude!,
        method: _settingsProvider.calculationMethod,
        madhab: _settingsProvider.madhab,
        date: now.add(const Duration(days: 1)),
      );
      nextPrayerName = _getPrayerName('fajr', lang);
      nextPrayerTime = tomorrowPrayerTimes.fajr;
    }

    // The widget follows system brightness for a seamless zero-config experience
    final targetBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;

    // Get current theme colors
    Color seedColor = const Color(0xFF2E7D32);
    
    final themePresetId = _settingsProvider.themePresetId;
    if (themePresetId == 'custom') {
      final customColors = _settingsProvider.customThemeColors;
      if (customColors != null && customColors['primary'] != null) {
        seedColor = _hexToColor(customColors['primary']!);
      }
    } else {
      try {
        final preset = ThemePresets.getById(themePresetId);
        seedColor = preset.primaryColor;
      } catch (e) {
        debugPrint(
          'WidgetUpdateService: Theme preset not found: $themePresetId',
        );
      }
    }

    // Use ColorScheme.fromSeed to derive a harmonious and high-contrast palette
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: targetBrightness,
    );

    final primaryColor = _colorToHex(colorScheme.primary);
    final accentColor = _colorToHex(colorScheme.secondary); // Using secondary as Accent
    final backgroundColor = _colorToHex(colorScheme.surface); // Use surface as background for consistency
    final surfaceColor = _colorToHex(colorScheme.surfaceContainerHighest);
    final textColor = _colorToHex(colorScheme.onSurface); 
    final textSecondaryColor = _colorToHex(colorScheme.onSurfaceVariant);

    final data = WidgetDataModel(
      gregorianDate: DateFormat('d MMMM yyyy', lang).format(now),
      hijriDate: hijriDate.toVisualString(lang),
      dayOfWeek: dayOfWeek,
      sunrise: sunrise,
      isRtl: isRtl,
      nextPrayerName: nextPrayerName,
      nextPrayerTime: nextPrayerTime.millisecondsSinceEpoch,
      lastUpdated: now.millisecondsSinceEpoch,
      primaryColorHex: primaryColor,
      accentColorHex: accentColor,
      backgroundColorHex: backgroundColor,
      surfaceColorHex: surfaceColor,
      textColorHex: textColor,
      textSecondaryColorHex: textSecondaryColor,
      prayers: [
        _createItem('fajr', prayerTimes.fajr, lang),
        _createItem('dhuhr', prayerTimes.dhuhr, lang),
        _createItem('asr', prayerTimes.asr, lang),
        _createItem('maghrib', prayerTimes.maghrib, lang),
        _createItem('isha', prayerTimes.isha, lang),
      ],
    );

    debugPrint(
      'WidgetUpdateService: Saving data for widget: ${data.gregorianDate}',
    );
    debugPrint(
      'WidgetUpdateService: Next prayer: $nextPrayerName at $nextPrayerTime',
    );
    debugPrint(
      'WidgetUpdateService: Target brightness: $targetBrightness',
    );
    debugPrint(
      'WidgetUpdateService: Primary color: $primaryColor, Background: $backgroundColor',
    );

    final jsonData = jsonEncode(data.toJson());
    final key = '${CalculationContract.prefPrefix}prayer_data';

    // DEBUG: Print the actual JSON being saved
    final jsonForDebug = jsonDecode(jsonData) as Map<String, dynamic>;
    debugPrint(
      'WidgetUpdateService: JSON primaryColorHex=${jsonForDebug['primaryColorHex']}, backgroundColorHex=${jsonForDebug['backgroundColorHex']}',
    );

    // Save to HomeWidget (for native background refresh if needed)
    try {
      await HomeWidget.saveWidgetData(key, jsonData);
    } catch (e) {
      debugPrint('WidgetUpdateService: Error saving to HomeWidget: $e');
    }

    // Save to standard SharedPreferences (which SettingsRepository.kt reads from)
    try {
      await _prefs.setString(key, jsonData);
      debugPrint(
        'WidgetUpdateService: Saved to SharedPreferences with key: $key',
      );
    } catch (e) {
      debugPrint('WidgetUpdateService: Error saving to SharedPreferences: $e');
    }

    // 🚀 CRITICAL FIX: Cache Hijri date separately for native worker
    // This prevents the native worker from showing "Loading..." placeholder
    final hijriKey = '${CalculationContract.prefPrefix}hijri_date_cache';
    try {
      await _prefs.setString(hijriKey, data.hijriDate);
      await HomeWidget.saveWidgetData('${CalculationContract.prefPrefix}hijri_date', data.hijriDate);
      debugPrint('WidgetUpdateService: Cached Hijri date: ${data.hijriDate}');
    } catch (e) {
      debugPrint('WidgetUpdateService: Error caching Hijri date: $e');
    }

    // 🚀 CRITICAL FIX: Sync settings to Native BEFORE updating widget
    // This ensures SettingsRepository.getSettings() returns valid data
    // _syncNative also triggers Glance widget update via MainActivity
    await _syncNative(jsonData);
    debugPrint('WidgetUpdateService: Settings synced to native');

    // 🚀 CRITICAL FIX: Explicitly request Glance widget update
    // This ensures Android calls provideGlance() again with new theme data
    try {
      await HomeWidget.updateWidget(
        name: 'PrayerWidget',
        androidName: 'PrayerWidget',
      );
      debugPrint('WidgetUpdateService: Requested PrayerWidget update');
    } catch (e) {
      debugPrint('WidgetUpdateService: Error updating PrayerWidget: $e');
    }

    try {
      await HomeWidget.updateWidget(
        name: 'NextPrayerCountdownWidget',
        androidName: 'NextPrayerCountdownWidget',
      );
      debugPrint('WidgetUpdateService: Requested CountdownWidget update');
    } catch (e) {
      debugPrint('WidgetUpdateService: Error updating CountdownWidget: $e');
    }

    debugPrint('WidgetUpdateService: Update complete!');
  }

  /// Get saved widget theme from native SharedPreferences
  Future<Map<String, String>?> getWidgetTheme() async {
    try {
      const channel = MethodChannel('com.qada.fard/widget_theme');
      final result = await channel.invokeMapMethod<String, String>('getWidgetTheme');
      return result;
    } catch (e) {
      debugPrint('WidgetUpdateService: Error getting widget theme: $e');
      return null;
    }
  }

  /// Save widget theme to native SharedPreferences and apply
  Future<void> applyWidgetTheme(Map<String, String> themeMap) async {
    try {
      const channel = MethodChannel('com.qada.fard/widget_theme');
      await channel.invokeMethod('applyWidgetTheme', themeMap);
    } catch (e) {
      debugPrint('WidgetUpdateService: Error applying widget theme: $e');
      rethrow;
    }
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
        'prayer_data': prayerDataJson, // Atomic sync of display data
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
      case 'muslim_league':
        return CalculationContract.methodMuslimWorldLeague;
      case 'egyptian':
        return CalculationContract.methodEgyptian;
      case 'karachi':
        return CalculationContract.methodKarachi;
      case 'umm_al_qura':
        return CalculationContract.methodUmmAlQura;
      case 'dubai':
        return CalculationContract.methodDubai;
      case 'moonsighting_committee':
        return CalculationContract.methodMoonSightingCommittee;
      case 'north_america':
        return CalculationContract.methodNorthAmerica;
      case 'kuwait':
        return CalculationContract.methodKuwait;
      case 'qatar':
        return CalculationContract.methodQatar;
      case 'singapore':
        return CalculationContract.methodSingapore;
      case 'tehran':
        return CalculationContract.methodTehran;
      case 'turkey':
        return CalculationContract.methodTurkey;
      default:
        return CalculationContract.methodMuslimWorldLeague;
    }
  }

  PrayerTimeItem _createItem(String id, DateTime time, String lang) {
    return PrayerTimeItem(
      name: _getPrayerName(id, lang),
      time: DateFormat.jm(lang).format(time),
      minutesFromMidnight: time.hour * 60 + time.minute,
    );
  }

  String _getPrayerName(String id, String lang) {
    if (lang == 'ar') {
      switch (id) {
        case 'fajr':
          return 'الفجر';
        case 'dhuhr':
          return 'الظهر';
        case 'asr':
          return 'العصر';
        case 'maghrib':
          return 'المغرب';
        case 'isha':
          return 'العشاء';
        default:
          return id;
      }
    } else {
      switch (id) {
        case 'fajr':
          return 'Fajr';
        case 'dhuhr':
          return 'Dhuhr';
        case 'asr':
          return 'Asr';
        case 'maghrib':
          return 'Maghrib';
        case 'isha':
          return 'Isha';
        default:
          return id;
      }
    }
  }

  /// Convert hex string to Color
  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convert Color to hex string
  String _colorToHex(Color color) {
    return '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}
