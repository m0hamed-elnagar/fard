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
import 'package:fard/features/quran/data/repositories/quran_repository.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies({String? hivePath}) async {
  try {
    if (hivePath != null) {
      Hive.init(hivePath);
    } else {
      await Hive.initFlutter();
    }
  } catch (e) {
    debugPrint('Hive initialization warning: $e');
  }
  
  try {
    Hive.registerAdapter(DailyRecordEntityAdapter());
  } catch (e) {
    debugPrint('Adapter registration warning: $e');
  }

  final box = await Hive.openBox<DailyRecordEntity>('daily_records');
  final azkarBox = await Hive.openBox<int>('azkar_progress');
  final prefs = await SharedPreferences.getInstance();
  
  getIt.registerSingleton<GlobalKey<NavigatorState>>(GlobalKey<NavigatorState>());
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<LocationService>(LocationService());
  getIt.registerSingleton<NotificationService>(NotificationService());
  getIt.registerSingleton<PrayerTimeService>(PrayerTimeService());
  getIt.registerSingleton<VoiceDownloadService>(VoiceDownloadService());
  getIt.registerSingleton<AzkarRepository>(AzkarRepository(azkarBox));
  getIt.registerSingleton<PrayerRepo>(PrayerRepoImpl(box));
  getIt.registerSingleton<QuranRepository>(QuranRepository());
  
  getIt.registerFactory<PrayerTrackerBloc>(() => PrayerTrackerBloc(getIt()));
  getIt.registerSingleton<SettingsCubit>(SettingsCubit(
        getIt(),
        getIt(),
        getIt(),
        getIt(),
      ));
  getIt.registerSingleton<AzkarBloc>(AzkarBloc(getIt()));
  getIt.registerFactory<QuranBloc>(() => QuranBloc(getIt()));
}
