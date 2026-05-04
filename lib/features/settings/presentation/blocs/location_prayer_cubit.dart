import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/location_service.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/usecases/sync_location_settings.dart';
import '../../domain/usecases/sync_notification_schedule.dart';
import '../../domain/usecases/update_calculation_method_usecase.dart';
import 'location_prayer_state.dart';

@injectable
class LocationPrayerCubit extends Cubit<LocationPrayerState> {
  final SettingsRepository _repo;
  final LocationService _location;
  final SyncLocationSettings _syncLoc;
  final SyncNotificationSchedule _syncNotif;
  final UpdateCalculationMethodUseCase _updateMethod;

  LocationPrayerCubit(
    this._repo,
    this._location,
    this._syncLoc,
    this._syncNotif,
    this._updateMethod,
  ) : super(
          LocationPrayerState(
            latitude: _repo.latitude,
            longitude: _repo.longitude,
            cityName: _repo.cityName,
            calculationMethod: _repo.calculationMethod,
            madhab: _repo.madhab,
            hijriAdjustment: _repo.hijriAdjustment,
          ),
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
  }

  Future<void> openLocationSettings() => _location.openLocationSettings();
  Future<void> openAppSettings() => _location.openAppSettings();

  void updateCalculationMethod(String m) {
    _updateCalculationMethodAsync(m);
  }

  Future<void> _updateCalculationMethodAsync(String m) async {
    final adj = await _updateMethod.execute(m);
    emit(state.copyWith(calculationMethod: m, hijriAdjustment: adj));
    _sync();
  }

  void updateMadhab(String v) {
    _updateMadhabAsync(v);
  }

  Future<void> _updateMadhabAsync(String v) async {
    await _repo.updateMadhab(v);
    emit(state.copyWith(madhab: v));
    _sync();
  }

  void updateHijriAdjustment(int v) {
    _updateHijriAdjustmentAsync(v);
  }

  Future<void> _updateHijriAdjustmentAsync(int v) async {
    await _repo.updateHijriAdjustment(v);
    emit(state.copyWith(hijriAdjustment: v));
  }

  void _sync() => Future.microtask(() async {
        try {
          await _syncNotif.execute();
        } catch (e, stack) {
          debugPrint('LocationPrayerCubit: Error syncing notifications: $e\n$stack');
        }
      });

  void refresh() {
    emit(state.copyWith(
      latitude: _repo.latitude,
      longitude: _repo.longitude,
      cityName: _repo.cityName,
      calculationMethod: _repo.calculationMethod,
      madhab: _repo.madhab,
      hijriAdjustment: _repo.hijriAdjustment,
    ));
    _sync();
  }
}

