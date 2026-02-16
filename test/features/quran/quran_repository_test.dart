import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:fard/features/quran/data/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/models/surah.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late QuranRepository repository;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    repository = QuranRepository(client: mockHttpClient);
  });

  group('QuranRepository', () {
    test('getSurahs returns a list of Surah objects when the response is 200', () async {
      final mockResponse = {
        'data': [
          {
            'number': 1,
            'name': 'سُورَةُ الْفَاتِحَةِ',
            'englishName': 'Al-Faatiha',
            'englishNameTranslation': 'The Opening',
            'numberOfAyahs': 7,
            'revelationType': 'Meccan'
          }
        ]
      };

      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => http.Response(
                json.encode(mockResponse),
                200,
                headers: {'content-type': 'application/json; charset=utf-8'},
              ));

      final result = await repository.getSurahs();

      expect(result, isA<List<Surah>>());
      expect(result.first.number, 1);
      expect(result.first.englishName, 'Al-Faatiha');
    });

    test('getSurahDetail returns SurahDetail when the response is 200', () async {
      final mockResponse = {
        'data': {
          'number': 1,
          'name': 'سُورَةُ الْفَاتِحَةِ',
          'englishName': 'Al-Faatiha',
          'englishNameTranslation': 'The Opening',
          'revelationType': 'Meccan',
          'numberOfAyahs': 7,
          'ayahs': [
            {
              'number': 1,
              'text': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              'numberInSurah': 1,
              'juz': 1,
              'manzil': 1,
              'page': 1,
              'ruku': 1,
              'hizbQuarter': 1,
              'sajda': false
            }
          ]
        }
      };

      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => http.Response(
                json.encode(mockResponse),
                200,
                headers: {'content-type': 'application/json; charset=utf-8'},
              ));

      final result = await repository.getSurahDetail(1);

      expect(result, isA<SurahDetail>());
      expect(result.number, 1);
      expect(result.ayahs.first.numberInSurah, 1);
    });

    test('throws an exception when the response is not 200', () async {
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      expect(() => repository.getSurahs(), throwsException);
    });
  });
}
