import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/werd_history_entry.dart';
import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/werd/presentation/blocs/werd_state.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:injectable/injectable.dart';
import 'package:quran/quran.dart' as quran;

import '../../domain/entities/werd_goal.dart';

@injectable
class WerdBloc extends Bloc<WerdEvent, WerdState> {
  final WerdRepository _repository;
  final NotificationService _notificationService;
  StreamSubscription? _progressSubscription;

  WerdBloc(
    this._repository, [
    NotificationService? notificationService,
  ]) : _notificationService =
           notificationService ?? getIt<NotificationService>(),
       super(WerdState.initial()) {
    on<WerdEvent>((event, emit) async {
      await event.map(
        load: (e) async {
          debugPrint('🔄 [WerdBloc] Load event triggered for: ${e.id}');
          emit(state.copyWith(isLoading: true));
          _progressSubscription?.cancel();
          _progressSubscription = _repository
              .watchProgress(goalId: e.id)
              .listen((result) {
                result.fold(
                  (_) => null,
                  (progress) {
                    debugPrint('📡 [WerdBloc] WatchProgress emitted progress update');
                    add(WerdEvent.progressUpdated(progress));
                  },
                );
              });

          final goalRes = await _repository.getGoal(id: e.id);
          final progressRes = await _repository.getProgress(goalId: e.id);
          
          // DEBUG: Log what we loaded
          debugPrint('📦 [WerdBloc] Loaded from storage:');
          progressRes.fold(
            (failure) => debugPrint('   ❌ Failed to load progress: ${failure.message}'),
            (progress) {
              debugPrint('   ✅ Progress loaded');
              debugPrint('   - Segments today: ${progress.segmentsToday.length}');
              debugPrint('   - Total ayahs today: ${progress.totalAmountReadToday}');
              for (var i = 0; i < progress.segmentsToday.length; i++) {
                final seg = progress.segmentsToday[i];
                debugPrint('   - Segment $i: ${seg.startAyah}-${seg.endAyah} (${seg.ayahsCount} ayahs, ${seg.formattedStartTime} - ${seg.formattedEndTime})');
              }
            },
          );

          emit(
            state.copyWith(
              isLoading: false,
              goal: goalRes.fold((_) => null, (g) => g),
              progress: progressRes.fold((_) => null, (p) => p),
            ),
          );
        },
        setGoal: (e) async {
          emit(state.copyWith(isLoading: true));
          await _repository.setGoal(e.goal);

          // Get current progress before resetting
          final currentProgressRes = await _repository.getProgress(
            goalId: e.goal.id,
          );
          final currentProgress = currentProgressRes.fold(
            (_) => WerdProgress(
              goalId: e.goal.id,
              totalAmountReadToday: 0,
              lastUpdated: DateTime.now(),
              streak: 0,
            ),
            (p) => p,
          );

          // FIX #4: Save today's sessions to history BEFORE resetting
          // This prevents data loss when changing goals
          var progressToSave = currentProgress;
          
          debugPrint('🔍 [Goal Change] Before saving to history:');
          debugPrint('   totalAmountReadToday: ${currentProgress.totalAmountReadToday}');
          debugPrint('   segmentsToday: ${currentProgress.segmentsToday.length}');
          debugPrint('   history entries: ${currentProgress.history.length}');
          
          if (currentProgress.totalAmountReadToday > 0 || currentProgress.segmentsToday.isNotEmpty) {
            final dateKey = DateTime.now().toIso8601String().split('T')[0];
            
            debugPrint('💾 [Goal Change] Saving to history with key: $dateKey');
            
            // Calculate history entry from current segments
            final startAbs = currentProgress.sessionStartAbsolute ?? 
                             (currentProgress.segmentsToday.isNotEmpty ? currentProgress.segmentsToday.first.startAyah : 1);
            final endAbs = currentProgress.lastReadAbsolute ?? 
                           (currentProgress.segmentsToday.isNotEmpty ? currentProgress.segmentsToday.last.endAyah : startAbs);
            
            final pagesRead = QuranHizbProvider.calculateFractionalProgressFromSegments(
              currentProgress.segmentsToday,
              WerdUnit.page,
            );
            final juzRead = QuranHizbProvider.calculateFractionalProgressFromSegments(
              currentProgress.segmentsToday,
              WerdUnit.juz,
            );
            
            final startPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(startAbs);
            final endPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(endAbs);
            final startSurahName = quran.getSurahName(startPos[0]);
            final endSurahName = quran.getSurahName(endPos[0]);
            
            final summary = "Read ${currentProgress.totalAmountReadToday} ayahs (${pagesRead.toStringAsFixed(1)} pages) from $startSurahName ${startPos[1]} to $endSurahName ${endPos[1]}";
            
            final historyEntry = WerdHistoryEntry(
              totalAyahsRead: currentProgress.totalAmountReadToday,
              startAbsolute: startAbs,
              endAbsolute: endAbs,
              pagesRead: pagesRead,
              juzRead: juzRead,
              segmentCount: currentProgress.segmentsToday.length,
              startSurahName: startSurahName,
              startAyahNumber: startPos[1],
              endSurahName: endSurahName,
              endAyahNumber: endPos[1],
              summary: summary,
              sessions: currentProgress.segmentsToday.isNotEmpty ? currentProgress.segmentsToday : null,
            );
            
            // Add to history
            final newHistory = Map<String, WerdHistoryEntry>.from(currentProgress.history);
            newHistory[dateKey] = historyEntry;
            
            debugPrint('💾 [Goal Change] Saved today\'s sessions to history: $dateKey - ${currentProgress.totalAmountReadToday} ayahs');
            debugPrint('   History entries now: ${newHistory.length}');
            
            progressToSave = currentProgress.copyWith(
              history: newHistory,
            );
          } else {
            debugPrint('⚠️ [Goal Change] No sessions to save (totalAmountReadToday=0, segmentsToday=0)');
          }

          // NOW reset progress for the new goal
          final updatedProgress = progressToSave.copyWith(
            lastReadAbsolute: e.goal.startAbsolute != null
                ? e.goal.startAbsolute! - 1
                : null,
            sessionStartAbsolute: e.goal.startAbsolute,
            totalAmountReadToday: 0,
            segmentsToday: const [], // ✅ Reset segments
            readItemsToday: const {}, // ✅ Reset read items
            lastUpdated: DateTime.now(),
          );
          
          debugPrint('📊 [Goal Change] After reset:');
          debugPrint('   totalAmountReadToday: ${updatedProgress.totalAmountReadToday}');
          debugPrint('   segmentsToday: ${updatedProgress.segmentsToday.length}');
          debugPrint('   history entries: ${updatedProgress.history.length}');
          
          await _repository.updateProgress(updatedProgress);
          debugPrint('✅ [Goal Change] Progress reset for new goal');

          if (state.goal?.id != e.goal.id) {
            debugPrint('🔄 [Goal Change] Loading progress for new goal: ${e.goal.id}');
            add(WerdEvent.load(id: e.goal.id));
          } else {
            emit(
              state.copyWith(
                isLoading: false,
                goal: e.goal,
                progress: updatedProgress,
              ),
            );
          }
        },
        startSession: (e) async {
          // Clicked "Continue": Create a new explicit reading session
          // NOTE: We don't update totalAmountReadToday or lastReadAbsolute here.
          // Those are only updated when the user actually reads (trackItemRead).
          debugPrint('🎬 [WerdBloc] Continue button - starting session at ayah ${e.startAyah}');

          final goalId = state.goal?.id ?? 'default';
          final progressRes = await _repository.getProgress(goalId: goalId);
          final currentProgress = progressRes.fold(
            (_) => WerdProgress(
              goalId: goalId,
              totalAmountReadToday: 0,
              segmentsToday: const [],
              lastUpdated: DateTime.now(),
              streak: 0,
            ),
            (p) => p,
          );

          final segments = List<ReadingSegment>.from(currentProgress.segmentsToday);

          // Find the last active session (endTime == null)
          int? activeIndex;
          for (int i = segments.length - 1; i >= 0; i--) {
            if (segments[i].endTime == null) {
              activeIndex = i;
              break;
            }
          }

          if (activeIndex != null) {
            final activeSeg = segments[activeIndex];
            final ayahsRead = activeSeg.endAyah - activeSeg.startAyah + 1;
            final sessionAge = DateTime.now().difference(activeSeg.startTime!);

            // If session is "empty" (just the start point) AND recent (< 5 min)
            // → Remove it to avoid ghost sessions from accidental double-Continue
            if (ayahsRead <= 1 && sessionAge.inMinutes < 5) {
              segments.removeAt(activeIndex);
              debugPrint('🗑️ Removed empty session at ${activeSeg.startAyah} (${sessionAge.inMinutes} min old)');
            } else {
              // User actually read something or it's an older session → end it properly
              segments[activeIndex] = activeSeg.endSession();
              debugPrint('✅ Ended previous session: ${activeSeg.startAyah}-${activeSeg.endAyah} (${activeSeg.durationMinutes} min)');
            }
          }

          // Create the NEW session for this Continue click
          segments.add(ReadingSegment(
            startAyah: e.startAyah,
            endAyah: e.startAyah,
            startTime: DateTime.now(),
          ));

          debugPrint('📖 Created new session: ayah ${e.startAyah} (Total sessions: ${segments.length})');

          final updatedProgress = currentProgress.copyWith(
            segmentsToday: segments,
            // Don't update totalAmountReadToday - only count when user actually reads
            sessionStartAbsolute: e.startAyah,
            // Don't update lastReadAbsolute - only update when user actually reads
            lastUpdated: DateTime.now(),
          );

          await _repository.updateProgress(updatedProgress);

          // Emit updated state
          await _emitUpdatedState(goalId);
        },
        endSession: (e) async {
          // User left Quran reader: End the daily session
          debugPrint('🏁 [WerdBloc] Ending daily session');

          final goalId = state.goal?.id ?? 'default';
          final progressRes = await _repository.getProgress(goalId: goalId);
          final currentProgress = progressRes.fold(
            (_) {
              debugPrint('⚠️ No progress found, nothing to end');
              return null;
            },
            (p) => p,
          );

          if (currentProgress == null) return;
          if (currentProgress.segmentsToday.isEmpty) {
            debugPrint('⚠️ No sessions to end');
            return;
          }

          // Find and end the active session
          final segments = List<ReadingSegment>.from(currentProgress.segmentsToday);
          int activeIndex = -1;
          
          for (int i = segments.length - 1; i >= 0; i--) {
            if (segments[i].endTime == null) {
              activeIndex = i;
              break;
            }
          }

          if (activeIndex >= 0) {
            segments[activeIndex] = segments[activeIndex].endSession();
            debugPrint('✅ Daily session ended: ${segments[activeIndex].startAyah} → ${segments[activeIndex].endAyah} (${segments[activeIndex].durationMinutes} min)');

            // Remove empty segments (where no ayahs were actually read)
            segments.removeWhere((seg) => seg.startAyah == seg.endAyah && seg.endTime != null);
          } else {
            debugPrint('⚠️ No active session to end');
          }

          final updatedProgress = currentProgress.copyWith(
            segmentsToday: segments,
            lastUpdated: DateTime.now(),
          );

          await _repository.updateProgress(updatedProgress);
          
          // Emit updated state
          await _emitUpdatedState(goalId);
        },
        progressUpdated: (e) {
          emit(state.copyWith(progress: e.progress));
          // Smart cancellation: if goal is completed today, cancel the reminder
          final goal = state.goal;
          if (goal != null && e.progress.totalAmountReadToday >= goal.valueInAyahs) {
            _notificationService.cancelWerdReminder(forTodayOnly: true);
          }
        },
        updateBookmark: (e) async {
          // No longer used to update progress
        },
        trackItemRead: (e) async {
          // If we track a single item (e.g. from Mushaf tap),
          // we treat it as "reached this point" for today's session
          await _handleBookmarkUpdate(e.absoluteIndex);
        },
        trackRangeRead: (e) async {
          // DEBUG: Log event received
          debugPrint('📨 [WerdBloc] Received trackRangeRead event:');
          debugPrint('   e.startAbsolute = ${e.startAbsolute}');
          debugPrint('   e.endAbsolute = ${e.endAbsolute}');
          
          // FIXED: Use _handleRangeTracking to properly create segment with both start and end
          // Previously was calling _handleBookmarkUpdate(e.endAbsolute) which only tracked the end ayah
          await _handleRangeTracking(e.startAbsolute, e.endAbsolute);
        },
        trackItemReadMarkAll: (e) async {
          // Jump dialog "Mark All": Extend daily session with full range
          debugPrint('📖 [WerdBloc] Jump dialog: Marking range ${e.startAbsolute}-${e.endAbsolute} as read');
          
          final goalId = state.goal?.id ?? 'default';
          final progressRes = await _repository.getProgress(goalId: goalId);
          final currentProgress = progressRes.fold(
            (_) => WerdProgress(
              goalId: goalId,
              totalAmountReadToday: 0,
              segmentsToday: const [],
              lastUpdated: DateTime.now(),
              streak: 0,
            ),
            (p) => p,
          );

          // Normalize the range
          final normalizedStart = e.startAbsolute < e.endAbsolute ? e.startAbsolute : e.endAbsolute;
          final normalizedEnd = e.startAbsolute < e.endAbsolute ? e.endAbsolute : e.startAbsolute;

          // Find or create daily session
          final segments = List<ReadingSegment>.from(currentProgress.segmentsToday);
          int activeSessionIndex = -1;
          for (int i = segments.length - 1; i >= 0; i--) {
            if (segments[i].endTime == null) {
              activeSessionIndex = i;
              break;
            }
          }

          if (activeSessionIndex >= 0) {
            // Extend existing daily session to include this range
            final activeSeg = segments[activeSessionIndex];
            final newStart = activeSeg.startAyah < normalizedStart ? activeSeg.startAyah : normalizedStart;
            final newEnd = activeSeg.endAyah > normalizedEnd ? activeSeg.endAyah : normalizedEnd;
            segments[activeSessionIndex] = ReadingSegment(
              startAyah: newStart,
              endAyah: newEnd,
              startTime: activeSeg.startTime,
              endTime: null,
            );
            debugPrint('📖 Extended daily session: $newStart → $newEnd');
          } else {
            // Create first session for today
            segments.add(ReadingSegment(
              startAyah: normalizedStart,
              endAyah: normalizedEnd,
              startTime: DateTime.now(),
            ));
            debugPrint('📖 Created daily session: $normalizedStart → $normalizedEnd');
          }

          final newTotal = segments.fold(0, (sum, seg) => sum + seg.ayahsCount);
          
          // FIX #1: Populate readItemsToday from segments for fractional calculations
          final readItems = _segmentsToReadItems(segments);

          final newProgress = currentProgress.copyWith(
            totalAmountReadToday: newTotal,
            segmentsToday: segments,
            readItemsToday: readItems,  // ✅ FIX: Populate from segments
            lastReadAbsolute: normalizedEnd,
            lastUpdated: DateTime.now(),
          );

          await _repository.updateProgress(newProgress);
          debugPrint('✅ Daily session updated - Total: $newTotal ayahs');
          
          // Emit updated state
          await _emitUpdatedState(goalId);
        },
        jumpToNewSession: (e) async {
          debugPrint(
              '🚀 [WerdBloc] Jump to New Session triggered: target ${e.targetAbsoluteIndex}');

          final goalId = state.goal?.id ?? 'default';
          final progressRes = await _repository.getProgress(goalId: goalId);
          final currentProgress = progressRes.fold(
            (_) => WerdProgress(
              goalId: goalId,
              totalAmountReadToday: 0,
              segmentsToday: const [],
              lastUpdated: DateTime.now(),
              streak: 0,
            ),
            (p) => p,
          );

          final segments =
              List<ReadingSegment>.from(currentProgress.segmentsToday);

          // 1. End any active session
          int activeIndex = -1;
          for (int i = segments.length - 1; i >= 0; i--) {
            if (segments[i].endTime == null) {
              activeIndex = i;
              break;
            }
          }

          if (activeIndex >= 0) {
            final activeSeg = segments[activeIndex];
            // If it's a "ghost" session (just a start point without progress), remove it
            if (activeSeg.startAyah == activeSeg.endAyah) {
              segments.removeAt(activeIndex);
              debugPrint('🗑️ Removed empty active session at ${activeSeg.startAyah}');
            } else {
              segments[activeIndex] = activeSeg.endSession();
              debugPrint(
                  '✅ Ended previous session: ${activeSeg.startAyah}-${activeSeg.endAyah}');
            }
          }

          // 2. Update tracking points to the target to avoid repeat jumps
          // We DON'T add a segment here, similar to how "Continue" button works.
          // The first ayah will be tracked when the user marks the NEXT ayah.
          final newProgress = currentProgress.copyWith(
            segmentsToday: segments,
            lastReadAbsolute: e.targetAbsoluteIndex,
            sessionStartAbsolute: e.targetAbsoluteIndex,
            lastUpdated: DateTime.now(),
          );

          await _repository.updateProgress(newProgress);
          debugPrint(
              '📖 Jumped to new session at ${e.targetAbsoluteIndex}. lastReadAbsolute updated.');

          // Emit updated state
          await _emitUpdatedState(goalId);
        },
        completeCycle: (e) async {
          // Increment completedCycles, keep position at 6236
          await _handleCycleCompletion(restartToAyah1: false);
        },
        completeCycleAndRestart: (e) async {
          // Increment completedCycles, set position to ayah 1
          await _handleCycleCompletion(restartToAyah1: true);
        },
        completeCycleStayHere: (e) async {
          // Increment completedCycles, stay at 6236
          await _handleCycleCompletion(restartToAyah1: false);
        },
        undoLastAction: (e) async {
          // Undo the last segment addition
          await _handleUndoLastAction();
        },
        toggleAyahMark: (e) async {
          // Toggle ayah mark: if already in a segment, remove it; otherwise mark it
          await _handleToggleAyahMark(e.absoluteIndex);
        },
        removeSegment: (e) async {
          // Remove specific segment by index (from edit dialog)
          await _handleRemoveSegment(e.segmentIndex);
        },
      );
    });
  }

  Future<void> _handleBookmarkUpdate(int bookmarkAbs) async {
    final goalId = state.goal?.id ?? 'default';
    final progressRes = await _repository.getProgress(goalId: goalId);
    final currentProgress = progressRes.fold(
      (_) => WerdProgress(
        goalId: goalId,
        totalAmountReadToday: 0,
        segmentsToday: const [],
        lastUpdated: DateTime.now(),
        streak: 0,
      ),
      (p) => p,
    );

    final segments = List<ReadingSegment>.from(currentProgress.segmentsToday);
    
    // Find the LAST active session (no endTime) to extend it
    int activeSessionIndex = -1;
    for (int i = segments.length - 1; i >= 0; i--) {
      if (segments[i].endTime == null) {
        activeSessionIndex = i;
        break;
      }
    }

    if (activeSessionIndex >= 0) {
      // Extend the active session to this ayah
      final activeSeg = segments[activeSessionIndex];
      segments[activeSessionIndex] = ReadingSegment(
        startAyah: activeSeg.startAyah,
        endAyah: bookmarkAbs,
        startTime: activeSeg.startTime,
        endTime: null,
      );
      debugPrint('📖 Extended session ${activeSessionIndex + 1}: ${activeSeg.startAyah} → $bookmarkAbs');
    } else {
      // No active session - create first one
      segments.add(ReadingSegment(
        startAyah: bookmarkAbs,
        endAyah: bookmarkAbs,
        startTime: DateTime.now(),
      ));
      debugPrint('📖 Created first session: ayah $bookmarkAbs');
    }

    // Calculate total from all segments
    final newTotal = segments.fold(0, (sum, seg) => sum + seg.ayahsCount);
    
    // FIX #1: Populate readItemsToday from segments for fractional calculations
    final readItems = _segmentsToReadItems(segments);

    final newProgress = currentProgress.copyWith(
      totalAmountReadToday: newTotal,
      segmentsToday: segments,
      readItemsToday: readItems,  // ✅ FIX: Populate from segments
      lastReadAbsolute: bookmarkAbs,
      lastUpdated: DateTime.now(),
    );

    await _repository.updateProgress(newProgress);
    
    // Emit updated state
    await _emitUpdatedState(goalId);
  }

  Future<void> _handleRangeTracking(int startAbs, int endAbs) async {
    // Jump dialog "Mark All": Create session for full range
    final goalId = state.goal?.id ?? 'default';
    final progressRes = await _repository.getProgress(goalId: goalId);
    final currentProgress = progressRes.fold(
      (_) => WerdProgress(
        goalId: goalId,
        totalAmountReadToday: 0,
        segmentsToday: const [],
        lastUpdated: DateTime.now(),
        streak: 0,
      ),
      (p) => p,
    );

    // End any active sessions first
    final endedSegments = currentProgress.segmentsToday.map((seg) {
      if (seg.endTime == null) {
        return seg.endSession();
      }
      return seg;
    }).toList();

    // Normalize the range
    final normalizedStart = startAbs < endAbs ? startAbs : endAbs;
    final normalizedEnd = startAbs < endAbs ? endAbs : startAbs;
    final rangeCount = normalizedEnd - normalizedStart + 1;

    // Create new session for the full range
    final newSegment = ReadingSegment(
      startAyah: normalizedStart,
      endAyah: normalizedEnd,
      startTime: DateTime.now(),
    );

    final finalSegments = [...endedSegments, newSegment];

    final newTotal = currentProgress.totalAmountReadToday + rangeCount;
    
    // FIX #1: Populate readItemsToday from segments for fractional calculations
    final readItems = _segmentsToReadItems(finalSegments);

    final newProgress = currentProgress.copyWith(
      totalAmountReadToday: newTotal,
      segmentsToday: finalSegments,
      readItemsToday: readItems,  // ✅ FIX: Populate from segments
      lastReadAbsolute: normalizedEnd,
      lastUpdated: DateTime.now(),
    );

    await _repository.updateProgress(newProgress);
    debugPrint('📖 Created range session: $normalizedStart → $normalizedEnd ($rangeCount ayahs)');
    
    // Emit updated state
    await _emitUpdatedState(goalId);
  }

  Future<void> _handleCycleCompletion({required bool restartToAyah1}) async {
    final goalId = state.goal?.id ?? 'default';
    final progressRes = await _repository.getProgress(goalId: goalId);
    final currentProgress = progressRes.fold(
      (_) => WerdProgress(
        goalId: goalId,
        totalAmountReadToday: 0,
        lastUpdated: DateTime.now(),
        streak: 0,
        completedCycles: 0,
      ),
      (p) => p,
    );

    // FIX #3: Save current sessions to history BEFORE clearing
    // This prevents data loss when completing a cycle
    var progressToSave = currentProgress;
    
    if (currentProgress.totalAmountReadToday > 0 || currentProgress.segmentsToday.isNotEmpty) {
      final dateKey = DateTime.now().toIso8601String().split('T')[0];
      
      // Calculate history entry from segments
      final startAbs = currentProgress.sessionStartAbsolute ?? 
                       (currentProgress.segmentsToday.isNotEmpty ? currentProgress.segmentsToday.first.startAyah : 1);
      final endAbs = currentProgress.lastReadAbsolute ?? 
                     (currentProgress.segmentsToday.isNotEmpty ? currentProgress.segmentsToday.last.endAyah : startAbs);
      
      final pagesRead = QuranHizbProvider.calculateFractionalProgressFromSegments(
        currentProgress.segmentsToday,
        WerdUnit.page,
      );
      final juzRead = QuranHizbProvider.calculateFractionalProgressFromSegments(
        currentProgress.segmentsToday,
        WerdUnit.juz,
      );
      
      final startPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(startAbs);
      final endPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(endAbs);
      final startSurahName = quran.getSurahName(startPos[0]);
      final endSurahName = quran.getSurahName(endPos[0]);
      
      final summary = "Read ${currentProgress.totalAmountReadToday} ayahs (${pagesRead.toStringAsFixed(1)} pages) from $startSurahName ${startPos[1]} to $endSurahName ${endPos[1]}";
      
      final historyEntry = WerdHistoryEntry(
        totalAyahsRead: currentProgress.totalAmountReadToday,
        startAbsolute: startAbs,
        endAbsolute: endAbs,
        pagesRead: pagesRead,
        juzRead: juzRead,
        segmentCount: currentProgress.segmentsToday.length,
        startSurahName: startSurahName,
        startAyahNumber: startPos[1],
        endSurahName: endSurahName,
        endAyahNumber: endPos[1],
        summary: summary,
        sessions: currentProgress.segmentsToday.isNotEmpty ? currentProgress.segmentsToday : null,
      );
      
      // Add to history
      final newHistory = Map<String, WerdHistoryEntry>.from(currentProgress.history);
      newHistory[dateKey] = historyEntry;
      
      debugPrint('💾 [Cycle Completion] Saved session to history: $dateKey - ${currentProgress.totalAmountReadToday} ayahs');
      
      progressToSave = currentProgress.copyWith(
        history: newHistory,
      );
    }

    // NOW complete the cycle
    final newProgress = progressToSave.copyWith(
      completedCycles: progressToSave.completedCycles + 1,
      totalAmountReadToday: 0,
      segmentsToday: [],
      readItemsToday: {},
      lastReadAbsolute: restartToAyah1 ? 1 : 6236,
      lastUpdated: DateTime.now(),
    );

    await _repository.updateProgress(newProgress);
    debugPrint('✅ [Cycle Completion] Cycle completed: ${newProgress.completedCycles} total cycles');

    // Emit updated state
    await _emitUpdatedState(goalId);
  }

  Future<void> _handleUndoLastAction() async {
    final goalId = state.goal?.id ?? 'default';
    final progressRes = await _repository.getProgress(goalId: goalId);
    final currentProgress = progressRes.fold(
      (_) => WerdProgress(
        goalId: goalId,
        totalAmountReadToday: 0,
        lastUpdated: DateTime.now(),
        streak: 0,
      ),
      (p) => p,
    );

    // Remove the last segment from segmentsToday
    if (currentProgress.segmentsToday.isNotEmpty) {
      final previousSegments = currentProgress.segmentsToday.sublist(
        0,
        currentProgress.segmentsToday.length - 1,
      );

      // Recalculate totalAmountReadToday from remaining segments
      final newTotal = previousSegments.fold(
        0,
        (sum, seg) => sum + seg.ayahsCount,
      );

      // Restore lastReadAbsolute to the end of the previous segment
      final newLastRead = previousSegments.isNotEmpty
          ? previousSegments.last.endAyah
          : currentProgress.sessionStartAbsolute;

      final newProgress = currentProgress.copyWith(
        segmentsToday: previousSegments,
        totalAmountReadToday: newTotal,
        lastReadAbsolute: newLastRead,
        lastUpdated: DateTime.now(),
      );

      await _repository.updateProgress(newProgress);
      
      // Emit updated state
      await _emitUpdatedState(goalId);
    }
  }

  Future<void> _handleToggleAyahMark(int ayahAbs) async {
    final goalId = state.goal?.id ?? 'default';
    final progressRes = await _repository.getProgress(goalId: goalId);
    final currentProgress = progressRes.fold(
      (_) => WerdProgress(
        goalId: goalId,
        totalAmountReadToday: 0,
        segmentsToday: const [],
        lastUpdated: DateTime.now(),
        streak: 0,
      ),
      (p) => p,
    );

    final segments = List<ReadingSegment>.from(currentProgress.segmentsToday);
    int segmentIndex = -1;
    
    // Check if ayah is already in a segment
    for (int i = 0; i < segments.length; i++) {
      if (ayahAbs >= segments[i].startAyah && ayahAbs <= segments[i].endAyah) {
        segmentIndex = i;
        break;
      }
    }
    
    if (segmentIndex >= 0) {
      // Ayah is already marked - REMOVE it (unmark)
      final segment = segments[segmentIndex];
      
      if (segment.startAyah == segment.endAyah) {
        // Single ayah segment - remove entirely
        segments.removeAt(segmentIndex);
      } else if (ayahAbs == segment.startAyah) {
        // Remove from start - shrink segment
        segments[segmentIndex] = ReadingSegment(
          startAyah: segment.startAyah + 1,
          endAyah: segment.endAyah,
        );
      } else if (ayahAbs == segment.endAyah) {
        // Remove from end - shrink segment
        segments[segmentIndex] = ReadingSegment(
          startAyah: segment.startAyah,
          endAyah: segment.endAyah - 1,
        );
      } else {
        // Remove from middle - split into two segments
        final firstHalf = ReadingSegment(
          startAyah: segment.startAyah,
          endAyah: ayahAbs - 1,
        );
        final secondHalf = ReadingSegment(
          startAyah: ayahAbs + 1,
          endAyah: segment.endAyah,
        );
        segments[segmentIndex] = firstHalf;
        segments.insert(segmentIndex + 1, secondHalf);
      }
    } else {
      // Ayah is not marked - MARK it
      segments.add(ReadingSegment(startAyah: ayahAbs, endAyah: ayahAbs));
    }
    
    // Merge segments
    final mergedSegments = ReadingSegment.mergeSegments(segments);
    final newTotal = mergedSegments.fold(0, (sum, seg) => sum + seg.ayahsCount);
    
    // FIX #1: Populate readItemsToday from segments for fractional calculations
    final readItems = _segmentsToReadItems(mergedSegments);

    // Update lastReadAbsolute to last marked ayah
    final newLastRead = mergedSegments.isNotEmpty ? mergedSegments.last.endAyah : null;

    final newProgress = currentProgress.copyWith(
      segmentsToday: mergedSegments,
      totalAmountReadToday: newTotal,
      readItemsToday: readItems,  // ✅ FIX: Populate from segments
      lastReadAbsolute: newLastRead,
      lastUpdated: DateTime.now(),
    );

    await _repository.updateProgress(newProgress);
    
    // Emit updated state
    await _emitUpdatedState(goalId);
  }

  Future<void> _handleRemoveSegment(int index) async {
    final goalId = state.goal?.id ?? 'default';
    final progressRes = await _repository.getProgress(goalId: goalId);
    final currentProgress = progressRes.fold(
      (_) => WerdProgress(
        goalId: goalId,
        totalAmountReadToday: 0,
        segmentsToday: const [],
        lastUpdated: DateTime.now(),
        streak: 0,
      ),
      (p) => p,
    );

    if (index >= 0 && index < currentProgress.segmentsToday.length) {
      final segments = List<ReadingSegment>.from(currentProgress.segmentsToday);
      segments.removeAt(index);

      // Recalculate total
      final newTotal = segments.fold(0, (sum, seg) => sum + seg.ayahsCount);
      
      // FIX #1: Populate readItemsToday from segments for fractional calculations
      final readItems = _segmentsToReadItems(segments);

      // Update lastReadAbsolute
      final newLastRead = segments.isNotEmpty ? segments.last.endAyah : currentProgress.sessionStartAbsolute;

      final newProgress = currentProgress.copyWith(
        segmentsToday: segments,
        totalAmountReadToday: newTotal,
        readItemsToday: readItems,  // ✅ FIX: Populate from segments
        lastReadAbsolute: newLastRead,
        lastUpdated: DateTime.now(),
      );

      await _repository.updateProgress(newProgress);
      
      // Emit updated state
      await _emitUpdatedState(goalId);
    }
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }

  /// Helper: Convert segments to a Set of individual ayah numbers
  /// This bridges the gap between modern session tracking and legacy fractional calculations
  Set<int> _segmentsToReadItems(List<ReadingSegment> segments) {
    final items = <int>{};
    for (final seg in segments) {
      for (int i = seg.startAyah; i <= seg.endAyah; i++) {
        items.add(i);
      }
    }
    return items;
  }

  /// Helper: Emit updated state after repository update
  Future<void> _emitUpdatedState(String goalId) async {
    final progressRes = await _repository.getProgress(goalId: goalId);
    final progress = progressRes.fold(
      (_) => state.progress,
      (p) => p,
    );
    if (progress != null) {
      // ignore: invalid_use_of_visible_for_testing_member
      emit(state.copyWith(progress: progress));
      debugPrint(
        '📡 [WerdBloc] State emitted - Segments: ${progress.segmentsToday.length}, Total: ${progress.totalAmountReadToday}',
      );

      // Smart cancellation: if goal is completed today, cancel the reminder
      final goal = state.goal;
      if (goal != null) {
        if (progress.totalAmountReadToday >= goal.valueInAyahs) {
          _notificationService.cancelWerdReminder(forTodayOnly: true);
        }
      }
    }
  }
}
