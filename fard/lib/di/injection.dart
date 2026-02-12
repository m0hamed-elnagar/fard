import 'package:fard/data/entities/daily_record_entity.dart';
import 'package:fard/data/repo/prayer_repo_impl.dart';
import 'package:fard/domain/repositories/prayer_repo.dart';
import 'package:fard/presentation/blocs/prayer_tracker/prayer_tracker_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DailyRecordEntityAdapter());

  final box = await Hive.openBox<DailyRecordEntity>('daily_records');
  getIt.registerSingleton<PrayerRepo>(PrayerRepoImpl(box));
  getIt.registerFactory<PrayerTrackerBloc>(() => PrayerTrackerBloc(getIt()));
}
