import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioRepository extends Mock implements AudioRepository {}
class MockAudioPlayerService extends Mock implements AudioPlayerService {}

void main() {
  late MockAudioRepository mockRepository;
  late MockAudioPlayerService mockPlayerService;
  late AudioBloc audioBloc;

  setUpAll(() {
    registerFallbackValue(AudioPlayMode.ayah);
    registerFallbackValue(AudioQuality.medium128);
  });

  final tReciter = Reciter(
    identifier: 'ar.alafasy',
    name: 'Alafasy',
    englishName: 'Alafasy',
    language: 'ar',
  );

  setUp(() {
    mockRepository = MockAudioRepository();
    mockPlayerService = MockAudioPlayerService();

    when(() => mockRepository.getCachedReciters())
        .thenAnswer((_) async => Result.success([tReciter]));
    when(() => mockRepository.getAvailableReciters())
        .thenAnswer((_) async => Result.success([tReciter]));
    
    when(() => mockPlayerService.watchStatus()).thenAnswer((_) => const Stream.empty());
    when(() => mockPlayerService.watchError()).thenAnswer((_) => const Stream.empty());
    when(() => mockPlayerService.watchPosition()).thenAnswer((_) => const Stream.empty());
    when(() => mockPlayerService.watchDuration()).thenAnswer((_) => const Stream.empty());
    when(() => mockPlayerService.watchCurrentIndex()).thenAnswer((_) => const Stream.empty());
    when(() => mockPlayerService.currentStatus).thenReturn(AudioStatus.idle);

    audioBloc = AudioBloc(
      audioRepository: mockRepository,
      playerService: mockPlayerService,
    );
  });

  tearDown(() {
    audioBloc.close();
  });

  group('Audio Quality Handling', () {
    test('initial state has medium128 quality', () {
      expect(audioBloc.state.quality, equals(AudioQuality.medium128));
    });

    blocTest<AudioBloc, AudioState>(
      'falls back to low64 when playStreaming fails for medium128',
      build: () {
        when(() => mockRepository.getAyahAudioUrl(
              reciterId: any(named: 'reciterId'),
              surahNumber: any(named: 'surahNumber'),
              ayahNumber: any(named: 'ayahNumber'),
              quality: AudioQuality.medium128,
            )).thenReturn('url_128');

        when(() => mockRepository.getAyahAudioUrl(
              reciterId: any(named: 'reciterId'),
              surahNumber: any(named: 'surahNumber'),
              ayahNumber: any(named: 'ayahNumber'),
              quality: AudioQuality.low64,
            )).thenReturn('url_64');
        
        when(() => mockPlayerService.playStreaming('url_128', mode: any(named: 'mode')))
            .thenAnswer((_) async => Result.failure(const ServerFailure('Failed')));
            
        when(() => mockPlayerService.playStreaming('url_64', mode: any(named: 'mode')))
            .thenAnswer((_) async => Result.success(null));

        return audioBloc;
      },
      act: (bloc) => bloc.add(AudioEvent.playAyah(
        surahNumber: 1,
        ayahNumber: 1,
      )),
      verify: (_) {
        // Should have called playAyah again with low64 (via changeQuality event)
        verify(() => mockRepository.getAyahAudioUrl(
              reciterId: any(named: 'reciterId'),
              surahNumber: 1,
              ayahNumber: 1,
              quality: AudioQuality.low64,
            )).called(1);
      },
    );

    blocTest<AudioBloc, AudioState>(
      'stops fallback loop when low64 fails',
      build: () {
        when(() => mockRepository.getAyahAudioUrl(
              reciterId: any(named: 'reciterId'),
              surahNumber: any(named: 'surahNumber'),
              ayahNumber: any(named: 'ayahNumber'),
              quality: AudioQuality.low64,
            )).thenReturn('url_64');
        
        when(() => mockPlayerService.playStreaming('url_64', mode: any(named: 'mode')))
            .thenAnswer((_) async => Result.failure(const ServerFailure('Failed again')));

        return audioBloc;
      },
      seed: () => AudioState(quality: AudioQuality.low64, currentReciter: tReciter),
      act: (bloc) => bloc.add(AudioEvent.playAyah(
        surahNumber: 1,
        ayahNumber: 1,
      )),
      expect: () => [
        isA<AudioState>().having((s) => s.status, 'status', AudioStatus.loading),
        isA<AudioState>().having((s) => s.status, 'status', AudioStatus.error)
                         .having((s) => s.error, 'error', 'Playback failed: Failed again')
                         .having((s) => s.lastErrorMessage, 'lastErrorMessage', null),
        isA<AudioState>().having((s) => s.status, 'status', AudioStatus.error)
                         .having((s) => s.error, 'error', 'Playback failed: Failed again')
                         .having((s) => s.lastErrorMessage, 'lastErrorMessage', 'Failed again'),
      ],
    );
  });
}
