import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:fard/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:fard/features/azkar/presentation/screens/main_navigation_screen.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/tasbih/presentation/bloc/tasbih_bloc.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:bloc_test/bloc_test.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}
class MockAzkarBloc extends MockBloc<AzkarEvent, AzkarState> implements AzkarBloc {}
class MockPrayerTrackerBloc extends MockBloc<PrayerTrackerEvent, PrayerTrackerState> implements PrayerTrackerBloc {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}
class MockNotificationService extends Mock implements NotificationService {}
class MockQuranBloc extends MockBloc<QuranEvent, QuranState> implements QuranBloc {}
class MockAudioBloc extends MockBloc<AudioEvent, AudioState> implements AudioBloc {}
class MockTasbihBloc extends MockBloc<TasbihEvent, TasbihState> implements TasbihBloc {}
class MockReaderBloc extends MockBloc<ReaderEvent, ReaderState> implements ReaderBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(PrayerTrackerEvent.load(DateTime.now()));
    registerFallbackValue(Salaah.fajr);
  });

  late MockSharedPreferences mockPrefs;
  late MockSettingsCubit mockSettingsCubit;
  late MockAzkarBloc mockAzkarBloc;
  late MockPrayerTrackerBloc mockPrayerTrackerBloc;
  late MockPrayerTimeService mockPrayerTimeService;
  late MockNotificationService mockNotificationService;
  late MockQuranBloc mockQuranBloc;
  late MockAudioBloc mockAudioBloc;
  late MockTasbihBloc mockTasbihBloc;
  late MockReaderBloc mockReaderBloc;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockSettingsCubit = MockSettingsCubit();
    mockAzkarBloc = MockAzkarBloc();
    mockPrayerTrackerBloc = MockPrayerTrackerBloc();
    mockPrayerTimeService = MockPrayerTimeService();
    mockNotificationService = MockNotificationService();
    mockQuranBloc = MockQuranBloc();
    mockAudioBloc = MockAudioBloc();
    mockTasbihBloc = MockTasbihBloc();
    mockReaderBloc = MockReaderBloc();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<SharedPreferences>(mockPrefs);
    getIt.registerSingleton<PrayerTrackerBloc>(mockPrayerTrackerBloc);
    getIt.registerSingleton<PrayerTimeService>(mockPrayerTimeService);
    getIt.registerSingleton<NotificationService>(mockNotificationService);
    getIt.registerSingleton<GlobalKey<NavigatorState>>(GlobalKey<NavigatorState>());
    getIt.registerFactory<QuranBloc>(() => mockQuranBloc);
    getIt.registerFactory<AudioBloc>(() => mockAudioBloc);
    getIt.registerFactory<TasbihBloc>(() => mockTasbihBloc);
    getIt.registerFactory<ReaderBloc>(() => mockReaderBloc);

    when(() => mockNotificationService.canScheduleExactNotifications()).thenAnswer((_) async => true);
    
    // Default mocks for PrayerTimeService
    when(() => mockPrayerTimeService.isUpcoming(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(false);
    when(() => mockPrayerTimeService.isPassed(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(true);

    when(() => mockSettingsCubit.state).thenReturn(SettingsState(locale: const Locale('en')));
    when(() => mockAzkarBloc.state).thenReturn(AzkarState.initial());
    when(() => mockPrayerTrackerBloc.state).thenReturn(const PrayerTrackerState.loading());
    when(() => mockQuranBloc.state).thenReturn(const QuranState());
    when(() => mockAudioBloc.state).thenReturn(const AudioState());
    when(() => mockTasbihBloc.state).thenReturn(TasbihState.initial());
    when(() => mockReaderBloc.state).thenReturn(const ReaderState.initial());
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
        BlocProvider<AzkarBloc>.value(value: mockAzkarBloc),
        BlocProvider<AudioBloc>.value(value: mockAudioBloc),
        BlocProvider<TasbihBloc>.value(value: mockTasbihBloc),
        BlocProvider<ReaderBloc>.value(value: mockReaderBloc),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SizedBox(
            width: 1080,
            height: 1920,
            child: RootScreen(),
          ),
        ),
      ),
    );
  }

  testWidgets('RootScreen shows OnboardingScreen when first time', (tester) async {
    when(() => mockPrefs.getBool('onboarding_complete')).thenReturn(false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('RootScreen shows MainNavigationScreen when onboarding complete', (tester) async {
    when(() => mockPrefs.getBool('onboarding_complete')).thenReturn(true);
    when(() => mockPrayerTrackerBloc.state).thenReturn(PrayerTrackerState.loaded(
      selectedDate: DateTime.now(),
      missedToday: {},
      qadaStatus: {},
      monthRecords: {},
      history: [],
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });
}
