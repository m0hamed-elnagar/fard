import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/quran/presentation/pages/scanned_mushaf_reader_page.dart';
import 'package:fard/features/quran/presentation/widgets/scanned/mushaf_page_item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Scanned Mushaf Reader Integration Test', () {
    testWidgets(
      'Verify ScannedMushafReaderPage renders images and handles navigation',
      (tester) async {
        final tempDir = Directory.systemTemp.createTempSync(
          'fard_scanned_test_',
        );
        await configureDependencies(hivePath: tempDir.path);

        final prefs = getIt<SharedPreferences>();
        await prefs.setBool('onboarding_complete', true);

        // Start the app
        await tester.pumpWidget(const QadaTrackerApp());
        await tester.pump(const Duration(seconds: 2));

        // 1. Navigate to Quran
        final quranIcon = find.byIcon(Icons.menu_book_outlined);
        await tester.tap(quranIcon.first);
        await tester.pump(const Duration(seconds: 2));

        // 2. Tap on Scanned Mushaf icon in AppBar
        final scannedIcon = find.byIcon(Icons.photo_library_outlined);
        await tester.tap(scannedIcon);
        await tester.pump(const Duration(seconds: 2));

        // 3. Verify ScannedMushafReaderPage is showing
        expect(find.byType(ScannedMushafReaderPage), findsOneWidget);

        // 4. Verify MushafPageItem is rendered (refactored widget)
        expect(find.byType(MushafPageItem), findsWidgets);

        // 5. Verify image is there
        expect(find.byType(Image), findsWidgets);

        // Clean up
        try {
          if (tempDir.existsSync()) {
            tempDir.deleteSync(recursive: true);
          }
        } catch (_) {}
      },
    );
  });
}
