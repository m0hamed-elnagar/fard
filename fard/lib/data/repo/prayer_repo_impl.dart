import 'package:hive/hive.dart';
import '../../domain/models/daily_record.dart';
import '../../domain/models/salaah.dart';
import '../../domain/repositories/prayer_repo.dart';
import '../entities/daily_record_entity.dart';
import '../mappers/daily_record_mapper.dart';

class PrayerRepoImpl implements PrayerRepo {
  final Box<DailyRecordEntity> _box;
  PrayerRepoImpl(this._box);

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Future<void> saveToday(DailyRecord record) async =>
      await _box.put(record.id, DailyRecordMapper.toEntity(record));

  @override
  Future<void> deleteRecord(DateTime date) async {
    final key = _dateKey(date);
    await _box.delete(key);
  }

  @override
  Future<DailyRecord?> loadRecord(DateTime date) async {
    final key = _dateKey(date);
    final entity = _box.get(key);
    return entity != null ? DailyRecordMapper.toDomain(entity) : null;
  }

  @override
  Future<Map<DateTime, DailyRecord>> loadMonth(int year, int month) async {
    final results = <DateTime, DailyRecord>{};
    for (final entry in _box.toMap().entries) {
      final date =
          DateTime.fromMillisecondsSinceEpoch(entry.value.dateMillis);
      if (date.year == year && date.month == month) {
        results[DateTime(date.year, date.month, date.day)] =
            DailyRecordMapper.toDomain(entry.value);
      }
    }
    return results;
  }

  @override
  Future<Map<Salaah, int>> calculateRemaining(
      DateTime from, DateTime to) async {
    final totals = <Salaah, int>{};
    for (final s in Salaah.values) {
      totals[s] = 0;
    }
    final records = _box.values.where((e) {
      final d = DateTime.fromMillisecondsSinceEpoch(e.dateMillis);
      return d.isAfter(from.subtract(const Duration(days: 1))) &&
          d.isBefore(to.add(const Duration(days: 1)));
    });
    for (final r in records) {
      for (final entry in r.qadaValues.entries) {
        final salaah = Salaah.values[entry.key];
        totals[salaah] = (totals[salaah] ?? 0) + entry.value;
      }
    }
    return totals;
  }

  @override
  Future<DailyRecord?> loadLastSavedRecord() async {
    if (_box.isEmpty) return null;
    final sorted = _box.values.toList()
      ..sort((a, b) => b.dateMillis.compareTo(a.dateMillis));
    return DailyRecordMapper.toDomain(sorted.first);
  }

  @override
  Future<List<DailyRecord>> loadAllRecords() async {
    final sorted = _box.values.toList()
      ..sort((a, b) => b.dateMillis.compareTo(a.dateMillis));
    return sorted.map(DailyRecordMapper.toDomain).toList();
  }
}
