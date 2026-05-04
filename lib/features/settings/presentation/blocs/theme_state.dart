import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/custom_theme.dart';

part 'theme_state.freezed.dart';

@freezed
sealed class ThemeState with _$ThemeState {
  const factory ThemeState({
    required Locale locale,
    @Default('emerald') String themePresetId,
    Map<String, String>? customThemeColors,
    @Default([]) List<CustomTheme> savedCustomThemes,
    String? activeCustomThemeId,
  }) = _ThemeState;
}
