import 'package:bloc_test/bloc_test.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/azkar/domain/azkar_item.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAzkarRepository extends Mock implements AzkarRepository {}

void main() {
  late AzkarBloc azkarBloc;
  late MockAzkarRepository mockAzkarRepository;

  final testAzkar = [
    const AzkarItem(
      category: 'Morning',
      zekr: 'Zekr 1',
      description: 'Desc 1',
      count: 3,
      reference: 'Ref 1',
      currentCount: 0,
    ),
  ];

  setUp(() {
    setupAzkarFallback();
    mockAzkarRepository = MockAzkarRepository();
    azkarBloc = AzkarBloc(mockAzkarRepository);
  });

  tearDown(() {
    azkarBloc.close();
  });

  group('AzkarBloc', () {
    blocTest<AzkarBloc, AzkarState>(
      'emits correct states when loadCategories is added',
      setUp: () {
        when(() => mockAzkarRepository.getCategories())
            .thenAnswer((_) async => ['Morning', 'Evening']);
      },
      build: () => azkarBloc,
      act: (bloc) => bloc.add(const AzkarEvent.loadCategories()),
      expect: () => [
        const AzkarState(isLoading: true),
        const AzkarState(isLoading: false, categories: ['Morning', 'Evening']),
      ],
    );

    blocTest<AzkarBloc, AzkarState>(
      'emits correct states when loadAzkar is added',
      setUp: () {
        when(() => mockAzkarRepository.getAzkarByCategory('Morning'))
            .thenAnswer((_) async => testAzkar);
      },
      build: () => azkarBloc,
      act: (bloc) => bloc.add(const AzkarEvent.loadAzkar('Morning')),
      expect: () => [
        const AzkarState(isLoading: true),
        AzkarState(isLoading: false, azkar: testAzkar, currentCategory: 'Morning'),
      ],
    );

    blocTest<AzkarBloc, AzkarState>(
      'updates item count and saves progress when incrementCount is added',
      setUp: () {
        when(() => mockAzkarRepository.saveProgress(any()))
            .thenAnswer((_) async => {});
      },
      build: () => azkarBloc,
      seed: () => AzkarState(azkar: testAzkar, currentCategory: 'Morning'),
      act: (bloc) => bloc.add(const AzkarEvent.incrementCount(0)),
      expect: () => [
        AzkarState(
          currentCategory: 'Morning',
          azkar: [
            testAzkar[0].copyWith(currentCount: 1),
          ],
        ),
      ],
      verify: (_) {
        verify(() => mockAzkarRepository.saveProgress(any())).called(1);
      },
    );

    blocTest<AzkarBloc, AzkarState>(
      'resets category and reloads items when resetCategory is added',
      setUp: () {
        when(() => mockAzkarRepository.resetCategory('Morning'))
            .thenAnswer((_) async => {});
        when(() => mockAzkarRepository.getAzkarByCategory('Morning'))
            .thenAnswer((_) async => [testAzkar[0].copyWith(currentCount: 0)]);
      },
      build: () => azkarBloc,
      act: (bloc) => bloc.add(const AzkarEvent.resetCategory('Morning')),
      expect: () => [
        const AzkarState(isLoading: true),
        AzkarState(isLoading: false, azkar: [testAzkar[0].copyWith(currentCount: 0)]),
      ],
      verify: (_) {
        verify(() => mockAzkarRepository.resetCategory('Morning')).called(1);
      },
    );
  });
}

// Fallback for Mocktail
void setupAzkarFallback() {
  registerFallbackValue(const AzkarItem(
    category: '', zekr: '', description: '', count: 0, reference: ''
  ));
}
