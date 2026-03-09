import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  // Disable GoogleFonts to avoid network calls during tests
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget createWidgetUnderTest({
    required DateTime selectedDate,
    required Map<DateTime, dynamic> monthRecords,
    Locale locale = const Locale('en'),
    int hijriAdjustment = 0,
  }) {
    return MaterialApp(
      locale: locale,
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
          selectedDate: selectedDate,
          monthRecords: const {}, // Simplified for this test
          onDaySelected: (_) {},
          onMonthChanged: (_, _) {},          hijriAdjustment: hijriAdjustment,
        ),
      ),
    );
  }

  group('CalendarWidget', () {
    testWidgets('renders correctly and shows Gregorian by default in collapsed header', (WidgetTester tester) async {
      final testDate = DateTime(2026, 3, 3); // March 3, 2026

      await tester.pumpWidget(createWidgetUnderTest(selectedDate: testDate, monthRecords: {}));
      await tester.pumpAndSettle();

      // Check for "March 2026" in the collapsed header.
      expect(find.text('March 2026'), findsOneWidget);

      // Expand the calendar to see the expanded header (tap the month text)
      await tester.tap(find.text('March 2026'));
      await tester.pumpAndSettle();

      // Expanded header should show Gregorian primary in the title builder or subtitle
      expect(find.textContaining('March 2026'), findsAtLeast(1));
      // Hijri secondary
      expect(find.textContaining('Ramadan 1447 هـ'), findsAtLeast(1));
    });

    testWidgets('switches focus to Hijri when header switch button is tapped', (WidgetTester tester) async {
      final testDate = DateTime(2026, 3, 3);
      
      await tester.pumpWidget(createWidgetUnderTest(selectedDate: testDate, monthRecords: {}));
      await tester.pumpAndSettle();

      // Find the switch button (contains Icons.swap_horiz_rounded)
      final switchBtn = find.byIcon(Icons.swap_horiz_rounded);
      expect(switchBtn, findsOneWidget);
      
      // Tap it to switch to Hijri
      await tester.tap(switchBtn);
      await tester.pumpAndSettle();

      // Collapsed header should now show Hijri
      expect(find.text('Ramadan 1447 هـ'), findsOneWidget);
      
      // Hijri icon (nightlight_round) should be shown
      expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
      
      // Toggle back to Gregorian
      await tester.tap(switchBtn);
      await tester.pumpAndSettle();
      expect(find.text('March 2026'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    });

    testWidgets('renders Arabic correctly', (WidgetTester tester) async {
      final testDate = DateTime(2026, 3, 3);
      
      await tester.pumpWidget(createWidgetUnderTest(
        selectedDate: testDate, 
        monthRecords: {},
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      // The header shows Gregorian by default in Arabic too (usually localized)
      // Tapping the focus switcher to ensure we see Ramadan
      final switchBtn = find.byIcon(Icons.swap_horiz_rounded);
      await tester.tap(switchBtn);
      await tester.pumpAndSettle();

      // Check for Arabic Hijri month (رمضان)
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Text &&
            (widget.data?.contains('رمضان') ?? false)),
        findsAtLeast(1),
      );
    });
  });
}
