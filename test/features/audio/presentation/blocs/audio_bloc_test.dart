import 'package:bloc_test/bloc_test.dart';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/audio/domain/entities/reciter.dart';
import 'package:fard/features/audio/domain/entities/audio_track.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioRepository extends Mock implements AudioRepository {}

class MockAudioPlayerService extends Mock implements AudioPlayerService {}

class MockAudioDownloadService extends Mock implements AudioDownloadService {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late MockAudioRepository mockRepository;
  late MockAudioPlayerService mockPlayerService;
  late MockAudioDownloadService mockDownloadService;
  late MockSettingsRepository mockSettingsRepository;
  late AudioBloc audioBloc;

  setUpAll(() {
    registerFallbackValue(AudioPlayMode.ayah);
    registerFallbackValue(AudioQuality.medium128);
    registerFallbackValue(
      const AudioTrack(remoteUrl: '', localPath: '', isDownloaded: false),
    );
    registerFallbackValue(const Locale('en'));
  });

  final tReciter = const Reciter(
    identifier: 'ar.alafasy',
    name: 'Alafasy',
    englishName: 'Alafasy',
    language: 'ar',
  );

  setUp(() {
    mockRepository = MockAudioRepository();
    mockPlayerService = MockAudioPlayerService();
    mockDownloadService = MockAudioDownloadService();
    mockSettingsRepository = MockSettingsRepository();

    when(() => mockSettingsRepository.locale).thenReturn(const Locale('ar'));

    when(
      () => mockRepository.getCachedReciters(),
    ).thenAnswer((_) async => Result.success([tReciter]));
    when(
      () => mockRepository.getAvailableReciters(),
    ).thenAnswer((_) async => Result.success([tReciter]));
    when(
      () => mockRepository.getCachedReciterData(),
    ).thenAnswer((_) async => const ReciterData(progress: {}, sizes: {}));
    when(
      () => mockRepository.cacheReciterData(any(), any()),
    ).thenAnswer((_) async {});
    when(
      () => mockRepository.shouldPrependBismillah(any(), any()),
    ).thenReturn(false);

    when(
      () => mockDownloadService.getReciterDownloadPercentage(any()),
    ).thenAnswer((_) async => 0.0);

    when(
      () => mockDownloadService.getReciterDownloadedSize(any()),
    ).thenAnswer((_) async => 0);

    when(
      () => mockPlayerService.watchStatus(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockPlayerService.watchError(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockPlayerService.watchPosition(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockPlayerService.watchDuration(),
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => mockPlayerService.watchCurrentIndex(),
    ).thenAnswer((_) => const Stream.empty());
    when(() => mockPlayerService.currentStatus).thenReturn(AudioStatus.idle);
    when(() => mockPlayerService.currentMode).thenReturn(AudioPlayMode.ayah);
    when(() => mockPlayerService.currentPosition).thenReturn(Duration.zero);
    when(() => mockPlayerService.currentDuration).thenReturn(null);
    when(() => mockPlayerService.currentIndex).thenReturn(null);
    when(
      () => mockPlayerService.stop(),
    ).thenAnswer((_) async => Result.success(null));
  });

  AudioBloc buildBloc() {
    return AudioBloc(
      audioRepository: mockRepository,
      playerService: mockPlayerService,
      downloadService: mockDownloadService,
      settingsRepository: mockSettingsRepository,
    );
  }

  group('Audio Quality Handling', () {
    test('initial state has medium128 quality', () {
      audioBloc = buildBloc();
      expect(audioBloc.state.quality, equals(AudioQuality.medium128));
      audioBloc.close();
    });

    blocTest<AudioBloc, AudioState>(
      'falls back to low64 when playStreaming fails for medium128',
      build: () {
        const track128 = AudioTrack(
          remoteUrl: 'url_128',
          localPath: 'path_128',
          isDownloaded: false,
        );
        const track64 = AudioTrack(
          remoteUrl: 'url_64',
          localPath: 'path_64',
          isDownloaded: false,
        );

        when(
          () => mockRepository.getAyahAudioTrack(
            reciterId: any(named: 'reciterId'),
            surahNumber: any(named: 'surahNumber'),
            ayahNumber: any(named: 'ayahNumber'),
            quality: AudioQuality.medium128,
          ),
        ).thenAnswer((_) async => track128);

        when(
          () => mockRepository.getAyahAudioTrack(
            reciterId: any(named: 'reciterId'),
            surahNumber: any(named: 'surahNumber'),
            ayahNumber: any(named: 'ayahNumber'),
            quality: AudioQuality.low64,
          ),
        ).thenAnswer((_) async => track64);

        when(
          () => mockPlayerService.playStreaming(
            track128,
            mode: any(named: 'mode'),
            metadata: any(named: 'metadata'),
          ),
        ).thenAnswer(
          (_) async => Result.failure(const ServerFailure('Failed')),
        );

        when(
          () => mockPlayerService.playStreaming(
            track64,
            mode: any(named: 'mode'),
            metadata: any(named: 'metadata'),
          ),
        ).thenAnswer((_) async => Result.success(null));

        return buildBloc();
      },
      seed: () =>
          AudioState(currentReciter: tReciter, quality: AudioQuality.medium128),
      act: (bloc) =>
          bloc.add(AudioEvent.playAyah(surahNumber: 1, ayahNumber: 1)),
      verify: (_) {
        verify(
          () => mockRepository.getAyahAudioTrack(
            reciterId: any(named: 'reciterId'),
            surahNumber: 1,
            ayahNumber: 1,
            quality: AudioQuality.low64,
          ),
        ).called(1);
      },
    );

    blocTest<AudioBloc, AudioState>(
      'stops fallback loop when low64 fails',
      build: () {
        const track64 = AudioTrack(
          remoteUrl: 'url_64',
          localPath: 'path_64',
          isDownloaded: false,
        );

        when(
          () => mockRepository.getCachedReciters(),
        ).thenAnswer((_) async => Result.success([]));
        when(
          () => mockRepository.getAvailableReciters(),
        ).thenAnswer((_) async => Result.success([]));

        when(
          () => mockRepository.getAyahAudioTrack(
            reciterId: any(named: 'reciterId'),
            surahNumber: any(named: 'surahNumber'),
            ayahNumber: any(named: 'ayahNumber'),
            quality: AudioQuality.low64,
          ),
        ).thenAnswer((_) async => track64);

        when(
          () => mockPlayerService.playStreaming(
            track64,
            mode: any(named: 'mode'),
            metadata: any(named: 'metadata'),
          ),
        ).thenAnswer(
          (_) async => Result.failure(const ServerFailure('Failed again')),
        );

        return buildBloc();
      },
      seed: () =>
          AudioState(quality: AudioQuality.low64, currentReciter: tReciter),
      act: (bloc) =>
          bloc.add(AudioEvent.playAyah(surahNumber: 1, ayahNumber: 1)),
      expect: () => [
        isA<AudioState>().having(
          (s) => s.status,
          'status',
          AudioStatus.loading,
        ),
        isA<AudioState>()
            .having((s) => s.status, 'status', AudioStatus.error)
            .having((s) => s.error, 'error', 'Playback failed: Failed again')
            .having((s) => s.lastErrorMessage, 'lastErrorMessage', null),
        isA<AudioState>()
            .having((s) => s.status, 'status', AudioStatus.error)
            .having((s) => s.error, 'error', 'Playback failed: Failed again')
            .having(
              (s) => s.lastErrorMessage,
              'lastErrorMessage',
              'Failed again',
            ),
      ],
    );
  });
}
