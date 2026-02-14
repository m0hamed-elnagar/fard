import 'package:fard/core/services/location_service.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';
import 'package:fard/features/prayer_tracking/data/prayer_repo_impl.dart';
import 'package:fard/features/prayer_tracking/domain/prayer_repo.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DailyRecordEntityAdapter());

  final box = await Hive.openBox<DailyRecordEntity>('daily_records');
  final prefs = await SharedPreferences.getInstance();
  
  getIt.registerSingleton<SharedPreferences>(prefs);
  getIt.registerSingleton<LocationService>(LocationService());
  getIt.registerSingleton<PrayerTimeService>(PrayerTimeService());
  getIt.registerSingleton<PrayerRepo>(PrayerRepoImpl(box));
  
  getIt.registerFactory<PrayerTrackerBloc>(() => PrayerTrackerBloc(getIt()));
  getIt.registerFactory<SettingsCubit>(() => SettingsCubit(getIt(), getIt()));
}
