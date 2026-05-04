import 'package:adhan/adhan.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePrayerRepo extends Fake implements PrayerRepo {
  final Map<DateTime, DailyRecord> _records = {};
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
  @override Future<DailyRecord?> loadRecord(DateTime date) async {
    return _records[_normalize(date)];
  }
  @override Future<void> saveToday(DailyRecord record) async {
    _records[_normalize(record.date)] = record;
  }
  @override Future<DailyRecord?> loadLastRecordBefore(DateTime date) async {
    final normalized = _normalize(date);
    final before = _records.keys.where((d) => d.isBefore(normalized)).toList()..sort((a, b) => b.compareTo(a));
    return before.isEmpty ? null : _records[before.first];
  }
  @override Future<List<DailyRecord>> loadAllRecords() async => _records.values.toList();
  @override Future<Map<DateTime, DailyRecord>> loadMonth(int y, int m) async {
    final result = Map<DateTime, DailyRecord>.from(_records);
    result.removeWhere((k, v) => k.year != y || k.month != m);
    return result;
  }
  @override Future<DailyRecord?> loadLastSavedRecord() async {
    if (_records.isEmpty) return null;
    final sortedKeys = _records.keys.toList()..sort((a, b) => b.compareTo(a));
    return _records[sortedKeys.first];
  }
  @override Future<void> deleteRecord(DateTime date) async => _records.remove(_normalize(date));
}

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}
class MockNotificationService extends Mock implements NotificationService {}
class MockPrayerTimes extends Mock implements PrayerTimes {}

void main() {
  setUpAll(() {
    registerFallbackValue(Salaah.fajr);
  });

  test('Changing yesterday prayer should impact today qada', () async {
    final repo = FakePrayerRepo();
    final prefs = MockSharedPreferences();
    final prayerTimeService = MockPrayerTimeService();
    final notificationService = MockNotificationService();
    final mockPrayerTimes = MockPrayerTimes();

    when(() => prefs.getDouble('latitude')).thenReturn(25.0);
    when(() => prefs.getDouble('longitude')).thenReturn(55.0);
    when(() => prayerTimeService.getPrayerTimes(latitude: any(named: 'latitude'), longitude: any(named: 'longitude'), method: any(named: 'method'), madhab: any(named: 'madhab'), date: any(named: 'date'))).thenReturn(mockPrayerTimes);
    when(() => prayerTimeService.isPassed(any(), prayerTimes: any(named: 'prayerTimes'), date: any(named: 'date'))).thenReturn(true);
    when(() => notificationService.cancelPrayerReminder(any(), forTodayOnly: any(named: 'forTodayOnly'))).thenAnswer((_) async {});

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    repo.saveToday(DailyRecord(id: 'y', date: yesterday, missedToday: {Salaah.fajr}, completedToday: {}, qada: {Salaah.fajr: const MissedCounter(1)}));
    repo.saveToday(DailyRecord(id: 't', date: today, missedToday: {Salaah.fajr}, completedToday: {}, qada: {Salaah.fajr: const MissedCounter(2)}));

    final bloc = PrayerTrackerBloc(repo, prefs, prayerTimeService, notificationService);
    
    bloc.add(PrayerTrackerEvent.load(yesterday));
    await Future.delayed(const Duration(milliseconds: 200));
    
    bloc.add(const PrayerTrackerEvent.togglePrayer(Salaah.fajr));
    await Future.delayed(const Duration(milliseconds: 500));
    
    final rec = await repo.loadRecord(today);
    expect(rec?.qada[Salaah.fajr]?.value, 1);
  });
}
