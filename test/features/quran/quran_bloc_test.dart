import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fard/features/quran/data/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/models/surah.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';

class MockQuranRepository extends Mock implements QuranRepository {}

void main() {
  late QuranBloc quranBloc;
  late MockQuranRepository mockQuranRepository;

  setUp(() {
    mockQuranRepository = MockQuranRepository();
    quranBloc = QuranBloc(mockQuranRepository);
  });

  tearDown(() {
    quranBloc.close();
  });

  group('QuranBloc', () {
    final tSurahs = [
      const Surah(
        number: 1,
        name: 'Al-Fatiha',
        englishName: 'The Opening',
        englishNameTranslation: 'The Opening',
        numberOfAyahs: 7,
        revelationType: 'Meccan',
      )
    ];

    final tSurahDetail = SurahDetail(
      number: 1,
      name: 'Al-Fatiha',
      englishName: 'The Opening',
      englishNameTranslation: 'The Opening',
      numberOfAyahs: 7,
      revelationType: 'Meccan',
      ayahs: [],
    );

    blocTest<QuranBloc, QuranState>(
      'emits [isLoading: true, surahs: [...]] when LoadSurahs is added',
      build: () {
        when(() => mockQuranRepository.getSurahs()).thenAnswer((_) async => tSurahs);
        return quranBloc;
      },
      act: (bloc) => bloc.add(const QuranEvent.loadSurahs()),
      expect: () => [
        const QuranState(isLoading: true),
        QuranState(isLoading: false, surahs: tSurahs),
      ],
    );

    blocTest<QuranBloc, QuranState>(
      'emits [isLoading: true, error: "error"] when LoadSurahs fails',
      build: () {
        when(() => mockQuranRepository.getSurahs()).thenThrow(Exception('Failed to fetch'));
        return quranBloc;
      },
      act: (bloc) => bloc.add(const QuranEvent.loadSurahs()),
      expect: () => [
        const QuranState(isLoading: true),
        const QuranState(isLoading: false, error: 'Exception: Failed to fetch'),
      ],
    );

    blocTest<QuranBloc, QuranState>(
      'emits [isLoading: true, selectedSurahDetail: ...] when LoadSurahDetails is added',
      build: () {
        when(() => mockQuranRepository.getSurahDetail(any()))
            .thenAnswer((_) async => tSurahDetail);
        return quranBloc;
      },
      act: (bloc) => bloc.add(const QuranEvent.loadSurahDetails(1)),
      expect: () => [
        const QuranState(isLoading: true),
        QuranState(isLoading: false, selectedSurahDetail: tSurahDetail),
      ],
    );
  });
}
