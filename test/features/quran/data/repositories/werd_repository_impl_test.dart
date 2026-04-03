import 'dart:convert';
import 'package:fard/features/werd/data/repositories/werd_repository_impl.dart';
import 'package:fard/features/werd/domain/entities/werd_progress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late WerdRepositoryImpl repository;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    repository = WerdRepositoryImpl(sharedPreferences);
  });

  group('WerdRepositoryImpl', () {
    test('should reset sessionStartAbsolute on new day in getProgress', () async {
      // 1. Arrange: Save progress from yesterday
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

      // 2. Act: Get progress today
      final result = await repository.getProgress();

      // 3. Assert
      final fetchedProgress = result.fold((_) => null, (p) => p)!;
      expect(fetchedProgress.totalAmountReadToday, 0);
      // In my new implementation it sets sessionStartAbsolute to (lastReadAbsolute ?? 0) + 1
      expect(fetchedProgress.sessionStartAbsolute, 11);
      expect(fetchedProgress.lastReadAbsolute, 10); // Should keep last read
    });
  });
}
