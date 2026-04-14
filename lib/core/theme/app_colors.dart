import 'package:flutter/material.dart';

/// Extension to access theme colors through BuildContext.
///
/// All colors come from Material 3 ColorScheme, which changes
/// dynamically when the theme preset is switched.
extension AppColors on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;

  // Primary brand colors
  Color get primaryColor => colors.primary;
  Color get primaryContainerColor => colors.primaryContainer;
  Color get secondaryColor => colors.secondary;
  Color get secondaryContainerColor => colors.secondaryContainer;

  // Surface colors
  Color get surfaceColor => colors.surface;
  Color get surfaceContainerColor => colors.surfaceContainer;
  Color get surfaceContainerHighestColor => colors.surfaceContainerHighest;
  Color get backgroundColor => colors.surface;

  // Text colors
  Color get onSurfaceColor => colors.onSurface;
  Color get onSurfaceVariantColor => colors.onSurfaceVariant;

  // Semantic colors
  Color get errorColor => colors.error;
  Color get onErrorColor => colors.onError;

  // Border and divider colors
  Color get outlineColor => colors.outline;
  Color get outlineVariantColor => colors.outlineVariant;

  // Inverse colors
  Color get inverseSurfaceColor => colors.inverseSurface;
  Color get onInverseSurfaceColor => colors.onInverseSurface;

  // Legacy AppTheme color mappings
  Color get primaryLight => colors.primaryContainer;
  Color get missedColor => colors.error;
  Color get neutralColor => colors.onSurfaceVariant;
  Color get surfaceLightColor => colors.surfaceContainerHighest;
  Color get onAccentColor => colors.onSecondary;
}
