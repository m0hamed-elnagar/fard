import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/prayer_reminder_type.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/entities/custom_theme.dart';
import 'package:fard/features/settings/domain/entities/theme_preset.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/domain/usecases/apply_theme_preset.dart';
import 'package:fard/features/settings/domain/usecases/get_available_theme_presets.dart';
import 'package:fard/features/settings/domain/usecases/save_custom_theme.dart';
import 'package:fard/features/settings/domain/usecases/sync_location_settings.dart';
import 'package:fard/features/settings/domain/usecases/sync_notification_schedule.dart';
import 'package:fard/features/settings/domain/usecases/toggle_after_salah_azkar_usecase.dart';
import 'package:fard/features/settings/domain/usecases/update_calculation_method_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/services/widget_update_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_presets.dart';
import '../../../audio/domain/repositories/audio_repository.dart';
import 'settings_state.dart';

/// Thin presentation-layer cubit for settings UI state.
/// Delegates business logic to domain use cases.
@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repo;
  final LocationService _location;
  final SyncLocationSettings _syncLoc;
  final SyncNotificationSchedule _syncNotif;
  final ToggleAfterSalahAzkarUseCase _toggleAzkar;
  final UpdateCalculationMethodUseCase _updateMethod;
  final ApplyThemePreset _applyTheme;
  final SaveCustomTheme _saveCustomTheme;
  final GetAvailableThemePresets _getPresets;
  final WidgetUpdateService _widget;

  SettingsCubit(
    this._repo,
    this._location,
    this._syncLoc,
    this._syncNotif,
    this._toggleAzkar,
    this._updateMethod,
    this._applyTheme,
    this._saveCustomTheme,
    this._getPresets,
    this._widget,
  ) : super(
        SettingsState(
          locale: const Locale('ar'), // Forced Arabic
          latitude: _repo.latitude,
          longitude: _repo.longitude,
          cityName: _repo.cityName,
          calculationMethod: _repo.calculationMethod,
          madhab: _repo.madhab,
          morningAzkarTime: _repo.morningAzkarTime,
          eveningAzkarTime: _repo.eveningAzkarTime,
          isAfterSalahAzkarEnabled: _repo.isAfterSalahAzkarEnabled,
          reminders: _repo.reminders,
          salaahSettings: _repo.salaahSettings,
          isQadaEnabled: _repo.isQadaEnabled,
          hijriAdjustment: _repo.hijriAdjustment,
          themePresetId: _repo.themePresetId,
          customThemeColors: _repo.customThemeColors,
          savedCustomThemes: _repo.savedCustomThemes,
          activeCustomThemeId: _repo.activeCustomThemeId,
          audioQuality: _repo.audioQuality,
          isAudioPlayerExpanded: _repo.isAudioPlayerExpanded,
          isSalahReminderEnabled: _repo.isSalahReminderEnabled,
          salahReminderOffsetMinutes: _repo.salahReminderOffsetMinutes,
          prayerReminderType: _repo.prayerReminderType,
          enabledSalahReminders: _repo.enabledSalahReminders,
          isWerdReminderEnabled: _repo.isWerdReminderEnabled,
          werdReminderTime: _repo.werdReminderTime,
          isSalawatReminderEnabled: _repo.isSalawatReminderEnabled,
          salawatFrequencyHours: _repo.salawatFrequencyHours,
          salawatStartTime: _repo.salawatStartTime,
          salawatEndTime: _repo.salawatEndTime,
        ),
      );

  void updateAudioPlayerExpanded(bool expanded) {
    try {
      _updateAudioPlayerExpandedAsync(expanded);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateAudioPlayerExpanded: $e');
    }
  }

  Future<void> _updateAudioPlayerExpandedAsync(bool expanded) async {
    await _repo.updateAudioPlayerExpanded(expanded);
    emit(state.copyWith(isAudioPlayerExpanded: expanded));
  }

  void toggleSalahReminder(bool enabled) {
    try {
      _toggleSalahReminderAsync(enabled);
    } catch (e) {
      debugPrint('SettingsCubit: Error in toggleSalahReminder: $e');
    }
  }

  Future<void> _toggleSalahReminderAsync(bool enabled) async {
    emit(state.copyWith(isSalahReminderEnabled: enabled));
    await _repo.updateSalahReminderEnabled(enabled);
    _sync();
  }

  void setSalahReminderOffset(int minutes) {
    try {
      _setSalahReminderOffsetAsync(minutes);
    } catch (e) {
      debugPrint('SettingsCubit: Error in setSalahReminderOffset: $e');
    }
  }

  Future<void> _setSalahReminderOffsetAsync(int minutes) async {
    emit(state.copyWith(salahReminderOffsetMinutes: minutes));
    await _repo.updateSalahReminderOffset(minutes);
    _sync();
  }

  void setPrayerReminderType(PrayerReminderType type) {
    try {
      _setPrayerReminderTypeAsync(type);
    } catch (e) {
      debugPrint('SettingsCubit: Error in setPrayerReminderType: $e');
    }
  }

  Future<void> _setPrayerReminderTypeAsync(PrayerReminderType type) async {
    emit(state.copyWith(prayerReminderType: type));
    await _repo.updatePrayerReminderType(type);
    _sync();
  }

  void toggleSpecificSalahReminder(Salaah salaah) {
    try {
      _toggleSpecificSalahReminderAsync(salaah);
    } catch (e) {
      debugPrint('SettingsCubit: Error in toggleSpecificSalahReminder: $e');
    }
  }

  Future<void> _toggleSpecificSalahReminderAsync(Salaah salaah) async {
    final set = Set<Salaah>.from(state.enabledSalahReminders);
    bool masterEnabled = state.isSalahReminderEnabled;

    if (set.contains(salaah)) {
      set.remove(salaah);
    } else {
      set.add(salaah);
      // Smart Toggle: If enabling a specific prayer but master is OFF, turn it ON
      if (!masterEnabled) {
        masterEnabled = true;
      }
    }

    emit(state.copyWith(
      enabledSalahReminders: set,
      isSalahReminderEnabled: masterEnabled,
    ));

    if (masterEnabled != state.isSalahReminderEnabled) {
      await _repo.updateSalahReminderEnabled(masterEnabled);
    }
    await _repo.updateEnabledSalahReminders(set);
    _sync();
  }

  void toggleWerdReminder(bool enabled) {
    try {
      _toggleWerdReminderAsync(enabled);
    } catch (e) {
      debugPrint('SettingsCubit: Error in toggleWerdReminder: $e');
    }
  }

  Future<void> _toggleWerdReminderAsync(bool enabled) async {
    emit(state.copyWith(isWerdReminderEnabled: enabled));
    await _repo.updateWerdReminderEnabled(enabled);
    _sync();
  }

  void setWerdReminderTime(String time) {
    try {
      _setWerdReminderTimeAsync(time);
    } catch (e) {
      debugPrint('SettingsCubit: Error in setWerdReminderTime: $e');
    }
  }

  Future<void> _setWerdReminderTimeAsync(String time) async {
    emit(state.copyWith(werdReminderTime: time));
    await _repo.updateWerdReminderTime(time);
    _sync();
  }

  void toggleSalawatReminder(bool enabled) {
    try {
      _toggleSalawatReminderAsync(enabled);
    } catch (e) {
      debugPrint('SettingsCubit: Error in toggleSalawatReminder: $e');
    }
  }

  Future<void> _toggleSalawatReminderAsync(bool enabled) async {
    emit(state.copyWith(isSalawatReminderEnabled: enabled));
    await _repo.updateSalawatReminderEnabled(enabled);
    _sync();
  }

  void setSalawatFrequency(int hours) {
    try {
      _setSalawatFrequencyAsync(hours);
    } catch (e) {
      debugPrint('SettingsCubit: Error in setSalawatFrequency: $e');
    }
  }

  Future<void> _setSalawatFrequencyAsync(int hours) async {
    emit(state.copyWith(salawatFrequencyHours: hours));
    await _repo.updateSalawatFrequency(hours);
    _sync();
  }

  void setSalawatStartTime(String time) {
    try {
      _setSalawatStartTimeAsync(time);
    } catch (e) {
      debugPrint('SettingsCubit: Error in setSalawatStartTime: $e');
    }
  }

  Future<void> _setSalawatStartTimeAsync(String time) async {
    emit(state.copyWith(salawatStartTime: time));
    await _repo.updateSalawatStartTime(time);
    _sync();
  }

  void setSalawatEndTime(String time) {
    try {
      _setSalawatEndTimeAsync(time);
    } catch (e) {
      debugPrint('SettingsCubit: Error in setSalawatEndTime: $e');
    }
  }

  Future<void> _setSalawatEndTimeAsync(String time) async {
    emit(state.copyWith(salawatEndTime: time));
    await _repo.updateSalawatEndTime(time);
    _sync();
  }

  void updateAudioQuality(AudioQuality quality) {
    try {
      _updateAudioQualityAsync(quality);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateAudioQuality: $e');
    }
  }

  Future<void> _updateAudioQualityAsync(AudioQuality quality) async {
    await _repo.updateAudioQuality(quality);
    emit(state.copyWith(audioQuality: quality));
  }

  void addReminder(AzkarReminder r) {
    try {
      _addReminderAsync(r);
    } catch (e) {
      debugPrint('SettingsCubit: Error in addReminder: $e');
    }
  }

  Future<void> _addReminderAsync(AzkarReminder r) async {
    await _repo.addReminder(r);
    emit(state.copyWith(reminders: _repo.reminders));
    _sync();
  }

  void removeReminder(int i) {
    try {
      _removeReminderAsync(i);
    } catch (e) {
      debugPrint('SettingsCubit: Error in removeReminder: $e');
    }
  }

  Future<void> _removeReminderAsync(int i) async {
    await _repo.removeReminder(i);
    emit(state.copyWith(reminders: _repo.reminders));
    _sync();
  }

  void updateReminder(int i, AzkarReminder r) {
    try {
      _updateReminderAsync(i, r);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateReminder: $e');
    }
  }

  Future<void> _updateReminderAsync(int i, AzkarReminder r) async {
    await _repo.updateReminder(i, r);
    emit(state.copyWith(reminders: _repo.reminders));
    _sync();
  }

  void toggleReminder(int i) {
    try {
      _toggleReminderAsync(i);
    } catch (e) {
      debugPrint('SettingsCubit: Error in toggleReminder: $e');
    }
  }

  Future<void> _toggleReminderAsync(int i) async {
    await _repo.toggleReminder(i);
    emit(state.copyWith(reminders: _repo.reminders));
    _sync();
  }

  void updateSalaahSettings(SalaahSettings s) {
    try {
      _updateSalaahSettingsAsync(s);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateSalaahSettings: $e');
    }
  }

  Future<void> _updateSalaahSettingsAsync(SalaahSettings s) async {
    final list = List<SalaahSettings>.from(state.salaahSettings);
    final idx = list.indexWhere((e) => e.salaah == s.salaah);
    if (idx != -1) {
      list[idx] = s;
    } else {
      list.add(s);
    }
    await _repo.updateSalaahSettings(list);
    emit(state.copyWith(salaahSettings: list));
    _sync();
  }

  void updateLocale(Locale loc) {
    try {
      _updateLocaleAsync(loc);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateLocale: $e');
    }
  }

  Future<void> _updateLocaleAsync(Locale loc) async {
    await _repo.updateLocale(loc);
    emit(state.copyWith(locale: loc));
    _sync();
    _widgetSync();
  }

  void toggleLocale() => updateLocale(
    state.locale.languageCode == 'ar' ? const Locale('en') : const Locale('ar'),
  );

  Future<void> refreshLocation() async {
    final r = await _syncLoc.execute();
    emit(
      state.copyWith(
        latitude: r.latitude,
        longitude: r.longitude,
        cityName: r.cityName,
        calculationMethod: r.calculationMethod,
        hijriAdjustment: r.hijriAdjustment,
        lastLocationStatus: r.status,
      ),
    );
    if (r.status == LocationStatus.success) {
      Future.delayed(const Duration(seconds: 1), () {
        if (!isClosed) emit(state.copyWith(lastLocationStatus: null));
      });
    }
    _sync();
    _widgetSync();
  }

  Future<void> openLocationSettings() => _location.openLocationSettings();
  Future<void> openAppSettings() => _location.openAppSettings();

  void updateCalculationMethod(String m) {
    try {
      _updateCalculationMethodAsync(m);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateCalculationMethod: $e');
    }
  }

  Future<void> _updateCalculationMethodAsync(String m) async {
    final adj = await _updateMethod.execute(m);
    emit(state.copyWith(calculationMethod: m, hijriAdjustment: adj));
    _sync();
    _widgetSync();
  }

  void updateMadhab(String v) {
    try {
      _updateMadhabAsync(v);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateMadhab: $e');
    }
  }

  Future<void> _updateMadhabAsync(String v) async {
    await _repo.updateMadhab(v);
    emit(state.copyWith(madhab: v));
    _sync();
    _widgetSync();
  }

  void updateMorningAzkarTime(String v) {
    try {
      _updateMorningAzkarTimeAsync(v);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateMorningAzkarTime: $e');
    }
  }

  Future<void> _updateMorningAzkarTimeAsync(String v) async {
    await _repo.updateMorningAzkarTime(v);
    emit(state.copyWith(morningAzkarTime: v));
    _sync();
  }

  void updateEveningAzkarTime(String v) {
    try {
      _updateEveningAzkarTimeAsync(v);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateEveningAzkarTime: $e');
    }
  }

  Future<void> _updateEveningAzkarTimeAsync(String v) async {
    await _repo.updateEveningAzkarTime(v);
    emit(state.copyWith(eveningAzkarTime: v));
    _sync();
  }

  void toggleAfterSalahAzkar() {
    try {
      _toggleAfterSalahAzkarAsync();
    } catch (e) {
      debugPrint('SettingsCubit: Error in toggleAfterSalahAzkar: $e');
    }
  }

  Future<void> _toggleAfterSalahAzkarAsync() async {
    final v = await _toggleAzkar.execute();
    emit(
      state.copyWith(
        isAfterSalahAzkarEnabled: v,
        salaahSettings: _repo.salaahSettings,
      ),
    );
    _sync();
  }

  void updateAllAzanEnabled(bool v) {
    try {
      _updateAllAzanEnabledAsync(v);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateAllAzanEnabled: $e');
    }
  }

  Future<void> _updateAllAzanEnabledAsync(bool v) async {
    await _repo.updateAllAzanEnabled(v);
    emit(state.copyWith(salaahSettings: _repo.salaahSettings));
    _sync();
    _widgetSync();
  }

  void updateAllReminderEnabled(bool v) {
    try {
      _updateAllReminderEnabledAsync(v);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateAllReminderEnabled: $e');
    }
  }

  Future<void> _updateAllReminderEnabledAsync(bool v) async {
    await _repo.updateAllReminderEnabled(v);
    emit(state.copyWith(salaahSettings: _repo.salaahSettings));
    _sync();
    _widgetSync();
  }

  void updateAllAzanSound(String? v) {
    try {
      _updateAllAzanSoundAsync(v);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateAllAzanSound: $e');
    }
  }

  Future<void> _updateAllAzanSoundAsync(String? v) async {
    await _repo.updateAllAzanSound(v);
    emit(state.copyWith(salaahSettings: _repo.salaahSettings));
    _sync();
    _widgetSync();
  }

  void updateAllReminderMinutes(int v) {
    try {
      _updateAllReminderMinutesAsync(v);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateAllReminderMinutes: $e');
    }
  }

  Future<void> _updateAllReminderMinutesAsync(int v) async {
    await _repo.updateAllReminderMinutes(v);
    emit(state.copyWith(salaahSettings: _repo.salaahSettings));
    _sync();
    _widgetSync();
  }

  void updateAllAfterSalahMinutes(int v) {
    try {
      _updateAllAfterSalahMinutesAsync(v);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateAllAfterSalahMinutes: $e');
    }
  }

  Future<void> _updateAllAfterSalahMinutesAsync(int v) async {
    await _repo.updateAllAfterSalahMinutes(v);
    emit(state.copyWith(salaahSettings: _repo.salaahSettings));
    _sync();
    _widgetSync();
  }

  void toggleQadaEnabled() {
    try {
      _toggleQadaEnabledAsync();
    } catch (e) {
      debugPrint('SettingsCubit: Error in toggleQadaEnabled: $e');
    }
  }

  Future<void> _toggleQadaEnabledAsync() async {
    await _repo.toggleQadaEnabled();
    emit(state.copyWith(isQadaEnabled: _repo.isQadaEnabled));
  }

  void updateHijriAdjustment(int v) {
    try {
      _updateHijriAdjustmentAsync(v);
    } catch (e) {
      debugPrint('SettingsCubit: Error in updateHijriAdjustment: $e');
    }
  }

  Future<void> _updateHijriAdjustmentAsync(int v) async {
    await _repo.updateHijriAdjustment(v);
    emit(state.copyWith(hijriAdjustment: v));
    _widgetSync();
  }

  Future<void> initReminders() => _syncNotif.init();

  // ==================== THEME MANAGEMENT ====================

  /// Get all available theme presets
  List<ThemePreset> getAvailablePresets() {
    return _getPresets.execute();
  }

  /// Get current theme preset
  ThemePreset getCurrentThemePreset() {
    if (state.themePresetId == 'custom') {
      // Return a custom preset placeholder
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

  /// Apply a theme preset
  Future<void> selectThemePreset(String presetId) async {
    try {
      await _applyTheme.execute(presetId);
      emit(
        state.copyWith(
          themePresetId: presetId,
          customThemeColors: null,
        ),
      );
      _widgetSync();
    } catch (e) {
      debugPrint('SettingsCubit: Error selecting theme preset: $e');
    }
  }

  /// Save custom theme
  Future<void> saveCustomTheme(Map<String, String> colors) async {
    try {
      await _saveCustomTheme.execute(colors);
      emit(
        state.copyWith(
          themePresetId: 'custom',
          customThemeColors: colors,
        ),
      );
      _widgetSync();
    } catch (e) {
      debugPrint('SettingsCubit: Error saving custom theme: $e');
    }
  }

  /// Add a new custom theme to the saved list
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
      _widgetSync();
    } catch (e) {
      debugPrint('SettingsCubit: Error adding custom theme: $e');
    }
  }

  /// Update an existing custom theme
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
      _widgetSync();
    } catch (e) {
      debugPrint('SettingsCubit: Error updating custom theme: $e');
    }
  }

  /// Delete a custom theme
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
      _widgetSync();
    } catch (e) {
      debugPrint('SettingsCubit: Error deleting custom theme: $e');
    }
  }

  /// Activate a saved custom theme
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
      _widgetSync();
    } catch (e) {
      debugPrint('SettingsCubit: Error activating custom theme: $e');
    }
  }

  void _sync() => Future.microtask(() async {
    try {
      await _syncNotif.execute();
    } catch (e, stack) {
      debugPrint('SettingsCubit: Error syncing notifications: $e\n$stack');
    }
  });
  
  Future<void> _widgetSync() async {
    try {
      await _widget.updateWidget();
    } catch (e) {
      debugPrint('Widget sync error: $e');
    }
  }
}
