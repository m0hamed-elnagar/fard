import 'package:json_annotation/json_annotation.dart';

part 'custom_theme.g.dart';

/// A user-created custom theme with a full palette of 8 colors.
@JsonSerializable(explicitToJson: true)
class CustomTheme {
  final String id;
  final String name;
  final String primary;
  final String accent;
  final String background;
  final String surface;
  final String text;
  final String textSecondary;
  final String cardBorder;
  final String surfaceLight;
  final bool isBuiltIn;

  const CustomTheme({
    required this.id,
    required this.name,
    required this.primary,
    required this.accent,
    required this.background,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.cardBorder,
    required this.surfaceLight,
    this.isBuiltIn = false,
  });

  factory CustomTheme.fromJson(Map<String, dynamic> json) =>
      _$CustomThemeFromJson(json);

  Map<String, dynamic> toJson() => _$CustomThemeToJson(this);

  /// Returns all 8 colors as a map.
  Map<String, String> toColorMap() {
    return {
      'primary': primary,
      'accent': accent,
      'background': background,
      'surface': surface,
      'text': text,
      'textSecondary': textSecondary,
      'cardBorder': cardBorder,
      'surfaceLight': surfaceLight,
    };
  }

  /// Creates a copy with updated colors from a map.
  CustomTheme copyWithColors(Map<String, String> colors) {
    return CustomTheme(
      id: id,
      name: name,
      primary: colors['primary'] ?? primary,
      accent: colors['accent'] ?? accent,
      background: colors['background'] ?? background,
      surface: colors['surface'] ?? surface,
      text: colors['text'] ?? text,
      textSecondary: colors['textSecondary'] ?? textSecondary,
      cardBorder: colors['cardBorder'] ?? cardBorder,
      surfaceLight: colors['surfaceLight'] ?? surfaceLight,
      isBuiltIn: isBuiltIn,
    );
  }

  /// Creates a copy with a new name.
  CustomTheme copyWith({String? name}) {
    return CustomTheme(
      id: id,
      name: name ?? this.name,
      primary: primary,
      accent: accent,
      background: background,
      surface: surface,
      text: text,
      textSecondary: textSecondary,
      cardBorder: cardBorder,
      surfaceLight: surfaceLight,
      isBuiltIn: isBuiltIn,
    );
  }

  /// Creates a theme with default Emerald-derived palette.
  static CustomTheme defaultPalette({required String id, required String name}) {
    return CustomTheme(
      id: id,
      name: name,
      primary: '#2E7D32',
      accent: '#FFD54F',
      background: '#0D1117',
      surface: '#161B22',
      text: '#E6EDF3',
      textSecondary: '#8B949E',
      cardBorder: '#30363D',
      surfaceLight: '#21262D',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomTheme && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
