import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';

abstract class WerdRepository {
  Future<Result<WerdGoal?>> getGoal({String id = 'default'});
  Future<Result<void>> setGoal(WerdGoal goal);
  Future<Result<WerdProgress>> getProgress({String goalId = 'default'});
  Stream<Result<WerdProgress>> watchProgress({String goalId = 'default'});
  Future<Result<void>> updateProgress(WerdProgress progress);

  // Backup/Restore methods
  Future<Result<List<WerdGoal>>> getAllGoals();
  Future<Result<List<WerdProgress>>> getAllProgress();
  Future<Result<void>> importGoals(List<WerdGoal> goals);
  Future<Result<void>> importProgress(List<WerdProgress> progress);
}
