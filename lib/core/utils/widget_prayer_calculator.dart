import 'package:fard/core/models/widget_data_model.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:intl/intl.dart';

class NextPrayerInfo {
  final String name;
  final DateTime time;

  NextPrayerInfo({required this.name, required this.time});
}

class WidgetPrayerCalculator {
  static NextPrayerInfo calculateNextPrayer({
    required DateTime now,
    required dynamic prayerTimes,
    required PrayerTimeService prayerTimeService,
    required double latitude,
    required double longitude,
    required String method,
    required String madhab,
    required String lang,
  }) {
    if (now.isBefore(prayerTimes.fajr)) {
      return NextPrayerInfo(name: getPrayerName('fajr', lang), time: prayerTimes.fajr);
    } else if (now.isBefore(prayerTimes.dhuhr)) {
      return NextPrayerInfo(name: getPrayerName('dhuhr', lang), time: prayerTimes.dhuhr);
    } else if (now.isBefore(prayerTimes.asr)) {
      return NextPrayerInfo(name: getPrayerName('asr', lang), time: prayerTimes.asr);
    } else if (now.isBefore(prayerTimes.maghrib)) {
      return NextPrayerInfo(name: getPrayerName('maghrib', lang), time: prayerTimes.maghrib);
    } else if (now.isBefore(prayerTimes.isha)) {
      return NextPrayerInfo(name: getPrayerName('isha', lang), time: prayerTimes.isha);
    } else {
      // After Isha - calculate tomorrow's Fajr
      final tomorrowPrayerTimes = prayerTimeService.getPrayerTimes(
        latitude: latitude,
        longitude: longitude,
        method: method,
        madhab: madhab,
        date: now.add(const Duration(days: 1)),
      );
      return NextPrayerInfo(name: getPrayerName('fajr', lang), time: tomorrowPrayerTimes.fajr);
    }
  }

  static String getPrayerName(String id, String lang) {
    if (lang == 'ar') {
      switch (id) {
        case 'fajr': return 'الفجر';
        case 'dhuhr': return 'الظهر';
        case 'asr': return 'العصر';
        case 'maghrib': return 'المغرب';
        case 'isha': return 'العشاء';
        default: return id;
      }
    } else {
      switch (id) {
        case 'fajr': return 'Fajr';
        case 'dhuhr': return 'Dhuhr';
        case 'asr': return 'Asr';
        case 'maghrib': return 'Maghrib';
        case 'isha': return 'Isha';
        default: return id;
      }
    }
  }

  static PrayerTimeItem createItem(String id, DateTime time, String lang) {
    return PrayerTimeItem(
      name: getPrayerName(id, lang),
      time: DateFormat('h:mm a', lang).format(time),
      minutesFromMidnight: time.hour * 60 + time.minute,
    );
  }
}
