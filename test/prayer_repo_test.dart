import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';
import 'package:fard/features/prayer_tracking/data/prayer_repo_impl.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:mocktail/mocktail.dart';

class MockBox extends Mock implements Box<DailyRecordEntity> {}

void main() {
  late MockBox mockBox;
  late PrayerRepoImpl repo;
  final date = DateTime(2024, 1, 1);
  final entity = DailyRecordEntity(
    id: '1',
    dateMillis: date.millisecondsSinceEpoch,
    missedIndices: [0], // fajr
    qadaValues: {0: 5, 1: 3},
  );

  setUpAll(() {
    registerFallbackValue(entity);
  });

  setUp(() {
    mockBox = MockBox();
    repo = PrayerRepoImpl(mockBox);
  });

  group('PrayerRepoImpl', () {
    test('saveToday puts entity in box', () async {
      final record = DailyRecord(
        id: '1',
        date: date,
        missedToday: {Salaah.fajr},
        qada: {Salaah.fajr: const MissedCounter(5), Salaah.dhuhr: const MissedCounter(3)},
      );

      when(() => mockBox.put(any(), any())).thenAnswer((_) async {});

      await repo.saveToday(record);

      verify(() => mockBox.put('1', any())).called(1);
    });

    test('loadRecord returns domain model', () async {
      when(() => mockBox.get(any())).thenReturn(entity);

      final result = await repo.loadRecord(date);

      expect(result?.date, date);
      expect(result?.missedToday.contains(Salaah.fajr), true);
      expect(result?.qada[Salaah.fajr]?.value, 5);
    });

    test('loadMonth filters records correctly', () async {
      final jan1 = DailyRecordEntity(id: '1', dateMillis: DateTime(2024, 1, 1).millisecondsSinceEpoch, missedIndices: [], qadaValues: {});
      final jan2 = DailyRecordEntity(id: '2', dateMillis: DateTime(2024, 1, 2).millisecondsSinceEpoch, missedIndices: [], qadaValues: {});
      final feb1 = DailyRecordEntity(id: '3', dateMillis: DateTime(2024, 2, 1).millisecondsSinceEpoch, missedIndices: [], qadaValues: {});

      when(() => mockBox.toMap()).thenReturn({
        '1': jan1,
        '2': jan2,
        '3': feb1,
      });

      final result = await repo.loadMonth(2024, 1);

      expect(result.length, 2);
      expect(result.containsKey(DateTime(2024, 1, 1)), true);
      expect(result.containsKey(DateTime(2024, 1, 2)), true);
    });

    test('calculateRemaining sums qada values in range', () async {
      final r1 = DailyRecordEntity(
        id: '1',
        dateMillis: DateTime(2024, 1, 1).millisecondsSinceEpoch,
        missedIndices: [],
        qadaValues: {0: 10}, // Fajr: 10
      );
      final r2 = DailyRecordEntity(
        id: '2',
        dateMillis: DateTime(2024, 1, 5).millisecondsSinceEpoch,
        missedIndices: [],
        qadaValues: {0: 5, 1: 5}, // Fajr: 5, Dhuhr: 5
      );

      when(() => mockBox.values).thenReturn([r1, r2]);

      final results = await repo.calculateRemaining(DateTime(2024, 1, 1), DateTime(2024, 1, 10));

      expect(results[Salaah.fajr], 15);
      expect(results[Salaah.dhuhr], 5);
      expect(results[Salaah.asr], 0);
    });

    test('loadLastSavedRecord returns newest record', () async {
       final old = DailyRecordEntity(id: 'old', dateMillis: DateTime(2024, 1, 1).millisecondsSinceEpoch, missedIndices: [], qadaValues: {});
       final newest = DailyRecordEntity(id: 'new', dateMillis: DateTime(2024, 1, 10).millisecondsSinceEpoch, missedIndices: [], qadaValues: {});

       when(() => mockBox.isEmpty).thenReturn(false);
       when(() => mockBox.values).thenReturn([old, newest]);

       final result = await repo.loadLastSavedRecord();

       expect(result?.date, DateTime(2024, 1, 10));
    });
  });
}
