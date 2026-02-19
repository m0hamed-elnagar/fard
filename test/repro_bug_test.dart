import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';

class MockPrayerRepo extends Mock implements PrayerRepo {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}

void main() {
  late MockPrayerRepo repo;
  late PrayerTrackerBloc bloc;
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;

  final yesterday = DateTime(2024, 2, 18);
  final today = DateTime(2024, 2, 19);

  final dummyPrayerTimes = PrayerTimes(
    Coordinates(30.0, 31.0),
    DateComponents.from(DateTime.now()),
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

    bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService);

    when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {});
    when(() => repo.saveToday(any())).thenAnswer((_) async {});
    
    when(() => prefs.getDouble('latitude')).thenReturn(30.0);
    when(() => prefs.getDouble('longitude')).thenReturn(31.0);
    when(() => prefs.getString('calculation_method')).thenReturn('egyptian');
    when(() => prefs.getString('madhab')).thenReturn('shafi');
    
    when(() => prayerTimeService.getPrayerTimes(
      latitude: any(named: 'latitude'),
      longitude: any(named: 'longitude'),
      method: any(named: 'method'),
      madhab: any(named: 'madhab'),
      date: any(named: 'date'),
    )).thenReturn(dummyPrayerTimes);
  });

  tearDown(() => bloc.close());

  group('Bug Reproduction: Missed yesterday not added to today', () {
    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Fajr missed yesterday should be reflected in Qada today',
      build: () => bloc,
      setUp: () {
        // Last saved record was yesterday, and all prayers were completed (Qada = 0)
        final lastSaved = DailyRecord(
          id: 'yesterday',
          date: yesterday,
          missedToday: {},
          completedToday: Set<Salaah>.from(Salaah.values),
          qada: {for (var s in Salaah.values) s: const MissedCounter(0)},
        );

        when(() => repo.loadRecord(today)).thenAnswer((_) async => null);
        when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => lastSaved);
        when(() => repo.loadLastRecordBefore(today)).thenAnswer((_) async => lastSaved);
        
        // Mock all prayers as PASSED both yesterday and today
        when(() => prayerTimeService.isPassed(any(), 
            prayerTimes: any(named: 'prayerTimes'), 
            date: any(named: 'date'))).thenReturn(true);
      },
      act: (bloc) => bloc.add(PrayerTrackerEvent.load(today)),
      verify: (bloc) {
        final state = bloc.state;
        state.maybeMap(
          loaded: (l) {
            for (final s in Salaah.values) {
               expect(l.qadaStatus[s]?.value, 1, reason: 'Prayer ${s.name} should have 1 qada');
            }
          },
          orElse: () => fail('State should be loaded'),
        );
      },
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'If I missed Fajr yesterday (saved in record) and open today, Qada should include yesterday',
      build: () => bloc,
      setUp: () {
        final lastSaved = DailyRecord(
          id: 'yesterday',
          date: yesterday,
          missedToday: {Salaah.fajr},
          completedToday: Set<Salaah>.from(Salaah.values).where((s) => s != Salaah.fajr).toSet(),
          qada: {
            for (var s in Salaah.values) 
              s: s == Salaah.fajr ? const MissedCounter(1) : const MissedCounter(0)
          },
        );

        when(() => repo.loadRecord(today)).thenAnswer((_) async => null);
        when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => lastSaved);
        when(() => repo.loadLastRecordBefore(today)).thenAnswer((_) async => lastSaved);
        
        // Mock all prayers as PASSED both yesterday and today
        when(() => prayerTimeService.isPassed(any(), 
            prayerTimes: any(named: 'prayerTimes'), 
            date: any(named: 'date'))).thenReturn(true);
      },
      act: (bloc) => bloc.add(PrayerTrackerEvent.load(today)),
      verify: (bloc) {
        final state = bloc.state;
        state.maybeMap(
          loaded: (l) {
            // Yesterday Fajr was 1. Today it's missed again. Total 2.
            // Others were 0 yesterday. Today they are missed. Total 1.
            expect(l.qadaStatus[Salaah.fajr]?.value, 2, reason: 'Fajr should have 2 qada');
            expect(l.qadaStatus[Salaah.dhuhr]?.value, 1, reason: 'Dhuhr should have 1 qada');
          },
          orElse: () => fail('State should be loaded'),
        );
      },
    );
  });
}
