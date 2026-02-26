import 'package:adhan/adhan.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PrayerTimeService service;

  setUp(() {
    service = PrayerTimeService();
  });

  group('PrayerTimeService', () {
    final date = DateTime(2026, 2, 26);

    test('getPrayerTimes returns valid adhan object', () {
      final times = service.getPrayerTimes(
        latitude: 30.0,
        longitude: 31.0,
        method: 'muslim_league',
        madhab: 'shafi',
        date: date,
      );

      expect(times, isA<PrayerTimes>());
      expect(times.fajr, isNotNull);
    });

    test('isPassed returns true for past dates', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 1));
      expect(service.isPassed(Salaah.fajr, date: pastDate), isTrue);
    });

    test('isPassed returns false for future dates', () {
      final futureDate = DateTime.now().add(const Duration(days: 1));
      expect(service.isPassed(Salaah.fajr, date: futureDate), isFalse);
    });

    test('isPassed fallback logic when prayerTimes is null', () {
      // Mocking "now" is hard without a wrapper, but we can test based on system clock
      // and conservative expectations or just verify the switch coverage.
      // Since we can't easily mock DateTime.now() in pure Dart without a wrapper,
      // we'll rely on current time but check if it matches the service's hardcoded hours.
      
      final now = DateTime.now();
      final isPassed = service.isPassed(Salaah.fajr);
      
      if (now.hour >= 5) {
        expect(isPassed, isTrue);
      } else {
        expect(isPassed, isFalse);
      }
    });

    test('getTimeForSalaah returns correct field', () {
      final times = service.getPrayerTimes(
        latitude: 30.0,
        longitude: 31.0,
        method: 'muslim_league',
        madhab: 'shafi',
        date: date,
      );

      expect(service.getTimeForSalaah(times, Salaah.fajr), times.fajr);
      expect(service.getTimeForSalaah(times, Salaah.dhuhr), times.dhuhr);
      expect(service.getTimeForSalaah(times, Salaah.asr), times.asr);
      expect(service.getTimeForSalaah(times, Salaah.maghrib), times.maghrib);
      expect(service.getTimeForSalaah(times, Salaah.isha), times.isha);
    });
  });
}
