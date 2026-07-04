import 'package:fard/core/services/location_service.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/usecases/sync_location_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';

class MockLocationService extends Mock implements LocationService {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late SyncLocationSettings syncLocationSettings;
  late MockLocationService mockLocationService;
  late MockSettingsRepository mockSettingsRepo;

  final dummyPosition = Position(
    latitude: 30.0444,
    longitude: 31.2357,
    timestamp: DateTime.now(),
    accuracy: 1.0,
    altitude: 0.0,
    altitudeAccuracy: 0.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  );

  setUp(() {
    mockLocationService = MockLocationService();
    mockSettingsRepo = MockSettingsRepository();
    syncLocationSettings = SyncLocationSettings(
      mockLocationService,
      mockSettingsRepo,
    );

    // Default mock behavior for repository
    when(() => mockSettingsRepo.calculationMethod).thenReturn('muslim_league');
    when(() => mockSettingsRepo.hijriAdjustment).thenReturn(0);
    when(() => mockSettingsRepo.cityName).thenReturn('Old City');

    when(() => mockSettingsRepo.updateLocation(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        )).thenAnswer((_) async {});
    when(() => mockSettingsRepo.updateLocation(
          cityName: any(named: 'cityName'),
        )).thenAnswer((_) async {});
    when(() => mockSettingsRepo.updateCalculationMethod(any()))
        .thenAnswer((_) async {});
    when(() => mockSettingsRepo.updateHijriAdjustment(any()))
        .thenAnswer((_) async {});
  });

  group('SyncLocationSettings Unit Tests', () {
    test('Successful sync updates and returns new city name', () async {
      when(() => mockLocationService.checkLocationStatus())
          .thenAnswer((_) async => LocationStatus.success);
      when(() => mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => dummyPosition);
      when(() => mockLocationService.getLocationDataFromCoordinates(30.0444, 31.2357))
          .thenAnswer((_) async => {'city': 'Cairo', 'countryCode': 'EG'});

      final result = await syncLocationSettings.execute();

      expect(result.status, LocationStatus.success);
      expect(result.cityName, 'Cairo');
      expect(result.calculationMethod, 'egyptian');
      expect(result.hijriAdjustment, 0); // Egypt has 0 adjustment

      verify(() => mockSettingsRepo.updateLocation(
            latitude: 30.0444,
            longitude: 31.2357,
          )).called(1);
      verify(() => mockSettingsRepo.updateLocation(cityName: 'Cairo')).called(1);
      verify(() => mockSettingsRepo.updateCalculationMethod('egyptian')).called(1);
      verify(() => mockSettingsRepo.updateHijriAdjustment(0)).called(1);
    });

    test('Transient reverse-geocoding failure falls back to cached city name and doesn\'t reset adjustment', () async {
      when(() => mockLocationService.checkLocationStatus())
          .thenAnswer((_) async => LocationStatus.success);
      when(() => mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => dummyPosition);
      when(() => mockLocationService.getLocationDataFromCoordinates(30.0444, 31.2357))
          .thenAnswer((_) async => null); // Geocoding failed

      // Let's set some existing settings that shouldn't be overwritten/lost
      when(() => mockSettingsRepo.cityName).thenReturn('Old City');
      when(() => mockSettingsRepo.calculationMethod).thenReturn('umm_al_qura');
      when(() => mockSettingsRepo.hijriAdjustment).thenReturn(2);

      final result = await syncLocationSettings.execute();

      expect(result.status, LocationStatus.success);
      // cityName should fall back to cached settings
      expect(result.cityName, 'Old City');
      expect(result.calculationMethod, 'umm_al_qura');
      expect(result.hijriAdjustment, 2);

      // Verify that updateLocation is called only for coordinates, not for cityName
      verify(() => mockSettingsRepo.updateLocation(
            latitude: 30.0444,
            longitude: 31.2357,
          )).called(1);
      verifyNever(() => mockSettingsRepo.updateLocation(cityName: any(named: 'cityName')));
      verifyNever(() => mockSettingsRepo.updateCalculationMethod(any()));
      verifyNever(() => mockSettingsRepo.updateHijriAdjustment(any()));
    });

    test('Empty or whitespace-only city name from geocoding falls back to cached city name', () async {
      when(() => mockLocationService.checkLocationStatus())
          .thenAnswer((_) async => LocationStatus.success);
      when(() => mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => dummyPosition);
      when(() => mockLocationService.getLocationDataFromCoordinates(30.0444, 31.2357))
          .thenAnswer((_) async => {'city': '   ', 'countryCode': 'EG'});

      when(() => mockSettingsRepo.cityName).thenReturn('Old City');

      final result = await syncLocationSettings.execute();

      expect(result.status, LocationStatus.success);
      expect(result.cityName, 'Old City');

      verify(() => mockSettingsRepo.updateLocation(
            latitude: 30.0444,
            longitude: 31.2357,
          )).called(1);
      verifyNever(() => mockSettingsRepo.updateLocation(cityName: any(named: 'cityName')));
    });
  });
}
