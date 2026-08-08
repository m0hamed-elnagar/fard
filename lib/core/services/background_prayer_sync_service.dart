import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/prayer_tracking/domain/daily_record.dart';
import 'package:fard/features/prayer_tracking/data/prayer_repo_impl.dart';
import 'package:fard/features/prayer_tracking/domain/missed_counter.dart';

class BackgroundPrayerSyncService {
  static Future<bool> drainQueue(SharedPreferences prefs) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheFile = File('${tempDir.path}/pending_prayers.json');
      final lockFile = File('${tempDir.path}/pending_prayers.lock');

      if (!cacheFile.existsSync()) {
        return false;
      }

      List<dynamic> entries = [];
      
      // Perform atomic read-and-clear under file lock
      final raf = await lockFile.open(mode: FileMode.write);
      try {
        await raf.lock();
        if (cacheFile.existsSync()) {
          final content = cacheFile.readAsStringSync();
          if (content.isNotEmpty) {
            entries = jsonDecode(content) as List<dynamic>;
          }
          // Clear the file
          cacheFile.writeAsStringSync('[]');
        }
      } finally {
        await raf.unlock();
        await raf.close();
      }

      if (entries.isEmpty) {
        return false;
      }

      print('BackgroundPrayerSyncService: Draining ${entries.length} pending prayers');
      for (final entry in entries) {
        if (entry is Map<String, dynamic>) {
          final prayerIdStr = entry['prayerId'] as String?;
          final dateStr = entry['date'] as String?;
          if (prayerIdStr != null && dateStr != null) {
            final prayer = Salaah.values.firstWhere(
              (s) => s.name.toLowerCase() == prayerIdStr.toLowerCase(),
              orElse: () => Salaah.fajr,
            );
            final date = DateTime.parse(dateStr);
            await markPrayerAsPrayed(date, prayer, prefs);
          }
        }
      }
      return true;
    } catch (e) {
      print('BackgroundPrayerSyncService: Error draining queue: $e');
      return false;
    }
  }

  static Future<void> markPrayerAsPrayed(
    DateTime date,
    Salaah prayer,
    SharedPreferences prefs,
  ) async {
    final boxName = 'daily_records';
    late Box<DailyRecordEntity> box;
    
    if (Hive.isBoxOpen(boxName)) {
      box = Hive.box<DailyRecordEntity>(boxName);
    } else {
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(DailyRecordEntityAdapter());
      }
      box = await Hive.openBox<DailyRecordEntity>(boxName);
    }
    
    final repo = PrayerRepoImpl(box);
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final record = await repo.loadRecord(normalizedDate);

    // Idempotency check: if already completed, do nothing
    if (record != null && record.completedToday.contains(prayer)) {
      print('BackgroundPrayerSyncService: ${prayer.name} already completed on $normalizedDate, skipping.');
      return;
    }

    Map<Salaah, MissedCounter> oldQadaMap = {};
    if (record != null) {
      oldQadaMap = Map.from(record.qada);
    } else {
      final lastBefore = await repo.loadLastRecordBefore(normalizedDate);
      if (lastBefore != null) {
        oldQadaMap = Map.from(lastBefore.qada);
      } else {
        for (final s in Salaah.values) {
          oldQadaMap[s] = const MissedCounter(0);
        }
      }
    }

    final completed = record != null ? Set<Salaah>.from(record.completedToday) : <Salaah>{};
    final missed = record != null ? Set<Salaah>.from(record.missedToday) : <Salaah>{};
    final qada = record != null ? Map<Salaah, MissedCounter>.from(record.qada) : Map<Salaah, MissedCounter>.from(oldQadaMap);
    final completedQada = record != null ? Map<Salaah, int>.from(record.completedQada) : <Salaah, int>{};

    if (missed.contains(prayer)) {
      missed.remove(prayer);
      completed.add(prayer);
      qada[prayer] = (qada[prayer] ?? const MissedCounter(0)).removeMissed();
    } else {
      completed.add(prayer);
    }

    final updatedRecord = DailyRecord(
      id: '${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}',
      date: normalizedDate,
      missedToday: missed,
      completedToday: completed,
      qada: qada,
      completedQada: completedQada,
    );

    await repo.saveToday(updatedRecord);
    await _cascadeUpdateFrom(repo, updatedRecord, oldBaseQada: oldQadaMap);

    // Write key for native countdown notification to display checkmark instantly
    final dateStr = '${normalizedDate.year}-${normalizedDate.month.toString().padLeft(2, '0')}-${normalizedDate.day.toString().padLeft(2, '0')}';
    await prefs.setBool('flutter.prayer_done_${prayer.name.toLowerCase()}_$dateStr', true);

    // If it's today, update SharedPreferences completed_today comma-separated list
    final now = DateTime.now();
    final isToday = normalizedDate.year == now.year &&
                    normalizedDate.month == now.month &&
                    normalizedDate.day == now.day;
    if (isToday) {
      final completedStr = completed.map((s) => s.name).join(',');
      await prefs.setString('completed_today', completedStr);
    }
  }

  static Future<void> _cascadeUpdateFrom(
    PrayerRepoImpl repo,
    DailyRecord updatedBaseRecord, {
    Map<Salaah, MissedCounter>? oldBaseQada,
  }) async {
    final allRecords = await repo.loadAllRecords();

    final List<DailyRecord> originalChain = List.from(allRecords);
    originalChain.sort((a, b) => a.date.compareTo(b.date));

    final futureRecords =
        allRecords.where((r) => r.date.isAfter(updatedBaseRecord.date)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    if (futureRecords.isEmpty) return;

    if (futureRecords.length > 1000) {
      print('WARNING: Cascade skipped - too many records (${futureRecords.length})');
      return;
    }

    DailyRecord runningNewPrev = updatedBaseRecord;

    for (final fr in futureRecords) {
      final currentIdx = originalChain.indexWhere(
        (r) => r.date.isAtSameMomentAs(fr.date),
      );
      if (currentIdx <= 0) {
        runningNewPrev = fr;
        continue;
      }

      final oldPrev = originalChain[currentIdx - 1];
      final updatedQada = <Salaah, MissedCounter>{};

      final oldLastUtc = DateTime.utc(
        oldPrev.date.year,
        oldPrev.date.month,
        oldPrev.date.day,
      );
      final targetUtc = DateTime.utc(fr.date.year, fr.date.month, fr.date.day);
      final oldDiff = targetUtc.difference(oldLastUtc).inDays;
      final oldGaps = oldDiff > 1 ? (oldDiff - 1) : 0;

      final newLastUtc = DateTime.utc(
        runningNewPrev.date.year,
        runningNewPrev.date.month,
        runningNewPrev.date.day,
      );
      final newDiff = targetUtc.difference(newLastUtc).inDays;
      final newGaps = newDiff > 1 ? (newDiff - 1) : 0;

      for (final s in Salaah.values) {
        int oldVal = fr.qada[s]?.value ?? 0;
        int oldPrevVal = oldPrev.qada[s]?.value ?? 0;

        if (oldPrev.date.isAtSameMomentAs(updatedBaseRecord.date) &&
            oldBaseQada != null) {
          oldPrevVal = oldBaseQada[s]?.value ?? oldPrevVal;
        }

        int newValPrev = runningNewPrev.qada[s]?.value ?? 0;

        int delta = (newValPrev + newGaps) - (oldPrevVal + oldGaps);
        updatedQada[s] = MissedCounter(oldVal + delta);
      }

      final updatedRecord = fr.copyWith(qada: updatedQada);
      await repo.saveToday(updatedRecord);
      runningNewPrev = updatedRecord;
    }
  }
}
