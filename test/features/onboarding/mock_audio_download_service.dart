import 'package:fard/features/audio/domain/services/audio_download_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAudioDownloadService extends Mock implements AudioDownloadService {
  MockAudioDownloadService() {
    when(() => progressStream).thenAnswer((_) => const Stream.empty());
  }
}
