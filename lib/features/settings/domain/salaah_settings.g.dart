// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salaah_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SalaahSettings _$SalaahSettingsFromJson(Map<String, dynamic> json) =>
    _SalaahSettings(
      salaah: $enumDecode(_$SalaahEnumMap, json['salaah']),
      isAzanEnabled: json['isAzanEnabled'] as bool? ?? true,
      isReminderEnabled: json['isReminderEnabled'] as bool? ?? true,
      reminderMinutesBefore:
          (json['reminderMinutesBefore'] as num?)?.toInt() ?? 15,
      azanSound: json['azanSound'] as String?,
    );

Map<String, dynamic> _$SalaahSettingsToJson(_SalaahSettings instance) =>
    <String, dynamic>{
      'salaah': _$SalaahEnumMap[instance.salaah]!,
      'isAzanEnabled': instance.isAzanEnabled,
      'isReminderEnabled': instance.isReminderEnabled,
      'reminderMinutesBefore': instance.reminderMinutesBefore,
      'azanSound': instance.azanSound,
    };

const _$SalaahEnumMap = {
  Salaah.fajr: 'fajr',
  Salaah.dhuhr: 'dhuhr',
  Salaah.asr: 'asr',
  Salaah.maghrib: 'maghrib',
  Salaah.isha: 'isha',
};
