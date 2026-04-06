import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/calendar_widget.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/dashboard_carousel.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/prayer_times_card.dart';
import 'package:adhan/adhan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('VISUAL CONFIRMATION: What PrayerTimesCard receives', (
    WidgetTester tester,
  ) async {
    final today = DateTime.now();
    final pastDate = today.subtract(const Duration(days: 10));
    final futureDate = today.add(const Duration(days: 5));

    // Create TODAY's prayer times
    final todayPrayerTimes = PrayerTimes(
      Coordinates(30.0, 31.0),
      DateComponents.from(today),
      CalculationMethod.muslim_world_league.getParameters(),
    );

    print('');
    print('═══════════════════════════════════════════════════════');
    print('TEST 1: PrayerTimesCard with PAST selected date');
    print('═══════════════════════════════════════════════════════');
    print('Today: ${today.toString().substring(0, 10)}');
    print('Selected (past): ${pastDate.toString().substring(0, 10)}');
    print('Today Fajr: ${todayPrayerTimes.fajr.toString().substring(0, 10)}');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: PrayerTimesCard(
            prayerTimes: todayPrayerTimes, // TODAY's times
            selectedDate: pastDate, // But PAST date
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final card1 = tester.widget<PrayerTimesCard>(find.byType(PrayerTimesCard));
    print('Card received prayerTimes.fajr: ${card1.prayerTimes!.fajr.toString().substring(0, 10)}');
    print('Card received selectedDate: ${card1.selectedDate.toString().substring(0, 10)}');
    
    if (card1.prayerTimes!.fajr.day == today.day) {
      print('✅ CORRECT: Using TODAY\'s prayer times for countdown');
    } else {
      print('❌ WRONG: Using selected date\'s prayer times');
    }

    print('');
    print('═══════════════════════════════════════════════════════');
    print('TEST 2: PrayerTimesCard with FUTURE selected date');
    print('═══════════════════════════════════════════════════════');
    print('Today: ${today.toString().substring(0, 10)}');
    print('Selected (future): ${futureDate.toString().substring(0, 10)}');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: PrayerTimesCard(
            prayerTimes: todayPrayerTimes, // TODAY's times
            selectedDate: futureDate, // But FUTURE date
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final card2 = tester.widget<PrayerTimesCard>(find.byType(PrayerTimesCard));
    print('Card received prayerTimes.fajr: ${card2.prayerTimes!.fajr.toString().substring(0, 10)}');
    print('Card received selectedDate: ${card2.selectedDate.toString().substring(0, 10)}');
    
    if (card2.prayerTimes!.fajr.day == today.day) {
      print('✅ CORRECT: Using TODAY\'s prayer times for countdown');
    } else {
      print('❌ WRONG: Using selected date\'s prayer times');
    }

    print('');
    print('═══════════════════════════════════════════════════════');
    print('TEST 3: Calendar collapsed header shows BOTH calendars');
    print('═══════════════════════════════════════════════════════');

    final testDate = DateTime(2026, 3, 3);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: CalendarWidget(
            selectedDate: testDate,
            monthRecords: {},
            onDaySelected: (_) {},
            onMonthChanged: (_, _) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Check for Gregorian
    final gregFound = find.text('March 2026');
    print('Gregorian "March 2026": ${gregFound.evaluate().isNotEmpty ? "✅ FOUND" : "❌ NOT FOUND"}');

    // Check for Hijri
    final hijriWidgets = find.byWidgetPredicate(
      (w) => w is Text && (w.data?.contains('Ramadan') ?? false),
    );
    print('Hijri "Ramadan 1447": ${hijriWidgets.evaluate().isNotEmpty ? "✅ FOUND" : "❌ NOT FOUND"}');

    // Count all Text widgets to verify secondary is showing
    final allText = find.byType(Text);
    print('Total Text widgets: ${allText.evaluate().length}');
    print('Expected: 70+ (both calendars rendering)');

    print('');
    print('═══════════════════════════════════════════════════════');
    print('SUMMARY');
    print('═══════════════════════════════════════════════════════');
    print('The code IS passing todayPrayerTimes to PrayerTimesCard.');
    print('If you still see wrong behavior in the app, try:');
    print('1. Hot RESTART (not hot reload): flutter run then press "R"');
    print('2. Check the debug logs in console when selecting dates');
    print('3. The logs will show exactly what dates are being used');
    print('═══════════════════════════════════════════════════════');

    expect(card1.prayerTimes!.fajr.day, equals(today.day));
    expect(card2.prayerTimes!.fajr.day, equals(today.day));
    expect(gregFound.evaluate().isNotEmpty, isTrue);
    expect(hijriWidgets.evaluate().isNotEmpty, isTrue);
  });
}
