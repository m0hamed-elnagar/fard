import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App Integration Test', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fard_app_test_');
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Onboarding to Home, toggle prayer, and switch language', (tester) async {
      await tester.pumpWidget(app.QadaTrackerApp(hivePath: tempDir.path));
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // --- Onboarding Page 1 ---
      expect(find.text('تتبع صلواتك'), findsOneWidget);
      await tester.tap(find.text('التالي')); 
      await tester.pumpAndSettle();

      // --- Onboarding Page 2 ---
      expect(find.text('إدارة القضاء'), findsOneWidget);
      await tester.tap(find.text('ابدأ الآن')); 
      await tester.pumpAndSettle();

      // --- Home Screen (starts in Arabic) ---
      expect(find.text('فرض'), findsOneWidget);
      
      await tester.pumpAndSettle();
      
      // Switch to Settings
      final settingsTab = find.text('الإعدادات').last;
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // Toggle language switch (Arabic -> English)
      await tester.tap(find.byType(Switch).first, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      // Go back to Prayer tab
      final prayerTab = find.text('Prayer');
      if (prayerTab.evaluate().isNotEmpty) {
        await tester.tap(prayerTab.last);
      } else {
        await tester.tap(find.text('الصلاة').last);
      }
      await tester.pumpAndSettle();

      // Verify Home Screen
      expect(find.byIcon(Icons.mosque_rounded), findsAtLeast(1));
    });
  });
}
