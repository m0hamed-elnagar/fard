import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/screens/home_screen.dart';
import 'package:fard/features/settings/presentation/blocs/theme_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/theme_state.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_state.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_state.dart';
import 'package:fard/features/settings/presentation/blocs/adhan_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/adhan_state.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:adhan/adhan.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';

class MockPrayerTrackerBloc
    extends MockBloc<PrayerTrackerEvent, PrayerTrackerState>
    implements PrayerTrackerBloc {}

class MockLocationPrayerCubit extends MockCubit<LocationPrayerState>
    implements LocationPrayerCubit {}

class MockDailyRemindersCubit extends MockCubit<DailyRemindersState>
    implements DailyRemindersCubit {}

class MockThemeCubit extends MockCubit<ThemeState>
    implements ThemeCubit {}

class MockAdhanCubit extends MockCubit<AdhanState>
    implements AdhanCubit {}

class MockAzkarBloc extends MockBloc<AzkarEvent, AzkarState>
    implements AzkarBloc {}

class MockWerdBloc extends MockBloc<WerdEvent, WerdState> implements WerdBloc {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockPrayerTimeService extends Mock implements PrayerTimeService {}

class MockWidgetUpdateService extends Mock implements WidgetUpdateService {
  @override
  Future<void> updateWidget() async {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(PrayerTrackerEvent.load(DateTime.now()));
    registerFallbackValue(
      PrayerTimes(
        Coordinates(0, 0),
        DateComponents.from(DateTime.now()),
        CalculationMethod.muslim_world_league.getParameters(),
      ),
    );
    registerFallbackValue(Salaah.fajr);
  });

  late MockPrayerTrackerBloc mockPrayerTrackerBloc;
  late MockLocationPrayerCubit mockLocationPrayerCubit;
  late MockDailyRemindersCubit mockDailyRemindersCubit;
  late MockThemeCubit mockThemeCubit;
  late MockAdhanCubit mockAdhanCubit;
  late MockAzkarBloc mockAzkarBloc;
  late MockWerdBloc mockWerdBloc;
  late MockPrayerTimeService mockPrayerTimeService;

  setUp(() {
    mockPrayerTrackerBloc = MockPrayerTrackerBloc();
    mockLocationPrayerCubit = MockLocationPrayerCubit();
    mockDailyRemindersCubit = MockDailyRemindersCubit();
    mockThemeCubit = MockThemeCubit();
    mockAdhanCubit = MockAdhanCubit();
    mockAzkarBloc = MockAzkarBloc();
    mockWerdBloc = MockWerdBloc();
    mockPrayerTimeService = MockPrayerTimeService();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<SharedPreferences>(MockSharedPreferences());
    getIt.registerSingleton<PrayerTrackerBloc>(mockPrayerTrackerBloc);
    getIt.registerSingleton<PrayerTimeService>(mockPrayerTimeService);
    getIt.registerSingleton<WidgetUpdateService>(MockWidgetUpdateService());

    // Default mocks for PrayerTimeService
    when(
      () => mockPrayerTimeService.isUpcoming(
        any(),
        prayerTimes: any(named: 'prayerTimes'),
        date: any(named: 'date'),
      ),
    ).thenReturn(false);
    when(
      () => mockPrayerTimeService.isPassed(
        any(),
        prayerTimes: any(named: 'prayerTimes'),
        date: any(named: 'date'),
      ),
    ).thenReturn(true);
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PrayerTrackerBloc>.value(value: mockPrayerTrackerBloc),
        BlocProvider<LocationPrayerCubit>.value(value: mockLocationPrayerCubit),
        BlocProvider<DailyRemindersCubit>.value(value: mockDailyRemindersCubit),
        BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
        BlocProvider<AdhanCubit>.value(value: mockAdhanCubit),
        BlocProvider<AzkarBloc>.value(value: mockAzkarBloc),
        BlocProvider<WerdBloc>.value(value: mockWerdBloc),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeScreen(),
      ),
    );
  }

  testWidgets('HomeScreen renders correctly', (tester) async {
    when(
      () => mockPrayerTrackerBloc.state,
    ).thenReturn(const PrayerTrackerState.loading());
    when(() => mockThemeCubit.state).thenReturn(const ThemeState(locale: Locale('en')));
    when(() => mockLocationPrayerCubit.state).thenReturn(const LocationPrayerState());
    when(() => mockDailyRemindersCubit.state).thenReturn(const DailyRemindersState());
    when(() => mockAdhanCubit.state).thenReturn(const AdhanState());
    when(() => mockAzkarBloc.state).thenReturn(AzkarState.initial());
    when(() => mockWerdBloc.state).thenReturn(WerdState.initial());

    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('HomeScreen shows loaded content', (tester) async {
    final now = DateTime.now();
    when(() => mockPrayerTrackerBloc.state).thenReturn(
      PrayerTrackerState.loaded(
        selectedDate: now,
        missedToday: {},
        completedToday: {},
        qadaStatus: {},
        completedQadaToday: {},
        monthRecords: {},
        history: [],
      ),
    );
    when(() => mockThemeCubit.state).thenReturn(const ThemeState(locale: Locale('en')));
    when(() => mockLocationPrayerCubit.state).thenReturn(
      const LocationPrayerState(cityName: 'Test City'),
    );
    when(() => mockDailyRemindersCubit.state).thenReturn(const DailyRemindersState());
    when(() => mockAdhanCubit.state).thenReturn(const AdhanState());
    when(() => mockAzkarBloc.state).thenReturn(AzkarState.initial());
    when(() => mockWerdBloc.state).thenReturn(WerdState.initial());

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    expect(find.text('Fard'), findsOneWidget);
    expect(find.text('Total Qada'), findsOneWidget);
    expect(find.text('Test City'), findsAtLeast(1));

    // Use dragUntilVisible for slivers
    final dailyPrayersFinder = find.text('Daily Prayers');
    await tester.dragUntilVisible(
      dailyPrayersFinder,
      find.byType(CustomScrollView),
      const Offset(0, -200),
    );
    expect(dailyPrayersFinder, findsAtLeast(1));
  });

  testWidgets('SalaahTile displays time', (tester) async {
    final now = DateTime.now();
    final time = DateTime(now.year, now.month, now.day, 5, 0); // 5:00 AM

    when(() => mockPrayerTrackerBloc.state).thenReturn(
      PrayerTrackerState.loaded(
        selectedDate: now,
        missedToday: {},
        completedToday: {},
        qadaStatus: {for (var s in Salaah.values) s: const MissedCounter(0)},
        completedQadaToday: {},
        monthRecords: {},
        history: [],
      ),
    );
    when(() => mockThemeCubit.state).thenReturn(const ThemeState(locale: Locale('en')));
    when(() => mockLocationPrayerCubit.state).thenReturn(
      const LocationPrayerState(latitude: 10, longitude: 10, cityName: 'Test City'),
    );
    when(() => mockDailyRemindersCubit.state).thenReturn(const DailyRemindersState());
    when(() => mockAdhanCubit.state).thenReturn(const AdhanState());
    when(() => mockAzkarBloc.state).thenReturn(AzkarState.initial());
    when(() => mockWerdBloc.state).thenReturn(WerdState.initial());

    // Mock PrayerTimeService to return specific times
    final prayerTimes = PrayerTimes(
      Coordinates(10, 10),
      DateComponents.from(now),
      CalculationMethod.muslim_world_league.getParameters(),
    );
    when(
      () => mockPrayerTimeService.getPrayerTimes(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        method: any(named: 'method'),
        madhab: any(named: 'madhab'),
        date: any(named: 'date'),
      ),
    ).thenReturn(prayerTimes);

    // Only return time for Fajr to avoid "Too many elements" in scroll
    when(
      () => mockPrayerTimeService.getTimeForSalaah(any(), Salaah.fajr),
    ).thenReturn(time);
    when(
      () => mockPrayerTimeService.getTimeForSalaah(
        any(),
        any(that: isNot(Salaah.fajr)),
      ),
    ).thenReturn(null);

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
