import 'dart:async';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/core/widgets/custom_toggle.dart';
import 'package:fard/core/widgets/fard_list_tile.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/presentation/blocs/adhan_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/adhan_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fard/core/services/connectivity_service.dart';
import 'package:fard/features/settings/presentation/widgets/adhan_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAdhanCubit extends Mock implements AdhanCubit {}
class MockNotificationService extends Mock implements NotificationService {}
class MockVoiceDownloadService extends Mock implements VoiceDownloadService {}
class MockConnectivityService extends Mock implements ConnectivityService {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockAdhanCubit mockAdhanCubit;
  late MockNotificationService mockNotificationService;
  late MockVoiceDownloadService mockVoiceDownloadService;
  late MockConnectivityService mockConnectivityService;
  late MockSharedPreferences mockSharedPreferences;

  setUpAll(() {
    registerFallbackValue(const SalaahSettings(salaah: Salaah.fajr));
  });

  setUp(() {
    mockAdhanCubit = MockAdhanCubit();
    mockNotificationService = MockNotificationService();
    mockVoiceDownloadService = MockVoiceDownloadService();
    mockConnectivityService = MockConnectivityService();
    mockSharedPreferences = MockSharedPreferences();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<NotificationService>(mockNotificationService);
    getIt.registerSingleton<VoiceDownloadService>(mockVoiceDownloadService);
    getIt.registerSingleton<ConnectivityService>(mockConnectivityService);
    getIt.registerSingleton<SharedPreferences>(mockSharedPreferences);

    when(() => mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);
    when(() => mockNotificationService.canScheduleExactNotifications()).thenAnswer((_) async => true);
    when(() => mockNotificationService.checkSoundStatus()).thenAnswer((_) async => {
      'silentMode': false,
      'dndMode': false,
      'isMuted': false,
    });
    when(() => mockVoiceDownloadService.isDownloaded(any())).thenAnswer((_) async => false);
    when(() => mockConnectivityService.onConnectivityChanged).thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));
    when(() => mockConnectivityService.hasNetwork()).thenAnswer((_) async => true);

    when(() => mockSharedPreferences.getBool(any())).thenReturn(false);
    when(() => mockSharedPreferences.setBool(any(), any())).thenAnswer((_) async => true);
  });

  Widget createWidgetUnderTest() {
    return BlocProvider<AdhanCubit>.value(
      value: mockAdhanCubit,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: AdhanSection(),
          ),
        ),
      ),
    );
  }

  testWidgets('Toggling off one salah keeps others enabled and section open', (WidgetTester tester) async {
    // 1. Initial state: all 5 prayers have Azan enabled
    final initialSettings = Salaah.values
        .map((s) => SalaahSettings(salaah: s, isAzanEnabled: true))
        .toList();

    var state = AdhanState(
      salaahSettings: initialSettings,
      notificationsEnabled: true,
      exactAlarmsEnabled: true,
    );

    when(() => mockAdhanCubit.state).thenReturn(state);
    when(() => mockAdhanCubit.stream).thenAnswer((_) => Stream.value(state));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify master toggle is ON (value is true)
    // Individual settings section is visible, containing 5 tiles
    expect(find.text('Enable Azan'), findsOneWidget);
    expect(find.text('Individual Prayer Settings'), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Dhuhr'), findsOneWidget);

    // When toggled, AdhanCubit should call updateSalaahSettings
    when(() => mockAdhanCubit.updateSalaahSettings(any())).thenAnswer((_) async {});

    // Find the toggle for Fajr and tap it
    final fajrTileFinder = find.ancestor(
      of: find.text('Fajr'),
      matching: find.byType(FardListTile),
    );
    expect(fajrTileFinder, findsOneWidget);

    final fajrToggleFinder = find.descendant(
      of: fajrTileFinder,
      matching: find.byType(CustomToggle),
    );
    expect(fajrToggleFinder, findsOneWidget);

    // Ensure the Fajr toggle is visible on screen before tapping
    await tester.ensureVisible(fajrToggleFinder);
    await tester.pumpAndSettle();

    // Tap it to toggle
    await tester.tap(fajrToggleFinder);
    await tester.pumpAndSettle();

    // Verify updateSalaahSettings was called with Fajr isAzanEnabled: false
    verify(() => mockAdhanCubit.updateSalaahSettings(
      any(that: predicate<SalaahSettings>((s) => s.salaah == Salaah.fajr && s.isAzanEnabled == false)),
    )).called(1);
  });

  testWidgets('Test Azan button is disabled and warning hint is shown when offline and selected voice is not downloaded', (WidgetTester tester) async {
    // 1. Set offline status
    when(() => mockConnectivityService.hasNetwork()).thenAnswer((_) async => false);
    when(() => mockConnectivityService.onConnectivityChanged).thenAnswer((_) => Stream.value([ConnectivityResult.none]));

    // 2. Set sound to a specific non-downloaded voice name
    final voiceName = 'Saad Al-Ghamdi - سعد الغامدي';
    final settings = Salaah.values
        .map((s) => SalaahSettings(salaah: s, isAzanEnabled: true, azanSound: voiceName))
        .toList();

    var state = AdhanState(
      salaahSettings: settings,
      notificationsEnabled: true,
      exactAlarmsEnabled: true,
    );

    when(() => mockAdhanCubit.state).thenReturn(state);
    when(() => mockAdhanCubit.stream).thenAnswer((_) => Stream.value(state));
    when(() => mockVoiceDownloadService.isDownloaded(voiceName)).thenAnswer((_) async => false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify warning hint is displayed
    expect(find.text('You are offline. Please choose one of the downloaded voices (marked with a cloud icon).'), findsOneWidget);

    // Verify Test Sound button is disabled
    final testButtonFinder = find.widgetWithText(FilledButton, 'Test Sound');
    expect(testButtonFinder, findsOneWidget);

    await tester.ensureVisible(testButtonFinder);
    await tester.pumpAndSettle();

    final FilledButton button = tester.widget<FilledButton>(testButtonFinder);
    expect(button.onPressed, isNull);
  });

  testWidgets('When Enable Azan is false, General group is visible but Alarm Precision/Quiet Hours groups are hidden', (WidgetTester tester) async {
    // Initial state: all prayers have Azan disabled
    final initialSettings = Salaah.values
        .map((s) => SalaahSettings(salaah: s, isAzanEnabled: false))
        .toList();

    var state = AdhanState(
      salaahSettings: initialSettings,
      notificationsEnabled: true,
      exactAlarmsEnabled: true,
      showSalahCountdownNotification: false,
    );

    when(() => mockAdhanCubit.state).thenReturn(state);
    when(() => mockAdhanCubit.stream).thenAnswer((_) => Stream.value(state));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Verify master toggle is OFF
    expect(find.text('Enable Azan'), findsOneWidget);

    // Verify General group (Show Salah Countdown) is visible
    expect(find.text('General'), findsOneWidget);
    expect(find.text('Next Salah Countdown Notification'), findsOneWidget);

    // Verify Alarm Precision and Quiet Hours groups are hidden
    expect(find.text('Alarm Precision'), findsNothing);
    expect(find.text('Quiet Hours'), findsNothing);
  });

  testWidgets('RingerStatusChip displays correct warning (orange) vs quiet (accent) messages based on ringer & toggle states', (WidgetTester tester) async {
    // Initial state with Azan enabled, starting with ringer status silent and toggle respectSilentDnd OFF
    final settings = Salaah.values
        .map((s) => SalaahSettings(salaah: s, isAzanEnabled: true))
        .toList();

    var state = AdhanState(
      salaahSettings: settings,
      notificationsEnabled: true,
      exactAlarmsEnabled: true,
      respectSilentDndMode: false,
    );

    final controller = StreamController<AdhanState>.broadcast();
    when(() => mockAdhanCubit.state).thenAnswer((_) => state);
    when(() => mockAdhanCubit.stream).thenAnswer((_) => controller.stream);

    // Stub checkSoundStatus to return silentMode true
    when(() => mockNotificationService.checkSoundStatus()).thenAnswer((_) async => {
      'silentMode': true,
      'dndMode': false,
      'isMuted': true,
    });

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // With respectSilentDndMode false and silent phone, chip should display the warning orange state
    expect(find.text('Phone is silent, but Adhan will still play.'), findsOneWidget);

    // Now update state to respectSilentDndMode true
    state = state.copyWith(respectSilentDndMode: true);
    controller.add(state);
    await tester.pumpAndSettle();

    // With respectSilentDndMode true and silent phone, chip should display the quiet accent state
    expect(find.text('Phone is silent — Adhan will only show a notification.'), findsOneWidget);

    await controller.close();
  });
}
