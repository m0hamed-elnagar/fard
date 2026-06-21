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

class MockAdhanCubit extends Mock implements AdhanCubit {}
class MockNotificationService extends Mock implements NotificationService {}
class MockVoiceDownloadService extends Mock implements VoiceDownloadService {}
class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late MockAdhanCubit mockAdhanCubit;
  late MockNotificationService mockNotificationService;
  late MockVoiceDownloadService mockVoiceDownloadService;
  late MockConnectivityService mockConnectivityService;

  setUpAll(() {
    registerFallbackValue(const SalaahSettings(salaah: Salaah.fajr));
  });

  setUp(() {
    mockAdhanCubit = MockAdhanCubit();
    mockNotificationService = MockNotificationService();
    mockVoiceDownloadService = MockVoiceDownloadService();
    mockConnectivityService = MockConnectivityService();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<NotificationService>(mockNotificationService);
    getIt.registerSingleton<VoiceDownloadService>(mockVoiceDownloadService);
    getIt.registerSingleton<ConnectivityService>(mockConnectivityService);

    when(() => mockNotificationService.areNotificationsEnabled()).thenAnswer((_) async => true);
    when(() => mockNotificationService.canScheduleExactNotifications()).thenAnswer((_) async => true);
    when(() => mockVoiceDownloadService.isDownloaded(any())).thenAnswer((_) async => false);
    when(() => mockConnectivityService.onConnectivityChanged).thenAnswer((_) => Stream.value([ConnectivityResult.wifi]));
    when(() => mockConnectivityService.hasNetwork()).thenAnswer((_) async => true);
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
    final testButtonFinder = find.widgetWithText(TextButton, 'Test Sound');
    expect(testButtonFinder, findsOneWidget);
    final TextButton button = tester.widget<TextButton>(testButtonFinder);
    expect(button.onPressed, isNull);
  });
}
