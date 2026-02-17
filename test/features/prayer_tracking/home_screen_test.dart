import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/screens/home_screen.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:adhan/adhan.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';

class MockPrayerTrackerBloc extends MockBloc<PrayerTrackerEvent, PrayerTrackerState>
    implements PrayerTrackerBloc {}

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

class MockAzkarBloc extends MockBloc<AzkarEvent, AzkarState> implements AzkarBloc {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockPrayerTimeService extends Mock implements PrayerTimeService {}

void main() {
  setUpAll(() {
    registerFallbackValue(PrayerTrackerEvent.load(DateTime.now()));
    registerFallbackValue(PrayerTimes(
      Coordinates(0, 0),
      DateComponents.from(DateTime.now()),
      CalculationMethod.muslim_world_league.getParameters(),
    ));
    registerFallbackValue(Salaah.fajr);
  });

  late MockPrayerTrackerBloc mockPrayerTrackerBloc;
  late MockSettingsCubit mockSettingsCubit;
  late MockAzkarBloc mockAzkarBloc;
  late MockPrayerTimeService mockPrayerTimeService;

  setUp(() {
    mockPrayerTrackerBloc = MockPrayerTrackerBloc();
    mockSettingsCubit = MockSettingsCubit();
    mockAzkarBloc = MockAzkarBloc();
    mockPrayerTimeService = MockPrayerTimeService();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<SharedPreferences>(MockSharedPreferences());
    getIt.registerSingleton<PrayerTrackerBloc>(mockPrayerTrackerBloc);
    getIt.registerSingleton<PrayerTimeService>(mockPrayerTimeService);

    // Default mocks for PrayerTimeService
    when(() => mockPrayerTimeService.isUpcoming(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(false);
    when(() => mockPrayerTimeService.isPassed(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(true);
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PrayerTrackerBloc>.value(value: mockPrayerTrackerBloc),
        BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
        BlocProvider<AzkarBloc>.value(value: mockAzkarBloc),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen renders correctly', (tester) async {
    when(() => mockPrayerTrackerBloc.state).thenReturn(const PrayerTrackerState.loading());
    when(() => mockSettingsCubit.state).thenReturn(SettingsState(locale: const Locale('en')));
    when(() => mockAzkarBloc.state).thenReturn(AzkarState.initial());

    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomeScreen shows loaded content', (tester) async {
    final now = DateTime.now();
    when(() => mockPrayerTrackerBloc.state).thenReturn(PrayerTrackerState.loaded(
      selectedDate: now,
      missedToday: {},
      qadaStatus: {},
      monthRecords: {},
      history: [],
    ));
    when(() => mockSettingsCubit.state).thenReturn(SettingsState(locale: const Locale('en'), cityName: 'Test City'));
    when(() => mockAzkarBloc.state).thenReturn(AzkarState.initial());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Fard'), findsOneWidget);
    expect(find.text('Total Qada'), findsOneWidget);
    expect(find.text('Test City'), findsOneWidget);
    
    // Use dragUntilVisible for slivers
    final dailyPrayersFinder = find.text('Daily Prayers');
    await tester.dragUntilVisible(
      dailyPrayersFinder,
      find.byType(CustomScrollView),
      const Offset(0, -200),
    );
    expect(dailyPrayersFinder, findsAtLeast(1));
    
    // Verify Salaah Time is displayed (mocked time service should return something if we setup correctly, 
    // but here we didn't setup mock return for getTimeForSalaah. Let's do that)
  });

  testWidgets('SalaahTile displays time', (tester) async {
    final now = DateTime.now();
    final time = DateTime(now.year, now.month, now.day, 5, 0); // 5:00 AM
    
    when(() => mockPrayerTrackerBloc.state).thenReturn(PrayerTrackerState.loaded(
      selectedDate: now,
      missedToday: {},
      qadaStatus: {for (var s in Salaah.values) s: const MissedCounter(0)},
      monthRecords: {},
      history: [],
    ));
    when(() => mockSettingsCubit.state).thenReturn(SettingsState(
      locale: const Locale('en'), 
      cityName: 'Test City',
      latitude: 10,
      longitude: 10,
    ));
    when(() => mockAzkarBloc.state).thenReturn(AzkarState.initial());
    
    // Mock PrayerTimeService to return specific times
    final prayerTimes = PrayerTimes(
      Coordinates(10, 10),
      DateComponents.from(now),
      CalculationMethod.muslim_world_league.getParameters(),
    );
    when(() => mockPrayerTimeService.getPrayerTimes(
      latitude: any(named: 'latitude'),
      longitude: any(named: 'longitude'),
      method: any(named: 'method'),
      madhab: any(named: 'madhab'),
      date: any(named: 'date'),
    )).thenReturn(prayerTimes);

    // Only return time for Fajr to avoid "Too many elements" in scroll
    when(() => mockPrayerTimeService.getTimeForSalaah(any(), Salaah.fajr))
        .thenReturn(time);
    when(() => mockPrayerTimeService.getTimeForSalaah(any(), any(that: isNot(Salaah.fajr))))
        .thenReturn(null);

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Drag to see SalaahTiles
    final timeFinder = find.textContaining('5:00');
    await tester.dragUntilVisible(
      timeFinder,
      find.byType(CustomScrollView),
      const Offset(0, -200),
    );
    expect(timeFinder, findsAtLeast(1));
  });
}
