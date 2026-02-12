import '../models/daily_record.dart';
import '../models/salaah.dart';

abstract interface class PrayerRepo {
  Future<void> saveToday(DailyRecord record);
  Future<void> deleteRecord(DateTime date);
  Future<DailyRecord?> loadRecord(DateTime date);
  Future<Map<DateTime, DailyRecord>> loadMonth(int year, int month);
  Future<Map<Salaah, int>> calculateRemaining(DateTime from, DateTime to);
  Future<DailyRecord?> loadLastSavedRecord();
  Future<List<DailyRecord>> loadAllRecords();
}
