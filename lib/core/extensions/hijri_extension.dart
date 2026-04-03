import 'package:hijri/hijri_calendar.dart';
import 'package:fard/core/extensions/number_extension.dart';

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
      // \u200F is the Right-to-Left Mark (RLM) to ensure correct Bidi rendering
      // Arabic-Indic digits provide stronger RTL context
      return '\u200F${hDay.toArabicIndic()} ${getLongMonthName()} ${hYear.toArabicIndic()} هـ';
    } else {
      return '$hDay ${getLongMonthName()} $hYear AH';
    }
  }
}
