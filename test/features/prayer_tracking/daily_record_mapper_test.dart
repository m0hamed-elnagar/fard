import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';
import 'package:fard/features/prayer_tracking/data/daily_record_mapper.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyRecordMapper', () {
    final date = DateTime(2026, 2, 26);
    final record = DailyRecord(
      id: '2026-02-26',
      date: date,
      missedToday: {Salaah.fajr, Salaah.dhuhr},
      completedToday: {Salaah.asr},
      qada: {
        Salaah.fajr: const MissedCounter(10),
        Salaah.dhuhr: const MissedCounter(5),
      },
      completedQada: {
        Salaah.fajr: 2,
        Salaah.maghrib: 1,
      },
    );

    test('should map domain model to entity correctly', () {
      final entity = DailyRecordMapper.toEntity(record);

      expect(entity.id, record.id);
      expect(entity.dateMillis, record.date.millisecondsSinceEpoch);
      expect(entity.missedIndices, containsAll([Salaah.fajr.index, Salaah.dhuhr.index]));
      expect(entity.completedIndices, contains(Salaah.asr.index));
      expect(entity.qadaValues[Salaah.fajr.index], 10);
      expect(entity.qadaValues[Salaah.dhuhr.index], 5);
      expect(entity.completedQadaValues?[Salaah.fajr.index], 2);
      expect(entity.completedQadaValues?[Salaah.maghrib.index], 1);
    });

    test('should map entity to domain model correctly', () {
      final entity = DailyRecordEntity(
        id: '2026-02-26',
        dateMillis: date.millisecondsSinceEpoch,
        missedIndices: [Salaah.fajr.index, Salaah.dhuhr.index],
        completedIndices: [Salaah.asr.index],
        qadaValues: {
          Salaah.fajr.index: 10,
          Salaah.dhuhr.index: 5,
        },
        completedQadaValues: {
          Salaah.fajr.index: 2,
          Salaah.maghrib.index: 1,
        },
      );

      final result = DailyRecordMapper.toDomain(entity);

      expect(result.id, entity.id);
      expect(result.date, date);
      expect(result.missedToday, containsAll([Salaah.fajr, Salaah.dhuhr]));
      expect(result.completedToday, contains(Salaah.asr));
      expect(result.qada[Salaah.fajr]?.value, 10);
      expect(result.qada[Salaah.dhuhr]?.value, 5);
      expect(result.completedQada[Salaah.fajr], 2);
      expect(result.completedQada[Salaah.maghrib], 1);
    });

    test('should handle null optional fields in entity when mapping to domain', () {
      final entity = DailyRecordEntity(
        id: '2026-02-26',
        dateMillis: date.millisecondsSinceEpoch,
        missedIndices: [],
        qadaValues: {},
        completedIndices: null,
        completedQadaValues: null,
      );

      final result = DailyRecordMapper.toDomain(entity);

      expect(result.completedToday, isEmpty);
      expect(result.completedQada, isEmpty);
    });
  });
}
