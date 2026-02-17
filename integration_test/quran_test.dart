import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart';
import 'package:fard/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Quran Feature Integration Test', () {
    testWidgets('Navigate to Quran tab and check for crash', (tester) async {
      // Initialize dependencies manually
      await configureDependencies();
      
      final prefs = getIt<SharedPreferences>();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setString('locale', 'en'); 

      await tester.pumpWidget(const QadaTrackerApp());
      
      // Wait for app to initialize and settle
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Attempt to find the Quran tab
      final quranIcon = find.byIcon(Icons.menu_book_outlined);
      final quranRoundedIcon = find.byIcon(Icons.menu_book_rounded);
      final quranTextEn = find.text('Quran');
      final quranTextAr = find.text('القرآن');

      Finder? targetTab;
      if (quranIcon.evaluate().isNotEmpty) {
        targetTab = quranIcon;
      } else if (quranRoundedIcon.evaluate().isNotEmpty) {
        targetTab = quranRoundedIcon;
      } else if (quranTextEn.evaluate().isNotEmpty) {
        targetTab = quranTextEn;
      } else if (quranTextAr.evaluate().isNotEmpty) {
        targetTab = quranTextAr;
      }

      if (targetTab == null) {
        // Fallback to NavigationBar index if text/icon finders fail
        final navBar = find.byType(NavigationBar);
        if (navBar.evaluate().isNotEmpty) {
          final destinations = find.descendant(of: navBar, matching: find.byType(NavigationDestination));
          if (destinations.evaluate().length > 1) {
            targetTab = destinations.at(1);
          }
        }
      }
      
      if (targetTab != null) {
        await tester.tap(targetTab.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      } else {
        fail('Could not find Quran tab or NavigationBar');
      }

      // Check if we are on the Quran page
      final loadingIndicator = find.byType(CircularProgressIndicator);
      final listTile = find.byType(ListTile);
      
      expect(
        loadingIndicator.evaluate().isNotEmpty || listTile.evaluate().isNotEmpty,
        isTrue,
        reason: 'Should show either a loading indicator or surah list',
      );
    });
  });
}
