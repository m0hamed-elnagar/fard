import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App Integration Test', () {
    setUp(() async {
      await Hive.initFlutter();
      await Hive.deleteBoxFromDisk('daily_records');
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Onboarding to Home, toggle prayer, and switch language', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // --- Onboarding Page 1 (starts in Arabic by default in Cubit) ---
      expect(find.text('تتبع صلواتك'), findsOneWidget);
      await tester.tap(find.text('التالي')); 
      await tester.pumpAndSettle();

      // --- Onboarding Page 2 ---
      expect(find.text('إدارة القضاء'), findsOneWidget);
      await tester.tap(find.text('ابدأ الآن')); 
      await tester.pumpAndSettle();

      // --- Home Screen (Arabic) ---
      expect(find.text('فرض'), findsOneWidget);
      
      // Wait for BLoC to load
      await tester.pumpAndSettle();
      
      // Toggle first prayer to missed (while in Arabic)
      final toggleFinder = find.ancestor(
        of: find.byIcon(Icons.check_rounded).first,
        matching: find.byType(GestureDetector),
      );
      await tester.tap(toggleFinder);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Now should show close icon
      expect(find.byIcon(Icons.close_rounded), findsAtLeast(1));

      // Switch to English
      await tester.tap(find.byIcon(Icons.language_rounded));
      await tester.pumpAndSettle();

      // --- Home Screen (English) ---
      expect(find.text('Fard'), findsOneWidget);
      expect(find.text('Daily Prayers'), findsOneWidget);

      // Look for the badge (+1) - using textContaining to be safe
      expect(find.textContaining('+1'), findsAtLeast(1));

      // Increment Qada
      await tester.tap(find.byIcon(Icons.add_rounded).first);
      await tester.pumpAndSettle();

      // Counter should be 2 (1 from toggle, 1 from manual add)
      expect(find.textContaining('2'), findsAtLeast(1));
    });
  });
}
