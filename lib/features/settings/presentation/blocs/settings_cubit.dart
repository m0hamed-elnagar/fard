import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/domain/usecases/sync_location_settings.dart';
import 'package:fard/features/settings/domain/usecases/sync_notification_schedule.dart';
import 'package:fard/features/settings/domain/usecases/toggle_after_salah_azkar_usecase.dart';
import 'package:fard/features/settings/domain/usecases/update_calculation_method_usecase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/location_service.dart';
import '../../../../core/services/widget_update_service.dart';
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
  final WidgetUpdateService _widget;

  SettingsCubit(
    this._repo,
    this._location,
    this._syncLoc,
    this._syncNotif,
    this._toggleAzkar,
    this._updateMethod,
    this._widget,
  ) : super(
        SettingsState(
          locale: _repo.locale,
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
        ),
      );

  void addReminder(AzkarReminder r) async {
    await _repo.addReminder(r);
    emit(state.copyWith(reminders: _repo.reminders));
    _sync();
  }

  void removeReminder(int i) async {
    await _repo.removeReminder(i);
    emit(state.copyWith(reminders: _repo.reminders));
    _sync();
  }

  void updateReminder(int i, AzkarReminder r) async {
    await _repo.updateReminder(i, r);
    emit(state.copyWith(reminders: _repo.reminders));
    _sync();
  }

  void toggleReminder(int i) async {
    await _repo.toggleReminder(i);
    emit(state.copyWith(reminders: _repo.reminders));
    _sync();
  }

  void updateSalaahSettings(SalaahSettings s) async {
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

  void updateLocale(Locale loc) async {
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

  void updateCalculationMethod(String m) async {
    final adj = await _updateMethod.execute(m);
    emit(state.copyWith(calculationMethod: m, hijriAdjustment: adj));
    _sync();
    _widgetSync();
  }

  void updateMadhab(String v) async {
    await _repo.updateMadhab(v);
    emit(state.copyWith(madhab: v));
    _sync();
    _widgetSync();
  }

  void updateMorningAzkarTime(String v) async {
    await _repo.updateMorningAzkarTime(v);
    emit(state.copyWith(morningAzkarTime: v));
    _sync();
  }

  void updateEveningAzkarTime(String v) async {
    await _repo.updateEveningAzkarTime(v);
    emit(state.copyWith(eveningAzkarTime: v));
    _sync();
  }

  void toggleAfterSalahAzkar() async {
    final v = await _toggleAzkar.execute();
    emit(
      state.copyWith(
        isAfterSalahAzkarEnabled: v,
        salaahSettings: _repo.salaahSettings,
      ),
    );
    _sync();
  }

  void updateAllAzanEnabled(bool v) async {
    await _repo.updateAllAzanEnabled(v);
    emit(state.copyWith(salaahSettings: _repo.salaahSettings));
    _sync();
  }

  void updateAllReminderEnabled(bool v) async {
    await _repo.updateAllReminderEnabled(v);
    emit(state.copyWith(salaahSettings: _repo.salaahSettings));
    _sync();
  }

  void updateAllAzanSound(String? v) async {
    await _repo.updateAllAzanSound(v);
    emit(state.copyWith(salaahSettings: _repo.salaahSettings));
    _sync();
  }

  void updateAllReminderMinutes(int v) async {
    await _repo.updateAllReminderMinutes(v);
    emit(state.copyWith(salaahSettings: _repo.salaahSettings));
    _sync();
  }

  void updateAllAfterSalahMinutes(int v) async {
    await _repo.updateAllAfterSalahMinutes(v);
    emit(state.copyWith(salaahSettings: _repo.salaahSettings));
    _sync();
  }

  void toggleQadaEnabled() async {
    await _repo.toggleQadaEnabled();
    emit(state.copyWith(isQadaEnabled: _repo.isQadaEnabled));
  }

  void updateHijriAdjustment(int v) async {
    await _repo.updateHijriAdjustment(v);
    emit(state.copyWith(hijriAdjustment: v));
    _widgetSync();
  }

  Future<void> initReminders() => _syncNotif.init();
  void _sync() => Future.microtask(() => _syncNotif.execute());
  Future<void> _widgetSync() async {
    try {
      await _widget.updateWidget();
    } catch (e) {
      debugPrint('Widget sync error: $e');
    }
  }
}
