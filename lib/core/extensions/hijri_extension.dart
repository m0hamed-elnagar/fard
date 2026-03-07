import 'package:hijri/hijri_calendar.dart';

extension HijriDateTimeExtension on DateTime {
  String toHijriDate(String locale, {int adjustment = 0}) {
    final adjustedDate = add(Duration(days: adjustment));
    final hijri = HijriCalendar.fromDate(adjustedDate);
    return hijri.toVisualString(locale);
  }
}

extension HijriCalendarVisual on HijriCalendar {
  String toVisualString(String locale) {
    // Save current local to restore it if needed, or just set it
    HijriCalendar.setLocal(locale);
    if (locale == 'ar') {
      return '$hDay ${getLongMonthName()} $hYear هـ';
    } else {
      return '$hDay ${getLongMonthName()} $hYear AH';
    }
  }
}
