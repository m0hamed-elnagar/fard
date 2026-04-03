import 'dart:convert';
import 'package:fard/core/extensions/hijri_extension.dart';
import 'package:fard/core/models/widget_data_model.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:home_widget/home_widget.dart';
import 'package:fard/core/constants/calculation_contract.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

@singleton
class WidgetUpdateService {
  static const platform = MethodChannel(CalculationContract.channelName);
  final PrayerTimeService _prayerTimeService;
  final SharedPreferences _prefs;

  WidgetUpdateService(this._prayerTimeService, this._prefs);

  Future<void> updateWidget(SettingsState settings) async {
    if (settings.latitude == null || settings.longitude == null) {
      debugPrint('WidgetUpdateService: Cannot update - missing location');
      return;
    }

    final now = DateTime.now();
    debugPrint('WidgetUpdateService: Starting update at $now');

    final prayerTimes = _prayerTimeService.getPrayerTimes(
      latitude: settings.latitude!,
      longitude: settings.longitude!,
      method: settings.calculationMethod,
      madhab: settings.madhab,
      date: now,
    );

    debugPrint(
      'WidgetUpdateService: Calculated prayer times - Fajr: ${prayerTimes.fajr}, Dhuhr: ${prayerTimes.dhuhr}, Asr: ${prayerTimes.asr}, Maghrib: ${prayerTimes.maghrib}, Isha: ${prayerTimes.isha}',
    );

    // Consistent with app's Hijri adjustment logic
    final hijriDate = HijriCalendar.fromDate(
      now.add(Duration(days: settings.hijriAdjustment)),
    );

    final lang = settings.locale.languageCode;
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
        latitude: settings.latitude!,
        longitude: settings.longitude!,
        method: settings.calculationMethod,
        madhab: settings.madhab,
        date: now.add(const Duration(days: 1)),
      );
      nextPrayerName = _getPrayerName('fajr', lang);
      nextPrayerTime = tomorrowPrayerTimes.fajr;
    }

    final data = WidgetDataModel(
      gregorianDate: DateFormat('d MMMM yyyy', lang).format(now),
      hijriDate: hijriDate.toVisualString(lang),
      dayOfWeek: dayOfWeek,
      sunrise: sunrise,
      isRtl: isRtl,
      nextPrayerName: nextPrayerName,
      nextPrayerTime: nextPrayerTime.millisecondsSinceEpoch,
      lastUpdated: now.millisecondsSinceEpoch,
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

    final jsonData = jsonEncode(data.toJson());
    const key = 'prayer_data';

    // Save to HomeWidget (for native background refresh if needed)
    try {
      await HomeWidget.saveWidgetData('prayer_data', jsonData);
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

    // 🚀 CRITICAL FIX: Sync settings to Native BEFORE updating widget
    // This ensures SettingsRepository.getSettings() returns valid data
    // _syncNative also triggers Glance widget update via MainActivity
    await _syncNative(settings, jsonData);
    debugPrint('WidgetUpdateService: Settings synced to native');

    debugPrint('WidgetUpdateService: Update complete!');
  }

  Future<void> _syncNative(
    SettingsState settings,
    String prayerDataJson,
  ) async {
    try {
      final now = DateTime.now();
      final prayerTimes = _prayerTimeService.getPrayerTimes(
        latitude: settings.latitude!,
        longitude: settings.longitude!,
        method: settings.calculationMethod,
        madhab: settings.madhab,
        date: now,
      );

      await platform.invokeMethod('settingsChanged', {
        'calculation_method': _mapMethodToContract(settings.calculationMethod),
        'latitude': settings.latitude,
        'longitude': settings.longitude,
        'madhab': settings.madhab == 'hanafi'
            ? CalculationContract.madhabHanafi
            : CalculationContract.madhabShafi,
        'locale': settings.locale.languageCode,
        'prayer_data': prayerDataJson, // Atomic sync of display data
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
}
