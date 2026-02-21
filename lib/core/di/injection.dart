import 'package:fard/core/services/location_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';
import 'package:fard/features/prayer_tracking/data/prayer_repo_impl.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/quran/injection.dart';
import 'package:fard/features/audio/injection.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/tasbih/data/tasbih_repository_impl.dart';
import 'package:fard/features/tasbih/domain/tasbih_repository.dart';
import 'package:fard/features/tasbih/presentation/bloc/tasbih_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final getIt = GetIt.instance;

Future<void> configureDependencies({String? hivePath}) async {
  debugPrint('configureDependencies: Starting...');
  // Initialize timezones
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('UTC'));
  debugPrint('configureDependencies: Timezones initialized');

  try {
    if (hivePath != null) {
      Hive.init(hivePath);
    } else {
      debugPrint('configureDependencies: Initializing Hive...');
      await Hive.initFlutter();
    }
    debugPrint('configureDependencies: Hive initialized');
  } catch (e) {
    debugPrint('Hive initialization warning: $e');
  }
  
  try {
    Hive.registerAdapter(DailyRecordEntityAdapter());
  } catch (e) {
    debugPrint('Adapter registration warning: $e');
  }

  debugPrint('configureDependencies: Opening boxes...');
  final box = await Hive.openBox<DailyRecordEntity>('daily_records');
  final azkarBox = await Hive.openBox<int>('azkar_progress');
  final tasbihProgressBox = await Hive.openBox<int>('tasbih_progress');
  final tasbihHistoryBox = await Hive.openBox<int>('tasbih_history');
  final tasbihPreferredDuaBox = await Hive.openBox<String>('tasbih_preferred_dua');
  debugPrint('configureDependencies: Boxes opened');
  
  debugPrint('configureDependencies: Getting SharedPreferences...');
  final prefs = await SharedPreferences.getInstance();
  debugPrint('configureDependencies: SharedPreferences ready');
  
  getIt.registerSingleton<GlobalKey<NavigatorState>>(GlobalKey<NavigatorState>());
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<LocationService>(LocationService());
  getIt.registerSingleton<NotificationService>(NotificationService());
  getIt.registerSingleton<PrayerTimeService>(PrayerTimeService());
  getIt.registerSingleton<VoiceDownloadService>(VoiceDownloadService());
  getIt.registerSingleton<AzkarRepository>(AzkarRepository(azkarBox));
  getIt.registerSingleton<PrayerRepo>(PrayerRepoImpl(box));
  getIt.registerSingleton<TasbihRepository>(TasbihRepositoryImpl(
    tasbihProgressBox, 
    tasbihHistoryBox, 
    tasbihPreferredDuaBox,
    prefs,
  ));
  
  debugPrint('configureDependencies: Initializing Audio Feature...');
  await initAudioFeature();
  debugPrint('configureDependencies: Audio Feature initialized');

  debugPrint('configureDependencies: Initializing Quran Feature...');
  // Initialize Quran Feature (DDD)
  await initQuranFeature();
  debugPrint('configureDependencies: Quran Feature initialized');
  
  getIt.registerFactory<PrayerTrackerBloc>(() => PrayerTrackerBloc(
        getIt<PrayerRepo>(),
        getIt<SharedPreferences>(),
        getIt<PrayerTimeService>(),
      ));
  getIt.registerSingleton<SettingsCubit>(SettingsCubit(
        getIt(),
        getIt(),
        getIt(),
        getIt(),
      ));
  getIt.registerSingleton<AzkarBloc>(AzkarBloc(getIt()));
  getIt.registerFactory<TasbihBloc>(() => TasbihBloc(getIt()));
  // Note: QuranBloc is now replaced by ReaderBloc in initQuranFeature()
  // But we might still need it if QuranPage is not yet refactored.
  // I'll keep it for now but point to the new repository if possible, 
  // though they are incompatible.
  // Actually, I'll keep the old registration if I want to keep old UI working.
}
