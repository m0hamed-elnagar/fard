import 'dart:io';
import 'package:fard/core/utils/file_download_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('FileDownloadUtils.isValidAudioFile', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('audio_test');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('returns false for non-existent file', () async {
      final file = File(path.join(tempDir.path, 'missing.mp3'));
      expect(await FileDownloadUtils.isValidAudioFile(file.path), isFalse);
    });

    test('returns false for empty file', () async {
      final file = File(path.join(tempDir.path, 'empty.mp3'));
      await file.create();
      expect(await FileDownloadUtils.isValidAudioFile(file.path), isFalse);
    });

    test('returns false for file too small (< 10KB)', () async {
      final file = File(path.join(tempDir.path, 'small.mp3'));
      await file.writeAsBytes(List.filled(100, 0));
      expect(await FileDownloadUtils.isValidAudioFile(file.path), isFalse);
    });

    test('returns true for valid file (> 10KB and has syncword)', () async {
      final file = File(path.join(tempDir.path, 'valid.mp3'));
      // Syncword 0xFF 0xE0 is at the start (10KB+ size)
      final data = List<int>.filled(12000, 0);
      data[0] = 0xFF;
      data[1] = 0xE0;
      await file.writeAsBytes(data);
      expect(await FileDownloadUtils.isValidAudioFile(file.path), isTrue);
    });
  });

  group('FileDownloadUtils.getExistingFileSizeBytes', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('size_test');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('returns 0 for non-existent file', () async {
      final filePath = path.join(tempDir.path, 'missing.mp3');
      expect(await FileDownloadUtils.getExistingFileSizeBytes(filePath), equals(0));
    });

    test('returns correct size for existing file', () async {
      final file = File(path.join(tempDir.path, 'test.mp3'));
      final data = List<int>.filled(500, 1);
      await file.writeAsBytes(data);
      expect(await FileDownloadUtils.getExistingFileSizeBytes(file.path), equals(500));
    });

    test('returns correct size for larger file', () async {
      final file = File(path.join(tempDir.path, 'large.mp3'));
      final data = List<int>.filled(1024 * 50, 2); // 50KB
      await file.writeAsBytes(data);
      expect(await FileDownloadUtils.getExistingFileSizeBytes(file.path), equals(1024 * 50));
    });
  });
}
