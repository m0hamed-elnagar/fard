import 'dart:io';
import 'package:fard/core/services/notification/sound_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  late SoundManager soundManager;

  setUpAll(() {
    PackageInfo.setMockInitialValues(
      appName: 'Fard',
      packageName: 'com.qada.fard',
      version: '1.0',
      buildNumber: '1',
      buildSignature: '',
      installerStore: '',
    );
  });

  setUp(() async {
    soundManager = SoundManager();
    await soundManager.init();
  });

  group('SoundManager', () {
    test('getSoundUriForChannel returns file URI for local files', () async {
      final tempDir = await Directory.systemTemp.createTemp();
      final tempFile = File('${tempDir.path}/azan.mp3');
      await tempFile.writeAsBytes([0, 1, 2, 3]);
      
      final String customPath = tempFile.path;
      final uri = await soundManager.getSoundUriForChannel(customPath);
      
      expect(uri, isNotNull);
      expect(uri, startsWith('file://'));
      expect(uri, contains('azan.mp3'));
      
      await tempDir.delete(recursive: true);
    });

    test('getSoundUriForChannel handles default', () async {
      final uri = await soundManager.getSoundUriForChannel('default');
      expect(uri, isNull);
    });
  });
}
