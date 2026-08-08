import 'dart:convert';
import 'dart:io';
import 'package:fard/core/services/background_prayer_sync_service.dart';
import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends Fake implements PathProviderPlatform {
  final Directory tempDir;
  FakePathProviderPlatform(this.tempDir);

  @override
  Future<String?> getTemporaryPath() async {
    return tempDir.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late SharedPreferences prefs;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sync_service_test');
    PathProviderPlatform.instance = FakePathProviderPlatform(tempDir);

    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DailyRecordEntityAdapter());
    }

    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('BackgroundPrayerSyncService', () {
    test('markPrayerAsPrayed writes to Hive and sets SharedPreferences flags', () async {
      final date = DateTime(2026, 7, 19);
      final todayStr = "2026-07-19";

      await BackgroundPrayerSyncService.markPrayerAsPrayed(date, Salaah.dhuhr, prefs);

      // Verify SharedPreferences flag is set
      expect(prefs.getBool('flutter.prayer_done_dhuhr_$todayStr'), isTrue);

      // Verify Hive write
      final box = Hive.box<DailyRecordEntity>('daily_records');
      expect(box.values.length, 1);
      
      final record = box.values.first;
      expect(record.id, todayStr);
      expect(record.completedIndices, contains(1)); // Dhuhr index is 1
    });

    test('drainQueue atomically clears file and processes all entries', () async {
      final cacheFile = File('${tempDir.path}/pending_prayers.json');
      final initialQueue = [
        {'prayerId': 'fajr', 'date': '2026-07-19', 'timestamp': 1000},
        {'prayerId': 'asr', 'date': '2026-07-19', 'timestamp': 2000},
      ];
      cacheFile.writeAsStringSync(jsonEncode(initialQueue));

      final didDrain = await BackgroundPrayerSyncService.drainQueue(prefs);
      expect(didDrain, isTrue);

      // Verify file queue was cleared
      expect(cacheFile.readAsStringSync(), '[]');

      // Verify Hive contains both prayers
      final box = Hive.box<DailyRecordEntity>('daily_records');
      expect(box.values.length, 1);

      final record = box.values.first;
      expect(record.completedIndices, contains(0)); // Fajr index is 0
      expect(record.completedIndices, contains(2)); // Asr index is 2
    });

    test('drainQueue returns false if file does not exist or is empty', () async {
      final didDrain = await BackgroundPrayerSyncService.drainQueue(prefs);
      expect(didDrain, isFalse);
    });
  });
}
