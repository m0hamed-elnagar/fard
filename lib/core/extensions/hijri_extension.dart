import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

extension HijriDateTimeExtension on DateTime {
  String toHijriDate(String locale) {
    final hijri = HijriCalendar.fromDate(this);
    return hijri.toVisualString(locale);
  }
}

extension HijriCalendarVisual on HijriCalendar {
  String toVisualString(String locale) {
    if (locale == 'ar') {
      return '$hDay ${getLongMonthName()} $hYear هـ';
    } else {
      return '$hDay ${getLongMonthName()} $hYear AH';
    }
  }
}
