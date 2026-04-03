import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';
import 'package:fard/features/quran/data/datasources/local/entities/surah_entity.dart';
import 'package:fard/features/quran/data/datasources/local/entities/bookmark_entity.dart';
import 'package:fard/features/quran/data/datasources/local/quran_local_source.dart';
import 'package:fard/features/quran/data/repositories/bookmark_repository_impl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@module
abstract class RegisterModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @preResolve
  @Named('dailyRecordsBox')
  Future<Box<DailyRecordEntity>> get dailyRecordsBox =>
      Hive.openBox<DailyRecordEntity>('daily_records');

  @preResolve
  @Named('azkarBox')
  Future<Box<int>> get azkarBox => Hive.openBox<int>('azkar_progress');

  @preResolve
  @Named('tasbihProgressBox')
  Future<Box<int>> get tasbihProgressBox =>
      Hive.openBox<int>('tasbih_progress');

  @preResolve
  @Named('tasbihHistoryBox')
  Future<Box<int>> get tasbihHistoryBox => Hive.openBox<int>('tasbih_history');

  @preResolve
  @Named('tasbihPreferredDuaBox')
  Future<Box<String>> get tasbihPreferredDuaBox =>
      Hive.openBox<String>('tasbih_preferred_dua');

  @preResolve
  @Named('surahBox')
  Future<Box<SurahEntity>> get surahBox =>
      Hive.openBox<SurahEntity>(QuranLocalSourceImpl.boxName);

  @preResolve
  @Named('bookmarkBox')
  Future<Box<BookmarkEntity>> get bookmarkBox =>
      Hive.openBox<BookmarkEntity>(BookmarkRepositoryImpl.boxName);

  @lazySingleton
  http.Client get httpClient => http.Client();

  @singleton
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  @lazySingleton
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();
}
