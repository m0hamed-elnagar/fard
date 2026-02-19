import 'package:adhan/adhan.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';

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
    switch (method) {
      case 'muslim_league':
        return CalculationMethod.muslim_world_league.getParameters();
      case 'egyptian':
        return CalculationMethod.egyptian.getParameters();
      case 'karachi':
        return CalculationMethod.karachi.getParameters();
      case 'umm_al_qura':
        return CalculationMethod.umm_al_qura.getParameters();
      case 'dubai':
        return CalculationMethod.dubai.getParameters();
      case 'moonsighting_committee':
        return CalculationMethod.moon_sighting_committee.getParameters();
      case 'north_america':
        return CalculationMethod.north_america.getParameters();
      case 'kuwait':
        return CalculationMethod.kuwait.getParameters();
      case 'qatar':
        return CalculationMethod.qatar.getParameters();
      case 'singapore':
        return CalculationMethod.singapore.getParameters();
      case 'tehran':
        return CalculationMethod.tehran.getParameters();
      case 'turkey':
        return CalculationMethod.turkey.getParameters();
      default:
        return CalculationMethod.muslim_world_league.getParameters();
    }
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
    final normalizedTarget = DateTime(targetDate.year, targetDate.month, targetDate.day);
    
    if (normalizedTarget.isBefore(today)) return true;
    if (normalizedTarget.isAfter(today)) return false;
    
    if (prayerTimes != null) {
      final time = getTimeForSalaah(prayerTimes, salaah);
      return time != null && time.isBefore(now);
    }
    
    // Conservative fallbacks when no location is available
    final hour = now.hour;
    switch (salaah) {
      case Salaah.fajr: return hour >= 5;
      case Salaah.dhuhr: return hour >= 12;
      case Salaah.asr: return hour >= 15;
      case Salaah.maghrib: return hour >= 18;
      case Salaah.isha: return hour >= 20;
    }
  }

  bool isUpcoming(Salaah salaah, {PrayerTimes? prayerTimes, DateTime? date}) {
    final now = DateTime.now();
    final targetDate = date ?? now;
    final today = DateTime(now.year, now.month, now.day);
    final normalizedTarget = DateTime(targetDate.year, targetDate.month, targetDate.day);
    
    if (normalizedTarget.isBefore(today)) return false;
    if (normalizedTarget.isAfter(today)) return true;
    
    if (prayerTimes != null) {
      final time = getTimeForSalaah(prayerTimes, salaah);
      return time != null && time.isAfter(now);
    }
    
    // Conservative fallbacks when no location is available
    final hour = now.hour;
    switch (salaah) {
      case Salaah.fajr: return hour < 5;
      case Salaah.dhuhr: return hour < 12;
      case Salaah.asr: return hour < 15;
      case Salaah.maghrib: return hour < 18;
      case Salaah.isha: return hour < 20;
    }
  }
}
