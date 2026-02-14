import 'package:fard/features/prayer_tracking/presentation/widgets/missed_days_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/core/l10n/app_localizations.dart';

void main() {
  group('MissedDaysDialog', () {
    final missedDates = [
      DateTime(2024, 1, 1),
      DateTime(2024, 1, 2),
      DateTime(2024, 1, 3),
      DateTime(2024, 1, 4),
      DateTime(2024, 1, 5),
      DateTime(2024, 1, 6),
      DateTime(2024, 1, 7),
    ];

    Widget createWidgetUnderTest({
      required List<DateTime> dates,
      required void Function(List<DateTime>) onResponse,
      Locale locale = const Locale('en'),
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: locale,
        home: Scaffold(
          body: MissedDaysDialog(
            missedDates: dates,
            onResponse: onResponse,
          ),
        ),
      );
    }

    testWidgets('displays missed dates as calendar items', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        dates: missedDates,
        onResponse: (_) {},
      ));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('LTR Swipe: Swiping right toggles multiple items', (WidgetTester tester) async {
      List<DateTime>? selected;
      await tester.pumpWidget(createWidgetUnderTest(
        dates: missedDates,
        onResponse: (res) => selected = res,
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();

      // Start drag on day '1' and move to day '3'
      final first = find.text('1');
      final third = find.text('3');
      
      await tester.dragFrom(tester.getCenter(first), tester.getCenter(third) - tester.getCenter(first));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Check that at least some items in the swipe path were toggled
      // Path: 1 -> 2 -> 3. Original: all ON. Should be some OFF.
      expect(selected?.length, lessThan(missedDates.length));
    });

    testWidgets('RTL Swipe: Swiping left toggles multiple items', (WidgetTester tester) async {
      List<DateTime>? selected;
      await tester.pumpWidget(createWidgetUnderTest(
        dates: missedDates,
        onResponse: (res) => selected = res,
        locale: const Locale('ar'),
      ));
      await tester.pumpAndSettle();

      // In RTL, day '1' is on right, day '3' is to its left
      final first = find.text('1');
      final third = find.text('3');
      
      await tester.dragFrom(tester.getCenter(first), tester.getCenter(third) - tester.getCenter(first));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(selected?.length, lessThan(missedDates.length));
    });
  });
}
