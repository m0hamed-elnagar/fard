import 'package:fard/core/errors/failure.dart';
import 'package:fard/core/usecases/usecase.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:fard/features/audio/domain/repositories/audio_player_service.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';
import 'package:injectable/injectable.dart';

@injectable
class PlayAudio implements UseCase<void, PlayAudioParams> {
  final AudioRepository audioRepository;
  final AudioPlayerService playerService;
  
  const PlayAudio({
    required this.audioRepository,
    required this.playerService,
  });
  
  @override
  Future<Result<void>> call(PlayAudioParams params) async {
    // 1. Get audio track
    final track = await audioRepository.getAyahAudioTrack(
      reciterId: params.reciterId,
      surahNumber: params.ayah.surahNumber,
      ayahNumber: params.ayah.ayahNumberInSurah,
      quality: params.quality,
    );
    
    // 2. Play using playerService (which handles remote/local switching automatically)
    return playerService.playStreaming(
      track, 
      mode: params.mode,
      metadata: {
        'title': 'Ayah ${params.ayah.ayahNumberInSurah}',
        'artist': params.reciterId,
      },
    );
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
    this.quality = AudioQuality.low64,
    this.audioUrl,
    this.mode = AudioPlayMode.ayah,
  });
}
