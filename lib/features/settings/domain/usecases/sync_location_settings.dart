import 'package:injectable/injectable.dart';

import '../../../../core/services/location_service.dart';
import '../repositories/settings_repository.dart';

/// Result of syncing location settings to prayer calculation config.
class LocationSyncResult {
  final double? latitude;
  final double? longitude;
  final String? cityName;
  final String calculationMethod;
  final int hijriAdjustment;
  final LocationStatus status;

  const LocationSyncResult({
    this.latitude,
    this.longitude,
    this.cityName,
    required this.calculationMethod,
    required this.hijriAdjustment,
    required this.status,
  });
}

/// Use case: Syncs GPS location → prayer calculation method + Hijri adjustment.
///
/// Encapsulates the full flow:
/// 1. Check location status
/// 2. Fetch GPS coordinates
/// 3. Reverse-geocode to get city + country code
/// 4. Map country → prayer calculation method
/// 5. Apply region-based Hijri calendar adjustment
@injectable
class SyncLocationSettings {
  final LocationService _locationService;
  final SettingsRepository _settingsRepo;

  SyncLocationSettings(this._locationService, this._settingsRepo);

  /// Executes the full location sync flow. Returns a [LocationSyncResult].
  Future<LocationSyncResult> execute() async {
    final status = await _locationService.checkLocationStatus();
    if (status != LocationStatus.success) {
      return LocationSyncResult(
        calculationMethod: _settingsRepo.calculationMethod,
        hijriAdjustment: _settingsRepo.hijriAdjustment,
        status: status,
      );
    }

    final position = await _locationService.getCurrentPosition();
    if (position == null) {
      return LocationSyncResult(
        calculationMethod: _settingsRepo.calculationMethod,
        hijriAdjustment: _settingsRepo.hijriAdjustment,
        status: LocationStatus.error,
      );
    }

    final locationData = await _locationService.getLocationDataFromCoordinates(
      position.latitude,
      position.longitude,
    );

    await _settingsRepo.updateLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );

    String? cityName;
    String? countryCode;
    String method = _settingsRepo.calculationMethod;

    if (locationData != null) {
      cityName = locationData['city'];
      countryCode = locationData['countryCode'];
      if (cityName != null) {
        await _settingsRepo.updateLocation(cityName: cityName);
      }

      if (countryCode != null) {
        method = _mapCountryToMethod(countryCode);
        await _settingsRepo.updateCalculationMethod(method);
      }
    }

    final hijriAdjustment = _computeHijriAdjustment(countryCode);
    await _settingsRepo.updateHijriAdjustment(hijriAdjustment);

    return LocationSyncResult(
      latitude: position.latitude,
      longitude: position.longitude,
      cityName: cityName,
      calculationMethod: method,
      hijriAdjustment: hijriAdjustment,
      status: LocationStatus.success,
    );
  }

  String _mapCountryToMethod(String countryCode) {
    switch (countryCode.toUpperCase()) {
      case 'EG':
        return 'egyptian';
      case 'SA':
        return 'umm_al_qura';
      case 'AE':
        return 'dubai';
      case 'QA':
        return 'qatar';
      case 'KW':
        return 'kuwait';
      case 'PK':
      case 'IN':
      case 'BD':
        return 'karachi';
      case 'SG':
        return 'singapore';
      case 'TR':
        return 'turkey';
      case 'IR':
        return 'tehran';
      case 'US':
      case 'CA':
        return 'north_america';
      case 'NG':
        return 'muslim_league';
      default:
        return 'muslim_league';
    }
  }

  int _computeHijriAdjustment(String? countryCode) {
    if (countryCode == null) return 0;
    final upper = countryCode.toUpperCase();
    if (upper == 'SA' || upper == 'AE' || upper == 'QA' || upper == 'KW') {
      return 0; // Gulf countries (Umm al-Qura based)
    }
    if (upper == 'PK' || upper == 'IN' || upper == 'BD') {
      return 1; // South Asia (local moon sighting may be +1)
    }
    return 0; // Default
  }
}
