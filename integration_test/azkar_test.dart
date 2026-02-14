import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_categories_screen.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_list_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Azkar Integration Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fard_azkar_test_');
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
    });

    testWidgets('Full Azkar Workflow: Browse, Interaction, and Stability', (tester) async {
      await tester.pumpWidget(app.QadaTrackerApp(hivePath: tempDir.path));
      await tester.pump();
      
      // Manual settle: Wait for initialization/splash
      debugPrint('Waiting for app initialization...');
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byIcon(Icons.menu_book_outlined).evaluate().isNotEmpty) break;
      }

      // 1. Navigate to Azkar Tab
      debugPrint('Navigating to Azkar Tab');
      final azkarTabIcon = find.byIcon(Icons.menu_book_outlined);
      expect(azkarTabIcon, findsOneWidget);
      await tester.tap(azkarTabIcon);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // 2. Verify Categories Load
      debugPrint('Checking Categories Screen');
      expect(find.byType(AzkarCategoriesScreen), findsOneWidget);
      
      // Wait for categories (avoid pumpAndSettle because of loading spinner)
      bool foundCategories = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byType(ListTile).evaluate().isNotEmpty) {
          foundCategories = true;
          break;
        }
      }
      expect(foundCategories, isTrue, reason: 'Categories should appear after loading');

      final categoryList = find.byType(ListTile);
      final categoryTitle = ((tester.widget(categoryList.first) as ListTile).title as Text).data;

      // 3. Enter first category
      debugPrint('Entering category: $categoryTitle');
      await tester.tap(categoryList.first);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // 4. Verify Azkar List Loads
      debugPrint('Checking Azkar List Screen');
      expect(find.byType(AzkarListScreen), findsOneWidget);
      
      // Wait for items
      bool foundCards = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byType(Card).evaluate().isNotEmpty) {
          foundCards = true;
          break;
        }
      }
      expect(foundCards, isTrue);

      // 5. Test Counter Increment
      debugPrint('Testing Counter Increment');
      final initialCountFinder = find.textContaining(' / ');
      expect(initialCountFinder, findsAtLeast(1));
      final String? initialText = (tester.widget(initialCountFinder.first) as Text).data;

      await tester.tap(find.byType(Card).first);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();

      final String? afterText = (tester.widget(initialCountFinder.first) as Text).data;
      expect(afterText, isNot(initialText));

      // 6. Test Individual Reset
      debugPrint('Testing Individual Reset');
      final itemResetButton = find.byTooltip('Reset Item');
      expect(itemResetButton, findsWidgets);
      await tester.tap(itemResetButton.first);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump();
      
      final resetItemText = (tester.widget(initialCountFinder.first) as Text).data;
      expect(resetItemText!.startsWith('0 /'), isTrue);

      // 7. Test Reset All (The button in the list)
      debugPrint('Testing Reset All Progress');
      final resetAllButton = find.text('Reset All Progress');
      expect(resetAllButton, findsOneWidget);
      
      // Increment something first
      await tester.tap(find.byType(Card).first);
      await tester.pump();
      
      await tester.tap(resetAllButton);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // Wait for reset completion
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 200));
        final resetText = (tester.widget(find.textContaining(' / ').first) as Text).data;
        if (resetText!.startsWith('0 /')) break;
      }
      
      final finalResetText = (tester.widget(find.textContaining(' / ').first) as Text).data;
      expect(finalResetText!.startsWith('0 /'), isTrue);

      // 8. Navigate Back
      debugPrint('Testing Back Navigation');
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
      } else {
        await tester.pageBack();
      }
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();

      // 9. Verify Categories Still Visible
      expect(find.byType(AzkarCategoriesScreen), findsOneWidget);
      expect(find.byType(ListTile), findsAtLeast(1));

      debugPrint('Integrated Azkar test passed successfully!');
    });
  });
}
