import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fard/features/quran/domain/repositories/audio_player_service.dart';
import 'package:fard/features/quran/domain/usecases/play_audio.dart';
import 'package:fard/features/quran/domain/value_objects/ayah_number.dart';

part 'audio_bloc.freezed.dart';
part 'audio_event.dart';
part 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final PlayAudio playAudio;
  final AudioPlayerService playerService;
  
  AudioBloc({
    required this.playAudio,
    required this.playerService,
  }) : super(const AudioState.initial()) {
    
    playerService.watchStatus().listen((status) {
      add(AudioEvent.statusChanged(status));
    });

    on<AudioEvent>((event, emit) async {
      await event.when(
        play: (ayah, reciterId, audioUrl, mode) => _onPlay(ayah, reciterId, audioUrl, mode, emit),
        pause: () => _onPause(emit),
        resume: () => _onResume(emit),
        stop: () => _onStop(emit),
        statusChanged: (status) async => _onStatusChanged(status, emit),
      );
    });
  }

  Future<void> _onPlay(
    AyahNumber ayah, 
    String reciterId, 
    String? audioUrl, 
    AudioPlayMode mode,
    Emitter<AudioState> emit
  ) async {
    emit(const AudioState.loading());
    final result = await playAudio(PlayAudioParams(
      ayah: ayah,
      reciterId: reciterId,
      audioUrl: audioUrl,
      mode: mode,
    ));

    result.fold(
      (failure) => emit(AudioState.error(failure.message)),
      (_) => null,
    );
  }

  Future<void> _onPause(Emitter<AudioState> emit) async {
    await playerService.pause();
  }

  Future<void> _onResume(Emitter<AudioState> emit) async {
    await playerService.resume();
  }

  Future<void> _onStop(Emitter<AudioState> emit) async {
    await playerService.stop();
  }

  void _onStatusChanged(AudioStatus status, Emitter<AudioState> emit) {
    emit(AudioState.loaded(status: status));
  }
}
