import 'package:fard/core/theme/twilight_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/settings/domain/entities/theme_preset.dart';
import 'app_theme.dart';

/// Contains all predefined theme presets and theme building logic.
///
/// This class provides:
/// - 4 preset themes: Emerald, Parchment, Rose, Midnight
/// - Theme builder that generates ThemeData from ThemePreset
/// - Custom theme builder with Material 3 auto-derivation
abstract final class ThemePresets {
  // ==================== PRESET DEFINITIONS ====================

  static final emerald = ThemePreset(
    id: 'emerald',
    name: 'Emerald',
    nameAr: 'الزمرد',
    primaryColor: const Color(0xFF2E7D32),
    accentColor: const Color(0xFFFFD54F),
    backgroundColor: const Color(0xFF0D1117),
    surfaceColor: const Color(0xFF161B22),
    surfaceLightColor: const Color(0xFF21262D),
    cardBorderColor: const Color(0xFF3D444D),
    textColor: const Color(0xFFF0F6FC),
    textSecondaryColor: const Color(0xFFD1D5DA),
    icon: Icons.eco_rounded,
    isDark: true,
  );

  static final parchment = ThemePreset(
    id: 'parchment',
    name: 'Parchment',
    nameAr: 'الرق',
    primaryColor: const Color(0xFF8B6914),
    accentColor: const Color(0xFF6B4F1D),
    backgroundColor: const Color(0xFFFFFAF0),
    surfaceColor: const Color(0xFFF5EDD8),
    surfaceLightColor: const Color(0xFFEDE0C4),
    cardBorderColor: const Color(0xFFD4C4A0),
    textColor: const Color(0xFF2C1810),
    textSecondaryColor: const Color(0xFF5C4033),
    icon: Icons.auto_stories_rounded,
    isDark: false,
  );

  static final rose = ThemePreset(
    id: 'rose',
    name: 'Rose',
    nameAr: 'الوردة',
    primaryColor: const Color(0xFFC2185B),
    accentColor: const Color(0xFF880E4F),
    backgroundColor: const Color(0xFFFFF0F5),
    surfaceColor: const Color(0xFFFCE4EC),
    surfaceLightColor: const Color(0xFFF8BBD0),
    cardBorderColor: const Color(0xFFF8BBD0),
    textColor: const Color(0xFF4A0E2E),
    textSecondaryColor: const Color(0xFF880E4F),
    icon: Icons.local_florist_rounded,
    isDark: false,
  );

  static final twilight = ThemePreset(
    id: 'twilight',
    name: 'Twilight',
    nameAr: 'الغسق',
    primaryColor: TwilightThemeColors.primary,
    accentColor: TwilightThemeColors.accent,
    backgroundColor: TwilightThemeColors.background,
    surfaceColor: TwilightThemeColors.surface,
    surfaceLightColor: const Color(0xFF282D3D), // Slightly lighter for surface variants
    cardBorderColor: const Color(0xFF383E50),
    textColor: TwilightThemeColors.text,
    textSecondaryColor: TwilightThemeColors.textSecondary,
    icon: Icons.nightlight_round,
    isDark: true,
  );

  /// All available presets
  static final List<ThemePreset> all = [emerald, parchment, rose, twilight];

  /// Get preset by ID
  static ThemePreset getById(String id) {
    return all.firstWhere(
      (p) => p.id == id,
      orElse: () => emerald,
    );
  }

  // ==================== THEME BUILDERS ====================

  /// Build ThemeData from a ThemePreset
  static ThemeData buildThemeData(ThemePreset preset) {
    final brightness = preset.isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: preset.backgroundColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: preset.primaryColor,
        onPrimary: preset.isDark ? const Color(0xFF003300) : preset.backgroundColor,
        secondary: preset.accentColor,
        onSecondary: preset.isDark ? const Color(0xFF3E2723) : preset.backgroundColor,
        surface: preset.surfaceColor,
        onSurface: preset.textColor,
        error: const Color(0xFFF85149),
        onError: AppTheme.textPrimary,
        outline: preset.cardBorderColor,
        surfaceContainer: preset.surfaceColor,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            color: preset.textColor,
            fontWeight: FontWeight.w700,
            fontSize: 32.0,
          ),
          displayMedium: TextStyle(
            color: preset.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 28.0,
          ),
          headlineLarge: TextStyle(
            color: preset.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 24.0,
          ),
          headlineMedium: TextStyle(
            color: preset.textColor,
            fontWeight: FontWeight.w500,
            fontSize: 20.0,
          ),
          titleLarge: TextStyle(
            color: preset.textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
          titleMedium: TextStyle(
            color: preset.textColor,
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
          ),
          bodyLarge: TextStyle(
            color: preset.textColor,
            fontWeight: FontWeight.w400,
            fontSize: 16.0,
          ),
          bodyMedium: TextStyle(
            color: preset.textSecondaryColor,
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
          ),
          labelLarge: TextStyle(
            color: preset.textColor,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: preset.backgroundColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: preset.textColor,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: preset.surfaceColor,
        indicatorColor: preset.accentColor.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
              color: preset.accentColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return GoogleFonts.outfit(
            color: preset.textSecondaryColor,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: preset.accentColor, size: 24);
          }
          return IconThemeData(
            color: preset.textSecondaryColor,
            size: 24,
          );
        }),
      ),
      cardTheme: CardThemeData(
        color: preset.surfaceColor,
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: BorderSide(color: preset.cardBorderColor, width: 1.0),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: preset.textSecondaryColor,
        textColor: preset.textColor,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: preset.textColor,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: preset.textSecondaryColor,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 8.0,
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: preset.surfaceColor,
        collapsedBackgroundColor: preset.surfaceColor,
        iconColor: preset.textSecondaryColor,
        collapsedIconColor: preset.textSecondaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(24.0)),
          side: BorderSide(color: preset.cardBorderColor, width: 1.0),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(24.0)),
          side: BorderSide(color: preset.cardBorderColor, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: preset.primaryColor,
          foregroundColor: preset.isDark ? const Color(0xFF003300) : AppTheme.textPrimary,
          elevation: 0.0,
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 14.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: preset.textSecondaryColor),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: preset.surfaceColor,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: preset.cardBorderColor, width: 1.0),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: preset.accentColor,
        unselectedLabelColor: preset.textSecondaryColor,
        indicatorColor: preset.accentColor,
        dividerColor: preset.cardBorderColor,
        labelStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: preset.cardBorderColor,
        thickness: 1.0,
      ),
    );
  }

  /// Build custom ThemeData from user-picked colors
  ///
  /// Requires at least primary and accent colors.
  /// Auto-derives remaining colors using Material 3 ColorScheme.fromSeed()
  /// if only 2 colors are provided.
  static ThemeData buildCustomThemeData(Map<String, Color> colors, {
    Color? primary,
    Color? accent,
    Color? backgroundColor,
    Color? surfaceColor,
    Color? surfaceLightColor,
    Color? cardBorderColor,
    Color? textColor,
    Color? textSecondaryColor,
  }) {
    // Auto-derive colors using Material 3
    final primaryColorRaw = primary ?? colors['primary']!;
    final accentColorRaw = accent ?? colors['accent']!;

    final isDark = _isDarkColor(primaryColorRaw);
    final seedScheme2 = ColorScheme.fromSeed(
      seedColor: primaryColorRaw,
      brightness: isDark ? Brightness.dark : Brightness.light,
    );

    final primaryColor = primaryColorRaw;
    final accentColor = accentColorRaw;

    final bgColor = backgroundColor ?? colors['background'] ??
        (isDark ? const Color(0xFF0D1117) : const Color(0xFFF5F5F5));
    final surfaceClr = surfaceColor ?? colors['surface'] ?? seedScheme2.surface;
    final surfaceLight = surfaceLightColor ?? colors['surfaceLight'] ??
        seedScheme2.surfaceContainerHigh;
    final borderClr = cardBorderColor ?? colors['cardBorder'] ??
        seedScheme2.outlineVariant;
    final textClr = textColor ?? colors['text'] ??
        (isDark ? const Color(0xFFF0F6FC) : const Color(0xFF212121));
    final textSecClr = textSecondaryColor ?? colors['textSecondary'] ??
        (isDark ? const Color(0xFFD1D5DA) : const Color(0xFF757575));

    final brightness = isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: isDark ? const Color(0xFF003300) : AppTheme.textPrimary,
        secondary: accentColor,
        onSecondary: isDark ? const Color(0xFF3E2723) : AppTheme.background,
        surface: surfaceClr,
        onSurface: textClr,
        error: const Color(0xFFF85149),
        onError: AppTheme.textPrimary,
        outline: borderClr,
        surfaceContainer: surfaceClr,
        surfaceContainerHighest: surfaceLight,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            color: textClr,
            fontWeight: FontWeight.w700,
            fontSize: 32.0,
          ),
          displayMedium: TextStyle(
            color: textClr,
            fontWeight: FontWeight.w600,
            fontSize: 28.0,
          ),
          headlineLarge: TextStyle(
            color: textClr,
            fontWeight: FontWeight.w600,
            fontSize: 24.0,
          ),
          headlineMedium: TextStyle(
            color: textClr,
            fontWeight: FontWeight.w500,
            fontSize: 20.0,
          ),
          titleLarge: TextStyle(
            color: textClr,
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
          titleMedium: TextStyle(
            color: textClr,
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
          ),
          bodyLarge: TextStyle(
            color: textClr,
            fontWeight: FontWeight.w400,
            fontSize: 16.0,
          ),
          bodyMedium: TextStyle(
            color: textSecClr,
            fontWeight: FontWeight.w400,
            fontSize: 14.0,
          ),
          labelLarge: TextStyle(
            color: textClr,
            fontWeight: FontWeight.w500,
            fontSize: 14.0,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textClr,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceClr,
        indicatorColor: accentColor.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.outfit(
              color: accentColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return GoogleFonts.outfit(
            color: textSecClr,
            fontWeight: FontWeight.w400,
            fontSize: 12,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: accentColor, size: 24);
          }
          return IconThemeData(color: textSecClr, size: 24);
        }),
      ),
      cardTheme: CardThemeData(
        color: surfaceClr,
        elevation: 0.0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
          side: BorderSide(color: borderClr, width: 1.0),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: textSecClr,
        textColor: textClr,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textClr,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: textSecClr,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 8.0,
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: surfaceClr,
        collapsedBackgroundColor: surfaceLight,
        iconColor: textSecClr,
        collapsedIconColor: textSecClr,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(24.0)),
          side: BorderSide(color: borderClr, width: 1.0),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(24.0)),
          side: BorderSide(color: borderClr, width: 1.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDark ? const Color(0xFF003300) : AppTheme.textPrimary,
          elevation: 0.0,
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: textSecClr),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceClr,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: borderClr, width: 1.0),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accentColor,
        unselectedLabelColor: textSecClr,
        indicatorColor: accentColor,
        dividerColor: borderClr,
        labelStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          fontSize: 14.0,
        ),
        unselectedLabelStyle: GoogleFonts.outfit(
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
      ),
      dividerTheme: DividerThemeData(color: borderClr, thickness: 1.0),
    );
  }

  /// Helper to determine if a color is "dark" for auto-deriving theme mode
  static bool _isDarkColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance < 0.4;
  }
}
