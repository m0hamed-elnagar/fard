import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_number_marker.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_detail_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:io';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Mock the compass channel
  const MethodChannel compassChannel = MethodChannel('hemanthraj/flutter_compass');
  binding.defaultBinaryMessenger.setMockMethodCallHandler(compassChannel, (MethodCall methodCall) async {
    return null;
  });

  // Mock the just_audio channels
  const MethodChannel audioMethodsChannel = MethodChannel('com.ryanheise.just_audio.methods');
  binding.defaultBinaryMessenger.setMockMethodCallHandler(audioMethodsChannel, (MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'init':
        return {};
      case 'disposeAllPlayers':
        return null;
      case 'load':
        return {'duration': 10000000};
      case 'play':
        return {};
      case 'pause':
        return {};
      case 'stop':
        return {};
      case 'dispose':
        return {};
      default:
        return null;
    }
  });

  group('Quran Reader Flow Integration Test', () {
    testWidgets('Full flow: navigate to Quran, verify big surah load, tafsir and audio', (tester) async {
      // 1. Setup environment
      final tempDir = Directory.systemTemp.createTempSync('fard_test_');
      await configureDependencies(hivePath: tempDir.path);
      
      final prefs = getIt<SharedPreferences>();
      await prefs.setBool('onboarding_complete', true);
      await prefs.setString('locale', 'en'); 

      // 2. Start app
      await tester.pumpWidget(const QadaTrackerApp());
      await tester.pump(const Duration(seconds: 2));

      // 3. Navigate to Quran tab
      final quranTab = find.byTooltip('Quran');
      if (quranTab.evaluate().isEmpty) {
        final quranIcon = find.byIcon(Icons.menu_book_outlined);
        await tester.tap(quranIcon.first);
      } else {
        await tester.tap(quranTab.first);
      }
      await tester.pump(const Duration(seconds: 2));

      // 4. Verify Al-Fatihah first
      debugPrint('Testing Al-Fatihah interaction...');
      final alFatihahFinder = find.text('Al-Fatihah');
      await tester.scrollUntilVisible(alFatihahFinder, 500);
      await tester.tap(alFatihahFinder);
      await tester.pump(const Duration(seconds: 3));

      // 5. Verify AyahText loaded and tap an AyahNumberMarker
      debugPrint('Tapping AyahNumberMarker...');
      final markerFinder = find.byType(AyahNumberMarker).first;
      await tester.ensureVisible(markerFinder);
      await tester.tap(markerFinder);
      await tester.pump(const Duration(seconds: 2));

      // 6. Verify AyahDetailSheet is open
      expect(find.byType(AyahDetailSheet), findsOneWidget);
      
      // 7. Verify Tafsir Tab content
      debugPrint('Verifying Tafsir tab...');
      expect(find.text('Tafsir'), findsOneWidget);
      for(int i=0; i<10; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
      }

      // 8. Switch to Audio tab
      debugPrint('Switching to Audio tab...');
      final audioTabFinder = find.text('Audio');
      await tester.tap(audioTabFinder);
      await tester.pump(const Duration(seconds: 1));

      // 9. Test Audio Play Button
      debugPrint('Testing Audio Play button...');
      final playButtonFinder = find.byIcon(Icons.play_arrow_rounded);
      expect(playButtonFinder, findsOneWidget);
      
      await tester.tap(playButtonFinder);
      await tester.pump(const Duration(seconds: 2)); 

      final pauseButtonFinder = find.byIcon(Icons.pause_rounded);
      final loadingIndicatorFinder = find.byType(CircularProgressIndicator);
      
      expect(
        pauseButtonFinder.evaluate().isNotEmpty || loadingIndicatorFinder.evaluate().isNotEmpty, 
        isTrue, 
        reason: 'UI should react to audio play tap'
      );

      // 10. Close the sheet
      debugPrint('Closing sheet...');
      final closeButtonFinder = find.byIcon(Icons.close);
      await tester.tap(closeButtonFinder.first);
      await tester.pump(const Duration(seconds: 1));
      
      // 11. Go back to Surah list
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton.first);
      } else {
        await tester.pageBack();
      }
      await tester.pump(const Duration(seconds: 2));

      // 12. Verify Al-Baqarah (Big Surah) load count
      debugPrint('Verifying Al-Baqarah load count...');
      final alBaqarahFinder = find.text('Al-Baqarah');
      await tester.scrollUntilVisible(alBaqarahFinder, 500);
      await tester.tap(alBaqarahFinder);
      await tester.pump(const Duration(seconds: 5));

      final markers = find.byType(AyahNumberMarker);
      final markerCount = markers.evaluate().length;
      debugPrint('Found $markerCount AyahNumberMarkers in Al-Baqarah');
      expect(markerCount, greaterThan(10), reason: 'Should load many ayahs for Al-Baqarah');

      // Clean up temp dir
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (e) {
        debugPrint('Failed to delete temp dir: $e');
      }
    });
  });
}

