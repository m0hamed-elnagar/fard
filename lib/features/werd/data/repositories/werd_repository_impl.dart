import 'dart:async';
import 'dart:convert';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/werd_history_entry.dart';
import 'package:fard/features/werd/domain/entities/reading_segment.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:fard/core/extensions/quran_extension.dart';
import 'package:quran/quran.dart' as quran;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: WerdRepository)
class WerdRepositoryImpl implements WerdRepository {
  final SharedPreferences sharedPreferences;
  final _progressControllers =
      <String, StreamController<Result<WerdProgress>>>{};

  WerdRepositoryImpl(this.sharedPreferences);

  /// Dispose all active stream controllers to prevent memory leaks
  @override
  void dispose() {
    for (final controller in _progressControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _progressControllers.clear();
  }

  String _getGoalKey(String id) => 'werd_goal_$id';
  String _getProgressKey(String goalId) => 'werd_progress_$goalId';

  @override
  Future<Result<WerdGoal?>> getGoal({String id = 'default'}) async {
    try {
      final jsonStr = sharedPreferences.getString(_getGoalKey(id));
      if (jsonStr == null) return Result.success(null);
      return Result.success(WerdGoal.fromJson(json.decode(jsonStr)));
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> setGoal(WerdGoal goal) async {
    try {
      await sharedPreferences.setString(
        _getGoalKey(goal.id),
        json.encode(goal.toJson()),
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<WerdProgress>> getProgress({String goalId = 'default'}) async {
    try {
      final jsonStr = sharedPreferences.getString(_getProgressKey(goalId));
      if (jsonStr == null) {
        return Result.success(
          WerdProgress(
            goalId: goalId,
            totalAmountReadToday: 0,
            lastUpdated: DateTime.now(),
            streak: 0,
          ),
        );
      }

      var progress = WerdProgress.fromJson(json.decode(jsonStr));

      // Check if it's a new day
      final now = DateTime.now();
      final lastUpdated = progress.lastUpdated;

      if (now.year != lastUpdated.year ||
          now.month != lastUpdated.month ||
          now.day != lastUpdated.day) {
        final dateKey =
            "${lastUpdated.year}-${lastUpdated.month.toString().padLeft(2, '0')}-${lastUpdated.day.toString().padLeft(2, '0')}";

        // Calculate details for history entry
        final startAbs = progress.sessionStartAbsolute ?? 1;
        final endAbs =
            progress.lastReadAbsolute ?? (startAbs - 1).clamp(1, 6236);
        final startPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(
          startAbs,
        );
        final endPos = QuranHizbProvider.getSurahAndAyahFromAbsolute(endAbs);

        // FIX #2: Use segments today, or fallback to items for compatibility
        final segments = progress.segmentsToday.isNotEmpty 
            ? progress.segmentsToday 
            : ReadingSegment.fromSet(progress.readItemsToday);
            
        final pagesRead = QuranHizbProvider.calculateFractionalProgressFromSegments(
          segments,
          WerdUnit.page,
        );
        final juzRead = QuranHizbProvider.calculateFractionalProgressFromSegments(
          segments,
          WerdUnit.juz,
        );

        final startSurahName = quran.getSurahName(startPos[0]);
        final endSurahName = quran.getSurahName(endPos[0]);

        String summary;
        if (progress.totalAmountReadToday > 0) {
          summary =
              "Read ${progress.totalAmountReadToday} ayahs (${pagesRead.toStringAsFixed(1)} pages) from $startSurahName ${startPos[1]} to $endSurahName ${endPos[1]}";
        } else {
          summary =
              "No progress recorded today. Last position: $startSurahName ${startPos[1]}";
        }

        final entry = WerdHistoryEntry(
          totalAyahsRead: progress.totalAmountReadToday,
          startAbsolute: startAbs,
          endAbsolute: endAbs,
          pagesRead: pagesRead,
          juzRead: juzRead,
          segmentCount: progress.segmentsToday.length,
          startSurahName: startSurahName,
          startAyahNumber: startPos[1],
          endSurahName: endSurahName,
          endAyahNumber: endPos[1],
          summary: summary,
          sessions: progress.segmentsToday.isNotEmpty ? progress.segmentsToday : null,
        );

        final newHistory = Map<String, WerdHistoryEntry>.from(progress.history);
        newHistory[dateKey] = entry;

        bool wasYesterday =
            now
                .difference(
                  DateTime(
                    lastUpdated.year,
                    lastUpdated.month,
                    lastUpdated.day,
                  ),
                )
                .inDays ==
            1;

        progress = WerdProgress(
          goalId: goalId,
          totalAmountReadToday: 0,
          readItemsToday: const {}, // Reset for new day
          lastReadAbsolute: progress.lastReadAbsolute,
          sessionStartAbsolute:
              (progress.lastReadAbsolute ?? 0) + 1, // Start where we left off
          lastUpdated: now,
          streak: wasYesterday ? progress.streak : 0,
          history: newHistory,
        );

        // Save the updated progress (reset for new day)
        await sharedPreferences.setString(
          _getProgressKey(goalId),
          json.encode(progress.toJson()),
        );
      }

      return Result.success(progress);
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<Result<WerdProgress>> watchProgress({String goalId = 'default'}) {
    final controller = _progressControllers.putIfAbsent(
      goalId,
      () => StreamController<Result<WerdProgress>>.broadcast(),
    );
    // Emit initial
    getProgress(goalId: goalId).then((res) => controller.add(res));
    return controller.stream;
  }

  @override
  Future<Result<void>> updateProgress(WerdProgress progress) async {
    try {
      await sharedPreferences.setString(
        _getProgressKey(progress.goalId),
        json.encode(progress.toJson()),
      );
      _progressControllers[progress.goalId]?.add(Result.success(progress));
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<WerdGoal>>> getAllGoals() async {
    try {
      final keys = sharedPreferences.getKeys().where(
        (k) => k.startsWith('werd_goal_'),
      );
      final goals = <WerdGoal>[];
      for (final key in keys) {
        final jsonStr = sharedPreferences.getString(key);
        if (jsonStr != null) {
          goals.add(WerdGoal.fromJson(json.decode(jsonStr)));
        }
      }
      return Result.success(goals);
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<WerdProgress>>> getAllProgress() async {
    try {
      final keys = sharedPreferences.getKeys().where(
        (k) => k.startsWith('werd_progress_'),
      );
      final progressList = <WerdProgress>[];
      for (final key in keys) {
        final jsonStr = sharedPreferences.getString(key);
        if (jsonStr != null) {
          progressList.add(WerdProgress.fromJson(json.decode(jsonStr)));
        }
      }
      return Result.success(progressList);
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> importGoals(List<WerdGoal> goals) async {
    try {
      // Clear existing goals first
      final existingKeys = sharedPreferences.getKeys().where(
        (k) => k.startsWith('werd_goal_'),
      );
      for (final key in existingKeys) {
        await sharedPreferences.remove(key);
      }

      for (final goal in goals) {
        await sharedPreferences.setString(
          _getGoalKey(goal.id),
          json.encode(goal.toJson()),
        );
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> importProgress(List<WerdProgress> progressList) async {
    try {
      // Clear existing progress first
      final existingKeys = sharedPreferences.getKeys().where(
        (k) => k.startsWith('werd_progress_'),
      );
      for (final key in existingKeys) {
        await sharedPreferences.remove(key);
      }

      for (final p in progressList) {
        await sharedPreferences.setString(
          _getProgressKey(p.goalId),
          json.encode(p.toJson()),
        );
        _progressControllers[p.goalId]?.add(Result.success(p));
      }
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }
}
