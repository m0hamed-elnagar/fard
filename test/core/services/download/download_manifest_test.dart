import 'package:fard/core/models/download_entry.dart';
import 'package:fard/core/services/download/download_manifest_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'dart:io';

void main() {
  late DownloadManifestService manifestService;
  late Box<DownloadEntry> box;
  final tempDir = Directory.systemTemp.createTempSync('hive_test');

  setUpAll(() async {
    Hive.init(tempDir.path);
    Hive.registerAdapter(DownloadEntryAdapter());
    Hive.registerAdapter(DownloadStatusAdapter());
    box = await Hive.openBox<DownloadEntry>(DownloadManifestServiceImpl.boxName);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    await box.clear();
    manifestService = DownloadManifestServiceImpl();
  });

  group('DownloadManifestService Tests', () {
    test('upsertEntry and getEntry should work', () async {
      final entry = DownloadEntry(
        fileId: 'test_file_1',
        relativePath: 'test/path/1.mp3',
        contentType: 'audio',
        url: 'https://example.com/1.mp3',
        expectedSize: 1000,
        status: DownloadStatus.pending,
        updatedAt: DateTime.now(),
        reciterId: 'husary',
        surahNumber: 1,
        ayahNumber: 1,
      );

      await manifestService.upsertEntry(entry);
      final retrieved = await manifestService.getEntry('test_file_1');

      expect(retrieved, isNotNull);
      expect(retrieved!.fileId, equals('test_file_1'));
      expect(retrieved.status, equals(DownloadStatus.pending));
    });

    test('getEntriesByStatus should work', () async {
      final entry1 = DownloadEntry(
        fileId: 'file1',
        relativePath: 'path1',
        contentType: 'audio',
        url: 'url1',
        expectedSize: 100,
        status: DownloadStatus.completed,
        updatedAt: DateTime.now(),
      );
      final entry2 = DownloadEntry(
        fileId: 'file2',
        relativePath: 'path2',
        contentType: 'audio',
        url: 'url2',
        expectedSize: 100,
        status: DownloadStatus.pending,
        updatedAt: DateTime.now(),
      );

      await manifestService.upsertEntry(entry1);
      await manifestService.upsertEntry(entry2);

      final completed = await manifestService.getEntriesByStatus(DownloadStatus.completed);
      expect(completed.length, equals(1));
      expect(completed.first.fileId, equals('file1'));
    });

    test('deleteEntriesByReciter should work', () async {
       final entry1 = DownloadEntry(
        fileId: 'file1',
        relativePath: 'path1',
        contentType: 'audio',
        url: 'url1',
        expectedSize: 100,
        status: DownloadStatus.completed,
        updatedAt: DateTime.now(),
        reciterId: 'reciter1',
      );
      final entry2 = DownloadEntry(
        fileId: 'file2',
        relativePath: 'path2',
        contentType: 'audio',
        url: 'url2',
        expectedSize: 100,
        status: DownloadStatus.completed,
        updatedAt: DateTime.now(),
        reciterId: 'reciter2',
      );

      await manifestService.upsertEntry(entry1);
      await manifestService.upsertEntry(entry2);

      await manifestService.deleteEntriesByReciter('reciter1');
      
      final all = box.values.toList();
      expect(all.length, equals(1));
      expect(all.first.reciterId, equals('reciter2'));
    });
   group('Watch entry tests', () {
      test('watchEntry should emit events', () async {
        final entry = DownloadEntry(
          fileId: 'watch_test',
          relativePath: 'path',
          contentType: 'audio',
          url: 'url',
          expectedSize: 100,
          status: DownloadStatus.pending,
          updatedAt: DateTime.now(),
        );

        final stream = manifestService.watchEntry('watch_test');
        
        // Use a future to wait for the update
        final future = stream.first;

        await manifestService.upsertEntry(entry);
        
        final retrievedEntry = await future;
        expect(retrievedEntry?.fileId, equals('watch_test'));
        expect(retrievedEntry?.status, equals(DownloadStatus.pending));
      });
    });
  });
}
