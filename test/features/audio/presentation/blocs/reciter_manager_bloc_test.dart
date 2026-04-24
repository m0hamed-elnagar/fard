import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:fard/features/audio/presentation/blocs/manager/reciter_manager_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioRepository extends Mock implements AudioRepository {}
class MockAudioDownloadService extends Mock implements AudioDownloadService {}

void main() {
  late MockAudioRepository mockRepository;
  late MockAudioDownloadService mockDownloadService;

  final tReciter = const Reciter(
    identifier: 'ar.alafasy',
    name: 'Alafasy',
    englishName: 'Alafasy',
    language: 'ar',
  );

  setUp(() {
    mockRepository = MockAudioRepository();
    mockDownloadService = MockAudioDownloadService();

    when(() => mockRepository.getCachedReciters()).thenAnswer((_) async => Result.success([tReciter]));
    when(() => mockRepository.getAvailableReciters()).thenAnswer((_) async => Result.success([tReciter]));
    when(() => mockRepository.getCachedReciterData()).thenAnswer((_) async => const ReciterData(progress: {}, sizes: {}));
    when(() => mockRepository.cacheReciterData(any(), any())).thenAnswer((_) async {});
    when(() => mockRepository.cacheReciters(any())).thenAnswer((_) async {});

    when(() => mockDownloadService.getReciterDownloadPercentage(any())).thenAnswer((_) async => 0.0);
    when(() => mockDownloadService.getReciterDownloadedSize(any())).thenAnswer((_) async => 0);
  });

  ReciterManagerBloc buildBloc() {
    return ReciterManagerBloc(
      audioRepository: mockRepository,
      downloadService: mockDownloadService,
    );
  }

  group('ReciterManagerBloc', () {
    test('initial state is correct', () {
      final bloc = buildBloc();
      expect(bloc.state, const ReciterManagerState());
      bloc.close();
    });

    blocTest<ReciterManagerBloc, ReciterManagerState>(
      'emits correct states when LoadReciters is added',
      build: () => buildBloc(),
      // Skip the emissions from constructor's add(LoadReciters)
      // Actually, since we want to test LoadReciters explicitly, we'll just check if it settles on the right state.
      act: (bloc) => bloc.add(const LoadReciters()),
      verify: (bloc) {
        expect(bloc.state.availableReciters, [tReciter]);
        expect(bloc.state.currentReciter, tReciter);
      },
    );

    blocTest<ReciterManagerBloc, ReciterManagerState>(
      'updates current reciter when SelectReciter is added',
      build: () => buildBloc(),
      act: (bloc) => bloc.add(SelectReciter(tReciter)),
      verify: (bloc) {
        expect(bloc.state.currentReciter, tReciter);
      },
    );
  });
}
