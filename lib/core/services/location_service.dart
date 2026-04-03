import 'dart:io';
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
    double longitude,
  ) async {
    if (Platform.isWindows) {
      return null; // Geocoding not supported on Windows
    }

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return {
          'city': place.locality ?? place.subAdministrativeArea,
          'countryCode': place.isoCountryCode,
        };
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
