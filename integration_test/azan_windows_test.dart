import 'dart:io';

import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Azan Real Download Integration Test (Windows Simplified)', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('azan_test_');
      
      // Skip onboarding. Locale is enforced to 'ar' in SettingsRepositoryImpl.
      SharedPreferences.setMockInitialValues({
        'onboarding_complete': true,
      });

      await configureDependencies(hivePath: tempDir.path);
      
      // Initialize NotificationService for testing
      await getIt<NotificationService>().init();
    });

    tearDown(() async {
      await getIt.reset();
      if (await tempDir.exists()) {
        try {
          await tempDir.delete(recursive: true);
        } catch (_) {}
      }
    });

    testWidgets('Download Abdul Basit and test playback', (tester) async {
      // 1. Start the app
      await tester.pumpWidget(app.QadaTrackerApp(hivePath: tempDir.path));
      await tester.pumpAndSettle();

      print('App started. Navigating to Settings...');

      // 2. Navigate to Settings Tab (Icon is most reliable)
      final settingsTab = find.byIcon(Icons.settings_outlined);
      expect(settingsTab, findsOneWidget);
      await tester.tap(settingsTab);
      await tester.pumpAndSettle();

      // 3. Navigate to Azan Settings (إعدادات الأذان)
      final azanSettingsTile = find.text('إعدادات الأذان');
      expect(azanSettingsTile, findsOneWidget);
      await tester.tap(azanSettingsTile);
      await tester.pumpAndSettle();

      // 4. Find the voice dropdown
      final dropdownFinder = find.byType(DropdownButtonFormField<String?>);
      expect(dropdownFinder, findsOneWidget);

      // 5. Select Abdul Basit (عبد الباسط)
      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      const voiceDisplayName = 'عبد الباسط';
      final itemFinder = find.text(voiceDisplayName).last;
      await tester.tap(itemFinder);
      
      // 6. Wait for download
      print('Downloading $voiceDisplayName...');
      
      bool downloadSuccess = false;
      // Wait up to 60 seconds for real download
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(seconds: 1));
        
        // Check for error snackbar (حدث خطأ أثناء تحميل الأذان)
        if (find.textContaining('خطأ').evaluate().isNotEmpty) {
           fail('Azan download failed for $voiceDisplayName: Error snackbar appeared.');
        }
        
        // Check if Test Sound button (تجربة الصوت) is now enabled
        final testButtonFinder = find.byWidgetPredicate(
          (w) => w is TextButton && find.descendant(of: find.byWidget(w), matching: find.text('تجربة الصوت')).evaluate().isNotEmpty
        );
        
        if (testButtonFinder.evaluate().isNotEmpty) {
          final testButton = tester.widget<TextButton>(testButtonFinder);
          if (testButton.onPressed != null) {
            downloadSuccess = true;
            print('Download finished after $i seconds.');
            break;
          }
        }
      }
      
      if (!downloadSuccess) {
        fail('Azan download timed out for $voiceDisplayName');
      }
      
      await tester.pumpAndSettle();

      // 7. Click Test Sound
      print('Clicking Test Sound...');
      await tester.tap(find.text('تجربة الصوت'));
      await tester.pumpAndSettle();

      // 8. Verify no error snackbar
      expect(find.textContaining('خطأ'), findsNothing);
      
      // Give it a moment to "play"
      await tester.pump(const Duration(seconds: 2));
      
      print('Test completed successfully for $voiceDisplayName');
    }, timeout: const Timeout(Duration(minutes: 3)));
  });
}
