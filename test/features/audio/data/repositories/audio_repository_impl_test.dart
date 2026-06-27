import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/features/audio/data/repositories/audio_repository_impl.dart';

class MockHttpClient extends Mock implements http.Client {}

class UriFake extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(UriFake());
  });

  late AudioRepositoryImpl repository;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    repository = AudioRepositoryImpl(client: mockHttpClient);
    // Initialize SharedPreferences with mock values
    SharedPreferences.setMockInitialValues({});
  });

  group('AudioRepositoryImpl - getAvailableReciters', () {
    test('filters out duplicate reciters ending with -2 from remote API', () async {
      final mockApiResponse = {
        'code': 200,
        'status': 'OK',
        'data': [
          {
            'identifier': 'ar.alafasy',
            'language': 'ar',
            'name': 'مشاري العفاسي',
            'englishName': 'Alafasy',
            'format': 'audio',
            'type': 'versebyverse'
          },
          {
            'identifier': 'ar.alafasy-2',
            'language': 'ar',
            'name': 'مشاري العفاسي',
            'englishName': 'Alafasy',
            'format': 'audio',
            'type': 'versebyverse'
          },
          {
            'identifier': 'ar.husary',
            'language': 'ar',
            'name': 'محمود خليل الحصري',
            'englishName': 'Husary',
            'format': 'audio',
            'type': 'versebyverse'
          },
          {
            'identifier': 'ar.husary-2',
            'language': 'ar',
            'name': 'محمود خليل الحصري',
            'englishName': 'Husary',
            'format': 'audio',
            'type': 'versebyverse'
          }
        ]
      };

      when(() => mockHttpClient.get(Uri.parse('https://api.alquran.cloud/v1/edition?format=audio&language=ar'))).thenAnswer(
        (_) async => http.Response.bytes(
          utf8.encode(json.encode(mockApiResponse)),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );

      final result = await repository.getAvailableReciters();

      expect(result.isSuccess, isTrue);
      final reciters = result.data!;
      
      // Should have ar.alafasy, ar.husary, plus the required popular reciters (ar.alijaber, ar.yasseraldossari)
      final identifiers = reciters.map((r) => r.identifier).toList();
      
      expect(identifiers, contains('ar.alafasy'));
      expect(identifiers, contains('ar.husary'));
      expect(identifiers, contains('ar.alijaber'));
      expect(identifiers, contains('ar.yasseraldossari'));
      
      // Should NOT contain any ending with -2
      expect(identifiers.any((id) => id.endsWith('-2')), isFalse);
      // Overall length: 4 (alafasy, husary, plus 2 required ones)
      expect(identifiers.length, equals(4));
    });
  });

  group('AudioRepositoryImpl - getCachedReciters', () {
    test('filters out duplicate reciters ending with -2 from local cache', () async {
      // Setup SharedPreferences with cached reciters that contain -2 entries
      final cachedList = [
        {
          'identifier': 'ar.alafasy',
          'name': 'مشاري العفاسي',
          'englishName': 'Alafasy',
          'language': 'ar',
          'style': 'Murattal'
        },
        {
          'identifier': 'ar.alafasy-2',
          'name': 'مشاري العفاسي',
          'englishName': 'Alafasy',
          'language': 'ar',
          'style': 'Murattal'
        }
      ];

      SharedPreferences.setMockInitialValues({
        'cached_reciters': json.encode(cachedList),
      });

      final result = await repository.getCachedReciters();

      expect(result.isSuccess, isTrue);
      final reciters = result.data!;
      
      final identifiers = reciters.map((r) => r.identifier).toList();
      
      expect(identifiers, contains('ar.alafasy'));
      expect(identifiers, contains('ar.alijaber'));
      expect(identifiers, contains('ar.yasseraldossari'));
      
      // Should NOT contain ar.alafasy-2
      expect(identifiers, isNot(contains('ar.alafasy-2')));
      expect(identifiers.any((id) => id.endsWith('-2')), isFalse);
    });
  });
}
