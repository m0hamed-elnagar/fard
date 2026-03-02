import 'package:adhan/adhan.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

part 'prayer_tracker_bloc.freezed.dart';
part 'prayer_tracker_event.dart';
part 'prayer_tracker_state.dart';

class PrayerTrackerBloc extends Bloc<PrayerTrackerEvent, PrayerTrackerState> {
  final PrayerRepo _repo;
  final SharedPreferences _prefs;
  final PrayerTimeService _prayerTimeService;

  PrayerTrackerBloc(
    this._repo,
    this._prefs,
    this._prayerTimeService,
  ) : super(const PrayerTrackerState.loading()) {
    on<_Load>(_onLoad, transformer: sequential());
    on<_TogglePrayer>(_onTogglePrayer, transformer: sequential());
    on<_AddQada>(_onAddQada, transformer: sequential());
    on<_RemoveQada>(_onRemoveQada, transformer: sequential());
    on<_Save>(_onSave, transformer: sequential());
    on<_LoadMonth>(_onLoadMonth, transformer: sequential());
    on<_CheckMissedDays>(_onCheckMissedDays, transformer: sequential());
    on<_AcknowledgeMissedDays>(_onAcknowledgeMissedDays, transformer: sequential());
    on<_BulkAddQada>(_onBulkAddQada, transformer: sequential());
    on<_UpdateQada>(_onUpdateQada, transformer: sequential());
    on<_DeleteRecord>(_onDeleteRecord, transformer: sequential());
  }

  Future<void> _onUpdateQada(
      _UpdateQada e, Emitter<PrayerTrackerState> em) async {
    if (state is _Loaded) {
      final s = state as _Loaded;
      final oldQada = s.qadaStatus;
      final qada = <Salaah, MissedCounter>{};
      for (final entry in e.counts.entries) {
        qada[entry.key] = MissedCounter(entry.value);
      }
      final newState = s.copyWith(qadaStatus: qada);
      em(newState);
      
      final normalizedDate = DateTime(s.selectedDate.year, s.selectedDate.month, s.selectedDate.day);
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

      final month = await _repo.loadMonth(s.selectedDate.year, s.selectedDate.month);
      final history = month.values.toList()..sort((a, b) => b.date.compareTo(a.date));
      em(newState.copyWith(monthRecords: month, history: history));
    }
  }

  Future<void> _onDeleteRecord(
      _DeleteRecord e, Emitter<PrayerTrackerState> em) async {
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
            updatedQada[s] = earliest.missedToday.contains(s) ? const MissedCounter(1) : const MissedCounter(0);
          }
          final updatedEarliest = earliest.copyWith(qada: updatedQada);
          await _repo.saveToday(updatedEarliest);
          await _cascadeUpdateFrom(updatedEarliest, oldBaseQada: originalEarliestQada);
        }
      }

      add(PrayerTrackerEvent.load(s.selectedDate));
    }
  }

  Future<void> _cascadeUpdateFrom(DailyRecord updatedBaseRecord, {
    Map<Salaah, MissedCounter>? oldBaseQada,
    DailyRecord? deletedRecord,
  }) async {
    final allRecords = await _repo.loadAllRecords();
    
    final List<DailyRecord> originalChain = List.from(allRecords);
    if (deletedRecord != null) {
      originalChain.add(deletedRecord);
    }
    originalChain.sort((a, b) => a.date.compareTo(b.date));

    final futureRecords = allRecords.where((r) => r.date.isAfter(updatedBaseRecord.date)).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (futureRecords.isEmpty) return;

    DailyRecord runningNewPrev = updatedBaseRecord;

    for (final fr in futureRecords) {
      final currentIdx = originalChain.indexWhere((r) => r.date.isAtSameMomentAs(fr.date));
      if (currentIdx <= 0) {
        runningNewPrev = fr;
        continue;
      }
      
      final oldPrev = originalChain[currentIdx - 1];
      final updatedQada = <Salaah, MissedCounter>{};
      
      final oldLastUtc = DateTime.utc(oldPrev.date.year, oldPrev.date.month, oldPrev.date.day);
      final targetUtc = DateTime.utc(fr.date.year, fr.date.month, fr.date.day);
      final oldDiff = targetUtc.difference(oldLastUtc).inDays;
      final oldGaps = oldDiff > 1 ? (oldDiff - 1) : 0;

      final newLastUtc = DateTime.utc(runningNewPrev.date.year, runningNewPrev.date.month, runningNewPrev.date.day);
      final newDiff = targetUtc.difference(newLastUtc).inDays;
      final newGaps = newDiff > 1 ? (newDiff - 1) : 0;

      for (final s in Salaah.values) {
        int oldVal = fr.qada[s]?.value ?? 0;
        int oldPrevVal = oldPrev.qada[s]?.value ?? 0;
        
        if (oldPrev.date.isAtSameMomentAs(updatedBaseRecord.date) && oldBaseQada != null) {
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
      em(const PrayerTrackerState.loading());
      final normalizedDate = DateTime(e.date.year, e.date.month, e.date.day);
      final record = await _repo.loadRecord(normalizedDate);
      final lastSavedBefore = await _repo.loadLastRecordBefore(normalizedDate);
      
      final lat = _prefs.getDouble('latitude');
      final lon = _prefs.getDouble('longitude');
      
      PrayerTimes? prayerTimes;
      if (lat != null && lon != null) {
        final method = _prefs.getString('calculation_method') ?? 'muslim_league';
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
      if (record != null) {
        completedToday = Set.from(record.completedToday);
        missedToday = <Salaah>{};
        for (final s in Salaah.values) {
          if (_prayerTimeService.isPassed(s, prayerTimes: prayerTimes, date: normalizedDate) && 
              !completedToday.contains(s)) {
            missedToday.add(s);
          }
        }
      } else {
        missedToday = <Salaah>{};
        completedToday = <Salaah>{};
        for (final s in Salaah.values) {
          if (_prayerTimeService.isPassed(s, prayerTimes: prayerTimes, date: normalizedDate)) {
            missedToday.add(s);
          }
        }
      }
      
      Map<Salaah, MissedCounter> qada;
      if (record != null) {
        qada = Map.from(record.qada);
      } else if (lastSavedBefore != null) {
        final lastDate = DateTime(lastSavedBefore.date.year, lastSavedBefore.date.month, lastSavedBefore.date.day);
        
        qada = Map<Salaah, MissedCounter>.from(lastSavedBefore.qada);
        
        final lastUtc = DateTime.utc(lastDate.year, lastDate.month, lastDate.day);
        final targetUtc = DateTime.utc(normalizedDate.year, normalizedDate.month, normalizedDate.day);
        final diff = targetUtc.difference(lastUtc).inDays;
        
        if (diff >= 1) {
           final lastSavedLat = _prefs.getDouble('latitude');
           final lastSavedLon = _prefs.getDouble('longitude');
           if (lastSavedLat != null && lastSavedLon != null) {
              final method = _prefs.getString('calculation_method') ?? 'muslim_league';
              final madhab = _prefs.getString('madhab') ?? 'shafi';
              final lastSavedTimes = _prayerTimeService.getPrayerTimes(
                latitude: lastSavedLat,
                longitude: lastSavedLon,
                method: method,
                madhab: madhab,
                date: lastDate,
              );
              
              final lastSavedCompleted = lastSavedBefore.completedToday;
              final lastSavedMissed = lastSavedBefore.missedToday;
              
              for (final s in Salaah.values) {
                if (_prayerTimeService.isPassed(s, prayerTimes: lastSavedTimes, date: lastDate)) {
                  if (!lastSavedCompleted.contains(s) && !lastSavedMissed.contains(s)) {
                    qada[s] = (qada[s] ?? const MissedCounter(0)).addMissed();
                  }
                }
              }
           }

          final missedFullDays = diff - 1;
          if (missedFullDays > 0) {
            for (final s in Salaah.values) {
              final current = qada[s] ?? const MissedCounter(0);
              qada[s] = MissedCounter(current.value + missedFullDays);
            }
          }
        }
      } else {
        qada = {for (final s in Salaah.values) s: const MissedCounter(0)};
      }

      final now = DateTime.now();
      final isToday = normalizedDate.year == now.year &&
                      normalizedDate.month == now.month &&
                      normalizedDate.day == now.day;
      
      bool needsSave = false;
      if (isToday || record == null) {
        final existingMissed = record?.missedToday ?? {};
        for (final s in missedToday) {
          if (!existingMissed.contains(s)) {
            qada[s] = (qada[s] ?? const MissedCounter(0)).addMissed();
            needsSave = true;
          }
        }
        if (isToday) {
          for (final s in existingMissed) {
            if (!missedToday.contains(s) && !completedToday.contains(s)) {
              qada[s] = (qada[s] ?? const MissedCounter(0)).removeMissed();
              needsSave = true;
            }
          }
        }
      }

      final currentState = state;
      final loadedState = PrayerTrackerState.loaded(
        selectedDate: normalizedDate,
        missedToday: missedToday,
        completedToday: completedToday,
        qadaStatus: qada,
        completedQadaToday: record?.completedQada ?? {},
        monthRecords: (currentState is _Loaded) ? currentState.monthRecords : {},
        history: (currentState is _Loaded) ? currentState.history : [], 
      );

      em(loadedState);

      if (needsSave) {
        await _saveInternal(loadedState as _Loaded, em);
      }

      final month = await _repo.loadMonth(normalizedDate.year, normalizedDate.month);
      if (state is _Loaded) {
        final current = state as _Loaded;
        em(current.copyWith(
          monthRecords: month,
          history: month.values.toList()
            ..sort((a, b) => b.date.compareTo(a.date)),
        ));
      }
    } catch (e) {
      em(PrayerTrackerState.error(message: e.toString()));
    }
  }

  Future<void> _onTogglePrayer(_TogglePrayer e, Emitter<PrayerTrackerState> em) async {
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
          qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).removeMissed();
        } else if (completed.contains(e.prayer)) {
          completed.remove(e.prayer);
          missed.add(e.prayer);
          qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).addMissed();
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
        
        final normalizedDate = DateTime(s.selectedDate.year, s.selectedDate.month, s.selectedDate.day);
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
        
        final month = await _repo.loadMonth(s.selectedDate.year, s.selectedDate.month);
        final history = month.values.toList()..sort((a, b) => b.date.compareTo(a.date));
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
      
      final normalizedDate = DateTime(s.selectedDate.year, s.selectedDate.month, s.selectedDate.day);
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
      
      final month = await _repo.loadMonth(s.selectedDate.year, s.selectedDate.month);
      final history = month.values.toList()..sort((a, b) => b.date.compareTo(a.date));
      em(newState.copyWith(monthRecords: month, history: history));
    }
  }

  Future<void> _onRemoveQada(_RemoveQada e, Emitter<PrayerTrackerState> em) async {
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
      
      qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).removeMissed();
      
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
      
      final normalizedDate = DateTime(s.selectedDate.year, s.selectedDate.month, s.selectedDate.day);
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
      
      final month = await _repo.loadMonth(s.selectedDate.year, s.selectedDate.month);
      final history = month.values.toList()..sort((a, b) => b.date.compareTo(a.date));
      em(newState.copyWith(monthRecords: month, history: history));
    }
  }

  Future<void> _onSave(_Save e, Emitter<PrayerTrackerState> em) async {
    if (state is _Loaded) {
      final s = state as _Loaded;
      await _saveInternal(s, em, oldQada: s.qadaStatus);
    }
  }

  Future<void> _saveInternal(_Loaded s, Emitter<PrayerTrackerState> em, {Map<Salaah, MissedCounter>? oldQada}) async {
    try {
      final normalizedDate = DateTime(s.selectedDate.year, s.selectedDate.month, s.selectedDate.day);
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

      final month = await _repo.loadMonth(s.selectedDate.year, s.selectedDate.month);
      final history = month.values.toList()..sort((a, b) => b.date.compareTo(a.date));
      em(s.copyWith(monthRecords: month, history: history));
    } catch (e) {
      em(PrayerTrackerState.error(message: e.toString()));
    }
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
    if (e.selectedDates.isEmpty) {
      final s = state;
      if (s is _Loaded) {
        add(PrayerTrackerEvent.load(s.selectedDate));
      } else {
        add(PrayerTrackerEvent.load(DateTime.now()));
      }
      return;
    }

    final lastRecord = await _repo.loadLastSavedRecord();
    var currentQada = lastRecord?.qada ??
        {for (final s in Salaah.values) s: const MissedCounter(0)};

    final updatedQada = <Salaah, MissedCounter>{};
    for (final s in Salaah.values) {
      final additional = e.selectedDates.length;
      final current = currentQada[s]?.value ?? 0;
      updatedQada[s] = MissedCounter(current + additional);
    }

    final latestDate = e.selectedDates.reduce((a, b) => a.isAfter(b) ? a : b);
    final normalizedLatest = DateTime(latestDate.year, latestDate.month, latestDate.day);
    final record = DailyRecord(
      id: '${normalizedLatest.year}-${normalizedLatest.month.toString().padLeft(2, '0')}-${normalizedLatest.day.toString().padLeft(2, '0')}',
      date: normalizedLatest,
      missedToday: Set<Salaah>.from(Salaah.values),
      completedToday: const {},
      qada: updatedQada,
    );
    await _repo.saveToday(record);
    await _cascadeUpdateFrom(record);

    add(PrayerTrackerEvent.load(normalizedLatest));
  }

  Future<void> _onBulkAddQada(
      _BulkAddQada e, Emitter<PrayerTrackerState> em) async {
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
