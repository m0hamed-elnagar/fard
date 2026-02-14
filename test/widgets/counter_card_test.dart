import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/counter_card.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CounterCard', () {
    final status = {
      for (var s in Salaah.values) s: const MissedCounter(10)
    };

    Widget createWidgetUnderTest(Map<Salaah, MissedCounter> qadaStatus, int todayMissedCount) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          body: CounterCard(
            qadaStatus: qadaStatus,
            todayMissedCount: todayMissedCount,
            onAddPressed: () {},
            onEditPressed: () {},
          ),
        ),
      );
    }

    testWidgets('displays total remaining count correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest(status, 2));
      await tester.pumpAndSettle();

      // Total = 5 * 10 = 50
      expect(find.text('50'), findsOneWidget);
      // Missed today badge
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('expands to show breakdown on tap', (WidgetTester tester) async {
       await tester.pumpWidget(createWidgetUnderTest(status, 0));
       await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('ar'));
      
      // Tap to expand
      await tester.tap(find.text(l10n.remaining));
      await tester.pumpAndSettle();

      // Now breakdown should be visible
      for (var s in Salaah.values) {
        expect(find.text(s.localizedName(l10n)), findsOneWidget);
        expect(find.text('10'), findsAtLeast(1));
      }
    });

    testWidgets('shows edit button when expanded and triggers callback', (WidgetTester tester) async {
      bool editPressed = false;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: CounterCard(
            qadaStatus: status,
            todayMissedCount: 0,
            onAddPressed: () {},
            onEditPressed: () => editPressed = true,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('en'));

      // Expand - tap the main row
      await tester.tap(find.text(l10n.remaining));
      await tester.pumpAndSettle();

      // Now Edit button should be visible
      final editBtn = find.text(l10n.edit);
      expect(editBtn, findsOneWidget);

      await tester.tap(editBtn);
      await tester.pumpAndSettle();
      
      expect(editPressed, isTrue);
    });
  });
}
