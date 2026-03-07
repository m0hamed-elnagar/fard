import 'package:hijri/hijri_calendar.dart';

void main() {
  final hijri = HijriCalendar.now();
  print('Default: ${hijri.getLongMonthName()}');
  
  HijriCalendar.setLocal('ar');
  print('Arabic: ${hijri.getLongMonthName()}');
  
  HijriCalendar.setLocal('en');
  print('English: ${hijri.getLongMonthName()}');
}
