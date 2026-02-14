import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Azkar Integration Test', () {
    setUp(() async {
      // Mocking storage
      await Hive.initFlutter();
      await Hive.deleteBoxFromDisk('daily_records');
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    });

    testWidgets('Navigate to Azkar and see categories', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Ensure we are on Home Screen first
      expect(find.text('Prayer'), findsOneWidget);

      // Tap Azkar tab
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();

      // Check for Azkar Categories Title (in Arabic as it's the title)
      expect(find.text('الأذكار'), findsOneWidget);

      // Check if categories are loaded (at least one should be there)
      // Since it's from a file, we might need a small delay if it's not immediate
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify some categories exist. Typical Hisn Al-Muslim has 'أذكار الصباح'
      // We'll search for any Card in the list
      expect(find.byType(Card), findsAtLeast(1));
      
      // Tap the first category
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // Verify Azkar items are shown
      expect(find.textContaining('/'), findsAtLeast(1)); // The counter text like '0 / 3'
    });
  });
}
