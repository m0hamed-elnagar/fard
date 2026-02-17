import 'package:fard/core/errors/failure.dart';
import 'package:fard/core/usecases/usecase.dart';
import 'package:fard/features/quran/domain/repositories/audio_repository.dart';
import 'package:fard/features/quran/domain/repositories/audio_player_service.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';

class PlayAudio implements UseCase<void, PlayAudioParams> {
  final AudioRepository audioRepository;
  final AudioPlayerService playerService;
  
  const PlayAudio({
    required this.audioRepository,
    required this.playerService,
  });
  
  @override
  Future<Result<void>> call(PlayAudioParams params) async {
    // 1. Get audio URL/info
    final audioResult = await audioRepository.getAudioUrl(
      ayah: params.ayah,
      reciterId: params.reciterId,
      quality: params.quality,
      audioUrl: params.audioUrl,
    );
    
    if (audioResult.isFailure) {
      return Result.failure(audioResult.failure!);
    }
    
    final audioSource = audioResult.data!;
    
    // 2. Check if downloaded
    final isDownloadedResult = await audioRepository.isAudioDownloaded(
      ayah: params.ayah,
      reciterId: params.reciterId,
    );
    
    final bool isDownloaded = isDownloadedResult.isSuccess && isDownloadedResult.data == true;
    
    // 3. Play from appropriate source
    if (isDownloaded && audioSource.localPath != null) {
      return playerService.playLocal(audioSource.localPath!, mode: params.mode);
    } else {
      return playerService.playStreaming(audioSource.url, mode: params.mode);
    }
  }
}

class PlayAudioParams {
  final AyahNumber ayah;
  final String reciterId;
  final AudioQuality quality;
  final String? audioUrl;
  final AudioPlayMode mode;
  
  const PlayAudioParams({
    required this.ayah,
    required this.reciterId,
    this.quality = AudioQuality.medium,
    this.audioUrl,
    this.mode = AudioPlayMode.surah,
  });
}
