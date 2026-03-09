import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';
import 'package:fard/features/quran/data/datasources/local/entities/surah_entity.dart';
import 'package:fard/features/quran/data/datasources/local/entities/ayah_entity.dart';
import 'package:fard/features/quran/data/datasources/local/entities/bookmark_entity.dart';

import 'configure_dependencies.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies({String? hivePath}) async {
  debugPrint('configureDependencies: Starting...');
  
  // Initialize timezones
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('UTC'));
  debugPrint('configureDependencies: Timezones initialized');

  // Initialize Hive
  try {
    debugPrint('configureDependencies: Initializing Hive...');
    if (hivePath != null) {
      Hive.init(hivePath);
    } else {
      await Hive.initFlutter();
    }
    debugPrint('configureDependencies: Hive initialized');
  } catch (e) {
    debugPrint('Hive initialization warning: $e');
  }

  // Register Adapters
  try {
    Hive.registerAdapter(DailyRecordEntityAdapter());
    Hive.registerAdapter(SurahEntityAdapter());
    Hive.registerAdapter(AyahEntityAdapter());
    Hive.registerAdapter(BookmarkEntityAdapter());
  } catch (e) {
    debugPrint('Adapter registration warning: $e');
  }

  // Initialize GetIt
  await getIt.init();
}
