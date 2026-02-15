import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

@freezed
sealed class SettingsState with _$SettingsState {
  const factory SettingsState({
    required Locale locale,
    double? latitude,
    double? longitude,
    String? cityName,
    @Default('muslim_league') String calculationMethod,
    @Default('shafi') String madhab,
    @Default('05:00') String morningAzkarTime,
    @Default('18:00') String eveningAzkarTime,
  }) = _SettingsState;
}
