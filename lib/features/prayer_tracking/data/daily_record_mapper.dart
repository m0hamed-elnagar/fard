import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';

class DailyRecordMapper {
  static DailyRecord toDomain(DailyRecordEntity e) => DailyRecord(
        id: e.id,
        date: DateTime.fromMillisecondsSinceEpoch(e.dateMillis),
        missedToday: e.missedIndices.map((i) => Salaah.values[i]).toSet(),
        completedToday: (e.completedIndices ?? []).map((i) => Salaah.values[i]).toSet(),
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
        completedIndices: m.completedToday.map((s) => s.index).toList(),
      );
}
