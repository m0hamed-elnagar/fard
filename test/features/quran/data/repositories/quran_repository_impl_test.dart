import 'package:fard/features/quran/data/datasources/local/quran_local_source.dart';
import 'package:fard/features/quran/data/datasources/remote/quran_remote_source.dart';
import 'package:fard/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockQuranRemoteSource extends Mock implements QuranRemoteSource {}
class MockQuranLocalSource extends Mock implements QuranLocalSource {}

void main() {
  late QuranRepositoryImpl repository;
  late MockQuranRemoteSource mockRemoteSource;
  late MockQuranLocalSource mockLocalSource;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    mockRemoteSource = MockQuranRemoteSource();
    mockLocalSource = MockQuranLocalSource();
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    repository = QuranRepositoryImpl(
      remoteSource: mockRemoteSource,
      localSource: mockLocalSource,
      sharedPreferences: sharedPreferences,
    );
  });

  group('QuranRepositoryImpl downloadAllSurahs', () {
    test('downloadAllSurahs throws exception if getSurahs fails', () async {
      when(() => mockLocalSource.getCachedSurahs()).thenAnswer((_) async => []);
      when(() => mockRemoteSource.getAllSurahs()).thenThrow(Exception('Network Error'));

      expect(
        () => repository.downloadAllSurahs().toList(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
