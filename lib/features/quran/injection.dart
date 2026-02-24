import 'package:fard/core/di/injection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fard/features/quran/domain/repositories/quran_repository.dart';
import 'package:fard/features/quran/domain/repositories/bookmark_repository.dart';
import 'package:fard/features/quran/domain/usecases/get_all_surahs.dart';
import 'package:fard/features/quran/domain/usecases/get_surah.dart';
import 'package:fard/features/quran/domain/usecases/get_page.dart';
import 'package:fard/features/quran/domain/usecases/get_tafsir.dart';
import 'package:fard/features/quran/domain/usecases/update_last_read.dart';
import 'package:fard/features/quran/domain/usecases/watch_last_read.dart';
import 'package:fard/features/quran/data/datasources/remote/quran_remote_source.dart';
import 'package:fard/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:fard/features/quran/data/repositories/bookmark_repository_impl.dart';
import 'package:fard/features/quran/presentation/blocs/reader_bloc.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/features/quran/data/datasources/local/entities/surah_entity.dart';
import 'package:fard/features/quran/data/datasources/local/entities/ayah_entity.dart';
import 'package:fard/features/quran/data/datasources/local/entities/bookmark_entity.dart';
import 'package:fard/features/quran/data/datasources/local/quran_local_source.dart';
import 'package:hive_ce/hive_ce.dart';

Future<void> initQuranFeature() async {
  // Hive Adapters
  try {
    Hive.registerAdapter(SurahEntityAdapter());
    Hive.registerAdapter(AyahEntityAdapter());
    Hive.registerAdapter(BookmarkEntityAdapter());
  } catch (_) {}

  // Hive Boxes
  debugPrint('initQuranFeature: Opening quran boxes...');
  final surahBox = await Hive.openBox<SurahEntity>(QuranLocalSourceImpl.boxName);
  final bookmarkBox = await Hive.openBox<BookmarkEntity>(BookmarkRepositoryImpl.boxName);
  debugPrint('initQuranFeature: boxes ready');

  // Blocs
  getIt.registerFactory(() => ReaderBloc(
    getSurah: getIt(),
    getPage: getIt(),
    updateLastRead: getIt(),
    watchLastRead: getIt(),
    bookmarkRepository: getIt(),
  ));

  getIt.registerFactory(() => QuranBloc(getIt(), getIt(), getIt()));

  // Use cases
  getIt.registerLazySingleton(() => GetAllSurahs(getIt()));
  getIt.registerLazySingleton(() => GetSurah(getIt()));
  getIt.registerLazySingleton(() => GetPage(getIt()));
  getIt.registerLazySingleton(() => GetTafsir(getIt()));
  getIt.registerLazySingleton(() => UpdateLastRead(getIt()));
  getIt.registerLazySingleton(() => WatchLastRead(getIt()));

  // Repository
  getIt.registerLazySingleton<QuranRepository>(() => QuranRepositoryImpl(
    remoteSource: getIt(),
    localSource: getIt(),
    sharedPreferences: getIt(),
  ));

  getIt.registerLazySingleton<BookmarkRepository>(() => BookmarkRepositoryImpl(bookmarkBox));

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
