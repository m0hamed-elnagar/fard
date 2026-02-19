import 'package:fard/core/di/injection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/usecases/get_all_surahs.dart';
import 'package:fard/features/quran/domain/usecases/get_surah.dart';
import 'package:fard/features/quran/domain/usecases/get_page.dart';
import 'package:fard/features/quran/domain/usecases/get_tafsir.dart';
import 'package:fard/features/quran/domain/usecases/play_audio.dart';
import 'package:fard/features/quran/domain/usecases/update_last_read.dart';
import 'package:fard/features/quran/domain/usecases/watch_last_read.dart';
import 'package:fard/features/quran/domain/repositories/audio_repository.dart';
import 'package:fard/features/quran/domain/repositories/audio_player_service.dart';
import 'package:fard/features/quran/data/datasources/remote/quran_remote_source.dart';
import 'package:fard/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:fard/features/quran/data/repositories/audio_repository_impl.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/presentation/blocs/audio_bloc.dart';
import 'package:fard/features/quran/services/audio_player_service_impl.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/features/quran/data/datasources/local/entities/surah_entity.dart';
import 'package:fard/features/quran/data/datasources/local/entities/ayah_entity.dart';
import 'package:fard/features/quran/data/datasources/local/quran_local_source.dart';
import 'package:hive_ce/hive_ce.dart';

Future<void> initQuranFeature() async {
  // Hive Adapters
  try {
    Hive.registerAdapter(SurahEntityAdapter());
    Hive.registerAdapter(AyahEntityAdapter());
  } catch (_) {}

  // Hive Box
  debugPrint('initQuranFeature: Opening surahBox...');
  final surahBox = await Hive.openBox<SurahEntity>(QuranLocalSourceImpl.boxName);
  debugPrint('initQuranFeature: surahBox ready');

  // Blocs
  getIt.registerFactory(() => ReaderBloc(
    getSurah: getIt(),
    getPage: getIt(),
    updateLastRead: getIt(),
    watchLastRead: getIt(),
  ));

  getIt.registerFactory(() => QuranBloc(getIt(), getIt()));

  getIt.registerFactory(() => AudioBloc(
    audioRepository: getIt(),
    playerService: getIt(),
  ));

  // Use cases
  getIt.registerLazySingleton(() => GetAllSurahs(getIt()));
  getIt.registerLazySingleton(() => GetSurah(getIt()));
  getIt.registerLazySingleton(() => GetPage(getIt()));
  getIt.registerLazySingleton(() => GetTafsir(getIt()));
  getIt.registerLazySingleton(() => PlayAudio(
    audioRepository: getIt(),
    playerService: getIt(),
  ));
  getIt.registerLazySingleton(() => UpdateLastRead(getIt()));
  getIt.registerLazySingleton(() => WatchLastRead(getIt()));

  // Services
  getIt.registerLazySingleton<AudioPlayerService>(() => AudioPlayerServiceImpl());

  // Repository
  getIt.registerLazySingleton<QuranRepository>(() => QuranRepositoryImpl(
    remoteSource: getIt(),
    localSource: getIt(),
    sharedPreferences: getIt(),
  ));

  getIt.registerLazySingleton<AudioRepository>(() => AudioRepositoryImpl(
    client: getIt(),
  ));

  // Data sources
  getIt.registerLazySingleton<QuranLocalSource>(() => QuranLocalSourceImpl(surahBox));
  
  getIt.registerLazySingleton<QuranRemoteSource>(() => QuranRemoteSourceImpl(
    client: getIt(),
  ));

  // External (if not already registered)
  if (!getIt.isRegistered<http.Client>()) {
    getIt.registerLazySingleton(() => http.Client());
  }
}
