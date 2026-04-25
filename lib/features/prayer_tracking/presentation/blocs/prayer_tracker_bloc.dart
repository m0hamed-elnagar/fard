import 'dart:developer' as developer;

import 'package:adhan/adhan.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

part 'prayer_tracker_bloc.freezed.dart';
part 'prayer_tracker_event.dart';
part 'prayer_tracker_state.dart';

@injectable
class PrayerTrackerBloc extends Bloc<PrayerTrackerEvent, PrayerTrackerState> {
  final PrayerRepo _repo;
  final SharedPreferences _prefs;
  final PrayerTimeService _prayerTimeService;
  final NotificationService _notificationService;

  PrayerTrackerBloc(
    this._repo,
    this._prefs,
    this._prayerTimeService, [
    NotificationService? notificationService,
  ]) : _notificationService =
           notificationService ?? getIt<NotificationService>(),
       super(const PrayerTrackerState.loading()) {
    on<_Load>(_onLoad, transformer: sequential());
    on<_TogglePrayer>(_onTogglePrayer, transformer: sequential());
    on<_AddQada>(_onAddQada, transformer: sequential());
    on<_RemoveQada>(_onRemoveQada, transformer: sequential());
    on<_Save>(_onSave, transformer: sequential());
    on<_LoadMonth>(_onLoadMonth, transformer: sequential());
    on<_CheckMissedDays>(_onCheckMissedDays, transformer: sequential());
    on<_AcknowledgeMissedDays>(
      _onAcknowledgeMissedDays,
      transformer: sequential(),
    );
    on<_BulkAddQada>(_onBulkAddQada, transformer: sequential());
    on<_UpdateQada>(_onUpdateQada, transformer: sequential());
    on<_DeleteRecord>(_onDeleteRecord, transformer: sequential());
  }

  Future<void> _onUpdateQada(
    _UpdateQada e,
    Emitter<PrayerTrackerState> em,
  ) async {
    if (state is _Loaded) {
      final s = state as _Loaded;
      final oldQada = s.qadaStatus;
      final qada = <Salaah, MissedCounter>{};
      for (final entry in e.counts.entries) {
        qada[entry.key] = MissedCounter(entry.value);
      }
      final newState = s.copyWith(qadaStatus: qada);
      em(newState);

      final normalizedDate = DateTime(
        s.selectedDate.year,
        s.selectedDate.month,
        s.selectedDate.day,
      );
      final recordToSave = DailyRecord(
        id: '${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}',
        date: normalizedDate,
        missedToday: s.missedToday,
        completedToday: s.completedToday,
        qada: qada,
        completedQada: s.completedQadaToday,
      );
      await _repo.saveToday(recordToSave);
      await _cascadeUpdateFrom(recordToSave, oldBaseQada: oldQada);

      final month = await _repo.loadMonth(
        s.selectedDate.year,
        s.selectedDate.month,
      );
      final history = month.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      em(newState.copyWith(monthRecords: month, history: history));
    }
  }

  Future<void> _onDeleteRecord(
    _DeleteRecord e,
    Emitter<PrayerTrackerState> em,
  ) async {
    if (state is _Loaded) {
      final s = state as _Loaded;
      final deletedDate = DateTime(e.date.year, e.date.month, e.date.day);

      final recordToDelete = await _repo.loadRecord(deletedDate);

      await _repo.deleteRecord(deletedDate);

      final base = await _repo.loadLastRecordBefore(deletedDate);
      if (base != null) {
        await _cascadeUpdateFrom(base, deletedRecord: recordToDelete);
      } else {
        final all = await _repo.loadAllRecords();
        if (all.isNotEmpty) {
          final sorted = all..sort((a, b) => a.date.compareTo(b.date));
          final earliest = sorted.first;
          final originalEarliestQada = earliest.qada;

          final updatedQada = <Salaah, MissedCounter>{};
          for (final s in Salaah.values) {
            updatedQada[s] = earliest.missedToday.contains(s)
                ? const MissedCounter(1)
                : const MissedCounter(0);
          }
          final updatedEarliest = earliest.copyWith(qada: updatedQada);
          await _repo.saveToday(updatedEarliest);
          await _cascadeUpdateFrom(
            updatedEarliest,
            oldBaseQada: originalEarliestQada,
          );
        }
      }

      add(PrayerTrackerEvent.load(s.selectedDate));
    }
  }

  Future<void> _cascadeUpdateFrom(
    DailyRecord updatedBaseRecord, {
    Map<Salaah, MissedCounter>? oldBaseQada,
    DailyRecord? deletedRecord,
  }) async {
    final allRecords = await _repo.loadAllRecords();

    final List<DailyRecord> originalChain = List.from(allRecords);
    if (deletedRecord != null) {
      originalChain.add(deletedRecord);
    }
    originalChain.sort((a, b) => a.date.compareTo(b.date));

    // Get all future records (including today) to cascade updates
    final futureRecords = allRecords
        .where((r) => r.date.isAfter(updatedBaseRecord.date))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (futureRecords.isEmpty) return;

    // Safety check: prevent infinite loops
    if (futureRecords.length > 1000) {
      developer.log(
        'WARNING: Cascade skipped - too many records (${futureRecords.length})',
      );
      return;
    }

    DailyRecord runningNewPrev = updatedBaseRecord;

    for (final fr in futureRecords) {
      final currentIdx = originalChain.indexWhere(
        (r) => r.date.isAtSameMomentAs(fr.date),
      );
      if (currentIdx <= 0) {
        runningNewPrev = fr;
        continue;
      }

      final oldPrev = originalChain[currentIdx - 1];
      final updatedQada = <Salaah, MissedCounter>{};

      final oldLastUtc = DateTime.utc(
        oldPrev.date.year,
        oldPrev.date.month,
        oldPrev.date.day,
      );
      final targetUtc = DateTime.utc(fr.date.year, fr.date.month, fr.date.day);
      final oldDiff = targetUtc.difference(oldLastUtc).inDays;
      final oldGaps = oldDiff > 1 ? (oldDiff - 1) : 0;

      final newLastUtc = DateTime.utc(
        runningNewPrev.date.year,
        runningNewPrev.date.month,
        runningNewPrev.date.day,
      );
      final newDiff = targetUtc.difference(newLastUtc).inDays;
      final newGaps = newDiff > 1 ? (newDiff - 1) : 0;

      for (final s in Salaah.values) {
        int oldVal = fr.qada[s]?.value ?? 0;
        int oldPrevVal = oldPrev.qada[s]?.value ?? 0;

        if (oldPrev.date.isAtSameMomentAs(updatedBaseRecord.date) &&
            oldBaseQada != null) {
          oldPrevVal = oldBaseQada[s]?.value ?? oldPrevVal;
        }

        int newValPrev = runningNewPrev.qada[s]?.value ?? 0;

        int delta = (newValPrev + newGaps) - (oldPrevVal + oldGaps);
        updatedQada[s] = MissedCounter(oldVal + delta);
      }

      final updatedRecord = fr.copyWith(qada: updatedQada);
      await _repo.saveToday(updatedRecord);
      runningNewPrev = updatedRecord;
    }
  }

  Future<void> _onLoad(_Load e, Emitter<PrayerTrackerState> em) async {
    try {
      final normalizedDate = DateTime(e.date.year, e.date.month, e.date.day);
      
      // Check if we already have cached data for this date
      final existingState = state;
      final hasCachedData = existingState is _Loaded && 
                            isSameDay(existingState.selectedDate, normalizedDate);
      
      // Only show loading state if we don't have cached data
      if (!hasCachedData) {
        em(const PrayerTrackerState.loading());
      }
      
      final record = await _repo.loadRecord(normalizedDate);
      final lastSavedBefore = await _repo.loadLastRecordBefore(normalizedDate);

      developer.log(
        'DEBUG: _onLoad record: ${record?.qada.map((k, v) => MapEntry(k, v.value))}, lastSavedBefore: ${lastSavedBefore?.qada.map((k, v) => MapEntry(k, v.value))}',
      );

      final lat = double.tryParse(_prefs.get('latitude')?.toString() ?? '');
      final lon = double.tryParse(_prefs.get('longitude')?.toString() ?? '');

      PrayerTimes? prayerTimes;
      if (lat != null && lon != null) {
        final method =
            _prefs.getString('calculation_method') ?? 'muslim_league';
        final madhab = _prefs.getString('madhab') ?? 'shafi';
        prayerTimes = _prayerTimeService.getPrayerTimes(
          latitude: lat,
          longitude: lon,
          method: method,
          madhab: madhab,
          date: normalizedDate,
        );
      }

      Set<Salaah> missedToday;
      Set<Salaah> completedToday;
      Map<Salaah, MissedCounter> qada;

      if (record != null) {
        completedToday = Set.from(record.completedToday);
        missedToday = Set.from(record.missedToday);
        qada = Map.from(record.qada);
      } else {
        // Only calculate when record is missing
        missedToday = <Salaah>{};
        completedToday = <Salaah>{};
        for (final s in Salaah.values) {
          if (_prayerTimeService.isPassed(
            s,
            prayerTimes: prayerTimes,
            date: normalizedDate,
          )) {
            missedToday.add(s);
          }
        }

        // Initial qada calculation for new records
        qada = {for (final s in Salaah.values) s: const MissedCounter(0)};

        if (lastSavedBefore != null) {
          qada = Map<Salaah, MissedCounter>.from(lastSavedBefore.qada);
        }

        // For a brand new record (first load of the day), auto-increment Qada for missed prayers
        for (final s in missedToday) {
          qada[s] = (qada[s] ?? const MissedCounter(0)).addMissed();
        }

        final newRecord = DailyRecord(
          id: '${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}',
          date: normalizedDate,
          missedToday: missedToday,
          completedToday: completedToday,
          qada: qada,
        );
        await _repo.saveToday(newRecord);
      }

      final now = DateTime.now();
      final isToday =
          normalizedDate.year == now.year &&
          normalizedDate.month == now.month &&
          normalizedDate.day == now.day;

      if (isToday && record != null) {
        // If record exists and it is today, check if new prayers have passed since last load
        bool needsUpdate = false;
        for (final s in Salaah.values) {
          if (_prayerTimeService.isPassed(
            s,
            prayerTimes: prayerTimes,
            date: normalizedDate,
          )) {
            if (!completedToday.contains(s) && !missedToday.contains(s)) {
              missedToday.add(s);
              qada[s] = (qada[s] ?? const MissedCounter(0)).addMissed();
              needsUpdate = true;
            }
          }
        }
        if (needsUpdate) {
          final updatedRecord = record.copyWith(
            missedToday: missedToday,
            qada: qada,
          );
          await _repo.saveToday(updatedRecord);
        }
      }

      // Final state construction logic
      final currentState = state;
      final loadedState = PrayerTrackerState.loaded(
        selectedDate: normalizedDate,
        missedToday: missedToday,
        completedToday: completedToday,
        qadaStatus: qada,
        completedQadaToday: record?.completedQada ?? {},
        monthRecords: (currentState is _Loaded)
            ? currentState.monthRecords
            : {},
        history: (currentState is _Loaded) ? currentState.history : [],
      );

      em(loadedState);

      final month = await _repo.loadMonth(
        normalizedDate.year,
        normalizedDate.month,
      );
      if (state is _Loaded) {
        final current = state as _Loaded;
        em(
          current.copyWith(
            monthRecords: month,
            history: month.values.toList()
              ..sort((a, b) => b.date.compareTo(a.date)),
          ),
        );
      }
    } catch (e) {
      em(PrayerTrackerState.error(message: e.toString()));
    }
  }

  Future<void> _onTogglePrayer(
    _TogglePrayer e,
    Emitter<PrayerTrackerState> em,
  ) async {
    try {
      if (state is _Loaded) {
        final s = state as _Loaded;
        final oldQadaMap = s.qadaStatus;
        final missed = Set<Salaah>.from(s.missedToday);
        final completed = Set<Salaah>.from(s.completedToday);
        final qada = Map<Salaah, MissedCounter>.from(s.qadaStatus);
        final completedQada = Map<Salaah, int>.from(s.completedQadaToday);

        bool isDayRecovery = missed.contains(e.prayer);

        if (isDayRecovery) {
          missed.remove(e.prayer);
          completed.add(e.prayer);
          qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0))
              .removeMissed();
          _notificationService.cancelPrayerReminder(e.prayer, forTodayOnly: true);
        } else if (completed.contains(e.prayer)) {
          completed.remove(e.prayer);
          missed.add(e.prayer);
          qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0))
              .addMissed();
        } else {
          // Case where prayer time hasn't passed yet but user wants to mark it done early
          completed.add(e.prayer);
        }

        final newState = s.copyWith(
          missedToday: missed,
          completedToday: completed,
          qadaStatus: qada,
          completedQadaToday: completedQada,
        );

        final normalizedDate = DateTime(
          s.selectedDate.year,
          s.selectedDate.month,
          s.selectedDate.day,
        );
        final recordToSave = DailyRecord(
          id: '${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}',
          date: normalizedDate,
          missedToday: missed,
          completedToday: completed,
          qada: qada,
          completedQada: completedQada,
        );
        await _repo.saveToday(recordToSave);
        await _cascadeUpdateFrom(recordToSave, oldBaseQada: oldQadaMap);

        em(newState);

        final month = await _repo.loadMonth(
          s.selectedDate.year,
          s.selectedDate.month,
        );
        final history = month.values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));
        em(newState.copyWith(monthRecords: month, history: history));
      }
    } catch (e) {
      em(PrayerTrackerState.error(message: e.toString()));
    }
  }

  Future<void> _onAddQada(_AddQada e, Emitter<PrayerTrackerState> em) async {
    if (state is _Loaded) {
      final s = state as _Loaded;
      final oldQadaMap = s.qadaStatus;
      final qada = Map<Salaah, MissedCounter>.from(s.qadaStatus);
      final missed = Set<Salaah>.from(s.missedToday);
      final completed = Set<Salaah>.from(s.completedToday);
      final completedQada = Map<Salaah, int>.from(s.completedQadaToday);

      final currentBudget = completedQada[e.prayer] ?? 0;

      if (currentBudget > 0) {
        // 1. First priority: Undo an extra Qada session (e.g., Qada 2 -> Qada 1)
        qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).addMissed();
        completedQada[e.prayer] = currentBudget - 1;
      } else if (completed.contains(e.prayer)) {
        // 2. Second priority: Mark today's daily prayer as missed (Done -> Missed)
        completed.remove(e.prayer);
        missed.add(e.prayer);
        qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).addMissed();
      } else {
        // 3. Last priority: Just add general manual debt
        qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).addMissed();
      }

      final newState = s.copyWith(
        qadaStatus: qada,
        completedQadaToday: completedQada,
        missedToday: missed,
        completedToday: completed,
      );
      em(newState);

      final normalizedDate = DateTime(
        s.selectedDate.year,
        s.selectedDate.month,
        s.selectedDate.day,
      );
      final recordToSave = DailyRecord(
        id: '${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}',
        date: normalizedDate,
        missedToday: missed,
        completedToday: completed,
        qada: qada,
        completedQada: completedQada,
      );
      await _repo.saveToday(recordToSave);
      await _cascadeUpdateFrom(recordToSave, oldBaseQada: oldQadaMap);

      final month = await _repo.loadMonth(
        s.selectedDate.year,
        s.selectedDate.month,
      );
      final history = month.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      em(newState.copyWith(monthRecords: month, history: history));
    }
  }

  Future<void> _onRemoveQada(
    _RemoveQada e,
    Emitter<PrayerTrackerState> em,
  ) async {
    if (state is _Loaded) {
      final s = state as _Loaded;
      final oldQadaMap = s.qadaStatus;
      final missed = Set<Salaah>.from(s.missedToday);
      final completed = Set<Salaah>.from(s.completedToday);
      final qada = Map<Salaah, MissedCounter>.from(s.qadaStatus);
      final completedQada = Map<Salaah, int>.from(s.completedQadaToday);

      bool isDayRecovery = missed.contains(e.prayer);

      if (isDayRecovery) {
        missed.remove(e.prayer);
        completed.add(e.prayer);
      }

      qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0))
          .removeMissed();

      if (!isDayRecovery) {
        completedQada[e.prayer] = (completedQada[e.prayer] ?? 0) + 1;
      }

      final newState = s.copyWith(
        missedToday: missed,
        completedToday: completed,
        qadaStatus: qada,
        completedQadaToday: completedQada,
      );
      em(newState);

      final normalizedDate = DateTime(
        s.selectedDate.year,
        s.selectedDate.month,
        s.selectedDate.day,
      );
      final recordToSave = DailyRecord(
        id: '${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}',
        date: normalizedDate,
        missedToday: missed,
        completedToday: completed,
        qada: qada,
        completedQada: completedQada,
      );
      await _repo.saveToday(recordToSave);
      await _cascadeUpdateFrom(recordToSave, oldBaseQada: oldQadaMap);

      final month = await _repo.loadMonth(
        s.selectedDate.year,
        s.selectedDate.month,
      );
      final history = month.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      em(newState.copyWith(monthRecords: month, history: history));
    }
  }

  Future<void> _onSave(_Save e, Emitter<PrayerTrackerState> em) async {
    if (state is _Loaded) {
      final s = state as _Loaded;
      await _saveInternal(s, em, oldQada: s.qadaStatus);
    }
  }

  Future<void> _saveInternal(
    _Loaded s,
    Emitter<PrayerTrackerState> em, {
    Map<Salaah, MissedCounter>? oldQada,
  }) async {
    try {
      final normalizedDate = DateTime(
        s.selectedDate.year,
        s.selectedDate.month,
        s.selectedDate.day,
      );
      final record = DailyRecord(
        id: '${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}',
        date: normalizedDate,
        missedToday: s.missedToday,
        completedToday: s.completedToday,
        qada: s.qadaStatus,
        completedQada: s.completedQadaToday,
      );
      await _repo.saveToday(record);
      await _cascadeUpdateFrom(record, oldBaseQada: oldQada);

      final month = await _repo.loadMonth(
        s.selectedDate.year,
        s.selectedDate.month,
      );
      final history = month.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));
      em(s.copyWith(monthRecords: month, history: history));
    } catch (e) {
      em(PrayerTrackerState.error(message: e.toString()));
    }
  }

  Future<void> _onLoadMonth(
    _LoadMonth e,
    Emitter<PrayerTrackerState> em,
  ) async {
    final month = await _repo.loadMonth(e.year, e.month);
    final history = month.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    final s = state;
    if (s is _Loaded) {
      em(s.copyWith(monthRecords: month, history: history));
    }
  }

  Future<void> _onCheckMissedDays(
    _CheckMissedDays e,
    Emitter<PrayerTrackerState> em,
  ) async {
    final lastRecord = await _repo.loadLastSavedRecord();
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    if (lastRecord == null) {
      add(PrayerTrackerEvent.load(normalizedToday));
      return;
    }

    final lastDate = DateTime(
      lastRecord.date.year,
      lastRecord.date.month,
      lastRecord.date.day,
    );
    final diff = normalizedToday.difference(lastDate).inDays;

    if (diff > 1) {
      final missedDates = <DateTime>[];
      for (int i = 1; i < diff; i++) {
        missedDates.add(lastDate.add(Duration(days: i)));
      }
      em(PrayerTrackerState.missedDaysPrompt(missedDates: missedDates));
    } else {
      add(PrayerTrackerEvent.load(normalizedToday));
    }
  }

  Future<void> _onAcknowledgeMissedDays(
    _AcknowledgeMissedDays e,
    Emitter<PrayerTrackerState> em,
  ) async {
    final lastRecord = await _repo.loadLastSavedRecord();
    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);

    if (lastRecord == null) {
      add(PrayerTrackerEvent.load(normalizedToday));
      return;
    }

    final lastDate = DateTime(
      lastRecord.date.year,
      lastRecord.date.month,
      lastRecord.date.day,
    );
    final diff = normalizedToday.difference(lastDate).inDays;

    if (diff <= 1) {
      add(PrayerTrackerEvent.load(normalizedToday));
      return;
    }

    final gapDates = <DateTime>[];
    for (int i = 1; i < diff; i++) {
      final date = lastDate.add(Duration(days: i));
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (normalizedDate.isBefore(normalizedToday)) {
        gapDates.add(normalizedDate);
      }
    }

    final selectedSet = Set<DateTime>.from(
      e.selectedDates.map((d) => DateTime(d.year, d.month, d.day)),
    );

    var runningQada = Map<Salaah, MissedCounter>.from(lastRecord.qada);

    for (final date in gapDates) {
      final isMissed = selectedSet.contains(date);

      if (isMissed) {
        for (final s in Salaah.values) {
          runningQada[s] = (runningQada[s] ?? const MissedCounter(0))
              .addMissed();
        }
      }

      final record = DailyRecord(
        id: '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        date: date,
        missedToday: isMissed ? Set<Salaah>.from(Salaah.values) : {},
        completedToday: isMissed ? {} : Set<Salaah>.from(Salaah.values),
        qada: Map.from(runningQada),
      );
      await _repo.saveToday(record);
    }

    final Set<Salaah> completedToday = <Salaah>{};
    final Set<Salaah> missedToday = <Salaah>{};
    final bool isPrayingToday = e.selectedDates.isEmpty;

    final lat = double.tryParse(_prefs.get('latitude')?.toString() ?? '');
    final lon = double.tryParse(_prefs.get('longitude')?.toString() ?? '');

    PrayerTimes? prayerTimes;
    if (lat != null && lon != null) {
      final method = _prefs.getString('calculation_method') ?? 'muslim_league';
      final madhab = _prefs.getString('madhab') ?? 'shafi';
      prayerTimes = _prayerTimeService.getPrayerTimes(
        latitude: lat,
        longitude: lon,
        method: method,
        madhab: madhab,
        date: today,
      );

      for (final s in Salaah.values) {
        if (_prayerTimeService.isPassed(
          s,
          prayerTimes: prayerTimes,
          date: today,
        )) {
          if (isPrayingToday) {
            completedToday.add(s);
          } else {
            missedToday.add(s);
            runningQada[s] = (runningQada[s] ?? const MissedCounter(0))
                .addMissed();
          }
        }
      }
    } else {
      for (final s in Salaah.values) {
        if (isPrayingToday) {
          completedToday.add(s);
        } else {
          missedToday.add(s);
          runningQada[s] = (runningQada[s] ?? const MissedCounter(0))
              .addMissed();
        }
      }
    }

    final todayRecord = DailyRecord(
      id: '${normalizedToday.year}-${normalizedToday.month.toString().padLeft(2, '0')}-${normalizedToday.day.toString().padLeft(2, '0')}',
      date: normalizedToday,
      missedToday: missedToday,
      completedToday: completedToday,
      qada: Map.from(runningQada),
    );
    await _repo.saveToday(todayRecord);

    add(PrayerTrackerEvent.load(normalizedToday));
  }

  Future<void> _onBulkAddQada(
    _BulkAddQada e,
    Emitter<PrayerTrackerState> em,
  ) async {
    if (state is _Loaded) {
      final s = state as _Loaded;
      final oldQada = s.qadaStatus;
      final qada = Map<Salaah, MissedCounter>.from(s.qadaStatus);
      for (final entry in e.counts.entries) {
        final current = qada[entry.key] ?? const MissedCounter(0);
        qada[entry.key] = MissedCounter(current.value + entry.value);
      }
      final newState = s.copyWith(qadaStatus: qada);
      em(newState);
      await _saveInternal(newState, em, oldQada: oldQada);
    }
  }
}
