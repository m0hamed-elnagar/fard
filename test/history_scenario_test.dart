import 'package:adhan/adhan.dart';
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
import 'package:bloc_test/bloc_test.dart';

class MockPrayerRepo extends Mock implements PrayerRepo {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}
class MockPrayerTimes extends Mock implements PrayerTimes {}

void main() {
  late MockPrayerRepo repo;
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;
  late PrayerTrackerBloc bloc;

  final day1 = DateTime(2024, 1, 1);
  final day2 = DateTime(2024, 1, 2);

  setUpAll(() {
    registerFallbackValue(day1);
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(DailyRecord(
      id: 'fallback',
      date: DateTime.now(),
      missedToday: const {},
      completedToday: const {},
      qada: const {},
      completedQada: const {},
    ));
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
    when(() => repo.loadLastRecordBefore(any())).thenAnswer((_) async => null);
    when(() => prefs.getDouble(any())).thenReturn(null);
    when(() => prefs.getString(any())).thenReturn(null);
  });

  tearDown(() => bloc.close());

  group('History Scenario Test', () {
    final day1RecordMidDay = DailyRecord(
      id: '2024-01-01',
      date: day1,
      completedToday: {Salaah.fajr, Salaah.dhuhr},
      missedToday: const {}, 
      qada: {for (var s in Salaah.values) s: const MissedCounter(0)},
      completedQada: const {},
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'Day 2 load correctly carries over missed prayers from Day 1 mid-day save',
      build: () => bloc,
      setUp: () {
        when(() => repo.loadRecord(day1)).thenAnswer((_) async => day1RecordMidDay);
        when(() => repo.loadLastRecordBefore(day2)).thenAnswer((_) async => day1RecordMidDay);
        when(() => repo.loadRecord(day2)).thenAnswer((_) async => null);
        
        when(() => prefs.getDouble('latitude')).thenReturn(25.0);
        when(() => prefs.getDouble('longitude')).thenReturn(55.0);
        when(() => prefs.getString('calculation_method')).thenReturn('muslim_league');
        when(() => prefs.getString('madhab')).thenReturn('shafi');
        
        final mockPT = MockPrayerTimes();
        // The bloc calls getPrayerTimes which is a REAL method in our setup if not mocked, 
        // but here it is a Mock. So we must mock it to return non-null.
        when(() => prayerTimeService.getPrayerTimes(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          method: any(named: 'method'),
          madhab: any(named: 'madhab'),
          date: any(named: 'date'),
        )).thenReturn(mockPT);

        // Day 2 Load sees Day 1 as fully passed
        when(() => prayerTimeService.isPassed(any(), prayerTimes: mockPT, date: day1))
            .thenReturn(true);
        // Day 2 hasn't passed anything yet
        when(() => prayerTimeService.isPassed(any(), prayerTimes: any(named: 'prayerTimes'), date: day2))
            .thenReturn(false);
      },
      act: (bloc) => bloc.add(PrayerTrackerEvent.load(day2)),
      expect: () => [
        const PrayerTrackerState.loading(),
        isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(
            loaded: (l) => l.selectedDate == day2 &&
                           l.qadaStatus[Salaah.asr]?.value == 1 && 
                           l.qadaStatus[Salaah.maghrib]?.value == 1 &&
                           l.qadaStatus[Salaah.isha]?.value == 1,
            orElse: () => false,
          ),
          'Day 2 qada should include missed Asr, Maghrib, Isha from Day 1',
          true,
        ),
        isA<PrayerTrackerState>(), // final loaded with month
      ],
    );

    test('History logic: missed Count calculation for past days', () {
      final record = day1RecordMidDay;
      bool isPassed(Salaah s) => true; 

      final passedPrayers = Salaah.values.where((s) => isPassed(s)).toList();
      
      final missedCount = passedPrayers.where((s) => !record.completedToday.contains(s)).length;
      expect(missedCount, 3); 
    });
  });
}
