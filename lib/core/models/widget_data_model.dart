import 'package:json_annotation/json_annotation.dart';

part 'widget_data_model.g.dart';

@JsonSerializable(explicitToJson: true)
class WidgetDataModel {
  final String gregorianDate;
  final String hijriDate;
  final String dayOfWeek;
  final String sunrise;
  final bool isRtl;
  final List<PrayerTimeItem> prayers;
  final String? nextPrayerName;
  final int? nextPrayerTime; // Timestamp in milliseconds
  final int lastUpdated; // Timestamp in milliseconds

  WidgetDataModel({
    required this.gregorianDate,
    required this.hijriDate,
    required this.dayOfWeek,
    required this.sunrise,
    required this.isRtl,
    required this.prayers,
    this.nextPrayerName,
    this.nextPrayerTime,
    required this.lastUpdated,
  });

  factory WidgetDataModel.fromJson(Map<String, dynamic> json) =>
      _$WidgetDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$WidgetDataModelToJson(this);
}

@JsonSerializable()
class PrayerTimeItem {
  final String name;
  final String time; // e.g. "05:30 AM"
  final int minutesFromMidnight; // For native time comparison

  PrayerTimeItem({
    required this.name,
    required this.time,
    required this.minutesFromMidnight,
  });

  factory PrayerTimeItem.fromJson(Map<String, dynamic> json) =>
      _$PrayerTimeItemFromJson(json);
  Map<String, dynamic> toJson() => _$PrayerTimeItemToJson(this);
}
