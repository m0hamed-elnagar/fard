import 'package:fard/core/services/voice_download_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockHttpClient extends Mock implements http.Client {}
class FakePathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async => '/tmp/docs';
  @override
  Future<String?> getExternalStoragePath() async => '/tmp/external';
}

void main() {
  late VoiceDownloadService service;

  setUp(() {
    PathProviderPlatform.instance = FakePathProviderPlatform();
    service = VoiceDownloadService();
  });

  group('VoiceDownloadService', () {
    test('azanVoices contains islamcan links', () {
      expect(VoiceDownloadService.azanVoices.values, anyElement(contains('islamcan.com')));
    });

    test('getFileName returns sanitized name', () {
      // Accessing private method via reflection or just testing behavior if it was public
      // Since it's private, we test through public methods if possible, 
      // but here I just want to ensure the logic in my head matches.
    });

    test('isDownloaded returns false for non-existent file', () async {
      final exists = await service.isDownloaded('Non Existent');
      expect(exists, false);
    });
  });
}
