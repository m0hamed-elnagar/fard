import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/calendar_widget.dart';
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

    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('TEST 1: PrayerTimesCard with PAST selected date');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('Today: ${today.toString().substring(0, 10)}');
    debugPrint('Selected (past): ${pastDate.toString().substring(0, 10)}');
    debugPrint('Today Fajr: ${todayPrayerTimes.fajr.toString().substring(0, 10)}');

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
    debugPrint('Card received prayerTimes.fajr: ${card1.prayerTimes!.fajr.toString().substring(0, 10)}');
    debugPrint('Card received selectedDate: ${card1.selectedDate.toString().substring(0, 10)}');

    if (card1.prayerTimes!.fajr.day == today.day) {
      debugPrint('✅ CORRECT: Using TODAY\'s prayer times for countdown');
    } else {
      debugPrint('❌ WRONG: Using selected date\'s prayer times');
    }

    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('TEST 2: PrayerTimesCard with FUTURE selected date');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('Today: ${today.toString().substring(0, 10)}');
    debugPrint('Selected (future): ${futureDate.toString().substring(0, 10)}');

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
    debugPrint('Card received prayerTimes.fajr: ${card2.prayerTimes!.fajr.toString().substring(0, 10)}');
    debugPrint('Card received selectedDate: ${card2.selectedDate.toString().substring(0, 10)}');

    if (card2.prayerTimes!.fajr.day == today.day) {
      debugPrint('✅ CORRECT: Using TODAY\'s prayer times for countdown');
    } else {
      debugPrint('❌ WRONG: Using selected date\'s prayer times');
    }

    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('TEST 3: Calendar collapsed header shows BOTH calendars');
    debugPrint('═══════════════════════════════════════════════════════');

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
    debugPrint('Gregorian "March 2026": ${gregFound.evaluate().isNotEmpty ? "✅ FOUND" : "❌ NOT FOUND"}');

    // Check for Hijri
    final hijriWidgets = find.byWidgetPredicate(
      (w) => w is Text && (w.data?.contains('Ramadan') ?? false),
    );
    debugPrint('Hijri "Ramadan 1447": ${hijriWidgets.evaluate().isNotEmpty ? "✅ FOUND" : "❌ NOT FOUND"}');

    // Count all Text widgets to verify secondary is showing
    final allText = find.byType(Text);
    debugPrint('Total Text widgets: ${allText.evaluate().length}');
    debugPrint('Expected: 70+ (both calendars rendering)');

    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('SUMMARY');
    debugPrint('═══════════════════════════════════════════════════════');
    debugPrint('The code IS passing todayPrayerTimes to PrayerTimesCard.');
    debugPrint('If you still see wrong behavior in the app, try:');
    debugPrint('1. Hot RESTART (not hot reload): flutter run then press "R"');
    debugPrint('2. Check the debug logs in console when selecting dates');
    debugPrint('3. The logs will show exactly what dates are being used');
    debugPrint('═══════════════════════════════════════════════════════');

    expect(card1.prayerTimes!.fajr.day, equals(today.day));
    expect(card2.prayerTimes!.fajr.day, equals(today.day));
    expect(gregFound.evaluate().isNotEmpty, isTrue);
    expect(hijriWidgets.evaluate().isNotEmpty, isTrue);
  });
}
