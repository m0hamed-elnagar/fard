import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../audio/domain/repositories/audio_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/salaah_settings.dart';
import '../../domain/usecases/sync_notification_schedule.dart';
import 'adhan_state.dart';

@injectable
class AdhanCubit extends Cubit<AdhanState> with WidgetsBindingObserver {
  final SettingsRepository _repo;
  final SyncNotificationSchedule _syncNotif;

  AdhanCubit(this._repo, this._syncNotif)
    : super(
        AdhanState(
          salaahSettings: _repo.salaahSettings,
          audioQuality: _repo.audioQuality,
          isAudioPlayerExpanded: _repo.isAudioPlayerExpanded,
          useExactAlarmClock: _repo.useExactAlarmClock,
          showSalahCountdownNotification: _repo.showSalahCountdownNotification,
          respectSilentDndMode: _repo.respectSilentDndMode,
        ),
      ) {
    WidgetsBinding.instance.addObserver(this);
    refreshPermissions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      refreshPermissions();
    }
  }

  Future<void> refreshPermissions() async {
    final ns = getIt<NotificationService>();
    final notifications = await ns.areNotificationsEnabled();
    final exactAlarms = await ns.canScheduleExactNotifications();
    
    if (!exactAlarms && state.useExactAlarmClock) {
      await _repo.updateUseExactAlarmClock(false);
      emit(
        state.copyWith(
          notificationsEnabled: notifications,
          exactAlarmsEnabled: exactAlarms,
          useExactAlarmClock: false,
        ),
      );
      _sync();
    } else {
      emit(
        state.copyWith(
          notificationsEnabled: notifications,
          exactAlarmsEnabled: exactAlarms,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }

  void updateAudioPlayerExpanded(bool expanded) {
    _updateAudioPlayerExpandedAsync(expanded);
  }

  Future<void> _updateAudioPlayerExpandedAsync(bool expanded) async {
    await _repo.updateAudioPlayerExpanded(expanded);
    emit(state.copyWith(isAudioPlayerExpanded: expanded));
  }

  void updateAudioQuality(AudioQuality quality) {
    _updateAudioQualityAsync(quality);
  }

  Future<void> _updateAudioQualityAsync(AudioQuality quality) async {
    await _repo.updateAudioQuality(quality);
    emit(state.copyWith(audioQuality: quality));
  }

  void updateSalaahSettings(SalaahSettings s) {
    _updateSalaahSettingsAsync(s);
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

  void updateAllAzanEnabled(bool v) {
    _updateAllAzanEnabledAsync(v);
  }

  Future<void> _updateAllAzanEnabledAsync(bool v) async {
    await _repo.updateAllAzanEnabled(v);
    final newList = state.salaahSettings
        .map((s) => s.copyWith(isAzanEnabled: v))
        .toList();
    emit(state.copyWith(salaahSettings: newList));
    _sync();
  }

  void updateAllAzanSound(String? v) {
    _updateAllAzanSoundAsync(v);
  }

  Future<void> _updateAllAzanSoundAsync(String? v) async {
    await _repo.updateAllAzanSound(v);
    final newList = state.salaahSettings
        .map((s) => s.copyWith(azanSound: v))
        .toList();
    emit(state.copyWith(salaahSettings: newList));
    _sync();
  }

  void toggleUseExactAlarmClock(bool v) {
    _toggleUseExactAlarmClockAsync(v);
  }

  Future<void> _toggleUseExactAlarmClockAsync(bool v) async {
    await _repo.updateUseExactAlarmClock(v);
    emit(state.copyWith(useExactAlarmClock: v));
    _sync();
  }

  void toggleShowSalahCountdownNotification(bool v) {
    _toggleShowSalahCountdownNotificationAsync(v);
  }

  Future<void> _toggleShowSalahCountdownNotificationAsync(bool v) async {
    await _repo.updateShowSalahCountdownNotification(v);
    emit(state.copyWith(showSalahCountdownNotification: v));
    _sync();
  }

  void toggleRespectSilentDndMode(bool v) {
    _toggleRespectSilentDndModeAsync(v);
  }

  Future<void> _toggleRespectSilentDndModeAsync(bool v) async {
    await _repo.updateRespectSilentDndMode(v);
    emit(state.copyWith(respectSilentDndMode: v));
    _sync();
  }

  void _sync() => Future.microtask(() async {
    try {
      await _syncNotif.execute();
    } catch (e, stack) {
      debugPrint('AdhanCubit: Error syncing notifications: $e\n$stack');
    }
  });

  void refresh() {
    emit(
      state.copyWith(
        salaahSettings: _repo.salaahSettings,
        audioQuality: _repo.audioQuality,
        isAudioPlayerExpanded: _repo.isAudioPlayerExpanded,
        useExactAlarmClock: _repo.useExactAlarmClock,
        showSalahCountdownNotification: _repo.showSalahCountdownNotification,
        respectSilentDndMode: _repo.respectSilentDndMode,
      ),
    );
    _sync();
  }
}
