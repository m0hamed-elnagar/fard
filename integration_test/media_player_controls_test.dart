import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
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

  group('Media Player Background and Controls Test', () {
    testWidgets('Verify Media Player Controls and State Persistence', (
      tester,
    ) async {
      debugPrint('DEBUG: Starting Media Player Controls Test');

      // Reset dependencies to avoid state bleed
      await GetIt.instance.reset();

      // Start the app
      app.main();
      await tester.pumpAndSettle();

      debugPrint('DEBUG: Handling Splash and Onboarding');
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Skip onboarding if present
      final onboardingFinder = find.byType(OnboardingScreen);
      if (tester.any(onboardingFinder)) {
        final skipOnboarding = find.textContaining('Skip');
        if (tester.any(skipOnboarding)) {
          await tester.tap(skipOnboarding.first);
          await tester.pumpAndSettle();
        }
      }

      // Skip missed days dialog if present
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

      // Open a Surah (e.g., Al-Fatihah)
      debugPrint('DEBUG: Opening Surah 1');
      final surah1Tile = find.textContaining('الفاتحة');
      await tester.tap(surah1Tile.first);
      await tester.pumpAndSettle();

      // Start Playback
      debugPrint('DEBUG: Starting Playback');
      final playButton = find.textContaining('تشغيل السورة');
      await tester.tap(playButton.first);
      await tester.pumpAndSettle();

      // Wait for audio to start loading/playing
      debugPrint('DEBUG: Waiting for audio bar to appear');
      await tester.pump(const Duration(seconds: 2));
      expect(find.byType(AudioPlayerBar), findsOneWidget);

      final audioBloc = tester
          .element(find.byType(AudioPlayerBar))
          .read<AudioBloc>();

      // Wait for "Playing" or "Paused" status (Active)
      bool isActive = false;
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(seconds: 1));
        if (audioBloc.state.isActive) {
          isActive = true;
          break;
        }
      }
      expect(
        isActive,
        isTrue,
        reason: "Audio should be active (loading, playing, or paused)",
      );

      // If it's paused, try to play it
      if (audioBloc.state.status == AudioStatus.paused) {
        debugPrint('DEBUG: Audio started as paused, tapping Play');
        final playBtn = find.descendant(
          of: find.byType(AudioPlayerBar),
          matching: find.byIcon(Icons.play_arrow_rounded),
        );
        await tester.tap(playBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
      }

      // 1. Test PAUSE
      if (audioBloc.state.isPlaying) {
        debugPrint('DEBUG: Testing Pause');
        final pauseBtn = find.descendant(
          of: find.byType(AudioPlayerBar),
          matching: find.byIcon(Icons.pause_rounded),
        );
        await tester.tap(pauseBtn.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 1));
        expect(audioBloc.state.status, AudioStatus.paused);
      }

      // 2. Test RESUME
      debugPrint('DEBUG: Testing Resume');
      final resumeBtn = find.descendant(
        of: find.byType(AudioPlayerBar),
        matching: find.byIcon(Icons.play_arrow_rounded),
      );
      await tester.tap(resumeBtn.first);
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      // 3. Test SKIP NEXT (Next Ayah)
      debugPrint('DEBUG: Testing Skip Next');
      final initialAyah = audioBloc.state.currentAyah;
      final nextIcon = find.descendant(
        of: find.byType(AudioPlayerBar),
        matching: find.byIcon(Icons.skip_next_rounded),
      );
      if (tester.any(nextIcon)) {
        await tester.tap(nextIcon.first);
        await tester.pumpAndSettle();
        await tester.pump(
          const Duration(seconds: 3),
        ); // Wait for next track to load
        debugPrint(
          'DEBUG: Initial Ayah: $initialAyah, Current Ayah: ${audioBloc.state.currentAyah}',
        );
      }

      // 4. Test SKIP PREVIOUS (Previous Ayah)
      debugPrint('DEBUG: Testing Skip Previous');
      final prevIcon = find.descendant(
        of: find.byType(AudioPlayerBar),
        matching: find.byIcon(Icons.skip_previous_rounded),
      );
      if (tester.any(prevIcon)) {
        await tester.tap(prevIcon.first);
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 3));
        debugPrint(
          'DEBUG: Current Ayah after skip back: ${audioBloc.state.currentAyah}',
        );
      }

      // 5. Test Background Persistence (Simulated)
      debugPrint('DEBUG: Simulating Background/Foreground');
      // We can't actually background the app process in integration_test easily,
      // but we can trigger the lifecycle change event.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump(const Duration(seconds: 2));

      // Audio should still be playing in background
      expect(
        audioBloc.state.isPlaying,
        isTrue,
        reason: "Audio should continue playing when app is paused",
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.byType(AudioPlayerBar), findsOneWidget);
      expect(audioBloc.state.isPlaying, isTrue);

      debugPrint('DEBUG: Media Player Controls Test completed successfully!');
    });
  });
}
