import 'package:adhan/adhan.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    on<_Load>(_onLoad);
    on<_TogglePrayer>(_onTogglePrayer);
    on<_AddQada>(_onAddQada);
    on<_RemoveQada>(_onRemoveQada);
    on<_Save>(_onSave);
    on<_LoadMonth>(_onLoadMonth);
    on<_CheckMissedDays>(_onCheckMissedDays);
    on<_AcknowledgeMissedDays>(_onAcknowledgeMissedDays);
    on<_BulkAddQada>(_onBulkAddQada);
    on<_UpdateQada>(_onUpdateQada);
    on<_DeleteRecord>(_onDeleteRecord);
  }

  Future<void> _onUpdateQada(
      _UpdateQada e, Emitter<PrayerTrackerState> em) async {
    if (state is _Loaded) {
      final s = state as _Loaded;
      final qada = <Salaah, MissedCounter>{};
      for (final entry in e.counts.entries) {
        qada[entry.key] = MissedCounter(entry.value);
      }
      final newState = s.copyWith(qadaStatus: qada);
      em(newState);
      await _saveInternal(newState, em);
    }
  }

  Future<void> _onDeleteRecord(
      _DeleteRecord e, Emitter<PrayerTrackerState> em) async {
    if (state is _Loaded) {
      final s = state as _Loaded;
      final deletedDate = DateTime(e.date.year, e.date.month, e.date.day);

      // 1. Perform actual deletion
      await _repo.deleteRecord(deletedDate);

      // 2. Cascade update for ALL records AFTER the deleted date
      // to ensure their qada balance is still correct relative to the new past
      final allRecords = await _repo.loadAllRecords();
      // loadAllRecords is sorted descending (newest first)
      final futureRecords = allRecords.where((r) => r.date.isAfter(deletedDate)).toList()
        ..sort((a, b) => a.date.compareTo(b.date)); // Sort ascending for sequential update

      if (futureRecords.isNotEmpty) {
        for (final fr in futureRecords) {
          // We need to re-calculate this record's qada based on its new predecessor
          final prev = await _repo.loadLastRecordBefore(fr.date);
          final updatedQada = <Salaah, MissedCounter>{};
          
          if (prev != null) {
             // Logic similar to _onLoad but focused on bridging from prev to fr
             final lastDate = DateTime(prev.date.year, prev.date.month, prev.date.day);
             final targetDate = DateTime(fr.date.year, fr.date.month, fr.date.day);
             
             // Initial balance from previous record
             for (final s in Salaah.values) {
               updatedQada[s] = prev.qada[s] ?? const MissedCounter(0);
             }

             final lat = _prefs.getDouble('latitude');
             final lon = _prefs.getDouble('longitude');
             final method = _prefs.getString('calculation_method') ?? 'muslim_league';
             final madhab = _prefs.getString('madhab') ?? 'shafi';

             // Step A: Account for missed on lastDate that weren't in prev.missedToday
             if (lat != null && lon != null) {
                final lastSavedTimes = _prayerTimeService.getPrayerTimes(
                  latitude: lat, longitude: lon, method: method, madhab: madhab, date: lastDate,
                );
                for (final s in Salaah.values) {
                  if (_prayerTimeService.isPassed(s, prayerTimes: lastSavedTimes, date: lastDate)) {
                    if (!prev.completedToday.contains(s) && !prev.missedToday.contains(s)) {
                      updatedQada[s] = updatedQada[s]!.addMissed();
                    }
                  }
                }
             }

             // Step B: Full days in between
             final lastUtc = DateTime.utc(lastDate.year, lastDate.month, lastDate.day);
             final targetUtc = DateTime.utc(targetDate.year, targetDate.month, targetDate.day);
             final diff = targetUtc.difference(lastUtc).inDays;
             if (diff > 1) {
               for (final s in Salaah.values) {
                 updatedQada[s] = MissedCounter(updatedQada[s]!.value + (diff - 1));
               }
             }

             // Step C: Current record's missedToday (these were already missed relative to targetDate)
             for (final s in fr.missedToday) {
               updatedQada[s] = updatedQada[s]!.addMissed();
             }
          } else {
            // No predecessor anymore, qada should just be fr.missedToday.length for each prayer?
            // Actually if there's no predecessor, it's like a fresh start.
            for (final s in Salaah.values) {
              updatedQada[s] = fr.missedToday.contains(s) ? const MissedCounter(1) : const MissedCounter(0);
            }
          }

          final updatedRecord = fr.copyWith(qada: updatedQada);
          await _repo.saveToday(updatedRecord);
        }
      }

      // 3. Trigger reload for current day to refresh counters and ensure DB sync
      add(PrayerTrackerEvent.load(s.selectedDate));
    }
  }

  Future<void> _onLoad(_Load e, Emitter<PrayerTrackerState> em) async {
    try {
      em(const PrayerTrackerState.loading());
      final record = await _repo.loadRecord(e.date);
      // Use loadLastRecordBefore to carry over qada from the past, not from a future record
      final lastSavedBefore = await _repo.loadLastRecordBefore(e.date);
      
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
          date: e.date,
        );
      }

      Set<Salaah> missedToday;
      Set<Salaah> completedToday;
      if (record != null) {
        completedToday = Set.from(record.completedToday);
        // Missed today should ONLY be what has PASSED and NOT been COMPLETED
        missedToday = <Salaah>{};
        for (final s in Salaah.values) {
          if (_prayerTimeService.isPassed(s, prayerTimes: prayerTimes, date: e.date) && 
              !completedToday.contains(s)) {
            missedToday.add(s);
          }
        }
      } else {
        missedToday = <Salaah>{};
        completedToday = <Salaah>{};
        for (final s in Salaah.values) {
          if (_prayerTimeService.isPassed(s, prayerTimes: prayerTimes, date: e.date)) {
            missedToday.add(s);
          }
        }
      }
      
      // If no records exist, carry over qada
      Map<Salaah, MissedCounter> qada;
      if (record != null) {
        qada = Map.from(record.qada);
      } else if (lastSavedBefore != null) {
        // Carry over base qada AND add missed prayers from days between lastSavedBefore and e.date
        final lastDate = DateTime(lastSavedBefore.date.year, lastSavedBefore.date.month, lastSavedBefore.date.day);
        final targetDate = DateTime(e.date.year, e.date.month, e.date.day);
        
        qada = Map<Salaah, MissedCounter>.from(lastSavedBefore.qada);
        
        if (targetDate.isAfter(lastDate)) {
          final lastUtc = DateTime.utc(lastDate.year, lastDate.month, lastDate.day);
          final targetUtc = DateTime.utc(targetDate.year, targetDate.month, targetDate.day);
          final diff = targetUtc.difference(lastUtc).inDays;
          
          if (diff >= 1) {
             // 1. Account for missed prayers on the 'lastSavedBefore' day that were not added to qada balance yet
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

            // 2. Add 5 prayers for every FULL day missed between lastDate and targetDate
            final missedFullDays = diff - 1;
            if (missedFullDays > 0) {
              for (final s in Salaah.values) {
                final current = qada[s] ?? const MissedCounter(0);
                qada[s] = MissedCounter(current.value + missedFullDays);
              }
            }
          }
        }
      } else {
        qada = {for (final s in Salaah.values) s: const MissedCounter(0)};
      }

      // If this is Today, account for newly added missedToday into the live qada balance.
      final now = DateTime.now();
      final isToday = e.date.year == now.year &&
                      e.date.month == now.month &&
                      e.date.day == now.day;
      
      bool needsSave = false;
      if (isToday || record == null) {
        final existingMissed = record?.missedToday ?? {};
        // Add new missed prayers
        for (final s in missedToday) {
          if (!existingMissed.contains(s)) {
            qada[s] = (qada[s] ?? const MissedCounter(0)).addMissed();
            needsSave = true;
          }
        }
        // Only remove if it's actually today (otherwise we might be retroactively changing history incorrectly if time service logic changes)
        if (isToday) {
          // Remove prayers that are no longer missed (e.g. time moved back)
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
        selectedDate: e.date,
        missedToday: missedToday,
        completedToday: completedToday,
        qadaStatus: qada,
        completedQadaToday: record?.completedQada ?? {},
        monthRecords: (currentState is _Loaded) ? currentState.monthRecords : {},
        history: (currentState is _Loaded) ? currentState.history : [], 
      );

      // Initial state without month records first to show UI quickly
      em(loadedState);

      if (needsSave) {
        await _saveInternal(loadedState as _Loaded, em);
      }

      // Load month data
      final month = await _repo.loadMonth(e.date.year, e.date.month);
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
    if (state is _Loaded) {
      final s = state as _Loaded;
      final missed = Set<Salaah>.from(s.missedToday);
      final completed = Set<Salaah>.from(s.completedToday);
      final qada = Map<Salaah, MissedCounter>.from(s.qadaStatus);
      
      final now = DateTime.now();
      final isToday = s.selectedDate.year == now.year &&
                      s.selectedDate.month == now.month &&
                      s.selectedDate.day == now.day;

      // Optional: Sync any prayers that might have passed since last load
      if (isToday) {
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
            date: s.selectedDate,
          );
        }

        for (final slh in Salaah.values) {
          if (_prayerTimeService.isPassed(slh, prayerTimes: prayerTimes, date: s.selectedDate)) {
            if (!completed.contains(slh) && !missed.contains(slh)) {
              missed.add(slh);
              qada[slh] = (qada[slh] ?? const MissedCounter(0)).addMissed();
            }
          } else {
            // If NOT passed, it cannot be missed
            if (missed.contains(slh)) {
              missed.remove(slh);
              qada[slh] = (qada[slh] ?? const MissedCounter(0)).removeMissed();
            }
          }
        }
      }

          final completedQada = Map<Salaah, int>.from(s.completedQadaToday);
          if (missed.contains(e.prayer)) {
            // It was missed, now it's prayed
            missed.remove(e.prayer);
            completed.add(e.prayer);
            if (isToday) {
              qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).removeMissed();
              completedQada[e.prayer] = (completedQada[e.prayer] ?? 0) + 1;
            }
          } else if (completed.contains(e.prayer)) {
            // It was prayed, now it's missed
            completed.remove(e.prayer);
            missed.add(e.prayer);
            if (isToday) {
              qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).addMissed();
              // If they had previously removed qada for this prayer today, 
              // toggling it back to missed should consume one of those "undos"
              if ((completedQada[e.prayer] ?? 0) > 0) {
                completedQada[e.prayer] = completedQada[e.prayer]! - 1;
              }
            }
          } else {
            // It was neither (e.g. time hadn't passed yet, or first load after time pass)
            // Toggle should probably mark it as COMPLETED if it wasn't already.
            completed.add(e.prayer);
          }
          final newState = s.copyWith(
            missedToday: missed, 
            completedToday: completed, 
            qadaStatus: qada,
            completedQadaToday: completedQada,
          );
      
      em(newState);
      await _saveInternal(newState, em);
    }
  }

  Future<void> _onAddQada(_AddQada e, Emitter<PrayerTrackerState> em) async {
    if (state is _Loaded) {
      final s = state as _Loaded;
      final qada = Map<Salaah, MissedCounter>.from(s.qadaStatus);
      final missed = Set<Salaah>.from(s.missedToday);
      final completed = Set<Salaah>.from(s.completedToday);
      
      final now = DateTime.now();
      final isToday = s.selectedDate.year == now.year &&
                      s.selectedDate.month == now.month &&
                      s.selectedDate.day == now.day;

      bool isUndoingTodayRecovery = false;
      if (isToday && completed.contains(e.prayer)) {
         // It was completed today, now it's missed again
         completed.remove(e.prayer);
         missed.add(e.prayer);
         isUndoingTodayRecovery = true;
      }

      final completedQada = Map<Salaah, int>.from(s.completedQadaToday);
      final currentBudget = completedQada[e.prayer] ?? 0;

      // Safety check: Only proceed if we are undoing a today-recovery OR we have budget
      if (isUndoingTodayRecovery || currentBudget > 0) {
        qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).addMissed();
        
        // Decrement completed today if we have budget
        if (currentBudget > 0) {
          completedQada[e.prayer] = currentBudget - 1;
        }
      }
      
      final newState = s.copyWith(
        qadaStatus: qada, 
        completedQadaToday: completedQada,
        missedToday: missed,
        completedToday: completed,
      );
      em(newState);
      await _saveInternal(newState, em);
    }
  }

  Future<void> _onRemoveQada(_RemoveQada e, Emitter<PrayerTrackerState> em) async {
    if (state is _Loaded) {
      final s = state as _Loaded;
      final missed = Set<Salaah>.from(s.missedToday);
      final completed = Set<Salaah>.from(s.completedToday);
      final qada = Map<Salaah, MissedCounter>.from(s.qadaStatus);
      
      final now = DateTime.now();
      final isToday = s.selectedDate.year == now.year &&
                      s.selectedDate.month == now.month &&
                      s.selectedDate.day == now.day;

      bool isRecoveringToday = false;
      if (isToday && missed.contains(e.prayer)) {
        // If user is removing qada for today's prayer that was missed, 
        // it means they prayed it now.
        missed.remove(e.prayer);
        completed.add(e.prayer);
        isRecoveringToday = true;
      }
      
      qada[e.prayer] = (qada[e.prayer] ?? const MissedCounter(0)).removeMissed();
      
      // Increment completed today budget/limit
      final completedQada = Map<Salaah, int>.from(s.completedQadaToday);
      completedQada[e.prayer] = (completedQada[e.prayer] ?? 0) + 1;
      
      final newState = s.copyWith(
        missedToday: missed, 
        completedToday: completed, 
        qadaStatus: qada,
        completedQadaToday: completedQada,
      );
      em(newState);
      await _saveInternal(newState, em);
    }
  }

  // Deprecated manual save, but we can keep handler just in case
  Future<void> _onSave(_Save e, Emitter<PrayerTrackerState> em) async {
    if (state is _Loaded) {
      await _saveInternal(state as _Loaded, em);
    }
  }

  Future<void> _saveInternal(_Loaded s, Emitter<PrayerTrackerState> em) async {
    try {
      final dateKey =
          '${s.selectedDate.year}-${s.selectedDate.month.toString().padLeft(2, '0')}-${s.selectedDate.day.toString().padLeft(2, '0')}';
      final record = DailyRecord(
        id: dateKey,
        date: DateTime(
            s.selectedDate.year, s.selectedDate.month, s.selectedDate.day),
        missedToday: s.missedToday,
        completedToday: s.completedToday,
        qada: s.qadaStatus,
        completedQada: s.completedQadaToday,
      );
      await _repo.saveToday(record);

      // Reload month data to update history list properly
      final month =
          await _repo.loadMonth(s.selectedDate.year, s.selectedDate.month);

      // Sort descending by date
      final history = month.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

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

    // Add selected days to the qada balance
    // We treat each selected date as a day where all 5 prayers were missed
    final updatedQada = <Salaah, MissedCounter>{};
    for (final s in Salaah.values) {
      final additional = e.selectedDates.length;
      final current = currentQada[s]?.value ?? 0;
      updatedQada[s] = MissedCounter(current + additional);
    }

    // Save a single record for the latest selected date to fill the timeline
    // and store the new cumulative qada balance
    final latestDate = e.selectedDates.reduce((a, b) => a.isAfter(b) ? a : b);
    final dateKey =
        '${latestDate.year}-${latestDate.month.toString().padLeft(2, '0')}-${latestDate.day.toString().padLeft(2, '0')}';

    final record = DailyRecord(
      id: dateKey,
      date: latestDate,
      missedToday: Set<Salaah>.from(Salaah.values),
      completedToday: const {},
      qada: updatedQada,
    );
    await _repo.saveToday(record);

    // Load the latest record date after handling to reflect the new state
    add(PrayerTrackerEvent.load(latestDate));
  }

  Future<void> _onBulkAddQada(
      _BulkAddQada e, Emitter<PrayerTrackerState> em) async {
    if (state is _Loaded) {
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
}
