import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart' as app;
import 'package:fard/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_categories_screen.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_list_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Azkar Integration Test', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fard_azkar_test_');
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
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

    testWidgets('Repeat Azkar Sequence: Choose, Count, Back (2 times)', (tester) async {
      await tester.pumpWidget(app.QadaTrackerApp(hivePath: tempDir.path));
      await tester.pumpAndSettle();

      // Tap Azkar tab using Icon (index 1 in NavigationBar)
      final azkarTabIcon = find.byIcon(Icons.menu_book_outlined);
      await tester.tap(azkarTabIcon);
      await tester.pumpAndSettle();

      // Repeat sequence 2 times
      for (int i = 0; i < 2; i++) {
        debugPrint('--- SEQUENCE REPETITION ${i+1} ---');
        
        // Ensure we are on AzkarCategoriesScreen
        expect(find.byType(AzkarCategoriesScreen), findsOneWidget);

        final BuildContext categoriesContext = tester.element(find.byType(AzkarCategoriesScreen));
        if (categoriesContext.mounted) {
          categoriesContext.read<AzkarBloc>().add(const AzkarEvent.loadCategories());
        }
        await tester.pumpAndSettle();

        // Wait for categories to load
        for (int wait = 0; wait < 5; wait++) {
          if (find.descendant(of: find.byType(AzkarCategoriesScreen), matching: find.byType(ListTile)).evaluate().isNotEmpty) break;
          await tester.pump(const Duration(seconds: 1));
        }

        final categoryItems = find.descendant(
          of: find.byType(AzkarCategoriesScreen),
          matching: find.byType(ListTile),
        );

        expect(categoryItems, findsAtLeast(i + 1));
        
        // Tap the i-th category
        await tester.tap(categoryItems.at(i));
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1)); // Wait for navigation

        // Verify we are on AzkarListScreen
        expect(find.byType(AzkarListScreen), findsOneWidget);

        // In new UI, we have one item at a time.
        // Look for the large counter button (Circle)
        final counterButton = find.descendant(
          of: find.byType(AzkarListScreen),
          matching: find.byType(GestureDetector),
        ).first;
        
        expect(counterButton, findsOneWidget);
        
        // Tap to increment
        await tester.tap(counterButton);
        await tester.pumpAndSettle();

        // Go back to categories
        await tester.tap(find.byIcon(Icons.arrow_back)); 
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
      }
    });
  });
}
