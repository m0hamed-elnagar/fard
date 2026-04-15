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
  
  // Theme-related fields
  final String primaryColorHex;
  final String accentColorHex;
  final String backgroundColorHex;
  final String surfaceColorHex;
  final String textColorHex;
  final String textSecondaryColorHex;

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
    this.primaryColorHex = '#2E7D32',
    this.accentColorHex = '#FFD54F',
    this.backgroundColorHex = '#0D1117',
    this.surfaceColorHex = '#161B22',
    this.textColorHex = '#FFFFFF',
    this.textSecondaryColorHex = '#8B949E',
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
