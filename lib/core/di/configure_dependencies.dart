import 'package:fard/core/models/download_entry.dart';
import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';
import 'package:fard/features/quran/data/datasources/local/entities/ayah_entity.dart';
import 'package:fard/features/quran/data/datasources/local/entities/bookmark_entity.dart';
import 'package:fard/features/quran/data/datasources/local/entities/surah_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

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
  // In timezone 0.11.0, UTC is accessed as 'Etc/UTC' or 'GMT'
  tz.setLocalLocation(tz.getLocation('Etc/UTC'));
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
    Hive.registerAdapter(DownloadStatusAdapter());
    Hive.registerAdapter(DownloadEntryAdapter());
  } catch (e) {
    debugPrint('Adapter registration warning: $e');
  }

  // Open Boxes
  try {
    await Hive.openBox<DownloadEntry>('download_manifest_box');
  } catch (e) {
    debugPrint('Box opening warning: $e');
  }

  // Register Services
  // getIt.registerLazySingleton(() => ConnectivityService());
  // getIt.registerLazySingleton(() => ConnectivityBloc(connectivityService: getIt<ConnectivityService>()));

  // Initialize GetIt
  await getIt.init();
}
