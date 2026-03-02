import 'dart:async';
import 'dart:convert';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/werd_goal.dart';
import 'package:fard/features/quran/domain/entities/werd_progress.dart';
import 'package:fard/features/quran/domain/repositories/werd_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WerdRepositoryImpl implements WerdRepository {
  final SharedPreferences sharedPreferences;
  final _progressController = StreamController<Result<WerdProgress>>.broadcast();

  static const String _goalKey = 'werd_goal';
  static const String _progressKey = 'werd_progress';

  WerdRepositoryImpl(this.sharedPreferences);

  @override
  Future<Result<WerdGoal?>> getGoal() async {
    try {
      final jsonStr = sharedPreferences.getString(_goalKey);
      if (jsonStr == null) return Result.success(null);
      return Result.success(WerdGoal.fromJson(json.decode(jsonStr)));
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> setGoal(WerdGoal goal) async {
    try {
      await sharedPreferences.setString(_goalKey, json.encode(goal.toJson()));
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<WerdProgress>> getProgress() async {
    try {
      final jsonStr = sharedPreferences.getString(_progressKey);
      if (jsonStr == null) {
        return Result.success(WerdProgress(
          totalAyahsReadToday: 0,
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
        
        bool wasYesterday = now.difference(DateTime(lastUpdated.year, lastUpdated.month, lastUpdated.day)).inDays == 1;
        
        progress = WerdProgress(
          totalAyahsReadToday: 0,
          lastReadAyah: progress.lastReadAyah,
          lastUpdated: now,
          streak: wasYesterday ? progress.streak : 0,
        );
      }
      
      return Result.success(progress);
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<Result<WerdProgress>> watchProgress() {
    // Emit initial
    getProgress().then((res) => _progressController.add(res));
    return _progressController.stream;
  }

  @override
  Future<Result<void>> updateProgress(WerdProgress progress) async {
    try {
      await sharedPreferences.setString(_progressKey, json.encode(progress.toJson()));
      _progressController.add(Result.success(progress));
      return Result.success(null);
    } catch (e) {
      return Result.failure(CacheFailure(e.toString()));
    }
  }
}
