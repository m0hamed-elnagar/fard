import 'package:freezed_annotation/freezed_annotation.dart';
import '../../prayer_tracking/domain/salaah.dart';

part 'salaah_settings.freezed.dart';
part 'salaah_settings.g.dart';

@freezed
sealed class SalaahSettings with _$SalaahSettings {
  const factory SalaahSettings({
    required Salaah salaah,
    @Default(true) bool isAzanEnabled,
    @Default(true) bool isReminderEnabled,
    @Default(15) int reminderMinutesBefore,
    @Default(false) bool isAfterSalahAzkarEnabled,
    String? azanSound,
  }) = _SalaahSettings;

  factory SalaahSettings.fromJson(Map<String, dynamic> json) =>
      _$SalaahSettingsFromJson(json);
}
