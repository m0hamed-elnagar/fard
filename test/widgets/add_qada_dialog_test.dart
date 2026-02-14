import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/add_qada_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AddQadaDialog', () {
    testWidgets('Add mode: shows both tabs and "Add" button', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AddQadaDialog(onConfirm: (_) {}),
      ));
      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('en'));
      
      expect(find.text(l10n.byCount), findsOneWidget);
      expect(find.text(l10n.byTime), findsOneWidget);
      expect(find.text(l10n.add), findsOneWidget);
      expect(find.text(l10n.addQada), findsOneWidget);
    });

    testWidgets('Edit mode: shows only count list and "Update" button', (WidgetTester tester) async {
      final initial = {for (var s in Salaah.values) s: 5};
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AddQadaDialog(
          title: 'Edit My Prayers',
          initialCounts: initial,
          onConfirm: (_) {},
        ),
      ));
      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('en'));

      expect(find.text('Edit My Prayers'), findsOneWidget);
      expect(find.text(l10n.byTime), findsNothing);
      expect(find.text(l10n.update), findsOneWidget);
      
      // Verify initial values are loaded
      expect(find.text('5'), findsNWidgets(5));
    });

    testWidgets('can increment and decrement values', (WidgetTester tester) async {
      Map<Salaah, int>? result;
      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AddQadaDialog(
          onConfirm: (val) => result = val,
        ),
      ));
      await tester.pumpAndSettle();

      // Find first increment button (for Fajr)
      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      final l10n = lookupAppLocalizations(const Locale('en'));
      await tester.tap(find.text(l10n.add));
      await tester.pumpAndSettle();

      expect(result?[Salaah.fajr], 1);
      expect(result?[Salaah.dhuhr], 0);
    });
  });
}
