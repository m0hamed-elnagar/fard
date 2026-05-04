import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_presets.dart';
import '../../domain/entities/custom_theme.dart';
import '../../domain/entities/theme_preset.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/apply_theme_preset.dart';
import '../../domain/usecases/get_available_theme_presets.dart';
import '../../domain/usecases/save_custom_theme.dart';
import 'theme_state.dart';

@injectable
class ThemeCubit extends Cubit<ThemeState> {
  final SettingsRepository _repo;
  final ApplyThemePreset _applyTheme;
  final SaveCustomTheme _saveCustomTheme;
  final GetAvailableThemePresets _getPresets;

  ThemeCubit(
    this._repo,
    this._applyTheme,
    this._saveCustomTheme,
    this._getPresets,
  ) : super(
          ThemeState(
            locale: _repo.locale,
            themePresetId: _repo.themePresetId,
            customThemeColors: _repo.customThemeColors,
            savedCustomThemes: _repo.savedCustomThemes,
            activeCustomThemeId: _repo.activeCustomThemeId,
          ),
        );

  void updateLocale(Locale loc) {
    _updateLocaleAsync(loc);
  }

  Future<void> _updateLocaleAsync(Locale loc) async {
    await _repo.updateLocale(loc);
    emit(state.copyWith(locale: loc));
  }

  void toggleLocale() => updateLocale(
        state.locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar'),
      );

  List<ThemePreset> getAvailablePresets() {
    return _getPresets.execute();
  }

  ThemePreset getCurrentThemePreset() {
    if (state.themePresetId == 'custom') {
      return const ThemePreset(
        id: 'custom',
        name: 'Custom',
        nameAr: 'مخصص',
        primaryColor: AppTheme.primary,
        accentColor: AppTheme.accent,
        backgroundColor: Color(0xFF0D1117),
        surfaceColor: Color(0xFF161B22),
        surfaceLightColor: Color(0xFF21262D),
        cardBorderColor: Color(0xFF3D444D),
        textColor: Color(0xFFF0F6FC),
        textSecondaryColor: Color(0xFFD1D5DA),
        icon: Icons.palette,
        isDark: true,
      );
    }
    return ThemePresets.getById(state.themePresetId);
  }

  Future<void> selectThemePreset(String presetId) async {
    try {
      await _applyTheme.execute(presetId);

      emit(
        state.copyWith(
          themePresetId: presetId,
          customThemeColors: null,
        ),
      );
    } catch (e) {
      debugPrint('ThemeCubit: Error selecting theme preset: $e');
    }
  }

  Future<void> saveCustomTheme(Map<String, String> colors) async {
    try {
      await _saveCustomTheme.execute(colors);

      emit(
        state.copyWith(
          themePresetId: 'custom',
          customThemeColors: colors,
        ),
      );
    } catch (e) {
      debugPrint('ThemeCubit: Error saving custom theme: $e');
    }
  }

  Future<void> addCustomTheme(CustomTheme theme) async {
    try {
      await _repo.addCustomTheme(theme);
      emit(
        state.copyWith(
          savedCustomThemes: [...state.savedCustomThemes, theme],
          themePresetId: 'custom',
          activeCustomThemeId: theme.id,
          customThemeColors: theme.toColorMap(),
        ),
      );
    } catch (e) {
      debugPrint('ThemeCubit: Error adding custom theme: $e');
    }
  }

  Future<void> updateCustomTheme(String themeId, Map<String, String> colors) async {
    try {
      await _repo.updateCustomTheme(themeId, colors);
      final updated = state.savedCustomThemes.map((t) {
        return t.id == themeId ? t.copyWithColors(colors) : t;
      }).toList();
      emit(
        state.copyWith(
          savedCustomThemes: updated,
          customThemeColors: state.activeCustomThemeId == themeId ? colors : state.customThemeColors,
        ),
      );
    } catch (e) {
      debugPrint('ThemeCubit: Error updating custom theme: $e');
    }
  }

  Future<void> deleteCustomTheme(String themeId) async {
    try {
      await _repo.deleteCustomTheme(themeId);
      final updated = state.savedCustomThemes.where((t) => t.id != themeId).toList();
      emit(
        state.copyWith(
          savedCustomThemes: updated,
          activeCustomThemeId: state.activeCustomThemeId == themeId ? null : state.activeCustomThemeId,
        ),
      );
    } catch (e) {
      debugPrint('ThemeCubit: Error deleting custom theme: $e');
    }
  }

  Future<void> activateCustomTheme(String themeId) async {
    try {
      await _repo.setActiveCustomTheme(themeId);

      final theme = state.savedCustomThemes.firstWhere(
        (t) => t.id == themeId,
        orElse: () => CustomTheme.defaultPalette(id: themeId, name: 'Unknown'),
      );
      emit(
        state.copyWith(
          themePresetId: 'custom',
          activeCustomThemeId: themeId,
          customThemeColors: theme.toColorMap(),
        ),
      );
    } catch (e) {
      debugPrint('ThemeCubit: Error activating custom theme: $e');
    }
  }

  void refresh() {
    emit(state.copyWith(
      locale: _repo.locale,
      themePresetId: _repo.themePresetId,
      customThemeColors: _repo.customThemeColors,
      savedCustomThemes: _repo.savedCustomThemes,
      activeCustomThemeId: _repo.activeCustomThemeId,
    ));
  }
}

