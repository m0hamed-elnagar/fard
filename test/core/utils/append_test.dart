import 'dart:io';
import 'dart:typed_data';
import 'package:fard/core/utils/file_download_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  group('FileDownloadUtils.appendToFile', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('append_test');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('appends bytes correctly to an existing file', () async {
      final file = File(path.join(tempDir.path, 'test.bin'));
      
      // 1. Initial write
      await file.writeAsBytes(Uint8List.fromList([1, 2, 3]));
      
      // 2. Append
      await FileDownloadUtils.appendToFile(
        bytes: Uint8List.fromList([4, 5, 6]),
        path: file.path,
      );
      
      final result = await file.readAsBytes();
      expect(result, equals([1, 2, 3, 4, 5, 6]));
    });
  });
}
