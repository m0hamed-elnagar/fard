import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fard/main.dart' as app;
import 'package:fard/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';
import 'package:fard/features/prayer_tracking/presentation/widgets/missed_days_dialog.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Missed Days Flow Integration Test', () {
    late Directory tempDir;
    late DateTime threeDaysAgo;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('fard_missed_days_test_');

      // Inject latitude/longitude so prayer times can be calculated
      SharedPreferences.setMockInitialValues({
        'latitude': 30.0,
        'longitude': 31.0,
        'onboarding_complete': true,
        'language_code': 'en',
      });

      await configureDependencies(hivePath: tempDir.path);

      final box = await Hive.openBox<DailyRecordEntity>('daily_records');
      await box.clear();

      // Inject a record from 3 days ago to trigger the gap dialog
      threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final dateStr =
          '${threeDaysAgo.year}-${threeDaysAgo.month.toString().padLeft(2, '0')}-${threeDaysAgo.day.toString().padLeft(2, '0')}';

      final oldRecord = DailyRecordEntity(
        id: dateStr,
        dateMillis: threeDaysAgo.millisecondsSinceEpoch,
        missedIndices: [],
        completedIndices: [0, 1, 2, 3, 4], // All prayed
        qadaValues: {0: 10, 1: 10, 2: 10, 3: 10, 4: 10},
        completedQadaValues: {},
      );
      await box.put(dateStr, oldRecord);
    });

    tearDown(() async {
      await Hive.close();
      await getIt.reset();
    });

    testWidgets('Should show missed days dialog and handle "I was praying (All)"', (
      tester,
    ) async {
      debugPrint('TEST: Verifying Hive setup...');
      final boxCheck = Hive.box<DailyRecordEntity>('daily_records');
      debugPrint('TEST: Box record count: ${boxCheck.length}');
      if (boxCheck.isNotEmpty) {
        final r = boxCheck.getAt(0);
        debugPrint(
          'TEST: Record in box: ${r?.id}, dateMillis: ${r?.dateMillis}',
        );
        final diff = DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(r!.dateMillis))
            .inDays;
        debugPrint('TEST: Calculated diff: $diff');
      }

      debugPrint('TEST: Pumping widget...');
      await tester.pumpWidget(app.QadaTrackerApp(hivePath: tempDir.path));

      // Manually pump until dialog appears to avoid pumpAndSettle hanging on CircularProgressIndicator
      debugPrint('TEST: Waiting for dialog...');
      bool dialogFound = false;
      for (int i = 0; i < 100; i++) {
        // Wait up to 10 seconds
        await tester.pump(const Duration(milliseconds: 100));
        if (find.byType(MissedDaysDialog).evaluate().isNotEmpty) {
          dialogFound = true;
          break;
        }
      }
      expect(dialogFound, isTrue, reason: 'MissedDaysDialog did not appear');

      // Find "I was praying" button (ElevatedButton)
      final prayingAllBtn = find.byType(ElevatedButton);
      expect(prayingAllBtn, findsOneWidget);

      debugPrint('TEST: Tapping "I was praying"...');
      await tester.tap(prayingAllBtn);

      // Wait for dialog to close
      debugPrint('TEST: Waiting for dialog to dismiss...');
      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.byType(MissedDaysDialog).evaluate().isEmpty) {
          break;
        }
      }
      expect(find.byType(MissedDaysDialog), findsNothing);
      debugPrint('TEST: Dialog dismissed.');

      // Verify Qada count remains 10 (gaps handled as prayed)
      final box = Hive.box<DailyRecordEntity>('daily_records');

      final date19 = threeDaysAgo.add(const Duration(days: 1));
      final key19 =
          '${date19.year}-${date19.month.toString().padLeft(2, '0')}-${date19.day.toString().padLeft(2, '0')}';
      final record19 = box.get(key19);
      expect(
        record19,
        isNotNull,
        reason: 'Record for 19th should exist (created as prayed)',
      );
      expect(
        record19!.qadaValues[0],
        10,
        reason: 'Fajr Qada on 19th should be 10',
      );

      final date20 = threeDaysAgo.add(const Duration(days: 2));
      final key20 =
          '${date20.year}-${date20.month.toString().padLeft(2, '0')}-${date20.day.toString().padLeft(2, '0')}';
      final record20 = box.get(key20);
      expect(record20, isNotNull);
      expect(
        record20!.qadaValues[0],
        10,
        reason: 'Fajr Qada on 20th should be 10',
      );
    });

    testWidgets('Should toggle "Select All" and confirm manual selection', (
      tester,
    ) async {
      await tester.pumpWidget(app.QadaTrackerApp(hivePath: tempDir.path));

      // Wait for dialog
      debugPrint('TEST: Waiting for dialog...');
      bool dialogFound = false;
      for (int i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.byType(MissedDaysDialog).evaluate().isNotEmpty) {
          dialogFound = true;
          break;
        }
      }
      expect(dialogFound, isTrue, reason: 'MissedDaysDialog did not appear');

      // Test Select All / Deselect All
      // TextButton with icon is used for toggle.
      // We can find by type TextButton.
      final toggleAllBtn = find.byType(TextButton);
      expect(toggleAllBtn, findsOneWidget);

      await tester.tap(toggleAllBtn);
      await tester.pump(); // Tap requires a frame

      // We assume it toggles state. We can't easily verify text if it's dynamic/localized without knowing key.
      // But we can tap it again.
      await tester.tap(toggleAllBtn);
      await tester.pump();

      // Confirm selection (All Selected = Missed)
      // Done button is OutlinedButton
      final doneBtn = find.byType(OutlinedButton);
      expect(doneBtn, findsOneWidget);

      await tester.tap(doneBtn);

      // Wait for dialog to dismiss
      for (int i = 0; i < 50; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.byType(MissedDaysDialog).evaluate().isEmpty) {
          break;
        }
      }
      expect(find.byType(MissedDaysDialog), findsNothing);

      // Verify Qada counts increased
      final box = Hive.box<DailyRecordEntity>('daily_records');

      final date19 = threeDaysAgo.add(const Duration(days: 1));
      final key19 =
          '${date19.year}-${date19.month.toString().padLeft(2, '0')}-${date19.day.toString().padLeft(2, '0')}';
      final record19 = box.get(key19);
      expect(record19, isNotNull);
      expect(
        record19!.qadaValues[0],
        11,
        reason: 'Fajr Qada on 19th should be 11 (10+1)',
      );

      final date20 = threeDaysAgo.add(const Duration(days: 2));
      final key20 =
          '${date20.year}-${date20.month.toString().padLeft(2, '0')}-${date20.day.toString().padLeft(2, '0')}';
      final record20 = box.get(key20);
      expect(record20, isNotNull);
      expect(
        record20!.qadaValues[0],
        12,
        reason: 'Fajr Qada on 20th should be 12 (11+1)',
      );
    });
  });
}
