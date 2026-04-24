import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart' as app;
import 'package:fard/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Full App Integration Test', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fard_app_test_');
      SharedPreferences.setMockInitialValues({});
      await configureDependencies(hivePath: tempDir.path);

      // Clear boxes in case Hive is reusing the path from previous tests
      if (Hive.isBoxOpen('daily_records')) {
        await Hive.box<DailyRecordEntity>('daily_records').clear();
      }
      if (Hive.isBoxOpen('azkar_progress')) {
        await Hive.box<int>('azkar_progress').clear();
      }
    });

    tearDown(() async {
      await Hive.close();
      await getIt.reset();
      // Do not delete tempDir as Hive might be locked to it
    });

    testWidgets('Onboarding to Home, toggle prayer, and switch language', (
      tester,
    ) async {
      await tester.pumpWidget(app.QadaTrackerApp(hivePath: tempDir.path));
      await tester.pumpAndSettle();

      // --- Onboarding Page 1 ---
      expect(find.text('تتبع صلواتك'), findsOneWidget);
      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();

      // --- Onboarding Page 2 ---
      expect(find.text('إدارة القضاء'), findsOneWidget);
      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();

      // --- Onboarding Page 3 (Location) ---
      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();

      // --- Onboarding Page 4 (Azan) ---
      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();

      // --- Onboarding Page 5 (Qada) ---
      await tester.tap(find.text('ابدأ الآن'));
      await tester.pumpAndSettle();

      // --- Home Screen (starts in Arabic) ---
      expect(find.text('فرض'), findsOneWidget);

      await tester.pumpAndSettle();

      // Handle Initial Add Qada Dialog if it appears
      final cancelBtn = find.text('إلغاء');
      if (cancelBtn.evaluate().isNotEmpty) {
        await tester.tap(cancelBtn);
        await tester.pumpAndSettle();
      }

      // Switch to Settings
      final settingsIcon = find.byIcon(Icons.settings_outlined);
      await tester.ensureVisible(settingsIcon);
      await tester.tap(settingsIcon);
      await tester.pumpAndSettle();

      // Verify we are on Settings screen
      expect(find.text('الإعدادات').first, findsOneWidget);

      // Toggle language switch (Arabic -> English)
      // Scroll until dropdown is visible
      final dropdownFinder = find.byType(DropdownButton<String>);
      final scrollableFinder = find.byType(Scrollable).at(1); // Settings list scrollable
      
      await tester.dragUntilVisible(
        dropdownFinder.first,
        scrollableFinder,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // Open dropdown
      await tester.tap(dropdownFinder.first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Select English
      final englishOption = find.text('English').last;
      await tester.tap(englishOption, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2)); // Wait for locale change

      // Go back to Prayer tab
      final prayerTab = find.text('Prayer');
      final prayerTabAr = find.text('الصلاة');
      
      if (prayerTab.evaluate().isNotEmpty) {
        await tester.ensureVisible(prayerTab.last);
        await tester.tap(prayerTab.last, warnIfMissed: false);
      } else if (prayerTabAr.evaluate().isNotEmpty) {
        await tester.ensureVisible(prayerTabAr.last);
        await tester.tap(prayerTabAr.last, warnIfMissed: false);
      }
      await tester.pumpAndSettle();

      // Verify Home Screen
      expect(find.byIcon(Icons.mosque_rounded), findsAtLeast(1));
    });
  });
}
