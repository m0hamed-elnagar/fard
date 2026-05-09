import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/prayer_tracking/presentation/screens/home_screen.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_state.dart';
import 'package:fard/features/settings/presentation/blocs/theme_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/theme_state.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/widget_update_service.dart';

class MockLocationPrayerCubit extends MockCubit<LocationPrayerState>
    implements LocationPrayerCubit {}

class MockThemeCubit extends MockCubit<ThemeState> implements ThemeCubit {}

class MockDailyRemindersCubit extends MockCubit<DailyRemindersState>
    implements DailyRemindersCubit {}

class MockAzkarBloc extends MockBloc<AzkarEvent, AzkarState>
    implements AzkarBloc {}

class MockPrayerTrackerBloc
    extends MockBloc<PrayerTrackerEvent, PrayerTrackerState>
    implements PrayerTrackerBloc {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockPrayerTimeService extends Mock implements PrayerTimeService {}

class MockWidgetUpdateService extends Mock implements WidgetUpdateService {
  @override
  Future<void> updateWidget() async {}
}

void main() {
  late MockLocationPrayerCubit mockLocationPrayerCubit;
  late MockThemeCubit mockThemeCubit;
  late MockDailyRemindersCubit mockDailyRemindersCubit;
  late MockAzkarBloc mockAzkarBloc;
  late MockPrayerTrackerBloc mockPrayerTrackerBloc;

  setUpAll(() {
    registerFallbackValue(PrayerTrackerEvent.load(DateTime.now()));
    registerFallbackValue(Salaah.fajr);
  });

  setUp(() {
    mockLocationPrayerCubit = MockLocationPrayerCubit();
    mockThemeCubit = MockThemeCubit();
    mockDailyRemindersCubit = MockDailyRemindersCubit();
    mockAzkarBloc = MockAzkarBloc();
    mockPrayerTrackerBloc = MockPrayerTrackerBloc();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<SharedPreferences>(MockSharedPreferences());
    getIt.registerSingleton<PrayerTrackerBloc>(mockPrayerTrackerBloc);
    final mockPrayerTimeService = MockPrayerTimeService();
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

    when(() => mockPrayerTrackerBloc.state).thenReturn(
      PrayerTrackerState.loaded(
        selectedDate: DateTime.now(),
        missedToday: {},
        qadaStatus: {},
        monthRecords: {},
        history: [],
      ),
    );

    when(() => mockLocationPrayerCubit.state).thenReturn(
      const LocationPrayerState(),
    );
    when(() => mockThemeCubit.state).thenReturn(
      const ThemeState(locale: Locale('en')),
    );
    when(() => mockDailyRemindersCubit.state).thenReturn(
      const DailyRemindersState(),
    );
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationPrayerCubit>.value(value: mockLocationPrayerCubit),
        BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
        BlocProvider<DailyRemindersCubit>.value(value: mockDailyRemindersCubit),
        BlocProvider<AzkarBloc>.value(value: mockAzkarBloc),
        BlocProvider<PrayerTrackerBloc>.value(value: mockPrayerTrackerBloc),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: HomeScreen(),
      ),
    );
  }

  testWidgets('Morning Azkar Dialog appears when time matches', (tester) async {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    when(() => mockDailyRemindersCubit.state).thenReturn(
      DailyRemindersState(
        reminders: [
          AzkarReminder(
            category: 'Morning Azkar',
            time: timeStr,
            title: 'Morning Azkar',
            isEnabled: true,
          ),
        ],
      ),
    );

    when(() => mockAzkarBloc.state).thenReturn(
      const AzkarState(
        categories: ['Morning Azkar', 'Evening Azkar'],
        azkar: [],
        isLoading: false,
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    // Wait for the dialog to appear (needs time for timer to fire)
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.textContaining('Morning Azkar'), findsAtLeast(1));
    expect(find.text('Yes'), findsOneWidget);
  });

  testWidgets('Evening Azkar Dialog appears when time matches', (tester) async {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    when(() => mockDailyRemindersCubit.state).thenReturn(
      DailyRemindersState(
        reminders: [
          AzkarReminder(
            category: 'Evening Azkar',
            time: timeStr,
            title: 'Evening Azkar',
            isEnabled: true,
          ),
        ],
      ),
    );

    when(() => mockAzkarBloc.state).thenReturn(
      const AzkarState(
        categories: ['Morning Azkar', 'Evening Azkar'],
        azkar: [],
        isLoading: false,
      ),
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.textContaining('Evening Azkar'), findsAtLeast(1));
    expect(find.text('Yes'), findsOneWidget);
  });
}
