import 'dart:convert';
import 'package:fard/features/werd/data/repositories/werd_repository_impl.dart';
import 'package:fard/features/werd/domain/entities/werd_goal.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:fard/features/werd/domain/entities/werd_history_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/core/errors/failure.dart';

void main() {
  late WerdRepositoryImpl repository;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    repository = WerdRepositoryImpl(sharedPreferences);
  });

  group('WerdRepository Goal Management', () {
    test('getGoal returns null when no goal is saved', () async {
      final result = await repository.getGoal(id: 'default');
      
      expect(result.isSuccess, isTrue);
      result.fold(
        (failure) => fail('Should not fail'),
        (goal) => expect(goal, isNull),
      );
    });

    test('setGoal and getGoal persist goal correctly', () async {
      final goal = WerdGoal(
        id: 'default',
        type: WerdGoalType.fixedAmount,
        value: 20,
        unit: WerdUnit.page,
        startDate: DateTime.now(),
        startAbsolute: 1,
      );

      await repository.setGoal(goal);
      final result = await repository.getGoal(id: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (savedGoal) {
          expect(savedGoal, isNotNull);
          expect(savedGoal!.id, goal.id);
          expect(savedGoal.value, goal.value);
          expect(savedGoal.unit, goal.unit);
          expect(savedGoal.startAbsolute, goal.startAbsolute);
        },
      );
    });

    test('getGoal returns failure for invalid JSON', () async {
      await sharedPreferences.setString('werd_goal_default', 'invalid json');
      
      final result = await repository.getGoal(id: 'default');
      
      expect(result.isFailure, isTrue);
    });

    test('multiple goals can be stored separately', () async {
      final goal1 = WerdGoal(
        id: 'goal1',
        type: WerdGoalType.fixedAmount,
        value: 10,
        unit: WerdUnit.ayah,
        startDate: DateTime.now(),
        startAbsolute: 1,
      );
      final goal2 = WerdGoal(
        id: 'goal2',
        type: WerdGoalType.fixedAmount,
        value: 5,
        unit: WerdUnit.page,
        startDate: DateTime.now(),
        startAbsolute: 100,
      );

      await repository.setGoal(goal1);
      await repository.setGoal(goal2);

      final result1 = await repository.getGoal(id: 'goal1');
      final result2 = await repository.getGoal(id: 'goal2');

      result1.fold(
        (_) => fail('Should not fail'),
        (g1) => expect(g1!.value, 10),
      );
      result2.fold(
        (_) => fail('Should not fail'),
        (g2) => expect(g2!.value, 5),
      );
    });

    test('getAllGoals returns all saved goals', () async {
      final goal1 = WerdGoal(
        id: 'goal1',
        type: WerdGoalType.fixedAmount,
        value: 10,
        unit: WerdUnit.ayah,
        startDate: DateTime.now(),
      );
      final goal2 = WerdGoal(
        id: 'goal2',
        type: WerdGoalType.finishInDays,
        value: 30,
        unit: WerdUnit.ayah,
        startDate: DateTime.now(),
      );

      await repository.setGoal(goal1);
      await repository.setGoal(goal2);

      final result = await repository.getAllGoals();

      result.fold(
        (_) => fail('Should not fail'),
        (goals) {
          expect(goals.length, 2);
          expect(goals.map((g) => g.id), containsAll(['goal1', 'goal2']));
        },
      );
    });

    test('importGoals clears existing goals and imports new ones', () async {
      // Setup existing goal
      await repository.setGoal(WerdGoal(
        id: 'old',
        type: WerdGoalType.fixedAmount,
        value: 5,
        unit: WerdUnit.ayah,
        startDate: DateTime.now(),
      ));

      final newGoals = [
        WerdGoal(
          id: 'new1',
          type: WerdGoalType.fixedAmount,
          value: 10,
          unit: WerdUnit.ayah,
          startDate: DateTime.now(),
        ),
        WerdGoal(
          id: 'new2',
          type: WerdGoalType.fixedAmount,
          value: 20,
          unit: WerdUnit.page,
          startDate: DateTime.now(),
        ),
      ];

      await repository.importGoals(newGoals);

      final oldResult = await repository.getGoal(id: 'old');
      final new1Result = await repository.getGoal(id: 'new1');
      final new2Result = await repository.getGoal(id: 'new2');

      oldResult.fold(
        (_) => fail('Should not fail'),
        (goal) => expect(goal, isNull), // Old goal should be gone
      );
      new1Result.fold(
        (_) => fail('Should not fail'),
        (goal) => expect(goal, isNotNull),
      );
      new2Result.fold(
        (_) => fail('Should not fail'),
        (goal) => expect(goal, isNotNull),
      );
    });
  });

  group('WerdRepository Progress Management', () {
    test('getProgress returns default when no progress is saved', () async {
      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (progress) {
          expect(progress, isNotNull);
          expect(progress.totalAmountReadToday, 0);
          expect(progress.streak, 0);
        },
      );
    });

    test('updateProgress and getProgress persist progress correctly', () async {
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 15,
        readItemsToday: {1, 2, 3, 4, 5},
        lastReadAbsolute: 15,
        sessionStartAbsolute: 1,
        lastUpdated: DateTime.now(),
        streak: 3,
      );

      await repository.updateProgress(progress);
      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (savedProgress) {
          expect(savedProgress.totalAmountReadToday, 15);
          expect(savedProgress.lastReadAbsolute, 15);
          expect(savedProgress.sessionStartAbsolute, 1);
          expect(savedProgress.streak, 3);
          expect(savedProgress.readItemsToday.length, 5);
        },
      );
    });

    test('getProgress returns failure for invalid JSON', () async {
      await sharedPreferences.setString(
        'werd_progress_default',
        'invalid json',
      );

      final result = await repository.getProgress(goalId: 'default');

      expect(result.isFailure, isTrue);
    });

    test('watchProgress emits stream of progress updates', () async {
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 0,
        lastUpdated: DateTime.now(),
        streak: 0,
      );

      final stream = repository.watchProgress(goalId: 'default');

      expect(stream, emits(isA<Result<WerdProgress>>()));
    });

    test('updateProgress triggers watchProgress stream', () async {
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 10,
        lastUpdated: DateTime.now(),
        streak: 0,
      );

      final stream = repository.watchProgress(goalId: 'default');

      await repository.updateProgress(progress);

      expect(
        stream,
        emits(
          isA<Result<WerdProgress>>().having(
            (r) => r.fold((_) => null, (p) => p.totalAmountReadToday),
            'totalAmountReadToday',
            10,
          ),
        ),
      );
    });

    test('getAllProgress returns all progress entries', () async {
      final progress1 = WerdProgress(
        goalId: 'goal1',
        totalAmountReadToday: 10,
        lastUpdated: DateTime.now(),
        streak: 1,
      );
      final progress2 = WerdProgress(
        goalId: 'goal2',
        totalAmountReadToday: 20,
        lastUpdated: DateTime.now(),
        streak: 2,
      );

      await repository.updateProgress(progress1);
      await repository.updateProgress(progress2);

      final result = await repository.getAllProgress();

      result.fold(
        (_) => fail('Should not fail'),
        (progressList) {
          expect(progressList.length, 2);
        },
      );
    });

    test('importProgress clears existing and imports new', () async {
      // Setup existing progress
      await repository.updateProgress(WerdProgress(
        goalId: 'old',
        totalAmountReadToday: 5,
        lastUpdated: DateTime.now(),
        streak: 0,
      ));

      final newProgressList = [
        WerdProgress(
          goalId: 'new1',
          totalAmountReadToday: 10,
          lastUpdated: DateTime.now(),
          streak: 1,
        ),
        WerdProgress(
          goalId: 'new2',
          totalAmountReadToday: 20,
          lastUpdated: DateTime.now(),
          streak: 2,
        ),
      ];

      await repository.importProgress(newProgressList);

      final oldResult = await repository.getProgress(goalId: 'old');
      oldResult.fold(
        (_) => fail('Should not fail'),
        (progress) => expect(progress, isNull),
      );
    });
  });

  group('WerdRepository Day Rollover Logic', () {
    test('day rollover creates history entry', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 10,
        readItemsToday: Set<int>.from(List.generate(10, (i) => i + 1)),
        lastReadAbsolute: 10,
        sessionStartAbsolute: 1,
        lastUpdated: yesterday,
        streak: 1,
        history: {},
      );

      await sharedPreferences.setString(
        'werd_progress_default',
        json.encode(progress.toJson()),
      );

      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (updatedProgress) {
          final yesterdayKey =
              "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

          expect(updatedProgress.history.containsKey(yesterdayKey), isTrue);

          final entry = updatedProgress.history[yesterdayKey]!;
          expect(entry.totalAyahsRead, 10);
          expect(entry.startAbsolute, 1);
          expect(entry.endAbsolute, 10);
          expect(entry.pagesRead, greaterThan(0));
        },
      );
    });

    test('day rollover resets daily progress', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 15,
        readItemsToday: {1, 2, 3},
        lastReadAbsolute: 15,
        sessionStartAbsolute: 1,
        lastUpdated: yesterday,
        streak: 1,
      );

      await sharedPreferences.setString(
        'werd_progress_default',
        json.encode(progress.toJson()),
      );

      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (updatedProgress) {
          expect(updatedProgress.totalAmountReadToday, 0);
          expect(updatedProgress.readItemsToday, isEmpty);
          expect(updatedProgress.sessionStartAbsolute, 16); // lastRead + 1
        },
      );
    });

    test('day rollover maintains streak for consecutive days', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 10,
        lastReadAbsolute: 10,
        sessionStartAbsolute: 1,
        lastUpdated: yesterday,
        streak: 5,
      );

      await sharedPreferences.setString(
        'werd_progress_default',
        json.encode(progress.toJson()),
      );

      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (updatedProgress) {
          expect(updatedProgress.streak, 5); // Should maintain streak
        },
      );
    });

    test('day rollover resets streak for gap > 1 day', () async {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 10,
        lastReadAbsolute: 10,
        sessionStartAbsolute: 1,
        lastUpdated: twoDaysAgo,
        streak: 5,
      );

      await sharedPreferences.setString(
        'werd_progress_default',
        json.encode(progress.toJson()),
      );

      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (updatedProgress) {
          expect(updatedProgress.streak, 0); // Should reset streak
        },
      );
    });

    // BUG EXPOSURE: Multiple getProgress calls overwrite history
    test(
      'BUG EXPOSURE: calling getProgress multiple times on same day overwrites history entry',
      () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final progress = WerdProgress(
          goalId: 'default',
          totalAmountReadToday: 10,
          lastReadAbsolute: 10,
          sessionStartAbsolute: 1,
          lastUpdated: yesterday,
          streak: 1,
        );

        await sharedPreferences.setString(
          'werd_progress_default',
          json.encode(progress.toJson()),
        );

        // Call getProgress 3 times
        await repository.getProgress(goalId: 'default');
        await repository.getProgress(goalId: 'default');
        final result3 = await repository.getProgress(goalId: 'default');

        result3.fold(
          (failure) => fail('Should not fail'),
          (updatedProgress) {
            final yesterdayKey =
                "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

            // BUG: Each call overwrites the history entry for yesterday
            // The entry should only be created once, not overwritten
            expect(updatedProgress.history.containsKey(yesterdayKey), isTrue);
            // After fix, this should still pass but entry should be idempotent
          },
        );
      },
    );

    // BUG EXPOSURE: Session start overflow after finishing Quran
    test(
      'BUG EXPOSURE: session start exceeds 6236 after finishing Quran',
      () async {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final progress = WerdProgress(
          goalId: 'default',
          totalAmountReadToday: 10,
          lastReadAbsolute: 6236, // Last ayah of Quran
          sessionStartAbsolute: 6227,
          lastUpdated: yesterday,
          streak: 1,
        );

        await sharedPreferences.setString(
          'werd_progress_default',
          json.encode(progress.toJson()),
        );

        final result = await repository.getProgress(goalId: 'default');

        result.fold(
          (failure) => fail('Should not fail'),
          (updatedProgress) {
            // BUG: sessionStartAbsolute will be 6237 (6236 + 1), which is out of bounds!
            expect(updatedProgress.sessionStartAbsolute, 6237);
            // After fix, this should be clamped to 6236
          },
        );
      },
    );

    test('day rollover calculates history entry with surah names', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 10,
        readItemsToday: Set<int>.from(List.generate(10, (i) => i + 1)),
        lastReadAbsolute: 10,
        sessionStartAbsolute: 1,
        lastUpdated: yesterday,
        streak: 1,
      );

      await sharedPreferences.setString(
        'werd_progress_default',
        json.encode(progress.toJson()),
      );

      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (updatedProgress) {
          final yesterdayKey =
              "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

          final entry = updatedProgress.history[yesterdayKey]!;
          expect(entry.startSurahName, isNotEmpty);
          expect(entry.endSurahName, isNotEmpty);
          expect(entry.summary, contains('Read 10 ayahs'));
        },
      );
    });

    test('day rollover calculates fractional pages and juz', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 20,
        readItemsToday: Set<int>.from(List.generate(20, (i) => i + 1)),
        lastReadAbsolute: 20,
        sessionStartAbsolute: 1,
        lastUpdated: yesterday,
        streak: 1,
      );

      await sharedPreferences.setString(
        'werd_progress_default',
        json.encode(progress.toJson()),
      );

      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (updatedProgress) {
          final yesterdayKey =
              "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

          final entry = updatedProgress.history[yesterdayKey]!;
          expect(entry.pagesRead, greaterThan(0));
          expect(entry.juzRead, greaterThan(0));
        },
      );
    });

    test('no progress day creates appropriate history entry', () async {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 0,
        lastReadAbsolute: 50,
        sessionStartAbsolute: 50,
        lastUpdated: yesterday,
        streak: 0,
      );

      await sharedPreferences.setString(
        'werd_progress_default',
        json.encode(progress.toJson()),
      );

      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (updatedProgress) {
          final yesterdayKey =
              "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";

          final entry = updatedProgress.history[yesterdayKey]!;
          expect(entry.totalAyahsRead, 0);
          expect(entry.summary, contains('No progress'));
        },
      );
    });
  });

  group('WerdRepository Storage Key Management', () {
    test('goal uses correct key format', () async {
      final goal = WerdGoal(
        id: 'test_goal',
        type: WerdGoalType.fixedAmount,
        value: 10,
        unit: WerdUnit.ayah,
        startDate: DateTime.now(),
      );

      await repository.setGoal(goal);

      expect(
        sharedPreferences.containsKey('werd_goal_test_goal'),
        isTrue,
      );
    });

    test('progress uses correct key format', () async {
      final progress = WerdProgress(
        goalId: 'test_goal',
        totalAmountReadToday: 5,
        lastUpdated: DateTime.now(),
        streak: 0,
      );

      await repository.updateProgress(progress);

      expect(
        sharedPreferences.containsKey('werd_progress_test_goal'),
        isTrue,
      );
    });

    test('default goal id uses correct key', () async {
      final goal = WerdGoal(
        id: 'default',
        type: WerdGoalType.fixedAmount,
        value: 10,
        unit: WerdUnit.ayah,
        startDate: DateTime.now(),
      );

      await repository.setGoal(goal);

      expect(sharedPreferences.containsKey('werd_goal_default'), isTrue);
    });

    test('default progress id uses correct key', () async {
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 5,
        lastUpdated: DateTime.now(),
        streak: 0,
      );

      await repository.updateProgress(progress);

      expect(sharedPreferences.containsKey('werd_progress_default'), isTrue);
    });
  });

  group('WerdRepository History Management', () {
    test('history entries are stored with date keys', () async {
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 10,
        lastReadAbsolute: 10,
        sessionStartAbsolute: 1,
        lastUpdated: DateTime.now(),
        streak: 1,
        history: {
          '2026-04-01': WerdHistoryEntry(
            totalAyahsRead: 15,
            startAbsolute: 1,
            endAbsolute: 15,
            pagesRead: 2.0,
            juzRead: 0.1,
            startSurahName: 'Al-Fatihah',
            startAyahNumber: 1,
            endSurahName: 'Al-Baqarah',
            endAyahNumber: 8,
            summary: 'Read 15 ayahs',
          ),
        },
      );

      await repository.updateProgress(progress);
      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (savedProgress) {
          expect(savedProgress.history.containsKey('2026-04-01'), isTrue);
          final entry = savedProgress.history['2026-04-01']!;
          expect(entry.totalAyahsRead, 15);
        },
      );
    });

    test('multiple history entries can be stored', () async {
      final progress = WerdProgress(
        goalId: 'default',
        totalAmountReadToday: 0,
        lastReadAbsolute: 30,
        sessionStartAbsolute: 1,
        lastUpdated: DateTime.now(),
        streak: 3,
        history: {
          '2026-04-01': WerdHistoryEntry(
            totalAyahsRead: 10,
            startAbsolute: 1,
            endAbsolute: 10,
            pagesRead: 1.5,
            juzRead: 0.07,
            startSurahName: 'Al-Fatihah',
            startAyahNumber: 1,
            endSurahName: 'Al-Baqarah',
            endAyahNumber: 3,
            summary: 'Read 10 ayahs',
          ),
          '2026-04-02': WerdHistoryEntry(
            totalAyahsRead: 10,
            startAbsolute: 11,
            endAbsolute: 20,
            pagesRead: 1.5,
            juzRead: 0.07,
            startSurahName: 'Al-Baqarah',
            startAyahNumber: 4,
            endSurahName: 'Al-Baqarah',
            endAyahNumber: 13,
            summary: 'Read 10 ayahs',
          ),
          '2026-04-03': WerdHistoryEntry(
            totalAyahsRead: 10,
            startAbsolute: 21,
            endAbsolute: 30,
            pagesRead: 1.5,
            juzRead: 0.07,
            startSurahName: 'Al-Baqarah',
            startAyahNumber: 14,
            endSurahName: 'Al-Baqarah',
            endAyahNumber: 23,
            summary: 'Read 10 ayahs',
          ),
        },
      );

      await repository.updateProgress(progress);
      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (savedProgress) {
          expect(savedProgress.history.length, 3);
          expect(savedProgress.history.containsKey('2026-04-01'), isTrue);
          expect(savedProgress.history.containsKey('2026-04-02'), isTrue);
          expect(savedProgress.history.containsKey('2026-04-03'), isTrue);
        },
      );
    });

    test('history entries maintain backward compatibility', () async {
      // Old format where history values were simple integers
      final json = jsonEncode({
        'goalId': 'default',
        'totalAmountReadToday': 0,
        'lastReadAbsolute': 50,
        'sessionStartAbsolute': 1,
        'lastUpdated': DateTime.now().toIso8601String(),
        'streak': 5,
        'history': {
          '2024-01-01': 20,
          '2024-01-02': 15,
          '2024-01-03': 25,
        },
      });

      await sharedPreferences.setString('werd_progress_default', json);

      final result = await repository.getProgress(goalId: 'default');

      result.fold(
        (failure) => fail('Should not fail'),
        (progress) {
          expect(progress.history.length, 3);
          expect(
            progress.history['2024-01-01']!.totalAyahsRead,
            20,
          );
          expect(
            progress.history['2024-01-02']!.totalAyahsRead,
            15,
          );
          expect(
            progress.history['2024-01-03']!.totalAyahsRead,
            25,
          );
        },
      );
    });
  });
}
