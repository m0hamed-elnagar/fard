import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fard/core/services/connectivity_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

class TestableConnectivityService extends ConnectivityService {
  final bool mockSocketSuccess;

  TestableConnectivityService({
    super.connectivity,
    this.mockSocketSuccess = true,
  });

  @override
  Future<bool> verifySocketConnection(String host, int port) async {
    return mockSocketSuccess;
  }
}

void main() {
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
  });

  group('ConnectivityService tests', () {
    test('hasNetwork returns true when connectivity_plus returns wifi', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      final service = TestableConnectivityService(connectivity: mockConnectivity);

      final hasNet = await service.hasNetwork();
      expect(hasNet, isTrue);
      verify(() => mockConnectivity.checkConnectivity()).called(1);
    });

    test('hasNetwork falls back to hasInternet (and returns true) when connectivity_plus returns none but socket succeeds', () async {
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      final service = TestableConnectivityService(
        connectivity: mockConnectivity,
        mockSocketSuccess: true,
      );

      final hasNet = await service.hasNetwork();
      expect(hasNet, isTrue);
    });

    test('hasInternet returns true when verifySocketConnection succeeds', () async {
      final service = TestableConnectivityService(
        connectivity: mockConnectivity,
        mockSocketSuccess: true,
      );

      final hasIntel = await service.hasInternet();
      expect(hasIntel, isTrue);
    });
  });
}
