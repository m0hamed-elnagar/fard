import 'mock_audio_download_service.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:fard/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:fard/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:fard/features/azkar/presentation/screens/main_navigation_screen.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/player/audio_player_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/manager/reciter_manager_bloc.dart';
import 'package:fard/features/tasbih/presentation/bloc/tasbih_bloc.dart';
import 'package:fard/core/blocs/connectivity/connectivity_bloc.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:bloc_test/bloc_test.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockSettingsCubit extends MockCubit<SettingsState>
    implements SettingsCubit {}

class MockAzkarBloc extends MockBloc<AzkarEvent, AzkarState>
    implements AzkarBloc {}

class MockPrayerTrackerBloc
    extends MockBloc<PrayerTrackerEvent, PrayerTrackerState>
    implements PrayerTrackerBloc {}

class MockPrayerTimeService extends Mock implements PrayerTimeService {}

class MockNotificationService extends Mock implements NotificationService {
  @override
  Future<Map<String, dynamic>> runDiagnostics() async => {
        'notifications_enabled': true,
        'exact_alarm_permission': true,
        'battery_optimization_ignored': true,
      };
}

class MockWidgetUpdateService extends Mock implements WidgetUpdateService {
  @override
  Future<void> updateWidget() async {}
}

class MockQuranBloc extends MockBloc<QuranEvent, QuranState>
    implements QuranBloc {}

class MockAudioPlayerBloc extends MockBloc<AudioPlayerEvent, AudioPlayerState>
    implements AudioPlayerBloc {}

class MockReciterManagerBloc extends MockBloc<ReciterManagerEvent, ReciterManagerState>
    implements ReciterManagerBloc {}

class MockTasbihBloc extends MockBloc<TasbihEvent, TasbihState>
    implements MockTasbihBlocInstance {}

// Need a non-mock class for implements if it has issues with multiple mocks
abstract class MockTasbihBlocInstance extends MockBloc<TasbihEvent, TasbihState> implements TasbihBloc {}

class MockReaderBloc extends MockBloc<ReaderEvent, ReaderState>
    implements ReaderBloc {}

class MockConnectivityBloc extends MockBloc<ConnectivityEvent, ConnectivityState>
    implements ConnectivityBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(PrayerTrackerEvent.load(DateTime.now()));
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(const ConnectivityChanged([]));
  });

  late MockSharedPreferences mockPrefs;
  late MockSettingsCubit mockSettingsCubit;
  late MockAzkarBloc mockAzkarBloc;
  late MockPrayerTrackerBloc mockPrayerTrackerBloc;
  late MockPrayerTimeService mockPrayerTimeService;
  late MockNotificationService mockNotificationService;
  late MockQuranBloc mockQuranBloc;
  late MockAudioPlayerBloc mockAudioPlayerBloc;
  late MockReciterManagerBloc mockReciterManagerBloc;
  late MockTasbihBloc mockTasbihBloc;
  late MockReaderBloc mockReaderBloc;
  late MockConnectivityBloc mockConnectivityBloc;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(const SettingsState(locale: Locale('en')));
    mockAzkarBloc = MockAzkarBloc();
    mockPrayerTrackerBloc = MockPrayerTrackerBloc();
    mockPrayerTimeService = MockPrayerTimeService();
    mockNotificationService = MockNotificationService();
    mockQuranBloc = MockQuranBloc();
    mockAudioPlayerBloc = MockAudioPlayerBloc();
    mockReciterManagerBloc = MockReciterManagerBloc();
    mockTasbihBloc = MockTasbihBloc();
    mockReaderBloc = MockReaderBloc();
    mockConnectivityBloc = MockConnectivityBloc();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<SharedPreferences>(mockPrefs);
    getIt.registerSingleton<AudioDownloadService>(MockAudioDownloadService());
    getIt.registerSingleton<PrayerTrackerBloc>(mockPrayerTrackerBloc);
    getIt.registerSingleton<PrayerTimeService>(mockPrayerTimeService);
    getIt.registerSingleton<NotificationService>(mockNotificationService);
    final mockWidgetUpdateService = MockWidgetUpdateService();
    when(() => mockWidgetUpdateService.getWidgetTheme()).thenAnswer((_) async => {});
    getIt.registerSingleton<WidgetUpdateService>(mockWidgetUpdateService);
    getIt.registerSingleton<GlobalKey<NavigatorState>>(
      GlobalKey<NavigatorState>(),
    );
    getIt.registerFactory<QuranBloc>(() => mockQuranBloc);
    getIt.registerFactory<AudioPlayerBloc>(() => mockAudioPlayerBloc);
    getIt.registerFactory<ReciterManagerBloc>(() => mockReciterManagerBloc);
    getIt.registerFactory<TasbihBloc>(() => mockTasbihBloc);
    getIt.registerFactory<ReaderBloc>(() => mockReaderBloc);
    getIt.registerFactory<ConnectivityBloc>(() => mockConnectivityBloc);

    when(() => mockNotificationService.canScheduleExactNotifications()).thenAnswer((_) async => true);
    when(() => mockPrayerTimeService.isUpcoming(any(), prayerTimes: any(named: 'prayerTimes'), date: any(named: 'date'))).thenReturn(false);
    when(() => mockPrayerTimeService.isPassed(any(), prayerTimes: any(named: 'prayerTimes'), date: any(named: 'date'))).thenReturn(true);
    when(() => mockSettingsCubit.getAvailablePresets()).thenReturn([]);
    when(() => mockAzkarBloc.state).thenReturn(AzkarState.initial());
    when(
      () => mockPrayerTrackerBloc.state,
    ).thenReturn(const PrayerTrackerState.loading());
    when(() => mockQuranBloc.state).thenReturn(const QuranState());
    when(() => mockAudioPlayerBloc.state).thenReturn(const AudioPlayerState());
    when(() => mockReciterManagerBloc.state).thenReturn(const ReciterManagerState());
    when(() => mockTasbihBloc.state).thenReturn(TasbihState.initial());
    when(() => mockReaderBloc.state).thenReturn(const ReaderState.initial());
    when(() => mockConnectivityBloc.state).thenReturn(const ConnectivityStatus(true));
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
        BlocProvider<AzkarBloc>.value(value: mockAzkarBloc),
        BlocProvider<AudioPlayerBloc>.value(value: mockAudioPlayerBloc),
        BlocProvider<ReciterManagerBloc>.value(value: mockReciterManagerBloc),
        BlocProvider<TasbihBloc>.value(value: mockTasbihBloc),
        BlocProvider<ReaderBloc>.value(value: mockReaderBloc),
        BlocProvider<QuranBloc>.value(value: mockQuranBloc),
        BlocProvider<PrayerTrackerBloc>.value(value: mockPrayerTrackerBloc),
        BlocProvider<ConnectivityBloc>.value(value: mockConnectivityBloc),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(width: 1080, height: 1920, child: RootScreen()),
        ),
      ),
    );
  }

  testWidgets('RootScreen shows OnboardingScreen when first time', (
    tester,
  ) async {
    when(() => mockPrefs.getBool('onboarding_complete')).thenReturn(false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets(
    'RootScreen shows MainNavigationScreen when onboarding complete',
    (tester) async {
      when(() => mockPrefs.getBool('onboarding_complete')).thenReturn(true);
      when(() => mockPrayerTrackerBloc.state).thenReturn(
        PrayerTrackerState.loaded(
          selectedDate: DateTime.now(),
          missedToday: {},
          qadaStatus: {},
          monthRecords: {},
          history: [],
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(MainNavigationScreen), findsOneWidget);
    },
  );
}
