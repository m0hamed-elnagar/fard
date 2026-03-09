import 'dart:async';
import 'dart:convert';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: WerdRepository)
class WerdRepositoryImpl implements WerdRepository {
  final SharedPreferences sharedPreferences;
  final _progressControllers = <String, StreamController<Result<WerdProgress>>>{};

  WerdRepositoryImpl(this.sharedPreferences);

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
      await sharedPreferences.setString(_getGoalKey(goal.id), json.encode(goal.toJson()));
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
        return Result.success(WerdProgress(
          goalId: goalId,
          totalAmountReadToday: 0,
          lastUpdated: DateTime.now(),
          streak: 0,
        ));
      }
      
      var progress = WerdProgress.fromJson(json.decode(jsonStr));
      
      // Check if it's a new day
      final now = DateTime.now();
      final lastUpdated = progress.lastUpdated;
      
      if (now.year != lastUpdated.year || 
          now.month != lastUpdated.month || 
          now.day != lastUpdated.day) {
        
        final dateKey = "${lastUpdated.year}-${lastUpdated.month.toString().padLeft(2, '0')}-${lastUpdated.day.toString().padLeft(2, '0')}";
        final newHistory = Map<String, int>.from(progress.history);
        newHistory[dateKey] = progress.totalAmountReadToday;

        bool wasYesterday = now.difference(DateTime(lastUpdated.year, lastUpdated.month, lastUpdated.day)).inDays == 1;
        
        progress = WerdProgress(
          goalId: goalId,
          totalAmountReadToday: 0,
          readItemsToday: const {}, // Reset for new day
          lastReadAbsolute: progress.lastReadAbsolute,
          sessionStartAbsolute: (progress.lastReadAbsolute ?? 0) + 1, // Start where we left off
          lastUpdated: now,
          streak: wasYesterday ? progress.streak : 0,
          history: newHistory,
        );
        
        // Save the updated progress (reset for new day)
        await sharedPreferences.setString(_getProgressKey(goalId), json.encode(progress.toJson()));
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
      () => StreamController<Result<WerdProgress>>.broadcast()
    );
    // Emit initial
    getProgress(goalId: goalId).then((res) => controller.add(res));
    return controller.stream;
  }

  @override
  Future<Result<void>> updateProgress(WerdProgress progress) async {
    try {
      await sharedPreferences.setString(_getProgressKey(progress.goalId), json.encode(progress.toJson()));
      _progressControllers[progress.goalId]?.add(Result.success(progress));
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }
}
