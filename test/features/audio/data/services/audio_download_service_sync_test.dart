import 'dart:io';

import 'package:fard/core/errors/failure.dart';
import 'package:fard/core/models/download_entry.dart';
import 'package:fard/core/services/download/download_manifest_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/features/audio/data/services/audio_download_service_impl.dart';
import 'package:fard/features/audio/domain/entities/audio_track.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as path;

class MockAudioRepository extends Mock implements AudioRepository {}
class MockHttpClient extends Mock implements http.Client {}
class MockNotificationService extends Mock implements NotificationService {}
class MockSettingsRepository extends Mock implements SettingsRepository {}
class MockDownloadManifestService extends Mock implements DownloadManifestService {}

class DownloadEntryFake extends Fake implements DownloadEntry {}

void main() {
  setUpAll(() {
    registerFallbackValue(DownloadEntryFake());
    registerFallbackValue(AudioQuality.medium128);
  });

  late AudioDownloadServiceImpl service;
  late MockAudioRepository mockAudioRepository;
  late MockHttpClient mockHttpClient;
  late MockNotificationService mockNotificationService;
  late MockSettingsRepository mockSettingsRepository;
  late MockDownloadManifestService mockManifestService;
  late Directory tempDir;

  setUp(() async {
    mockAudioRepository = MockAudioRepository();
    mockHttpClient = MockHttpClient();
    mockNotificationService = MockNotificationService();
    mockSettingsRepository = MockSettingsRepository();
    mockManifestService = MockDownloadManifestService();
    tempDir = await Directory.systemTemp.createTemp('sync_test');

    service = AudioDownloadServiceImpl(
      mockAudioRepository,
      mockHttpClient,
      mockNotificationService,
      mockSettingsRepository,
      mockManifestService,
    );

    when(() => mockSettingsRepository.audioQuality).thenReturn(AudioQuality.medium128);
    when(() => mockAudioRepository.getAyahCount(any())).thenReturn(7);
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('AudioDownloadServiceImpl._syncManifestForSurah', () {
    test('marks partial files as paused and sets correct downloadedBytes', () async {
      final reciterId = 'test_reciter';
      final surahNumber = 1;
      
      final partialFilePath = path.join(tempDir.path, 'partial.mp3');
      final completeFilePath = path.join(tempDir.path, 'complete.mp3');
      final missingFilePath = path.join(tempDir.path, 'missing.mp3');

      // Create partial file (50KB, no syncword)
      await File(partialFilePath).create(recursive: true);
      await File(partialFilePath).writeAsBytes(List.filled(50 * 1024, 0));

      // Create complete file (15KB, with syncword)
      final completeData = List<int>.filled(15 * 1024, 0);
      completeData[0] = 0xFF;
      completeData[1] = 0xE0;
      await File(completeFilePath).writeAsBytes(completeData);

      final tracks = [
        AudioTrack(remoteUrl: 'url1', localPath: partialFilePath),
        AudioTrack(remoteUrl: 'url2', localPath: completeFilePath),
        AudioTrack(remoteUrl: 'url3', localPath: missingFilePath),
      ];

      when(() => mockAudioRepository.getSurahAudioTracks(
        reciterId: any(named: 'reciterId'),
        surahNumber: any(named: 'surahNumber'),
        ayahCount: any(named: 'ayahCount'),
        quality: any(named: 'quality'),
      )).thenAnswer((_) async => Result.success(tracks));

      when(() => mockManifestService.upsertEntry(any())).thenAnswer((_) async {});

      // Call getSurahStatus which triggers _syncManifestForSurah if manifest is empty
      when(() => mockManifestService.getEntriesBySurah(any(), any())).thenAnswer((_) async => []);

      await service.getSurahStatus(reciterId: reciterId, surahNumber: surahNumber);

      // Verify upsertEntry calls
      final captured = verify(() => mockManifestService.upsertEntry(captureAny())).captured;
      expect(captured.length, equals(3));

      final partialEntry = captured[0] as DownloadEntry;
      final completeEntry = captured[1] as DownloadEntry;
      final missingEntry = captured[2] as DownloadEntry;

      // Partial file
      expect(partialEntry.downloadedBytes, equals(50 * 1024));
      expect(partialEntry.status, equals(DownloadStatus.paused));
      expect(partialEntry.expectedSize, equals(0));

      // Complete file
      expect(completeEntry.downloadedBytes, equals(15 * 1024));
      expect(completeEntry.status, equals(DownloadStatus.completed));
      expect(completeEntry.expectedSize, equals(15 * 1024));

      // Missing file
      expect(missingEntry.downloadedBytes, equals(0));
      expect(missingEntry.status, equals(DownloadStatus.pending));
      expect(missingEntry.expectedSize, equals(0));
    });
  });
}
