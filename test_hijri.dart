import 'package:flutter/foundation.dart';
import 'package:hijri/hijri_calendar.dart';

void main() {
  final hijri = HijriCalendar.now();
  debugPrint('Default: ${hijri.getLongMonthName()}');
  
  HijriCalendar.setLocal('ar');
  debugPrint('Arabic: ${hijri.getLongMonthName()}');
  
  HijriCalendar.setLocal('en');
  debugPrint('English: ${hijri.getLongMonthName()}');
}
