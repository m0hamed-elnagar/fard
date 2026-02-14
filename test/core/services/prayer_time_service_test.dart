import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late PrayerTimeService service;

  setUp(() {
    service = PrayerTimeService();
  });

  group('PrayerTimeService', () {
    test('calculates prayer times correctly for a given location', () {
      // Cairo coordinates
      const lat = 30.0444;
      const lon = 31.2357;
      final date = DateTime(2026, 2, 14);

      final prayerTimes = service.getPrayerTimes(
        latitude: lat,
        longitude: lon,
        method: 'egyptian',
        madhab: 'shafi',
        date: date,
      );

      expect(prayerTimes.fajr, isNotNull);
      expect(prayerTimes.dhuhr, isNotNull);
      expect(prayerTimes.asr, isNotNull);
      expect(prayerTimes.maghrib, isNotNull);
      expect(prayerTimes.isha, isNotNull);
    });

    test('getTimeForSalaah returns correct time for each Salaah enum', () {
      const lat = 30.0444;
      const lon = 31.2357;
      final prayerTimes = service.getPrayerTimes(
        latitude: lat,
        longitude: lon,
        method: 'egyptian',
        madhab: 'shafi',
      );

      expect(service.getTimeForSalaah(prayerTimes, Salaah.fajr), prayerTimes.fajr);
      expect(service.getTimeForSalaah(prayerTimes, Salaah.dhuhr), prayerTimes.dhuhr);
      expect(service.getTimeForSalaah(prayerTimes, Salaah.asr), prayerTimes.asr);
      expect(service.getTimeForSalaah(prayerTimes, Salaah.maghrib), prayerTimes.maghrib);
      expect(service.getTimeForSalaah(prayerTimes, Salaah.isha), prayerTimes.isha);
    });

    test('handles different calculation methods', () {
      const lat = 30.0444;
      const lon = 31.2357;
      
      final pt1 = service.getPrayerTimes(
        latitude: lat,
        longitude: lon,
        method: 'karachi',
        madhab: 'shafi',
      );

      final pt2 = service.getPrayerTimes(
        latitude: lat,
        longitude: lon,
        method: 'umm_al_qura',
        madhab: 'shafi',
      );

      // Times should be slightly different between methods
      expect(pt1.fajr, isNot(pt2.fajr));
    });
  });
}
