import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:fard/features/audio/data/repositories/audio_repository_impl.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late AudioRepositoryImpl repository;
  late MockHttpClient mockClient;

  setUp(() async {
    mockClient = MockHttpClient();
    repository = AudioRepositoryImpl(client: mockClient);
    SharedPreferences.setMockInitialValues({});
    
    registerFallbackValue(Uri());
  });

  group('AudioRepositoryImpl Reciter Injection', () {
    test('should inject Ali Jaber and Yasser Al-Dosari at the top of the list', () async {
      // Mock API response with some other reciters but NOT Ali Jaber/Yasser
      final mockApiResponse = {
        'code': 200,
        'status': 'OK',
        'data': [
          {
            'identifier': 'ar.alafasy',
            'name': 'Mishary Rashid Alafasy',
            'englishName': 'Alafasy',
            'language': 'ar',
            'format': 'audio'
          },
          {
            'identifier': 'ar.husary',
            'name': 'Mahmoud Khalil Al-Husary',
            'englishName': 'Husary',
            'language': 'ar',
            'format': 'audio'
          }
        ]
      };

      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(json.encode(mockApiResponse), 200));

      final result = await repository.getAvailableReciters();

      expect(result.isSuccess, true);
      final reciters = result.data!;

      // Verify they are at the top
      expect(reciters[0].identifier, equals('ar.alijaber'));
      expect(reciters[1].identifier, equals('ar.yasseraldossari'));
      
      // Verify they have the correct names
      expect(reciters[0].englishName, equals('Ali Jaber'));
      expect(reciters[1].englishName, equals('Yasser Al-Dosari'));

      // Verify original reciters are still there
      expect(reciters.any((r) => r.identifier == 'ar.alafasy'), true);
      expect(reciters.any((r) => r.identifier == 'ar.husary'), true);
    });

    test('should move them to the top even if API returns them in a different position', () async {
      // Mock API response that ALREADY includes them but at the bottom
      final mockApiResponse = {
        'code': 200,
        'status': 'OK',
        'data': [
          {
            'identifier': 'ar.alafasy',
            'name': 'Alafasy',
            'englishName': 'Alafasy',
            'language': 'ar',
            'format': 'audio'
          },
          {
            'identifier': 'ar.alijaber',
            'name': 'Old Name',
            'englishName': 'Old English Name',
            'language': 'ar',
            'format': 'audio'
          }
        ]
      };

      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response(json.encode(mockApiResponse), 200));

      final result = await repository.getAvailableReciters();

      expect(result.isSuccess, true);
      final reciters = result.data!;

      // Should be at index 0 because it was moved
      expect(reciters[0].identifier, equals('ar.alijaber'));
      // Should have our hardcoded name, not the "Old Name" from API
      expect(reciters[0].englishName, equals('Ali Jaber'));
      
      // Ensure no duplicates
      expect(reciters.where((r) => r.identifier == 'ar.alijaber').length, equals(1));
    });

    test('should still return injected reciters when API fails and cache is empty', () async {
      when(() => mockClient.get(any()))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      // First call fails, returns failure (or tries cache)
      await repository.getAvailableReciters();
      
      // Since cache is empty in this setup, it might return failure or empty list depending on impl
      // But getCachedReciters should ALWAYS have them
      final cachedResult = await repository.getCachedReciters();
      expect(cachedResult.data!.any((r) => r.identifier == 'ar.alijaber'), true);
      expect(cachedResult.data!.any((r) => r.identifier == 'ar.yasseraldossari'), true);
    });

    test('should verify popularity list consistency', () {
      expect(Reciter.popularReciters.contains('ar.alijaber'), true);
      expect(Reciter.popularReciters.contains('ar.yasseraldossari'), true);
      // Verify they are at the very beginning of the popular list
      expect(Reciter.popularReciters[0], equals('ar.alijaber'));
      expect(Reciter.popularReciters[1], equals('ar.yasseraldossari'));
    });
  });
}
