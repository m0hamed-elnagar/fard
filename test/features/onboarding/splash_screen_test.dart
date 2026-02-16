import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:fard/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:fard/features/azkar/presentation/screens/main_navigation_screen.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
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

void main() {
  setUpAll(() {
    registerFallbackValue(PrayerTrackerEvent.load(DateTime.now()));
  });

  late MockSharedPreferences mockPrefs;
  late MockSettingsCubit mockSettingsCubit;
  late MockAzkarBloc mockAzkarBloc;
  late MockPrayerTrackerBloc mockPrayerTrackerBloc;
  late MockPrayerTimeService mockPrayerTimeService;
  late MockNotificationService mockNotificationService;
  late MockQuranBloc mockQuranBloc;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockSettingsCubit = MockSettingsCubit();
    mockAzkarBloc = MockAzkarBloc();
    mockPrayerTrackerBloc = MockPrayerTrackerBloc();
    mockPrayerTimeService = MockPrayerTimeService();
    mockNotificationService = MockNotificationService();
    mockQuranBloc = MockQuranBloc();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<SharedPreferences>(mockPrefs);
    getIt.registerSingleton<PrayerTrackerBloc>(mockPrayerTrackerBloc);
    getIt.registerSingleton<PrayerTimeService>(mockPrayerTimeService);
    getIt.registerSingleton<NotificationService>(mockNotificationService);
    getIt.registerSingleton<GlobalKey<NavigatorState>>(GlobalKey<NavigatorState>());
    getIt.registerFactory<QuranBloc>(() => mockQuranBloc);

    when(() => mockNotificationService.canScheduleExactNotifications()).thenAnswer((_) async => true);

    when(() => mockSettingsCubit.state).thenReturn(SettingsState(locale: const Locale('en')));
    when(() => mockAzkarBloc.state).thenReturn(AzkarState.initial());
    when(() => mockPrayerTrackerBloc.state).thenReturn(const PrayerTrackerState.loading());
    when(() => mockQuranBloc.state).thenReturn(const QuranState());
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
        BlocProvider<AzkarBloc>.value(value: mockAzkarBloc),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SplashScreen(),
      ),
    );
  }

  testWidgets('SplashScreen navigates to OnboardingScreen when first time', (tester) async {
    when(() => mockPrefs.getBool('onboarding_complete')).thenReturn(false);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for navigation

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('SplashScreen navigates to MainNavigationScreen when onboarding complete', (tester) async {
    when(() => mockPrefs.getBool('onboarding_complete')).thenReturn(true);
    when(() => mockPrayerTrackerBloc.state).thenReturn(PrayerTrackerState.loaded(
      selectedDate: DateTime.now(),
      missedToday: {},
      qadaStatus: {},
      monthRecords: {},
      history: [],
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Wait for navigation

    expect(find.byType(MainNavigationScreen), findsOneWidget);
  });
}
