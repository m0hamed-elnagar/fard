import 'package:adhan/adhan.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/salaah_tile.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockPrayerRepo extends Mock implements PrayerRepo {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}
class MockSettingsCubit extends MockCubit<SettingsState> implements SettingsCubit {}

void main() {
  late MockPrayerRepo repo;
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;
  late MockSettingsCubit settingsCubit;

  final today = DateTime.now();
  final dummyPrayerTimes = PrayerTimes(
    Coordinates(30.0, 31.0),
    DateComponents.from(today),
    CalculationMethod.muslim_world_league.getParameters(),
  );

  setUpAll(() {
    registerFallbackValue(DateTime(2024));
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(DailyRecord(
      id: 'dummy',
      date: DateTime.now(),
      missedToday: {},
      completedToday: {},
      qada: {},
    ));
    registerFallbackValue(dummyPrayerTimes);
  });

  setUp(() {
    getIt.pushNewScope();
    repo = MockPrayerRepo();
    prefs = MockSharedPreferences();
    prayerTimeService = MockPrayerTimeService();
    settingsCubit = MockSettingsCubit();

    getIt.registerSingleton<SharedPreferences>(prefs);
    getIt.registerSingleton<PrayerTimeService>(prayerTimeService);

    when(() => settingsCubit.state).thenReturn(const SettingsState(
      locale: Locale('en'),
      latitude: 30.0,
      longitude: 31.0,
      isQadaEnabled: true,
    ));
    when(() => settingsCubit.stream).thenAnswer((_) => const Stream.empty());

    when(() => prayerTimeService.isPassed(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(true);
    when(() => prayerTimeService.isUpcoming(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(false);
    when(() => prayerTimeService.getPrayerTimes(
      latitude: any(named: 'latitude'),
      longitude: any(named: 'longitude'),
      method: any(named: 'method'),
      madhab: any(named: 'madhab'),
      date: any(named: 'date'),
    )).thenReturn(dummyPrayerTimes);
    
    when(() => repo.loadRecord(any())).thenAnswer((_) async => null);
    when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => null);
    when(() => repo.loadLastRecordBefore(any())).thenAnswer((_) async => null);
    when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {});
    when(() => repo.saveToday(any())).thenAnswer((_) async {});
  });

  tearDown(() {
    getIt.popScope();
  });

  testWidgets('SalaahTile: Manual toggle should decrement _removedInSession', (tester) async {
    bool toggled = false;
    int addedCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SalaahTile(
                salaah: Salaah.fajr,
                qadaCount: 10,
                completedQadaCount: 0,
                isMissedToday: !toggled,
                isCompletedToday: toggled,
                isUpcoming: false,
                isQadaEnabled: true,
                onToggleMissed: () {
                  setState(() => toggled = !toggled);
                },
                onAdd: () => addedCount++,
                onRemove: () {
                  setState(() => toggled = true);
                },
              );
            },
          ),
        ),
      ),
    );

    // Initial state: Fajr missed.
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // 1. Press Minus (Recovers today). 
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pumpAndSettle();
    expect(toggled, isTrue);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    // 2. Press Status Toggle (Manual toggle back to missed).
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    expect(toggled, isFalse);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // 3. Press Add (Undo).
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();
    
    expect(addedCount, 0);
    expect(find.textContaining('Use "Add Qada"'), findsOneWidget);
  });

  group('PrayerTrackerBloc - Undo Limit Fix', () {
    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Toggle back to missed should consume completedQadaToday budget',
      build: () => PrayerTrackerBloc(repo, prefs, prayerTimeService),
      act: (bloc) async {
        bloc.add(PrayerTrackerEvent.load(DateTime(2026, 2, 26)));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const PrayerTrackerEvent.updateQada({Salaah.fajr: 10}));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const PrayerTrackerEvent.removeQada(Salaah.fajr));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const PrayerTrackerEvent.removeQada(Salaah.fajr));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const PrayerTrackerEvent.togglePrayer(Salaah.fajr));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const PrayerTrackerEvent.addQada(Salaah.fajr));
        await Future.delayed(const Duration(milliseconds: 100));
      },
      verify: (bloc) {
        bloc.state.maybeMap(
          loaded: (l) {
            expect(l.qadaStatus[Salaah.fajr]?.value, 10);
            expect(l.completedQadaToday[Salaah.fajr], 0);
          },
          orElse: () => fail('State should be loaded but was ${bloc.state}'),
        );
      },
    );
  });
}
