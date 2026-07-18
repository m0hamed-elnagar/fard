import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/azkar_reminder.dart';
import '../../domain/prayer_reminder_type.dart';
import '../../../prayer_tracking/domain/salaah.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/sync_notification_schedule.dart';
import '../../domain/usecases/toggle_after_salah_azkar_usecase.dart';
import 'daily_reminders_state.dart';

@lazySingleton
class DailyRemindersCubit extends Cubit<DailyRemindersState> {
  final SettingsRepository _repo;
  final SyncNotificationSchedule _syncNotif;
  final ToggleAfterSalahAzkarUseCase _toggleAzkar;

  DailyRemindersCubit(this._repo, this._syncNotif, this._toggleAzkar)
    : super(
        DailyRemindersState(
          morningAzkarTime: _repo.morningAzkarTime,
          eveningAzkarTime: _repo.eveningAzkarTime,
          isAfterSalahAzkarEnabled: _repo.isAfterSalahAzkarEnabled,
          reminders: _repo.reminders,
          isQadaEnabled: _repo.isQadaEnabled,
          isSalahReminderEnabled: _repo.isSalahReminderEnabled,
          salahReminderOffsetMinutes: _repo.salahReminderOffsetMinutes,
          prayerReminderType: _repo.prayerReminderType,
          isBeforeSalahReminderEnabled: _repo.isBeforeSalahReminderEnabled,
          isAfterSalahReminderEnabled: _repo.isAfterSalahReminderEnabled,
          enabledSalahReminders: _repo.enabledSalahReminders,
          enabledBeforeSalahReminders: _repo.enabledBeforeSalahReminders,
          isWerdReminderEnabled: _repo.isWerdReminderEnabled,
          werdReminderTime: _repo.werdReminderTime,
          isSalawatReminderEnabled: _repo.isSalawatReminderEnabled,
          salawatFrequencyHours: _repo.salawatFrequencyHours,
          salawatStartTime: _repo.salawatStartTime,
          salawatEndTime: _repo.salawatEndTime,
        ),
      );

  void toggleSalahReminder(bool enabled) {
    _toggleSalahReminderAsync(enabled);
  }

  Future<void> _toggleSalahReminderAsync(bool enabled) async {
    emit(state.copyWith(isSalahReminderEnabled: enabled));
    await _repo.updateSalahReminderEnabled(enabled);
    _sync();
  }

  void setSalahReminderOffset(int minutes) {
    _setSalahReminderOffsetAsync(minutes);
  }

  Future<void> _setSalahReminderOffsetAsync(int minutes) async {
    emit(state.copyWith(salahReminderOffsetMinutes: minutes));
    await _repo.updateSalahReminderOffset(minutes);
    _sync();
  }

  void setPrayerReminderType(PrayerReminderType type) {
    _setPrayerReminderTypeAsync(type);
  }

  Future<void> _setPrayerReminderTypeAsync(PrayerReminderType type) async {
    emit(state.copyWith(prayerReminderType: type));
    await _repo.updatePrayerReminderType(type);
    _sync();
  }

  void toggleBeforeSalahReminder(bool enabled) {
    _toggleBeforeSalahReminderAsync(enabled);
  }

  Future<void> _toggleBeforeSalahReminderAsync(bool enabled) async {
    final bool newMasterEnabled = enabled || state.isAfterSalahAzkarEnabled;
    emit(state.copyWith(
      isBeforeSalahReminderEnabled: enabled,
      isSalahReminderEnabled: newMasterEnabled,
    ));
    await _repo.updateBeforeSalahReminderEnabled(enabled);
    await _repo.updateSalahReminderEnabled(newMasterEnabled);
    _sync();
  }

  void toggleAfterSalahReminder(bool enabled) {
    _toggleAfterSalahReminderAsync(enabled);
  }

  Future<void> _toggleAfterSalahReminderAsync(bool enabled) async {
    final bool newMasterEnabled = state.isBeforeSalahReminderEnabled || enabled;
    emit(state.copyWith(
      isAfterSalahReminderEnabled: enabled,
      isSalahReminderEnabled: newMasterEnabled,
    ));
    await _repo.updateAfterSalahReminderEnabled(enabled);
    await _repo.updateSalahReminderEnabled(newMasterEnabled);
    _sync();
  }

  void toggleSpecificSalahReminder(Salaah salaah) {
    _toggleSpecificSalahReminderAsync(salaah);
  }

  Future<void> _toggleSpecificSalahReminderAsync(Salaah salaah) async {
    final set = Set<Salaah>.from(state.enabledSalahReminders);
    final bool oldMasterEnabled = state.isSalahReminderEnabled;
    bool masterEnabled = oldMasterEnabled;

    if (set.contains(salaah)) {
      set.remove(salaah);
    } else {
      set.add(salaah);
      if (!masterEnabled) {
        masterEnabled = true;
      }
    }

    emit(
      state.copyWith(
        enabledSalahReminders: set,
        isSalahReminderEnabled: masterEnabled,
      ),
    );

    if (masterEnabled != oldMasterEnabled) {
      await _repo.updateSalahReminderEnabled(masterEnabled);
    }
    await _repo.updateEnabledSalahReminders(set);
    _sync();
  }

  void toggleSpecificBeforeSalahReminder(Salaah salaah) {
    _toggleSpecificBeforeSalahReminderAsync(salaah);
  }

  Future<void> _toggleSpecificBeforeSalahReminderAsync(Salaah salaah) async {
    final set = Set<Salaah>.from(state.enabledBeforeSalahReminders);
    final bool oldMasterEnabled = state.isSalahReminderEnabled;
    bool masterEnabled = oldMasterEnabled;

    if (set.contains(salaah)) {
      set.remove(salaah);
    } else {
      set.add(salaah);
      if (!masterEnabled) {
        masterEnabled = true;
      }
    }

    emit(
      state.copyWith(
        enabledBeforeSalahReminders: set,
        isSalahReminderEnabled: masterEnabled,
      ),
    );

    if (masterEnabled != oldMasterEnabled) {
      await _repo.updateSalahReminderEnabled(masterEnabled);
    }
    await _repo.updateEnabledBeforeSalahReminders(set);
    _sync();
  }

  void toggleWerdReminder(bool enabled) {
    _toggleWerdReminderAsync(enabled);
  }

  Future<void> _toggleWerdReminderAsync(bool enabled) async {
    emit(state.copyWith(isWerdReminderEnabled: enabled));
    await _repo.updateWerdReminderEnabled(enabled);
    _sync();
  }

  void setWerdReminderTime(String time) {
    _setWerdReminderTimeAsync(time);
  }

  Future<void> _setWerdReminderTimeAsync(String time) async {
    emit(state.copyWith(werdReminderTime: time));
    await _repo.updateWerdReminderTime(time);
    _sync();
  }

  void toggleSalawatReminder(bool enabled) {
    _toggleSalawatReminderAsync(enabled);
  }

  Future<void> _toggleSalawatReminderAsync(bool enabled) async {
    emit(state.copyWith(isSalawatReminderEnabled: enabled));
    await _repo.updateSalawatReminderEnabled(enabled);
    _sync();
  }

  void setSalawatFrequency(int hours) {
    _setSalawatFrequencyAsync(hours);
  }

  Future<void> _setSalawatFrequencyAsync(int hours) async {
    emit(state.copyWith(salawatFrequencyHours: hours));
    await _repo.updateSalawatFrequency(hours);
    _sync();
  }

  void setSalawatStartTime(String time) {
    _setSalawatStartTimeAsync(time);
  }

  Future<void> _setSalawatStartTimeAsync(String time) async {
    emit(state.copyWith(salawatStartTime: time));
    await _repo.updateSalawatStartTime(time);
    _sync();
  }

  void setSalawatEndTime(String time) {
    _setSalawatEndTimeAsync(time);
  }

  Future<void> _setSalawatEndTimeAsync(String time) async {
    emit(state.copyWith(salawatEndTime: time));
    await _repo.updateSalawatEndTime(time);
    _sync();
  }

  void addReminder(AzkarReminder r) {
    final newList = List<AzkarReminder>.from(state.reminders)..add(r);
    emit(state.copyWith(reminders: newList));
    _addReminderAsync(r);
  }

  Future<void> _addReminderAsync(AzkarReminder r) async {
    await _repo.addReminder(r);
    _sync();
  }

  void removeReminder(int i) {
    final newList = List<AzkarReminder>.from(state.reminders);
    if (i >= 0 && i < newList.length) {
      newList.removeAt(i);
      emit(state.copyWith(reminders: newList));
    }
    _removeReminderAsync(i);
  }

  Future<void> _removeReminderAsync(int i) async {
    await _repo.removeReminder(i);
    _sync();
  }

  void updateReminder(int i, AzkarReminder r) {
    final newList = List<AzkarReminder>.from(state.reminders);
    if (i >= 0 && i < newList.length) {
      newList[i] = r;
      emit(state.copyWith(reminders: newList));
    }
    _updateReminderAsync(i, r);
  }

  Future<void> _updateReminderAsync(int i, AzkarReminder r) async {
    await _repo.updateReminder(i, r);
    _sync();
  }

  void toggleReminder(int i) {
    final newList = List<AzkarReminder>.from(state.reminders);
    if (i >= 0 && i < newList.length) {
      newList[i] = newList[i].copyWith(isEnabled: !newList[i].isEnabled);
      emit(state.copyWith(reminders: newList));
    }
    _toggleReminderAsync(i);
  }

  Future<void> _toggleReminderAsync(int i) async {
    await _repo.toggleReminder(i);
    _sync();
  }

  void updateMorningAzkarTime(String v) {
    emit(state.copyWith(morningAzkarTime: v));
    _updateMorningAzkarTimeAsync(v);
  }

  Future<void> _updateMorningAzkarTimeAsync(String v) async {
    await _repo.updateMorningAzkarTime(v);
    _sync();
  }

  void updateEveningAzkarTime(String v) {
    emit(state.copyWith(eveningAzkarTime: v));
    _updateEveningAzkarTimeAsync(v);
  }

  Future<void> _updateEveningAzkarTimeAsync(String v) async {
    await _repo.updateEveningAzkarTime(v);
    _sync();
  }

  void toggleAfterSalahAzkar() {
    _toggleAfterSalahAzkarAsync();
  }

  Future<void> _toggleAfterSalahAzkarAsync() async {
    final v = await _toggleAzkar.execute();
    final bool newMasterEnabled = state.isBeforeSalahReminderEnabled || v;
    emit(state.copyWith(
      isAfterSalahAzkarEnabled: v,
      isSalahReminderEnabled: newMasterEnabled,
    ));
    await _repo.updateSalahReminderEnabled(newMasterEnabled);
    _sync();
  }

  void toggleQadaEnabled() {
    _toggleQadaEnabledAsync();
  }

  Future<void> _toggleQadaEnabledAsync() async {
    await _repo.toggleQadaEnabled();
    emit(state.copyWith(isQadaEnabled: _repo.isQadaEnabled));
    _sync();
  }

  void updateAllReminderEnabled(bool v) {
    _updateAllReminderEnabledAsync(v);
  }

  Future<void> _updateAllReminderEnabledAsync(bool v) async {
    await _repo.updateAllReminderEnabled(v);
    _sync();
  }

  void updateAllReminderMinutes(int v) {
    _updateAllReminderMinutesAsync(v);
  }

  Future<void> _updateAllReminderMinutesAsync(int v) async {
    await _repo.updateAllReminderMinutes(v);
    _sync();
  }

  void updateAllAfterSalahMinutes(int v) {
    _updateAllAfterSalahMinutesAsync(v);
  }

  Future<void> _updateAllAfterSalahMinutesAsync(int v) async {
    await _repo.updateAllAfterSalahMinutes(v);
    _sync();
  }

  void _sync() => Future.microtask(() async {
    try {
      await _syncNotif.execute();
    } catch (e, stack) {
      debugPrint(
        'DailyRemindersCubit: Error syncing notifications: $e\n$stack',
      );
    }
  });

  void refresh() {
    emit(
      state.copyWith(
        morningAzkarTime: _repo.morningAzkarTime,
        eveningAzkarTime: _repo.eveningAzkarTime,
        isAfterSalahAzkarEnabled: _repo.isAfterSalahAzkarEnabled,
        reminders: _repo.reminders,
        isQadaEnabled: _repo.isQadaEnabled,
        isSalahReminderEnabled: _repo.isSalahReminderEnabled,
        salahReminderOffsetMinutes: _repo.salahReminderOffsetMinutes,
        prayerReminderType: _repo.prayerReminderType,
        isBeforeSalahReminderEnabled: _repo.isBeforeSalahReminderEnabled,
        isAfterSalahReminderEnabled: _repo.isAfterSalahReminderEnabled,
        enabledSalahReminders: _repo.enabledSalahReminders,
        enabledBeforeSalahReminders: _repo.enabledBeforeSalahReminders,
        isWerdReminderEnabled: _repo.isWerdReminderEnabled,
        werdReminderTime: _repo.werdReminderTime,
        isSalawatReminderEnabled: _repo.isSalawatReminderEnabled,
        salawatFrequencyHours: _repo.salawatFrequencyHours,
        salawatStartTime: _repo.salawatStartTime,
        salawatEndTime: _repo.salawatEndTime,
      ),
    );
    _sync();
  }
}
