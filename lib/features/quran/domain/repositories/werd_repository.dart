import 'package:fard/core/errors/failure.dart';
import 'package:fard/features/quran/domain/entities/werd_goal.dart';
import 'package:fard/features/quran/domain/entities/werd_progress.dart';

abstract interface class WerdRepository {
  Future<Result<WerdGoal?>> getGoal();
  Future<Result<void>> setGoal(WerdGoal goal);
  Future<Result<WerdProgress>> getProgress();
  Stream<Result<WerdProgress>> watchProgress();
  Future<Result<void>> updateProgress(WerdProgress progress);
}
