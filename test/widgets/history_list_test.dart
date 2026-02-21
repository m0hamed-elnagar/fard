
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/history_list.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:adhan/adhan.dart';

class MockPrayerTimeService extends Mock implements PrayerTimeService {}
class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

void main() {
  late MockPrayerTimeService mockPrayerTimeService;
  late MockSettingsCubit mockSettingsCubit;

  setUpAll(() {
    registerFallbackValue(Salaah.fajr);
  });

  setUp(() async {
    mockPrayerTimeService = MockPrayerTimeService();
    mockSettingsCubit = MockSettingsCubit();

    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerSingleton<PrayerTimeService>(mockPrayerTimeService);

    when(() => mockSettingsCubit.state).thenReturn(const SettingsState(locale: Locale('en')));
    when(() => mockSettingsCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockPrayerTimeService.isPassed(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(true);
    
    final prayerTimes = PrayerTimes(
      Coordinates(0, 0),
      DateComponents.from(DateTime.now()),
      CalculationMethod.muslim_world_league.getParameters(),
    );
    when(() => mockPrayerTimeService.getPrayerTimes(
      latitude: any(named: 'latitude'),
      longitude: any(named: 'longitude'),
      method: any(named: 'method'),
      madhab: any(named: 'madhab'),
      date: any(named: 'date'),
    )).thenReturn(prayerTimes);
  });

  testWidgets('HistoryList displays records correctly', (WidgetTester tester) async {
    final record = DailyRecord(
      id: 'test',
      date: DateTime(2024, 2, 17),
      missedToday: {Salaah.fajr},
      completedToday: const {},
      qada: {
        Salaah.fajr: const MissedCounter(10),
        Salaah.dhuhr: const MissedCounter(0),
        Salaah.asr: const MissedCounter(0),
        Salaah.maghrib: const MissedCounter(0),
        Salaah.isha: const MissedCounter(0),
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: BlocProvider<SettingsCubit>.value(
            value: mockSettingsCubit,
            child: HistoryList(
              records: [record],
              onDelete: (_) {},
            ),
          ),
        ),
      ),
    );

    // Initial state might be collapsed, depends on implementation (sortedKeys.first is expanded)
    await tester.pumpAndSettle();

    // Check for missed icon (close_rounded) for Fajr
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    
    // Check for check icons for other prayers (4 other prayers)
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(4));
  });
}
