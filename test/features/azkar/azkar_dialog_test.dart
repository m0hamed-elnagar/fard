import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/prayer_tracking/presentation/screens/home_screen.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
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

class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}
class MockAzkarBloc extends MockBloc<AzkarEvent, AzkarState> implements AzkarBloc {}
class MockPrayerTrackerBloc extends MockBloc<PrayerTrackerEvent, PrayerTrackerState> implements PrayerTrackerBloc {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}

void main() {
  late MockSettingsCubit mockSettingsCubit;
  late MockAzkarBloc mockAzkarBloc;
  late MockPrayerTrackerBloc mockPrayerTrackerBloc;

  setUpAll(() {
    registerFallbackValue(PrayerTrackerEvent.load(DateTime.now()));
    registerFallbackValue(Salaah.fajr);
  });

  setUp(() {
    mockSettingsCubit = MockSettingsCubit();
    mockAzkarBloc = MockAzkarBloc();
    mockPrayerTrackerBloc = MockPrayerTrackerBloc();

    final getIt = GetIt.instance;
    getIt.reset();
    getIt.registerSingleton<SharedPreferences>(MockSharedPreferences());
    getIt.registerSingleton<PrayerTrackerBloc>(mockPrayerTrackerBloc);
    final mockPrayerTimeService = MockPrayerTimeService();
    getIt.registerSingleton<PrayerTimeService>(mockPrayerTimeService);

    // Default mocks for PrayerTimeService
    when(() => mockPrayerTimeService.isUpcoming(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(false);
    when(() => mockPrayerTimeService.isPassed(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(true);

    when(() => mockPrayerTrackerBloc.state).thenReturn(PrayerTrackerState.loaded(
      selectedDate: DateTime.now(),
      missedToday: {},
      qadaStatus: {},
      monthRecords: {},
      history: [],
    ));
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
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
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    when(() => mockSettingsCubit.state).thenReturn(SettingsState(
      locale: const Locale('en'),
      morningAzkarTime: timeStr,
      eveningAzkarTime: '23:59',
      isAzanVoiceDownloading: false,
      reminders: [
        AzkarReminder(category: 'Morning Azkar', time: timeStr, title: 'Morning Azkar'),
      ],
    ));

    when(() => mockAzkarBloc.state).thenReturn(const AzkarState(
      categories: ['Morning Azkar', 'Evening Azkar'],
      azkar: [],
      isLoading: false,
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); 

    expect(find.textContaining('Morning Azkar'), findsAtLeast(1));
    expect(find.text('Yes'), findsOneWidget);
  });

  testWidgets('Evening Azkar Dialog appears when time matches', (tester) async {
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    when(() => mockSettingsCubit.state).thenReturn(SettingsState(
      locale: const Locale('en'),
      morningAzkarTime: '00:00',
      eveningAzkarTime: timeStr,
      isAzanVoiceDownloading: false,
      reminders: [
        AzkarReminder(category: 'Evening Azkar', time: timeStr, title: 'Evening Azkar'),
      ],
    ));

    when(() => mockAzkarBloc.state).thenReturn(const AzkarState(
      categories: ['Morning Azkar', 'Evening Azkar'],
      azkar: [],
      isLoading: false,
    ));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump(); 

    expect(find.textContaining('Evening Azkar'), findsAtLeast(1));
    expect(find.text('Yes'), findsOneWidget);
  });
}
