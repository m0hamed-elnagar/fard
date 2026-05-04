import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../audio/domain/repositories/audio_repository.dart';
import '../../domain/salaah_settings.dart';

part 'adhan_state.freezed.dart';

@freezed
sealed class AdhanState with _$AdhanState {
  const factory AdhanState({
    @Default([]) List<SalaahSettings> salaahSettings,
    @Default(AudioQuality.low64) AudioQuality audioQuality,
    @Default(false) bool isAudioPlayerExpanded,
    @Default(false) bool isAzanVoiceDownloading,
  }) = _AdhanState;
}
