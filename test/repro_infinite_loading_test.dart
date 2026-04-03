import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockPrayerRepo extends Mock implements PrayerRepo {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockPrayerTimeService extends Mock implements PrayerTimeService {}

void main() {
  late MockPrayerRepo repo;
  late PrayerTrackerBloc bloc;
  late MockSharedPreferences prefs;
  late MockPrayerTimeService prayerTimeService;

  setUpAll(() {
    registerFallbackValue(DateTime(2024));
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(
      DailyRecord(
        id: 'dummy',
        date: DateTime(2024),
        missedToday: {},
        completedToday: {},
        qada: {},
      ),
    );
  });

  setUp(() {
    getIt.reset();
    repo = MockPrayerRepo();
    prefs = MockSharedPreferences();
    prayerTimeService = MockPrayerTimeService();

    getIt.registerSingleton<SharedPreferences>(prefs);
    getIt.registerSingleton<PrayerTimeService>(prayerTimeService);

    bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService);

    // Default stubs
    when(() => repo.loadRecord(any())).thenAnswer((_) async => null);
    when(() => repo.loadLastSavedRecord()).thenAnswer((_) async => null);
    when(() => repo.loadLastRecordBefore(any())).thenAnswer((_) async => null);
    when(() => repo.loadAllRecords()).thenAnswer((_) async => []);
    when(() => repo.loadMonth(any(), any())).thenAnswer((_) async => {});
    when(() => repo.saveToday(any())).thenAnswer((_) async {});
    when(() => prefs.getDouble(any())).thenReturn(null);
    when(
      () => prayerTimeService.isPassed(
        any(),
        prayerTimes: any(named: 'prayerTimes'),
        date: any(named: 'date'),
      ),
    ).thenReturn(false);
  });

  tearDown(() => bloc.close());

  group('Reproduction: Infinite Loading', () {
    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'checkMissedDays should trigger load if no records exist',
      build: () => bloc,
      act: (bloc) => bloc.add(const PrayerTrackerEvent.checkMissedDays()),
      expect: () => [
        const PrayerTrackerState.loading(), // From _onLoad which is added via add()
        isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(loaded: (_) => true, orElse: () => false),
          'should eventually emit loaded',
          true,
        ),
      ],
    );

    blocTest<PrayerTrackerBloc, PrayerTrackerState>(
      'checkMissedDays should trigger load if diff <= 1',
      build: () => bloc,
      setUp: () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        when(() => repo.loadLastSavedRecord()).thenAnswer(
          (_) async => DailyRecord(
            id: 'yesterday',
            date: yesterday,
            missedToday: {},
            completedToday: {},
            qada: {},
          ),
        );
      },
      act: (bloc) => bloc.add(const PrayerTrackerEvent.checkMissedDays()),
      expect: () => [
        const PrayerTrackerState.loading(),
        isA<PrayerTrackerState>().having(
          (s) => s.maybeMap(loaded: (_) => true, orElse: () => false),
          'should eventually emit loaded',
          true,
        ),
      ],
    );
  });
}
