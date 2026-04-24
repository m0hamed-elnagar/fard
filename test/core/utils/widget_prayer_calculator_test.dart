import 'package:flutter_test/flutter_test.dart';
import 'package:fard/core/utils/widget_prayer_calculator.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:mocktail/mocktail.dart';

class MockPrayerTimeService extends Mock implements PrayerTimeService {}
class MockPrayerTimes extends Mock {
  DateTime get fajr => DateTime(2026, 4, 24, 4, 30);
  DateTime get dhuhr => DateTime(2026, 4, 24, 12, 15);
  DateTime get asr => DateTime(2026, 4, 24, 15, 45);
  DateTime get maghrib => DateTime(2026, 4, 24, 18, 30);
  DateTime get isha => DateTime(2026, 4, 24, 20, 00);
}

void main() {
  group('WidgetPrayerCalculator', () {
    final prayerTimes = MockPrayerTimes();
    late MockPrayerTimeService mockService;

    setUp(() {
      mockService = MockPrayerTimeService();
    });

    test('calculateNextPrayer returns Fajr if before Fajr', () {
      final now = DateTime(2026, 4, 24, 3, 0);
      final next = WidgetPrayerCalculator.calculateNextPrayer(
        now: now,
        prayerTimes: prayerTimes,
        prayerTimeService: mockService,
        latitude: 0,
        longitude: 0,
        method: '',
        madhab: '',
        lang: 'en',
      );

      expect(next.name, equals('Fajr'));
      expect(next.time, equals(prayerTimes.fajr));
    });

    test('calculateNextPrayer returns Dhuhr if after Fajr', () {
      final now = DateTime(2026, 4, 24, 5, 0);
      final next = WidgetPrayerCalculator.calculateNextPrayer(
        now: now,
        prayerTimes: prayerTimes,
        prayerTimeService: mockService,
        latitude: 0,
        longitude: 0,
        method: '',
        madhab: '',
        lang: 'en',
      );

      expect(next.name, equals('Dhuhr'));
    });

    test('getPrayerName returns Arabic names', () {
      expect(WidgetPrayerCalculator.getPrayerName('fajr', 'ar'), equals('الفجر'));
    });
  });
}
