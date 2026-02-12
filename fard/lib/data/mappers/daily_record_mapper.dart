import '../../domain/models/daily_record.dart';
import '../../domain/models/missed_counter.dart';
import '../../domain/models/salaah.dart';
import '../entities/daily_record_entity.dart';

class DailyRecordMapper {
  static DailyRecord toDomain(DailyRecordEntity e) => DailyRecord(
        id: e.id,
        date: DateTime.fromMillisecondsSinceEpoch(e.dateMillis),
        missedToday: e.missedIndices.map((i) => Salaah.values[i]).toSet(),
        qada: {
          for (final entry in e.qadaValues.entries)
            Salaah.values[entry.key]: MissedCounter(entry.value),
        },
      );

  static DailyRecordEntity toEntity(DailyRecord m) => DailyRecordEntity(
        id: m.id,
        dateMillis: m.date.millisecondsSinceEpoch,
        missedIndices: m.missedToday.map((s) => s.index).toList(),
        qadaValues: m.qada.map((k, v) => MapEntry(k.index, v.value)),
      );
}
