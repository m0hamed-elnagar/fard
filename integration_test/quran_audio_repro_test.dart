import 'dart:io';

import 'package:fard/features/audio/presentation/widgets/audio_player_bar.dart';
import 'package:fard/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/missed_days_dialog.dart';
import 'package:fard/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Quran Audio Feature Test', () {
    testWidgets('Verify Audio Playback and UI Interaction', (tester) async {
      debugPrint('DEBUG: Setting up isolated test environment');
      
      // Ensure we start fresh
      await GetIt.instance.reset();
      
      // Create a temporary directory for Hive to avoid lock issues
      final tempDir = await Directory.systemTemp.createTemp('fard_test_');
      debugPrint('DEBUG: Using temp Hive path: ${tempDir.path}');

      // Note: We can't call app.main() directly because it doesn't accept hivePath.
      // But we can call configureDependencies(hivePath: ...) and then runApp.
      // However, app.main() does other things like QuranLibrary.init().
      
      // Let's try to run the app normally but hope the lock is released or 
      // use a hack to clear the lock if we can.
      // Actually, since we are on Windows, the lock is very strict.
      
      // I'll try to just run it and see.
      app.main();
      await tester.pumpAndSettle();
      
      debugPrint('DEBUG: Waiting for splash');
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      debugPrint('DEBUG: Checking for Onboarding');
      final onboardingFinder = find.byType(OnboardingScreen);
      if (tester.any(onboardingFinder)) {
        debugPrint('DEBUG: Skipping Onboarding');
        final skipOnboarding = find.textContaining('Skip');
        if (tester.any(skipOnboarding)) {
          await tester.tap(skipOnboarding.first);
          await tester.pumpAndSettle();
        }
      }

      debugPrint('DEBUG: Checking for MissedDaysDialog');
      final missedDaysDialog = find.byType(MissedDaysDialog);
      if (tester.any(missedDaysDialog)) {
        debugPrint('DEBUG: Dismissing MissedDaysDialog');
        final skipButton = find.descendant(
          of: missedDaysDialog,
          matching: find.textContaining('Skip'),
        );
        if (tester.any(skipButton)) {
          await tester.tap(skipButton.first);
        } else {
          final addAllButton = find.textContaining('Add All');
          if (tester.any(addAllButton)) {
             await tester.tap(addAllButton.first);
          }
        }
        await tester.pumpAndSettle();
      }

      debugPrint('DEBUG: Navigating to Quran Tab');
      final quranTab = find.byIcon(Icons.menu_book_outlined);
      if (tester.any(quranTab)) {
        await tester.tap(quranTab.first);
        await tester.pumpAndSettle();
      } else {
        debugPrint('DEBUG: Falling back to Quran Tooltip');
        final quranTooltip = find.byTooltip('القرآن');
        if (tester.any(quranTooltip)) {
           await tester.tap(quranTooltip.first);
           await tester.pumpAndSettle();
        }
      }

      debugPrint('DEBUG: Selecting Surah');
      // Wait for list to load
      bool listFound = false;
      for (int i = 0; i < 20; i++) {
        if (tester.any(find.byType(CircularProgressIndicator))) {
          debugPrint('DEBUG: Still loading surahs...');
        }
        
        // Check for error state and retry
        final retryButton = find.byIcon(Icons.refresh);
        if (tester.any(retryButton)) {
           debugPrint('DEBUG: Error loading Surahs. Retrying...');
           await tester.tap(retryButton.first);
           await tester.pumpAndSettle();
        }

        if (tester.any(find.byType(ListTile))) {
          listFound = true;
          break;
        }
        await tester.pump(const Duration(milliseconds: 500));
      }
      
      final surahTile = find.byType(ListTile);
      if (!listFound) {
        debugPrint('DEBUG: Surah list NOT found. Dumping widget tree (partial)...');
        // debugDumpApp(); // Too large for logs usually, skipping
      }
      expect(surahTile, findsWidgets, reason: "Surah list should be visible");
      await tester.tap(surahTile.first);
      await tester.pumpAndSettle();

      debugPrint('DEBUG: Starting Playback');
      final playSurahButton = find.textContaining('تشغيل السورة');
      if (tester.any(playSurahButton)) {
        await tester.tap(playSurahButton.first);
        await tester.pumpAndSettle();
      }

      debugPrint('DEBUG: Verifying Player Bar Visibility');
      // The bar might take a frame to appear due to Bloc state change
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(AudioPlayerBar), findsOneWidget);
      
      debugPrint('DEBUG: Waiting for Audio to start (Pause icon)');
      bool isPlaying = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (tester.any(find.byIcon(Icons.pause_rounded))) {
          isPlaying = true;
          debugPrint('DEBUG: Audio is playing!');
          break;
        }
      }
      
      expect(isPlaying, isTrue, reason: "Playback did not start (Pause icon not found)");

      debugPrint('DEBUG: Verifying Hide Button Visibility');
      final hideButton = find.byIcon(Icons.close_rounded);
      expect(hideButton, findsOneWidget, reason: "Hide button should be visible directly on the player bar");
      
      debugPrint('DEBUG: Clicking Hide Button');
      await tester.tap(hideButton);
      await tester.pumpAndSettle();
      
      debugPrint('DEBUG: Verifying Player Bar Hidden');
      expect(find.byType(AudioPlayerBar), findsNothing, reason: "Player bar should be hidden after clicking close");

      // print('DEBUG: Navigating back to check persistence');
      // await tester.pageBack();
      // await tester.pumpAndSettle();
      
      // expect(find.byType(AudioPlayerBar), findsOneWidget);
      debugPrint('DEBUG: Integration test passed!');
      
      // Cleanup
      await tempDir.delete(recursive: true);
    });
  });
}
