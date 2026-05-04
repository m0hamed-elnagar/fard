import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/services/location_service.dart';

part 'location_prayer_state.freezed.dart';

@freezed
sealed class LocationPrayerState with _$LocationPrayerState {
  const factory LocationPrayerState({
    double? latitude,
    double? longitude,
    String? cityName,
    @Default('muslim_league') String calculationMethod,
    @Default('shafi') String madhab,
    @Default(0) int hijriAdjustment,
    LocationStatus? lastLocationStatus,
  }) = _LocationPrayerState;
}
