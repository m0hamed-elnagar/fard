import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/salaah_tile.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SalaahTile', () {
    Widget createWidgetUnderTest({
      required Salaah salaah,
      required int qadaCount,
      required bool isMissedToday,
      VoidCallback? onAdd,
      VoidCallback? onRemove,
      VoidCallback? onToggleMissed,
    }) {
      return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Scaffold(
          body: SalaahTile(
            salaah: salaah,
            qadaCount: qadaCount,
            isMissedToday: isMissedToday,
            onAdd: onAdd ?? () {},
            onRemove: onRemove ?? () {},
            onToggleMissed: onToggleMissed ?? () {},
          ),
        ),
      );
    }

    testWidgets('renders all components correctly', (WidgetTester tester) async {
      bool addCalled = false;
      bool removeCalled = false;
      bool toggleCalled = false;
      final testTime = DateTime(2026, 2, 14, 5, 30);

      await tester.pumpWidget(createWidgetUnderTest(
        salaah: Salaah.fajr,
        qadaCount: 5,
        isMissedToday: true,
        onAdd: () => addCalled = true,
        onRemove: () => removeCalled = true,
        onToggleMissed: () => toggleCalled = true,
      ));
      await tester.pumpAndSettle();

      final l10n = lookupAppLocalizations(const Locale('ar'));

      // Verify labels
      expect(find.text(Salaah.fajr.localizedName(l10n)), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('${l10n.remaining}: 5'), findsOneWidget);
    });

    testWidgets('displays prayer time when provided', (WidgetTester tester) async {
      final testTime = DateTime(2026, 2, 14, 13, 45); // 1:45 PM

      await tester.pumpWidget(MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SalaahTile(
            salaah: Salaah.dhuhr,
            qadaCount: 0,
            isMissedToday: false,
            time: testTime,
            onAdd: () {},
            onRemove: () {},
            onToggleMissed: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('1:45'), findsOneWidget);
    });

    testWidgets('remove button is disabled when count is 0', (WidgetTester tester) async {
       bool removeCalled = false;

       await tester.pumpWidget(createWidgetUnderTest(
         salaah: Salaah.fajr,
         qadaCount: 0,
         isMissedToday: false,
         onRemove: () => removeCalled = true,
       ));
       await tester.pumpAndSettle();

      // Tap remove button
      await tester.tap(find.byIcon(Icons.remove_rounded));
      
      // Should NOT have been called because it's passed as null in the widget when count is 0
      expect(removeCalled, isFalse);
    });
  });
}
