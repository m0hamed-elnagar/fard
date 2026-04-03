// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WidgetDataModel _$WidgetDataModelFromJson(Map<String, dynamic> json) =>
    WidgetDataModel(
      gregorianDate: json['gregorianDate'] as String,
      hijriDate: json['hijriDate'] as String,
      dayOfWeek: json['dayOfWeek'] as String,
      sunrise: json['sunrise'] as String,
      isRtl: json['isRtl'] as bool,
      prayers: (json['prayers'] as List<dynamic>)
          .map((e) => PrayerTimeItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPrayerName: json['nextPrayerName'] as String?,
      nextPrayerTime: (json['nextPrayerTime'] as num?)?.toInt(),
      lastUpdated: (json['lastUpdated'] as num).toInt(),
    );

Map<String, dynamic> _$WidgetDataModelToJson(WidgetDataModel instance) =>
    <String, dynamic>{
      'gregorianDate': instance.gregorianDate,
      'hijriDate': instance.hijriDate,
      'dayOfWeek': instance.dayOfWeek,
      'sunrise': instance.sunrise,
      'isRtl': instance.isRtl,
      'prayers': instance.prayers.map((e) => e.toJson()).toList(),
      'nextPrayerName': instance.nextPrayerName,
      'nextPrayerTime': instance.nextPrayerTime,
      'lastUpdated': instance.lastUpdated,
    };

PrayerTimeItem _$PrayerTimeItemFromJson(Map<String, dynamic> json) =>
    PrayerTimeItem(
      name: json['name'] as String,
      time: json['time'] as String,
      minutesFromMidnight: (json['minutesFromMidnight'] as num).toInt(),
    );

Map<String, dynamic> _$PrayerTimeItemToJson(PrayerTimeItem instance) =>
    <String, dynamic>{
      'name': instance.name,
      'time': instance.time,
      'minutesFromMidnight': instance.minutesFromMidnight,
    };
