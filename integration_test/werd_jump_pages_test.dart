import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart';
import 'package:fard/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Werd Jump Pages Integration Test', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('fard_werd_jump_test_');
      await getIt.reset();
      await configureDependencies(hivePath: tempDir.path);
      final prefs = getIt<SharedPreferences>();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setString('locale', 'ar'); // Arabic
      await prefs.setString('werd_progress_default', 
        '{"goalId":"default","totalAmountReadToday":0,"readItemsToday":[],"lastUpdated":"2026-03-09T12:00:00.000","streak":0,"sessionStartAbsolute":1}');
    });

    tearDown(() async {
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (_) {}
    });

    testWidgets('Verify jump dialog shows correct page count in Arabic', (tester) async {
      await tester.pumpWidget(const QadaTrackerApp());
      await tester.pumpAndSettle();

      getIt<GlobalKey<NavigatorState>>().currentState?.push(
        QuranReaderPage.route(surahNumber: 2, ayahNumber: 1), 
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final marker60 = find.textContaining('٦٠'); 
      
      bool found = false;
      for (int i = 0; i < 40; i++) {
        if (marker60.evaluate().isNotEmpty) {
           try {
             await tester.ensureVisible(marker60.first);
             await tester.pumpAndSettle();
             found = true;
             break;
           } catch (e) {
             // Ignore if not found yet
           }
        }
        await tester.drag(find.byType(ListView), const Offset(0, -700));
        await tester.pumpAndSettle();
      }
      
      expect(found, true);

      await tester.longPress(marker60.first);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final markAsRead = find.byIcon(Icons.menu_book_outlined);
      await tester.tap(markAsRead.first);
      await tester.pumpAndSettle();

      expect(find.text('قفزة كبيرة'), findsOneWidget);
      
      // We expect the message to contain "٨" (Arabic 8) now.
      // Search only in the dialog to avoid matching Quran text
      final dialog = find.byType(AlertDialog);
      expect(find.descendant(of: dialog, matching: find.textContaining('٨')), findsOneWidget);
    });
  });
}
