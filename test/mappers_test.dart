import 'package:fard/data/entities/daily_record_entity.dart';
import 'package:fard/data/mappers/daily_record_mapper.dart';
import 'package:fard/domain/models/daily_record.dart';
import 'package:fard/domain/models/missed_counter.dart';
import 'package:fard/domain/models/salaah.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DailyRecordMapper', () {
    final date = DateTime(2024, 1, 1);
    
    test('converts entity to domain correctly', () {
      final entity = DailyRecordEntity(
        id: '1',
        dateMillis: date.millisecondsSinceEpoch,
        missedIndices: [0, 2], // fajr, asr
        qadaValues: {0: 10, 1: 5},
      );

      final domain = DailyRecordMapper.toDomain(entity);

      expect(domain.id, '1');
      expect(domain.date, date);
      expect(domain.missedToday, {Salaah.fajr, Salaah.asr});
      expect(domain.qada[Salaah.fajr]?.value, 10);
      expect(domain.qada[Salaah.dhuhr]?.value, 5);
    });

    test('converts domain to entity correctly', () {
      final domain = DailyRecord(
        id: '2',
        date: date,
        missedToday: {Salaah.maghrib},
        qada: {Salaah.maghrib: const MissedCounter(20)},
      );

      final entity = DailyRecordMapper.toEntity(domain);

      expect(entity.id, '2');
      expect(entity.dateMillis, date.millisecondsSinceEpoch);
      expect(entity.missedIndices, [3]); // maghrib index
      expect(entity.qadaValues[3], 20);
    });
  });
}
