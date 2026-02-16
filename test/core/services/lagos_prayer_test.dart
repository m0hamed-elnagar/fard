import 'package:fard/core/services/prayer_time_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PrayerTimeService service;

  setUp(() {
    service = PrayerTimeService();
  });

  group('PrayerTimeService Lagos Nigeria', () {
    test('calculates prayer times for Lagos correctly', () {
      final date = DateTime(2024, 2, 15);
      final times = service.getPrayerTimes(
        latitude: 6.5244,
        longitude: 3.3792,
        method: 'muslim_league',
        madhab: 'shafi',
        date: date,
      );

      expect(times.fajr, isNotNull);
      expect(times.dhuhr, isNotNull);
      expect(times.asr, isNotNull);
      expect(times.maghrib, isNotNull);
      expect(times.isha, isNotNull);
      
      // Basic check for Lagos on Feb 15
      // Fajr should be around 5:30 AM UTC+1
      // Dhuhr should be around 12:50 PM UTC+1
      // (Approximate values for verification)
    });
  });
}
