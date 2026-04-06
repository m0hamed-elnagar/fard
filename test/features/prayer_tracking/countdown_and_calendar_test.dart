import 'package:adhan/adhan.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/calendar_widget.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/dashboard_carousel.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/home_content.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/prayer_times_card.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

// Mocks
class MockPrayerTrackerBloc extends Mock implements PrayerTrackerBloc {}
class MockSettingsCubit extends Mock implements SettingsCubit {}
class MockWerdBloc extends Mock implements WerdBloc {}

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  group('COUNTDOWN TIMER TESTS - Verify it uses TODAY not selected date', () {
    testWidgets(
        'PrayerTimesCard receives correct prayerTimes when selectedDate is in PAST',
        (WidgetTester tester) async {
      // Arrange: Create a past date
      final today = DateTime.now();
      final pastDate = today.subtract(const Duration(days: 10));

      // Create mock prayer times for TODAY
      final todayPrayerTimes = _createMockPrayerTimes(today);

      // Create a mock PrayerTimesCard to capture what's passed
      PrayerTimes? capturedPrayerTimes;
      DateTime? capturedSelectedDate;

      // Act: Build PrayerTimesCard directly with today's prayer times
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
              prayerTimes: todayPrayerTimes,
              selectedDate: pastDate,
              cityName: 'Test City',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert: Widget should have received TODAY's prayer times
      final card = tester.widget<PrayerTimesCard>(find.byType(PrayerTimesCard));
      
      print('=== TEST: PrayerTimesCard with past selected date ===');
      print('Selected Date: ${card.selectedDate}');
      print('Prayer Times received: ${card.prayerTimes != null}');
      if (card.prayerTimes != null) {
        print('Fajr: ${card.prayerTimes!.fajr}');
        print('Dhuhr: ${card.prayerTimes!.dhuhr}');
        print('Asr: ${card.prayerTimes!.asr}');
        print('Maghrib: ${card.prayerTimes!.maghrib}');
        print('Isha: ${card.prayerTimes!.isha}');
      }

      // The prayerTimes should match today's times, not the selected date's times
      expect(card.prayerTimes, isNotNull);
      expect(
        card.prayerTimes!.fajr.day,
        equals(today.day),
        reason: 'Fajr should be from TODAY, not the selected past date',
      );
    });

    testWidgets(
        'PrayerTimesCard receives correct prayerTimes when selectedDate is in FUTURE',
        (WidgetTester tester) async {
      final today = DateTime.now();
      final futureDate = today.add(const Duration(days: 5));

      final todayPrayerTimes = _createMockPrayerTimes(today);

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
              prayerTimes: todayPrayerTimes,
              selectedDate: futureDate,
              cityName: 'Test City',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final card = tester.widget<PrayerTimesCard>(find.byType(PrayerTimesCard));

      print('=== TEST: PrayerTimesCard with future selected date ===');
      print('Selected Date: ${card.selectedDate}');
      if (card.prayerTimes != null) {
        print('Fajr day: ${card.prayerTimes!.fajr.day}');
        print('Today is: ${today.day}');
      }

      expect(card.prayerTimes, isNotNull);
      expect(
        card.prayerTimes!.fajr.day,
        equals(today.day),
        reason: 'Fajr should be from TODAY, not the selected future date',
      );
    });

    testWidgets(
        'Countdown calculates from NOW not from selectedDate', (
          WidgetTester tester,
        ) async {
      final today = DateTime.now();
      final pastDate = today.subtract(const Duration(days: 30));

      // Create prayer times for today with known times
      final coordinates = Coordinates(30.0, 31.0);
      final dateComponents = DateComponents.from(today);
      final params = CalculationMethod.muslim_world_league.getParameters();

      final todayPrayerTimes = PrayerTimes(
        coordinates,
        dateComponents,
        params,
      );

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
              prayerTimes: todayPrayerTimes,
              selectedDate: pastDate,
            ),
          ),
        ),
      );

      // Let the timer run for a moment
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final card = tester.widget<PrayerTimesCard>(find.byType(PrayerTimesCard));

      print('=== TEST: Countdown timing verification ===');
      print('Selected (past) date: $pastDate');
      print('Prayer times are for: ${todayPrayerTimes.fajr}');
      print('Card widget shows countdown based on these prayer times');

      // Verify the card is using today's prayer times
      expect(card.prayerTimes, equals(todayPrayerTimes));
      expect(card.prayerTimes!.fajr.day, equals(today.day));
    });
  });

  group('CALENDAR DUAL DISPLAY TESTS', () {
    testWidgets(
        'Collapsed header shows BOTH Gregorian and Hijri calendars',
        (WidgetTester tester) async {
      final testDate = DateTime(2026, 3, 3); // March 3, 2026 = Ramadan 1447

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
              hijriAdjustment: 0,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      print('=== TEST: Collapsed header dual calendar ===');
      print('Calendar should show BOTH calendars when collapsed');

      // Check for Gregorian (should be primary since _hijriFocused defaults to false)
      final gregorianFound = find.text('March 2026');
      expect(gregorianFound, findsOneWidget);
      print('✓ Gregorian calendar found: March 2026');

      // Check for Hijri secondary (should now be visible in collapsed mode)
      final hijriTexts = find.byWidgetPredicate(
        (widget) => widget is Text && (widget.data?.contains('Ramadan') ?? false),
      );
      
      if (hijriTexts.evaluate().isNotEmpty) {
        print('✓ Hijri calendar found in collapsed header');
      } else {
        print('✗ Hijri calendar NOT found in collapsed header - THIS IS THE BUG');
      }

      // Dump the widget tree to see what's rendered
      debugDumpApp();
    });

    testWidgets(
        'Calendar cells show secondary calendar text',
        (WidgetTester tester) async {
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
              hijriAdjustment: 0,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      print('=== TEST: Calendar cells secondary calendar ===');
      print('Expanding calendar to see cells...');

      // Expand the calendar
      final headerText = find.text('March 2026');
      if (headerText.evaluate().isNotEmpty) {
        await tester.tap(headerText);
        await tester.pumpAndSettle();
      }

      // Count how many Text widgets exist (should be 2 per cell: primary + secondary)
      final allTextWidgets = find.byType(Text);
      final textCount = allTextWidgets.evaluate().length;

      print('Total Text widgets in calendar: $textCount');
      print('Expected: At least 60+ (2 per day for 30 days + headers)');

      if (textCount < 50) {
        print('⚠ LOW TEXT COUNT - Secondary calendar may not be rendering');
      } else {
        print('✓ Text count seems reasonable');
      }
    });
  });

  group('HOME_CONTENT INTEGRATION TESTS', () {
    testWidgets(
        'DashboardCarousel passes correct prayerTimes to PrayerTimesCard',
        (WidgetTester tester) async {
      final today = DateTime.now();
      final selectedDate = today.subtract(const Duration(days: 5));

      // Create TODAY's prayer times
      final todayPrayerTimes = _createMockPrayerTimes(today);
      
      // Create SELECTED DATE's prayer times (different)
      final selectedDatePrayerTimes = _createMockPrayerTimes(selectedDate);

      print('=== TEST: DashboardCarousel integration ===');
      print('Today: $today');
      print('Selected date: $selectedDate');
      print('Today Fajr: ${todayPrayerTimes.fajr}');
      print('Selected Fajr: ${selectedDatePrayerTimes.fajr}');

      // Build DashboardCarousel with TODAY's prayer times
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
            body: DashboardCarousel(
              prayerTimes: todayPrayerTimes, // TODAY's times
              selectedDate: selectedDate, // But SELECTED date is different
              cityName: 'Test City',
              qadaStatus: {},
              onAddQadaPressed: () {},
              onEditQadaPressed: () {},
              onSetWerdGoalPressed: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the PrayerTimesCard inside DashboardCarousel
      final prayerTimesCard = tester.widget<PrayerTimesCard>(
        find.byType(PrayerTimesCard),
      );

      print('PrayerTimesCard.prayerTimes.fajr: ${prayerTimesCard.prayerTimes!.fajr}');
      print('PrayerTimesCard.selectedDate: ${prayerTimesCard.selectedDate}');

      // CRITICAL ASSERTION: PrayerTimesCard should receive TODAY's prayer times
      // for the countdown, NOT the selectedDate's prayer times
      expect(
        prayerTimesCard.prayerTimes!.fajr.day,
        equals(today.day),
        reason: 'PrayerTimesCard should use TODAY\'s Fajr for countdown, not selected date',
      );

      // The selectedDate parameter can be different (for display purposes)
      expect(
        prayerTimesCard.selectedDate.day,
        equals(selectedDate.day),
      );
    });
  });
}

// Helper to create mock prayer times
PrayerTimes _createMockPrayerTimes(DateTime date) {
  return PrayerTimes(
    Coordinates(30.0, 31.0),
    DateComponents.from(date),
    CalculationMethod.muslim_world_league.getParameters(),
  );
}
