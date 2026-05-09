import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart' as app;
import 'package:fard/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/features/tasbih/presentation/pages/tasbih_page.dart';
import 'package:fard/features/tasbih/presentation/widgets/tasbih_widgets.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tasbih Integration Test', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fard_tasbih_test_');
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      await configureDependencies(hivePath: tempDir.path);

      if (Hive.isBoxOpen('daily_records')) {
        await Hive.box<DailyRecordEntity>('daily_records').clear();
      }
    });

    tearDown(() async {
      await Hive.close();
      await getIt.reset();
    });

    testWidgets('Tasbih Auto-scroll and Manual Navigation', (tester) async {
      await tester.pumpWidget(app.QadaTrackerApp(hivePath: tempDir.path));
      await tester.pumpAndSettle();

      // Tap Tasbih tab (index 3 in NavigationBar)
      final tasbihTabIcon = find.byIcon(Icons.touch_app_outlined);
      await tester.tap(tasbihTabIcon);
      await tester.pumpAndSettle();

      // Ensure we are on TasbihPage
      expect(find.byType(TasbihPage), findsOneWidget);

      // Verify initial item (SubhanAllah)
      expect(find.text('سُبْحَانَ ٱللَّٰهِ'), findsOneWidget);

      // Verify manual navigation via arrow buttons
      final nextArrow = find.byIcon(Icons.arrow_forward_ios_rounded);
      expect(nextArrow, findsOneWidget);
      await tester.tap(nextArrow);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Should be on next item (Alhamdulillah)
      expect(find.text('ٱلْحَمْدُ لِلَّٰهِ'), findsOneWidget);

      final prevArrow = find.byIcon(Icons.arrow_back_ios_rounded);
      expect(prevArrow, findsOneWidget);
      await tester.tap(prevArrow);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Back to SubhanAllah
      expect(find.text('سُبْحَانَ ٱللَّٰهِ'), findsOneWidget);

      // Test Auto-scroll (Rotating Mode - Tasbih after Salah)
      // We need to complete 33 counts to trigger auto-scroll.
      // For testing, let's find the Tap button
      final tapButton = find.byType(TasbihButton);
      expect(tapButton, findsOneWidget);

      // Rapid tap 33 times
      for (int i = 0; i < 33; i++) {
        await tester.tap(tapButton);
        await tester.pump(const Duration(milliseconds: 50));
      }
      
      // Wait for auto-scroll animation
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Should have auto-scrolled to Alhamdulillah
      expect(find.text('ٱلْحَمْدُ لِلَّٰهِ'), findsOneWidget);
    });

    testWidgets('Tasbih Progress Memory across items', (tester) async {
      await tester.pumpWidget(app.QadaTrackerApp(hivePath: tempDir.path));
      await tester.pumpAndSettle();

      // Tap Tasbih tab
      await tester.tap(find.byIcon(Icons.touch_app_outlined));
      await tester.pumpAndSettle();

      // We should be on index 0 (SubhanAllah)
      expect(find.text('سُبْحَانَ ٱللَّٰهِ'), findsOneWidget);

      final tapButton = find.byType(TasbihButton);
      
      // Tap 5 times on index 0
      for (int i = 0; i < 5; i++) {
        await tester.tap(tapButton);
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('5'), findsOneWidget);

      // Navigate to index 1 (Alhamdulillah) using the arrow
      await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Should be on index 1 with 0 count
      expect(find.text('ٱلْحَمْدُ لِلَّٰهِ'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      // Tap 10 times on index 1
      for (int i = 0; i < 10; i++) {
        await tester.tap(tapButton);
        await tester.pump(const Duration(milliseconds: 50));
      }
      expect(find.text('10'), findsOneWidget);

      // Navigate back to index 0 (SubhanAllah) using the arrow
      await tester.tap(find.byIcon(Icons.arrow_back_ios_rounded));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Should REMEMBER 5 for index 0!
      expect(find.text('سُبْحَانَ ٱللَّٰهِ'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      // Navigate to index 1 again
      await tester.tap(find.byIcon(Icons.arrow_forward_ios_rounded));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Should REMEMBER 10 for index 1!
      expect(find.text('10'), findsOneWidget);
    });
  });
}
