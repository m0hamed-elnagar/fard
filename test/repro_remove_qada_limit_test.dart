import 'package:adhan/adhan.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockPrayerRepo extends Mock implements PrayerRepo {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}

void main() {
  late MockPrayerRepo repo;
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;

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
    getIt.reset();
    repo = MockPrayerRepo();
    prefs = MockSharedPreferences();
    prayerTimeService = MockPrayerTimeService();

    getIt.registerSingleton<SharedPreferences>(prefs);
    getIt.registerSingleton<PrayerTimeService>(prayerTimeService);

    when(() => prayerTimeService.isPassed(any(), 
        prayerTimes: any(named: 'prayerTimes'), 
        date: any(named: 'date'))).thenReturn(true);
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

  group('PrayerTrackerBloc - Remove Qada Limit Repro', () {
    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Removing today\'s missed prayer should increment completedQadaToday',
      build: () => PrayerTrackerBloc(repo, prefs, prayerTimeService),
      act: (bloc) async {
        bloc.add(PrayerTrackerEvent.load(today));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const PrayerTrackerEvent.removeQada(Salaah.fajr));
        await Future.delayed(const Duration(milliseconds: 100));
      },
      verify: (bloc) {
        bloc.state.maybeMap(
          loaded: (l) {
            expect(l.qadaStatus[Salaah.fajr]?.value, 0);
            expect(l.completedQadaToday[Salaah.fajr], 1);
          },
          orElse: () => fail('State should be loaded'),
        );
      },
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Toggling today\'s missed prayer to DONE should increment completedQadaToday',
      build: () => PrayerTrackerBloc(repo, prefs, prayerTimeService),
      act: (bloc) async {
        bloc.add(PrayerTrackerEvent.load(today));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const PrayerTrackerEvent.togglePrayer(Salaah.fajr));
        await Future.delayed(const Duration(milliseconds: 100));
      },
      verify: (bloc) {
        bloc.state.maybeMap(
          loaded: (l) {
            expect(l.qadaStatus[Salaah.fajr]?.value, 0);
            expect(l.completedQadaToday[Salaah.fajr], 1);
          },
          orElse: () => fail('State should be loaded'),
        );
      },
    );
  });
}
