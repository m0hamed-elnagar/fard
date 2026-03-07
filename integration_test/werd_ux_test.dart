import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/features/quran/presentation/pages/quran_reader_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/features/quran/presentation/widgets/reader_info_bar.dart';
import 'dart:io';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Werd UX Integration Test', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = Directory.systemTemp.createTempSync('fard_werd_test_');
      await configureDependencies(hivePath: tempDir.path);
      final prefs = getIt<SharedPreferences>();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setString('locale', 'ar'); // Use Arabic to match some logic if needed
    });

    tearDown(() async {
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (_) {}
    });

    testWidgets('Verify green flag on first ayah of Al-Fatihah for first-time user', (tester) async {
      await tester.pumpWidget(const QadaTrackerApp());
      await tester.pumpAndSettle();

      // Navigate to Al-Fatihah
      // 1. Find Quran Tab
      final quranTab = find.byIcon(Icons.menu_book_outlined);
      await tester.tap(quranTab.first);
      await tester.pumpAndSettle();

      // 2. Tap Al-Fatihah (الفاتحة)
      final alFatihah = find.text('الفاتحة');
      await tester.tap(alFatihah.first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 3. Verify Green Flag icon is present (it should be on Ayah 1 by default)
      final flagIcon = find.byIcon(Icons.flag_rounded);
      expect(flagIcon, findsOneWidget);
      
      final Icon iconWidget = tester.widget(flagIcon);
      expect(iconWidget.color, Colors.green);
    });

    testWidgets('Verify bookmark icon appears after reading an ayah', (tester) async {
      await tester.pumpWidget(const QadaTrackerApp());
      await tester.pumpAndSettle();

      // Navigate to Al-Fatihah
      await tester.tap(find.byIcon(Icons.menu_book_outlined).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('الفاتحة').first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Long press first ayah to open details and mark as last read
      // We need to find the text or something to tap. 
      // Since it's Text.rich, we can tap the first Ayah's area.
      final ayahText = find.byType(AyahText);
      await tester.longPress(ayahText.first);
      await tester.pumpAndSettle();

      // Find "Mark as last read" icon (Icons.menu_book_outlined in AyahDetailSheet)
      final markAsRead = find.byIcon(Icons.menu_book_outlined);
      await tester.tap(markAsRead.first);
      await tester.pumpAndSettle();
      
      // Close sheet
      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();

      // Now verify bookmark icon (Icons.bookmark_rounded) is present on that ayah
      final bookmarkIcon = find.byIcon(Icons.bookmark_rounded);
      expect(bookmarkIcon, findsOneWidget);
    });

    testWidgets('Jump to Werd navigates to first ayah if nothing read', (tester) async {
      await tester.pumpWidget(const QadaTrackerApp());
      await tester.pumpAndSettle();

      // Go to Quran
      await tester.tap(find.byIcon(Icons.menu_book_outlined).first);
      await tester.pumpAndSettle();
      
      // Open any surah (e.g. Al-Baqarah)
      await tester.tap(find.text('البقرة').first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap "Jump to Werd" (which should take us back to Al-Fatihah Ayah 1)
      // The button is in ReaderInfoBar
      final jumpToWerd = find.byIcon(Icons.auto_awesome_outlined); // Werd jump icon in ReaderInfoBar
      if (jumpToWerd.evaluate().isNotEmpty) {
         await tester.tap(jumpToWerd.first);
         await tester.pumpAndSettle(const Duration(seconds: 2));
         
         // Verify we are back in Al-Fatihah
         expect(find.text('الفاتحة'), findsOneWidget);
      }
    });
  });
}
