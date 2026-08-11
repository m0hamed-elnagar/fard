import 'dart:io';
import 'dart:ui' as ui;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:injectable/injectable.dart';

enum LocationStatus { success, serviceDisabled, denied, deniedForever, error }

@singleton
class LocationService {
  Future<LocationStatus> checkLocationStatus() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationStatus.serviceDisabled;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationStatus.deniedForever;
    }

    return LocationStatus.success;
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  Future<Position?> getCurrentPosition() async {
    final status = await checkLocationStatus();
    if (status != LocationStatus.success) {
      return null;
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, String?>?> getLocationDataFromCoordinates(
    double latitude,
    double longitude, {
    String? localeIdentifier,
  }) async {
    if (Platform.isWindows) {
      return null; // Geocoding not supported on Windows
    }

    try {
      ui.Locale? parsedLocale;
      if (localeIdentifier != null && localeIdentifier.isNotEmpty) {
        final parts = localeIdentifier.split('_');
        parsedLocale = parts.length > 1 ? ui.Locale(parts[0], parts[1]) : ui.Locale(parts[0]);
      }
      
      final geocoding = Geocoding(locale: parsedLocale);
      List<Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        
        // Find the best non-empty name representing the city/region
        String? city = place.locality;
        if (city == null || city.trim().isEmpty) {
          city = place.subAdministrativeArea;
        }
        if (city == null || city.trim().isEmpty) {
          city = place.administrativeArea;
        }
        if (city == null || city.trim().isEmpty) {
          city = place.subLocality;
        }
        if (city == null || city.trim().isEmpty) {
          city = place.name;
        }

        final trimmedCity = cleanCityName(city);

        return {
          'city': trimmedCity,
          'countryCode': place.isoCountryCode,
        };
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static String? cleanCityName(String? name) {
    if (name == null) return null;
    final cleaned = name
        .replaceAll(
          RegExp(r'(?<=^|\s)(m[ae]dina[ht]?|m[ae]dinet)(?=$|\s)', caseSensitive: false),
          '',
        )
        .replaceAll(RegExp(r'(?<=^|\s)(مدينة|مدينه)(?=$|\s)'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isNotEmpty ? cleaned : null;
  }
}
