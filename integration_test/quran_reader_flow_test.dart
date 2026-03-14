import 'dart:io';

import 'package:fard/core/di/injection.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_detail_sheet.dart';
import 'package:fard/features/quran/presentation/widgets/ayah_text.dart';
import 'package:fard/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    if (methodCall.method == 'init') {
      final String id = methodCall.arguments['id'];
      debugPrint('just_audio init called for ID: $id');
      
      // Setup the mock for THIS specific player channel
      final MethodChannel playerChannel = MethodChannel('com.ryanheise.just_audio.methods.$id');
      binding.defaultBinaryMessenger.setMockMethodCallHandler(playerChannel, (MethodCall playerMethodCall) async {
        switch (playerMethodCall.method) {
          case 'load':
            // When load is called, we should also trigger an event on the event channel
            // to move processingState to 'ready' (3)
            final ByteData eventData = const StandardMethodCodec().encodeSuccessEnvelope({
              'processingState': 3, // ready
              'updateTime': DateTime.now().millisecondsSinceEpoch,
              'updatePosition': 0,
              'bufferedPosition': 10000000,
              'duration': 10000000,
              'currentIndex': 0,
            });
            
            // Push to the event channel
            binding.defaultBinaryMessenger.handlePlatformMessage(
              'com.ryanheise.just_audio.events.$id',
              eventData,
              (_) {},
            );
            
            return {'duration': 10000000};
          case 'setVolume':
          case 'setAudioSource':
          case 'setAudioSources':
          case 'setAndroidAudioAttributes':
          case 'setAutomaticallyPauseOnAmbiguity':
          case 'setCanEarlyExit':
          case 'play':
          case 'pause':
          case 'stop':
          case 'setSpeed':
          case 'setLoopMode':
          case 'setShuffleMode':
          case 'setShuffleOrder':
          case 'dispose':
            return {};
          default:
            return null;
        }
      });

      // Also mock the listen calls for events and data channels to avoid MissingPluginException
      binding.defaultBinaryMessenger.setMockMessageHandler('com.ryanheise.just_audio.events.$id', (message) async {
        return const StandardMethodCodec().encodeSuccessEnvelope(null);
      });
      binding.defaultBinaryMessenger.setMockMessageHandler('com.ryanheise.just_audio.data.$id', (message) async {
        return const StandardMethodCodec().encodeSuccessEnvelope(null);
      });

      return {'id': id};
    } else if (methodCall.method == 'disposeAllPlayers') {
      return {'playerIds': []};
    }
    return null;
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
      final alFatihahFinder = find.text('الفاتحة').first;
      await tester.scrollUntilVisible(
        alFatihahFinder, 
        500, 
        scrollable: find.descendant(
          of: find.byKey(const Key('surah_list_view')), 
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(alFatihahFinder);
      await tester.pump(const Duration(seconds: 3));

      // 5. Verify AyahText loaded and long press it to open detail sheet
      debugPrint('Long pressing AyahText...');
      final ayahTextFinder = find.byType(AyahText).first;
      await tester.ensureVisible(ayahTextFinder);

      final center = tester.getCenter(ayahTextFinder);
      await tester.longPressAt(center);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // 6. Verify AyahDetailSheet is open
      expect(find.byType(AyahDetailSheet), findsOneWidget);

      // Drag the sheet up to ensure it is fully expanded and buttons are hit-testable
      debugPrint('Expanding sheet...');
      final handleFinder = find.byWidgetPredicate((w) => w is Container && w.constraints?.maxWidth == 40 && w.constraints?.maxHeight == 4);
      if (handleFinder.evaluate().isNotEmpty) {
        await tester.drag(handleFinder, const Offset(0, -400));
        await tester.pumpAndSettle();
      }
      
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
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));

      // 9. Test Audio Play Button
      debugPrint('Testing Audio Play button...');
      
      try {
        final playButtonFinder = find.descendant(
          of: find.byType(AyahDetailSheet),
          matching: find.byIcon(Icons.play_arrow_rounded),
        ).first;
        
        await tester.ensureVisible(playButtonFinder);
        await tester.tap(playButtonFinder);
        await tester.pumpAndSettle(const Duration(seconds: 2)); 

        final pauseButtonFinder = find.descendant(
          of: find.byType(AyahDetailSheet),
          matching: find.byIcon(Icons.pause_rounded),
        );
        final loadingIndicatorFinder = find.descendant(
          of: find.byType(AyahDetailSheet),
          matching: find.byType(CircularProgressIndicator),
        );
        
        expect(
          pauseButtonFinder.evaluate().isNotEmpty || loadingIndicatorFinder.evaluate().isNotEmpty, 
          isTrue, 
          reason: 'UI should react to audio play tap'
        );
      } catch (e) {
        debugPrint('Failed during Audio Play Button test: $e');
        // debugDumpApp(); // Removed to reduce output noise if not needed
        rethrow;
      }

      // 10. Close the sheet
      debugPrint('Closing sheet...');
      // Stop audio first to avoid background noise/events
      final stopButtonFinder = find.descendant(
        of: find.byType(AyahDetailSheet),
        matching: find.byIcon(Icons.stop_rounded),
      );
      if (stopButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(stopButtonFinder.first);
        await tester.pumpAndSettle();
      }

      final closeButtonFinder = find.descendant(
        of: find.byType(AyahDetailSheet),
        matching: find.byIcon(Icons.close),
      );
      
      if (closeButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(closeButtonFinder.first);
      } else {
        debugPrint('Close button not found, using pageBack() to close modal...');
        await tester.pageBack();
      }
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Verification: Sheet should be gone
      expect(find.byType(AyahDetailSheet), findsNothing);
      
      // 11. Go back to Surah list
      debugPrint('Navigating back to Surah list...');
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Verify we are back on the surah list
      expect(find.byKey(const Key('surah_list_view')), findsOneWidget);

      // 12. Verify Al-Baqarah (Big Surah) load count
      debugPrint('Verifying Al-Baqarah load count...');
      final alBaqarahFinder = find.text('البقرة').first;
      await tester.scrollUntilVisible(
        alBaqarahFinder, 
        500, 
        scrollable: find.descendant(
          of: find.byKey(const Key('surah_list_view')), 
          matching: find.byType(Scrollable),
        ).first,
      );
      await tester.tap(alBaqarahFinder);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      final ayahTexts = find.byType(AyahText);
      final count = ayahTexts.evaluate().length;
      debugPrint('Found $count AyahText blocks in Al-Baqarah');
      expect(count, greaterThan(0), reason: 'Should load Al-Baqarah ayahs');

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

