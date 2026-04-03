import 'package:adhan/adhan.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:injectable/injectable.dart';

@singleton
class PrayerTimeService {
  PrayerTimes getPrayerTimes({
    required double latitude,
    required double longitude,
    required String method,
    required String madhab,
    DateTime? date,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = _getParams(method);
    params.madhab = madhab == 'hanafi' ? Madhab.hanafi : Madhab.shafi;

    return PrayerTimes(
      coordinates,
      DateComponents.from(date ?? DateTime.now()),
      params,
    );
  }

  CalculationParameters _getParams(String method) {
    CalculationParameters params;
    switch (method) {
      case 'muslim_league':
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
      case 'egyptian':
        params = CalculationMethod.egyptian.getParameters();
        break;
      case 'karachi':
        params = CalculationMethod.karachi.getParameters();
        break;
      case 'umm_al_qura':
        params = CalculationMethod.umm_al_qura.getParameters();
        break;
      case 'dubai':
        params = CalculationMethod.dubai.getParameters();
        break;
      case 'moonsighting_committee':
        params = CalculationMethod.moon_sighting_committee.getParameters();
        break;
      case 'north_america':
        params = CalculationMethod.north_america.getParameters();
        break;
      case 'kuwait':
        params = CalculationMethod.kuwait.getParameters();
        break;
      case 'qatar':
        params = CalculationMethod.qatar.getParameters();
        break;
      case 'singapore':
        params = CalculationMethod.singapore.getParameters();
        break;
      case 'tehran':
        params = CalculationMethod.tehran.getParameters();
        break;
      case 'turkey':
        params = CalculationMethod.turkey.getParameters();
        break;
      default:
        params = CalculationMethod.muslim_world_league.getParameters();
    }

    // Explicitly set these for parity with Kotlin adhan-java implementation
    params.highLatitudeRule = HighLatitudeRule.middle_of_the_night;

    return params;
  }

  DateTime? getTimeForSalaah(PrayerTimes prayerTimes, Salaah salaah) {
    switch (salaah) {
      case Salaah.fajr:
        return prayerTimes.fajr;
      case Salaah.dhuhr:
        return prayerTimes.dhuhr;
      case Salaah.asr:
        return prayerTimes.asr;
      case Salaah.maghrib:
        return prayerTimes.maghrib;
      case Salaah.isha:
        return prayerTimes.isha;
    }
  }

  bool isPassed(Salaah salaah, {PrayerTimes? prayerTimes, DateTime? date}) {
    final now = DateTime.now();
    final targetDate = date ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final normalizedTarget = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    if (normalizedTarget.isBefore(today)) return true;
    if (normalizedTarget.isAfter(today)) return false;

    if (prayerTimes != null) {
      final time = getTimeForSalaah(prayerTimes, salaah);
      return time != null && time.isBefore(now);
    }

    // Conservative fallbacks when no location is available
    final hour = now.hour;
    switch (salaah) {
      case Salaah.fajr:
        return hour >= 5;
      case Salaah.dhuhr:
        return hour >= 12;
      case Salaah.asr:
        return hour >= 15;
      case Salaah.maghrib:
        return hour >= 18;
      case Salaah.isha:
        return hour >= 20;
    }
  }

  bool isUpcoming(Salaah salaah, {PrayerTimes? prayerTimes, DateTime? date}) {
    final now = DateTime.now();
    final targetDate = date ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final normalizedTarget = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );

    if (normalizedTarget.isBefore(today)) return false;
    if (normalizedTarget.isAfter(today)) return true;

    if (prayerTimes != null) {
      final time = getTimeForSalaah(prayerTimes, salaah);
      return time != null && time.isAfter(now);
    }

    // Conservative fallbacks when no location is available
    final hour = now.hour;
    switch (salaah) {
      case Salaah.fajr:
        return hour < 5;
      case Salaah.dhuhr:
        return hour < 12;
      case Salaah.asr:
        return hour < 15;
      case Salaah.maghrib:
        return hour < 18;
      case Salaah.isha:
        return hour < 20;
    }
  }
}
