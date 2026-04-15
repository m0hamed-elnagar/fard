import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/core/theme/theme_presets.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

class MockSettingsCubit extends Mock implements SettingsCubit {}

class MockNotificationService extends Mock implements NotificationService {}

class MockVoiceDownloadService extends Mock implements VoiceDownloadService {}

class MockAzkarBloc extends Mock implements AzkarBloc {}

class MockWidgetUpdateService extends Mock implements WidgetUpdateService {}

void main() {
  late MockSettingsCubit mockSettingsCubit;
  late MockNotificationService mockNotificationService;
  late MockVoiceDownloadService mockVoiceDownloadService;
  late MockAzkarBloc mockAzkarBloc;
  late MockWidgetUpdateService mockWidgetUpdateService;

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    mockNotificationService = MockNotificationService();
    mockVoiceDownloadService = MockVoiceDownloadService();
    mockAzkarBloc = MockAzkarBloc();
    mockWidgetUpdateService = MockWidgetUpdateService();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<NotificationService>(mockNotificationService);
    getIt.registerSingleton<VoiceDownloadService>(mockVoiceDownloadService);
    getIt.registerSingleton<WidgetUpdateService>(mockWidgetUpdateService);

    when(
      () => mockNotificationService.canScheduleExactNotifications(),
    ).thenAnswer((_) async => true);
    
    when(() => mockWidgetUpdateService.getWidgetTheme()).thenAnswer((_) async => null);

    when(() => mockSettingsCubit.getAvailablePresets()).thenReturn(ThemePresets.all);
    when(() => mockSettingsCubit.state).thenReturn(
      const SettingsState(
        locale: Locale('en'),
        cityName: 'London',
        calculationMethod: 'muslim_league',
        madhab: 'shafi',
        isAzanVoiceDownloading: false,
        themePresetId: 'emerald',
        latitude: 51.5074,
        longitude: -0.1278,
        salaahSettings: [
          SalaahSettings(salaah: Salaah.fajr),
          SalaahSettings(salaah: Salaah.dhuhr),
          SalaahSettings(salaah: Salaah.asr),
          SalaahSettings(salaah: Salaah.maghrib),
          SalaahSettings(salaah: Salaah.isha),
        ],
      ),
    );
    when(
      () => mockSettingsCubit.stream,
    ).thenAnswer((_) => const Stream.empty());

    when(() => mockAzkarBloc.state).thenReturn(AzkarState.initial());
    when(() => mockAzkarBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
          BlocProvider<AzkarBloc>.value(value: mockAzkarBloc),
        ],
        child: const SettingsScreen(),
      ),
    );
  }

  testWidgets('renders settings screen with all sections', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Data & Location'), findsOneWidget);

    // Scroll by dragging
    await tester.drag(find.byType(ListView).first, const Offset(0, -500));
    await tester.pumpAndSettle();

    expect(find.text('Prayer & Azan'), findsOneWidget);
    expect(find.text('General App Settings'), findsOneWidget);
  });

  testWidgets('shows current location city', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('London'), findsOneWidget);
  });

  /*
  testWidgets('tapping a prayer opens azan settings dialog', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Scroll to the list of prayers
    await tester.drag(find.byType(ListView).first, const Offset(0, -600));
    await tester.pumpAndSettle();

    // Find the ListTile that contains "Fajr"
    final fajrListTileFinder = find.ancestor(
      of: find.text('Fajr'),
      matching: find.byType(ListTile),
    ).first;
    
    await tester.scrollUntilVisible(
      fajrListTileFinder,
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(fajrListTileFinder);
    await tester.pumpAndSettle();

    expect(find.text('Enable Azan'), findsOneWidget);
    expect(find.text('Enable Reminder'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
  });
  */
}
