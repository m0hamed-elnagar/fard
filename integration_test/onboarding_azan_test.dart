import 'dart:io';

import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/core/widgets/custom_toggle.dart';
import 'package:fard/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/presentation/blocs/theme_state.dart';
import 'package:fard/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockVoiceDownloadService extends Mock implements VoiceDownloadService {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(const ThemeSt~ate(locale: Locale('ar')));
  });

  group('Onboarding Azan Integration Test', () {
    late MockVoiceDownloadService mockVoiceService;
    late MockNotificationService mockNotificationService;
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('onboarding_test_');
      mockVoiceService = MockVoiceDownloadService();
      mockNotificationService = MockNotificationService();

      // Setup default mock behaviors
      when(
        () => mockVoiceService.downloadAzan(any()),
      ).thenAnswer((_) async => '/mock/path/azan.mp3');
      when(
        () => mockNotificationService.canScheduleExactNotifications(),
      ).thenAnswer((_) async => true);
      when(
        () => mockNotificationService.testAzan(any(), any()),
      ).thenAnswer((_) async {});
      when(() => mockNotificationService.init()).thenAnswer((_) async {});

      SharedPreferences.setMockInitialValues({'onboarding_complete': false});

      // We need to configure dependencies but replace the services we want to mock
      await configureDependencies(hivePath: tempDir.path);

      // Unregister and re-register mocks
      getIt.unregister<VoiceDownloadService>();
      getIt.unregister<NotificationService>();
      getIt.registerSingleton<VoiceDownloadService>(mockVoiceService);
      getIt.registerSingleton<NotificationService>(mockNotificationService);
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets('Verify 5-page onboarding flow including Azan selection', (
      tester,
    ) async {
      await tester.pumpWidget(app.QadaTrackerApp(hivePath: tempDir.path));
      await tester.pumpAndSettle();

      final l10n = AppLocalizations.of(
        tester.element(find.byType(OnboardingScreen)),
      )!;

      // 1. First Page (Track Your Prayers)
      expect(find.text(l10n.onboardingTitle1), findsOneWidget);
      await tester.tap(find.text(l10n.next));
      await tester.pumpAndSettle();

      // 2. Second Page (Manage Qada)
      expect(find.text(l10n.onboardingTitle2), findsOneWidget);
      await tester.tap(find.text(l10n.next));
      await tester.pumpAndSettle();

      // 3. Third Page (Location & Prayer Settings)
      expect(find.text(l10n.prayerSettings), findsOneWidget);
      expect(find.text(l10n.madhab), findsOneWidget);
      await tester.tap(find.text(l10n.next));
      await tester.pumpAndSettle();

      // 4. Fourth Page (Azan Settings)
      expect(find.text(l10n.azanSettings), findsOneWidget);
      expect(find.text(l10n.enableAzan), findsOneWidget);

      // Default should be enabled and show "Phone Notification"
      expect(find.text(l10n.defaultVal), findsAtLeast(1));

      // Change Voice
      // We search for the dropdown that contains our default text
      final dropdownFinder = find.byWidgetPredicate(
        (widget) => widget is DropdownButton<String>,
      );

      await tester.tap(dropdownFinder);
      await tester.pumpAndSettle();

      // Select Al-Minshawi from the overlay
      const voiceName = 'Muhammad Siddiq Al-Minshawi - محمد صديق المنشاوي';
      final itemFinder = find.text(voiceName).last;
      await tester.tap(itemFinder);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      verify(() => mockVoiceService.downloadAzan(voiceName)).called(1);

      // Test Azan button
      await tester.tap(find.text(l10n.testAzan));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      verify(
        () => mockNotificationService.testAzan(Salaah.fajr, any()),
      ).called(1);

      // NOW test the toggle (it will hide everything)
      await tester.tap(find.byType(CustomToggle).first);
      await tester.pumpAndSettle();

      // Verify dropdown is gone
      expect(dropdownFinder, findsNothing);

      // Toggle it back on for completeness
      await tester.tap(find.byType(CustomToggle).first);
      await tester.pumpAndSettle();
      expect(dropdownFinder, findsOneWidget);

      await tester.tap(find.text(l10n.next));
      await tester.pumpAndSettle();

      // 5. Fifth Page (Qada Selection)
      expect(find.text(l10n.qadaOnboardingTitle), findsOneWidget);
      expect(find.text(l10n.enableQada), findsOneWidget);

      await tester.tap(find.byType(CustomToggle).last); // Toggle Qada
      await tester.pumpAndSettle();

      await tester.tap(find.text(l10n.getStarted));
      await tester.pumpAndSettle();

      // Should be on Main Screen
      // Re-read localizations if needed, though in tests usually we can keep using l10n
      // But for the sake of removing the warning if it's there
      final finalL10n = AppLocalizations.of(
        tester.element(find.byType(app.QadaTrackerApp)),
      )!;
      expect(find.text(finalL10n.appName), findsAtLeast(1));
    });
  });
}
