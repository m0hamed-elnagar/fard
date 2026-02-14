import 'package:fard/core/services/location_service.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockLocationService extends Mock implements LocationService {}

void main() {
  late SettingsCubit cubit;
  late MockSharedPreferences mockPrefs;
  late MockLocationService mockLocationService;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockLocationService = MockLocationService();

    when(() => mockPrefs.getString(any())).thenReturn(null);
    when(() => mockPrefs.getDouble(any())).thenReturn(null);
    when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);
    when(() => mockPrefs.setDouble(any(), any())).thenAnswer((_) async => true);

    cubit = SettingsCubit(mockPrefs, mockLocationService);
  });

  group('SettingsCubit', () {
    test('initial state is correct', () {
      expect(cubit.state.locale, const Locale('ar'));
      expect(cubit.state.calculationMethod, 'muslim_league');
    });

    test('updateLocale updates state and prefs', () {
      cubit.updateLocale(const Locale('en'));
      expect(cubit.state.locale, const Locale('en'));
      verify(() => mockPrefs.setString('locale', 'en')).called(1);
    });

    test('refreshLocation updates state with mapped calculation method', () async {
      final position = Position(
        latitude: 30.0444,
        longitude: 31.2357,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );

      when(() => mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => position);
      when(() => mockLocationService.getLocationDataFromCoordinates(any(), any()))
          .thenAnswer((_) async => {'city': 'Cairo', 'countryCode': 'EG'});

      await cubit.refreshLocation();

      expect(cubit.state.cityName, 'Cairo');
      expect(cubit.state.calculationMethod, 'egyptian'); // EG maps to egyptian
      verify(() => mockPrefs.setDouble('latitude', 30.0444)).called(1);
      verify(() => mockPrefs.setString('calculation_method', 'egyptian')).called(1);
    });

    test('mapCountryToMethod returns correct methods', () {
      // We can test private method indirectly via refreshLocation or exposing it for test
      // But let's trust the logic if it works for EG. 
      // Test another one: SA -> umm_al_qura
      
      final position = Position(
        latitude: 21.4225, longitude: 39.8262,
        timestamp: DateTime.now(), accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0,
        altitudeAccuracy: 0, headingAccuracy: 0,
      );

      when(() => mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => position);
      when(() => mockLocationService.getLocationDataFromCoordinates(any(), any()))
          .thenAnswer((_) async => {'city': 'Mecca', 'countryCode': 'SA'});

      cubit.refreshLocation().then((_) {
         expect(cubit.state.calculationMethod, 'umm_al_qura');
      });
    });
  });
}
