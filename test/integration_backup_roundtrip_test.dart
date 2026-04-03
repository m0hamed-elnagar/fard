import 'dart:convert';
import 'package:fard/core/errors/failure.dart';
import 'package:fard/core/services/app_backup_dto.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/repositories/werd_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeWerdRepository implements WerdRepository {
  List<WerdGoal> goals = [];
  List<WerdProgress> progress = [];

  @override
  Future<Result<List<WerdGoal>>> getAllGoals() async => Result.success(goals);

  @override
  Future<Result<List<WerdProgress>>> getAllProgress() async =>
      Result.success(progress);

  @override
  Future<Result<void>> importGoals(List<WerdGoal> goals) async {
    this.goals = List.from(goals);
    return Result.success(null);
  }

  @override
  Future<Result<void>> importProgress(List<WerdProgress> progress) async {
    this.progress = List.from(progress);
    return Result.success(null);
  }

  // Other methods not needed for this specific test
  @override
  Future<Result<WerdGoal?>> getGoal({String id = 'default'}) async =>
      Result.success(null);
  @override
  Future<Result<void>> setGoal(WerdGoal goal) async => Result.success(null);
  @override
  Future<Result<WerdProgress>> getProgress({String goalId = 'default'}) async =>
      throw UnimplementedError();
  @override
  Stream<Result<WerdProgress>> watchProgress({String goalId = 'default'}) =>
      throw UnimplementedError();
  @override
  Future<Result<void>> updateProgress(WerdProgress progress) async =>
      Result.success(null);
}

class FakePrayerRepo implements PrayerRepo {
  List<DailyRecord> db = [];

  @override
  Future<List<DailyRecord>> loadAllRecords() async => db;

  @override
  Future<void> importAllRecords(List<DailyRecord> records) async {
    db = List.from(records);
  }

  // Not needed
  @override
  Future<void> saveToday(DailyRecord record) async {}
  @override
  Future<void> deleteRecord(DateTime date) async {}
  @override
  Future<DailyRecord?> loadRecord(DateTime date) async => null;
  @override
  Future<Map<DateTime, DailyRecord>> loadMonth(int year, int month) async => {};
  @override
  Future<Map<Salaah, int>> calculateRemaining(
    DateTime from,
    DateTime to,
  ) async => {};
  @override
  Future<DailyRecord?> loadLastSavedRecord() async => null;
  @override
  Future<DailyRecord?> loadLastRecordBefore(DateTime date) async => null;
}

void main() {
  late FakeWerdRepository werdRepo;
  late FakePrayerRepo prayerRepo;

  setUp(() {
    werdRepo = FakeWerdRepository();
    prayerRepo = FakePrayerRepo();
  });

  test(
    'Full System Round-trip: Data should be identical after export and import',
    () async {
      // 1. Seed Initial Data
      prayerRepo.db = [
        DailyRecord(
          id: '1',
          date: DateTime(2024, 1, 1),
          missedToday: {Salaah.fajr},
          completedToday: {},
          qada: {Salaah.fajr: const MissedCounter(1)},
        ),
      ];

      werdRepo.goals = [
        WerdGoal(
          id: 'g1',
          type: WerdGoalType.fixedAmount,
          value: 5,
          startDate: DateTime(2024, 1, 1),
        ),
      ];

      werdRepo.progress = [
        WerdProgress(
          goalId: 'g1',
          totalAmountReadToday: 2,
          lastUpdated: DateTime(2024, 1, 1),
          streak: 1,
        ),
      ];

      // 2. Simulate Export Action
      final exportedBackup = AppBackup(
        version: 1,
        appVersion: '1.0.0',
        timestamp: DateTime.now(),
        prayerRecords: await prayerRepo.loadAllRecords(),
        werdGoals: (await werdRepo.getAllGoals()).fold((l) => [], (r) => r),
        werdProgress: (await werdRepo.getAllProgress()).fold(
          (l) => [],
          (r) => r,
        ),
      );

      final jsonString = jsonEncode(exportedBackup.toJson());

      // 3. Clear System (Simulate app reinstall)
      prayerRepo.db = [];
      werdRepo.goals = [];
      werdRepo.progress = [];

      // 4. Simulate Import Action
      final decodedJson = jsonDecode(jsonString);
      final importedBackup = AppBackup.fromJson(decodedJson);

      await prayerRepo.importAllRecords(importedBackup.prayerRecords);
      await werdRepo.importGoals(importedBackup.werdGoals);
      await werdRepo.importProgress(importedBackup.werdProgress);

      // 5. Final Verification
      expect(prayerRepo.db.length, 1);
      expect(prayerRepo.db.first.missedToday, {Salaah.fajr});
      expect(werdRepo.goals.length, 1);
      expect(werdRepo.goals.first.id, 'g1');
      expect(werdRepo.progress.length, 1);
      expect(werdRepo.progress.first.streak, 1);
    },
  );
}
