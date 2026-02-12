import 'package:fard/domain/models/daily_record.dart';
import 'package:fard/domain/models/missed_counter.dart';
import 'package:fard/domain/models/salaah.dart';
import 'package:fard/domain/repositories/prayer_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'prayer_tracker_bloc.freezed.dart';
part 'prayer_tracker_event.dart';
part 'prayer_tracker_state.dart';

class PrayerTrackerBloc extends Bloc<PrayerTrackerEvent, PrayerTrackerState> {
  final PrayerRepo _repo;

  PrayerTrackerBloc(this._repo) : super(const PrayerTrackerState.loading()) {
    on<_Load>(_onLoad);
    on<_TogglePrayer>(_onTogglePrayer);
    on<_AddQada>(_onAddQada);
    on<_RemoveQada>(_onRemoveQada);
    on<_Save>(_onSave);
    on<_LoadMonth>(_onLoadMonth);
    on<_CheckMissedDays>(_onCheckMissedDays);
    on<_AcknowledgeMissedDays>(_onAcknowledgeMissedDays);
    on<_BulkAddQada>(_onBulkAddQada);
    on<_DeleteRecord>(_onDeleteRecord);
  }

  Future<void> _onDeleteRecord(
      _DeleteRecord e, Emitter<PrayerTrackerState> em) async {
    if (state is _Loaded) {
      final s = state as _Loaded;
      final dateKey = DateTime(e.date.year, e.date.month, e.date.day);

      // 1. Optimistic Update: Remove from local state immediately
      final updatedMonth = Map<DateTime, DailyRecord>.from(s.monthRecords);
      if (updatedMonth.containsKey(dateKey)) {
        updatedMonth.remove(dateKey);
        final history = updatedMonth.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        em(s.copyWith(monthRecords: updatedMonth, history: history));
      }

      // 2. Perform actual deletion
      await _repo.deleteRecord(e.date);

      // 3. Trigger reload for current day to refresh counters and ensure DB sync
      add(PrayerTrackerEvent.load(s.selectedDate));
    }
  }

  Future<void> _onLoad(_Load e, Emitter<PrayerTrackerState> em) async {
    em(const PrayerTrackerState.loading());
    final record = await _repo.loadRecord(e.date);
    final lastSaved = await _repo.loadLastSavedRecord();
    final missedToday = record?.missedToday ?? <Salaah>{};
    // If not records exists, carry over qada
    Map<Salaah, MissedCounter> qada;
    if (record != null) {
      qada = record.qada;
    } else {
      qada = lastSaved?.qada ??
          {for (final s in Salaah.values) s: const MissedCounter(0)};
    }
    
    // Initial state without month records first to show UI quickly
    em(PrayerTrackerState.loaded(
      selectedDate: e.date,
      missedToday: missedToday,
      qadaStatus: qada,
      monthRecords: {},
      history: [], // We'll populate this from monthRecords in UI or Bloc
    ));
    
    // Load month data
    final month = await _repo.loadMonth(e.date.year, e.date.month);
    final currentState = state;
    if (currentState is _Loaded) {
      em(currentState.copyWith(
        monthRecords: month,
        history: month.values.toList()..sort((a, b) => b.date.compareTo(a.date)),
      ));
    }
  }

  Future<void> _onTogglePrayer(_TogglePrayer e, Emitter<PrayerTrackerState> em) async {
    final s = state as _Loaded;
    final updated = Set<Salaah>.from(s.missedToday);
    final qada = Map<Salaah, MissedCounter>.from(s.qadaStatus);
    if (updated.contains(e.prayer)) {
      updated.remove(e.prayer);
      qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).removeMissed();
    } else {
      updated.add(e.prayer);
      qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).addMissed();
    }
    final newState = s.copyWith(missedToday: updated, qadaStatus: qada);
    em(newState);
    await _saveInternal(newState, em);
  }

  Future<void> _onAddQada(_AddQada e, Emitter<PrayerTrackerState> em) async {
    final s = state as _Loaded;
    final qada = Map<Salaah, MissedCounter>.from(s.qadaStatus);
    qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).addMissed();
    final newState = s.copyWith(qadaStatus: qada);
    em(newState);
    await _saveInternal(newState, em);
  }

  Future<void> _onRemoveQada(_RemoveQada e, Emitter<PrayerTrackerState> em) async {
    final s = state as _Loaded;
    final qada = Map<Salaah, MissedCounter>.from(s.qadaStatus);
    qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).removeMissed();
    final newState = s.copyWith(qadaStatus: qada);
    em(newState);
    await _saveInternal(newState, em);
  }

  // Deprecated manual save, but we can keep handler just in case
  Future<void> _onSave(_Save e, Emitter<PrayerTrackerState> em) async {
    if (state is _Loaded) {
      await _saveInternal(state as _Loaded, em);
    }
  }

  Future<void> _saveInternal(_Loaded s, Emitter<PrayerTrackerState> em) async {
    final dateKey =
        '${s.selectedDate.year}-${s.selectedDate.month.toString().padLeft(2, '0')}-${s.selectedDate.day.toString().padLeft(2, '0')}';
    final record = DailyRecord(
      id: dateKey,
      date: DateTime(
          s.selectedDate.year, s.selectedDate.month, s.selectedDate.day),
      missedToday: s.missedToday,
      qada: s.qadaStatus,
    );
    await _repo.saveToday(record);
    
    // Reload month data to update history list properly
    final month =
        await _repo.loadMonth(s.selectedDate.year, s.selectedDate.month);
    
    // Sort descending by date
    final history = month.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    
    em(s.copyWith(monthRecords: month, history: history));
  }

  Future<void> _onLoadMonth(
      _LoadMonth e, Emitter<PrayerTrackerState> em) async {
    final month = await _repo.loadMonth(e.year, e.month);
    final history = month.values.toList()..sort((a, b) => b.date.compareTo(a.date));
    final s = state;
    if (s is _Loaded) {
      em(s.copyWith(monthRecords: month, history: history));
    }
  }

  Future<void> _onCheckMissedDays(
      _CheckMissedDays e, Emitter<PrayerTrackerState> em) async {
    final lastRecord = await _repo.loadLastSavedRecord();
    if (lastRecord == null) return;

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final lastDate = DateTime(
        lastRecord.date.year, lastRecord.date.month, lastRecord.date.day);
    final diff = normalizedToday.difference(lastDate).inDays;

    if (diff > 1) {
      final missedDates = <DateTime>[];
      for (int i = 1; i < diff; i++) {
        missedDates.add(lastDate.add(Duration(days: i)));
      }
      em(PrayerTrackerState.missedDaysPrompt(missedDates: missedDates));
    }
  }

  Future<void> _onAcknowledgeMissedDays(
      _AcknowledgeMissedDays e, Emitter<PrayerTrackerState> em) async {
    if (e.addAsMissed) {
      for (final date in e.dates) {
        final dateKey =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final existing = await _repo.loadRecord(date);
        final qada = existing?.qada ??
            {for (final s in Salaah.values) s: const MissedCounter(0)};
        // Add all 5 prayers as missed for that day
        final allMissedQada = <Salaah, MissedCounter>{};
        for (final s in Salaah.values) {
          allMissedQada[s] =
              (qada[s] ?? const MissedCounter(0)).addMissed();
        }
        final record = DailyRecord(
          id: dateKey,
          date: date,
          missedToday: Set<Salaah>.from(Salaah.values),
          qada: allMissedQada,
        );
        await _repo.saveToday(record);
      }
    }
    // Load today after handling
    add(PrayerTrackerEvent.load(DateTime.now()));
  }

  Future<void> _onBulkAddQada(
      _BulkAddQada e, Emitter<PrayerTrackerState> em) async {
    final s = state as _Loaded;
    final qada = Map<Salaah, MissedCounter>.from(s.qadaStatus);
    for (final entry in e.counts.entries) {
      final current = qada[entry.key] ?? const MissedCounter(0);
      qada[entry.key] = MissedCounter(current.value + entry.value);
    }
    final newState = s.copyWith(qadaStatus: qada);
    em(newState);
    await _saveInternal(newState, em);
  }
}
