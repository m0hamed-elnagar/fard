import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Azkar Integration Test', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fard_azkar_test_');
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    });

    testWidgets('Repeat Azkar Sequence: Choose, Count, Back (2 times)', (tester) async {
      await tester.pumpWidget(app.QadaTrackerApp(hivePath: tempDir.path));
      await tester.pumpAndSettle();

      // Wait for splash
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Tap Azkar tab
      final azkarTab = find.text('الأذكار').last; 
      await tester.tap(azkarTab);
      await tester.pumpAndSettle();

      // Wait for data load
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Repeat sequence 2 times
      for (int i = 0; i < 2; i++) {
        // Verify categories exist
        expect(find.byType(ListTile), findsAtLeast(i + 1));
        
        // Tap category (i-th category)
        await tester.tap(find.byType(ListTile).at(i));
        await tester.pumpAndSettle();

        // Verify items exist
        expect(find.textContaining('/'), findsAtLeast(1));

        // Tap the first zekr card to increment
        final zekrCard = find.byType(GestureDetector).at(1); // The first zekr card uses GestureDetector
        await tester.tap(zekrCard);
        await tester.pumpAndSettle();

        // Go back to categories
        await tester.tap(find.byIcon(Icons.arrow_back)); 
        await tester.pumpAndSettle();

        // Should be back at categories
        expect(find.text('الأذكار'), findsAtLeast(1));
      }
    });
  });
}
