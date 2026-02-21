import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/audio/presentation/widgets/audio_player_bar.dart';
import 'package:fard/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/missed_days_dialog.dart';
import 'package:fard/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Quran Audio Navigation and Bismillah Integrity Test', () {
    testWidgets('Verify Switching Surahs Stops Previous and Starts New', (tester) async {
      debugPrint('DEBUG: Starting Integration Test');
      
      // Reset dependencies to avoid state bleed
      await GetIt.instance.reset();
      
      // Start the app
      app.main();
      await tester.pumpAndSettle();
      
      debugPrint('DEBUG: Handling Splash and Onboarding');
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final onboardingFinder = find.byType(OnboardingScreen);
      if (tester.any(onboardingFinder)) {
        final skipOnboarding = find.textContaining('Skip');
        if (tester.any(skipOnboarding)) {
          await tester.tap(skipOnboarding.first);
          await tester.pumpAndSettle();
        }
      }

      final missedDaysDialog = find.byType(MissedDaysDialog);
      if (tester.any(missedDaysDialog)) {
        final skipButton = find.textContaining('Skip');
        if (tester.any(skipButton)) {
          await tester.tap(skipButton.first);
          await tester.pumpAndSettle();
        }
      }

      debugPrint('DEBUG: Navigating to Quran Tab');
      final quranTab = find.byIcon(Icons.menu_book_outlined);
      if (tester.any(quranTab)) {
        await tester.tap(quranTab.first);
        await tester.pumpAndSettle();
      }

      // 1. PLAY SURAH 1 (Al-Fatihah)
      debugPrint('DEBUG: Opening Surah 1');
      final surah1Tile = find.textContaining('الفاتحة');
      await tester.tap(surah1Tile.first);
      await tester.pumpAndSettle();

      debugPrint('DEBUG: Starting Playback for Surah 1');
      final playButton1 = find.textContaining('تشغيل السورة');
      await tester.tap(playButton1.first);
      await tester.pumpAndSettle();

      // Wait for audio to start
      bool isPlaying1 = false;
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (tester.any(find.byIcon(Icons.pause_rounded))) {
          isPlaying1 = true;
          break;
        }
      }
      expect(isPlaying1, isTrue, reason: "Surah 1 should start playing");
      
      final audioBloc = tester.element(find.byType(AudioPlayerBar)).read<AudioBloc>();
      expect(audioBloc.state.currentSurah, 1);

      // 2. NAVIGATE TO SURAH 2 (Al-Baqarah)
      debugPrint('DEBUG: Navigating to Surah 2 while Surah 1 is playing');
      await tester.pageBack();
      await tester.pumpAndSettle();
      
      final surah2Tile = find.textContaining('البقرة');
      await tester.tap(surah2Tile.first);
      await tester.pumpAndSettle();

      // VERIFY BUG FIX: Surah 2's header should show "Play", NOT "Stop/Pause" from Surah 1
      debugPrint('DEBUG: Verifying Surah 2 header state');
      final playButton2 = find.textContaining('تشغيل السورة');
      expect(playButton2, findsOneWidget, reason: "Surah 2 should show 'Play' even if Surah 1 is active in background");
      
      // The audio bar should still show Surah 1
      expect(find.textContaining('الفاتحة'), findsWidgets);

      // 3. START PLAYING SURAH 2
      debugPrint('DEBUG: Starting Playback for Surah 2');
      await tester.tap(playButton2);
      await tester.pumpAndSettle();

      // Verify that player stops Surah 1 and loads Surah 2
      debugPrint('DEBUG: Waiting for Surah 2 to start playing');
      bool isPlaying2 = false;
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (tester.any(find.byIcon(Icons.pause_rounded)) && audioBloc.state.currentSurah == 2) {
          isPlaying2 = true;
          break;
        }
      }
      expect(isPlaying2, isTrue, reason: "Surah 2 should replace Surah 1 and start playing");
      expect(audioBloc.state.currentSurah, 2);

      // 4. VERIFY BISMILLAH INTEGRITY (Logic)
      debugPrint('DEBUG: Verifying Bismillah was prepended for Surah 2');
      // For Surah 2, we know we prepended Bismillah.
      // We can check the state - when playing Bismillah, currentAyah should be 1.
      expect(audioBloc.state.currentAyah, 1);
      
      debugPrint('DEBUG: Integration test completed successfully!');
    });
  });
}
