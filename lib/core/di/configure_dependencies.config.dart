// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:flutter/material.dart' as _i409;
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as _i163;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive_ce/hive.dart' as _i738;
import 'package:hive_ce/hive_ce.dart' as _i1055;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/audio/data/repositories/audio_player_service_impl.dart'
    as _i241;
import '../../features/audio/data/repositories/audio_repository_impl.dart'
    as _i757;
import '../../features/audio/data/services/audio_download_service_impl.dart'
    as _i779;
import '../../features/audio/domain/repositories/audio_player_service.dart'
    as _i720;
import '../../features/audio/domain/repositories/audio_repository.dart'
    as _i451;
import '../../features/audio/domain/services/audio_download_service.dart'
    as _i224;
import '../../features/audio/domain/usecases/play_audio.dart' as _i1008;
import '../../features/audio/presentation/blocs/audio_download/audio_download_cubit.dart'
    as _i352;
import '../../features/audio/presentation/blocs/manager/reciter_manager_bloc.dart'
    as _i730;
import '../../features/audio/presentation/blocs/player/audio_player_bloc.dart'
    as _i288;
import '../../features/azkar/data/azkar_repository.dart' as _i1004;
import '../../features/azkar/data/azkar_source.dart' as _i1027;
import '../../features/azkar/presentation/blocs/azkar_bloc.dart' as _i1037;
import '../../features/prayer_tracking/data/daily_record_entity.dart' as _i453;
import '../../features/prayer_tracking/data/prayer_repo_impl.dart' as _i107;
import '../../features/prayer_tracking/domain/prayer_repo.dart' as _i800;
import '../../features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart'
    as _i278;
import '../../features/quran/data/datasources/local/entities/bookmark_entity.dart'
    as _i800;
import '../../features/quran/data/datasources/local/entities/surah_entity.dart'
    as _i852;
import '../../features/quran/data/datasources/local/quran_local_source.dart'
    as _i733;
import '../../features/quran/data/datasources/remote/quran_remote_source.dart'
    as _i331;
import '../../features/quran/data/repositories/bookmark_repository_impl.dart'
    as _i215;
import '../../features/quran/data/repositories/quran_repository_impl.dart'
    as _i82;
import '../../features/quran/data/repositories/quran_symbols_repository_impl.dart'
    as _i1014;
import '../../features/quran/domain/repositories/bookmark_repository.dart'
    as _i33;
import '../../features/quran/domain/repositories/quran_repository.dart'
    as _i498;
import '../../features/quran/domain/repositories/quran_symbols_repository.dart'
    as _i303;
import '../../features/quran/domain/usecases/get_all_surahs.dart' as _i177;
import '../../features/quran/domain/usecases/get_page.dart' as _i451;
import '../../features/quran/domain/usecases/get_surah.dart' as _i941;
import '../../features/quran/domain/usecases/get_tafsir.dart' as _i289;
import '../../features/quran/domain/usecases/search_quran.dart' as _i623;
import '../../features/quran/domain/usecases/update_last_read.dart' as _i588;
import '../../features/quran/domain/usecases/watch_bookmark.dart' as _i218;
import '../../features/quran/domain/usecases/watch_last_read.dart' as _i358;
import '../../features/quran/presentation/bloc/quran_bloc.dart' as _i733;
import '../../features/quran/presentation/blocs/reader_bloc.dart' as _i1060;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/data/repositories/settings_storage.dart'
    as _i307;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i674;
import '../../features/settings/domain/usecases/apply_theme_preset.dart'
    as _i808;
import '../../features/settings/domain/usecases/get_available_theme_presets.dart'
    as _i494;
import '../../features/settings/domain/usecases/save_custom_theme.dart'
    as _i1036;
import '../../features/settings/domain/usecases/sync_location_settings.dart'
    as _i47;
import '../../features/settings/domain/usecases/sync_notification_schedule.dart'
    as _i760;
import '../../features/settings/domain/usecases/toggle_after_salah_azkar_usecase.dart'
    as _i769;
import '../../features/settings/domain/usecases/update_calculation_method_usecase.dart'
    as _i6;
import '../../features/settings/presentation/blocs/settings_cubit.dart'
    as _i573;
import '../../features/tasbih/data/tasbih_repository_impl.dart' as _i196;
import '../../features/tasbih/domain/tasbih_repository.dart' as _i352;
import '../../features/tasbih/presentation/bloc/tasbih_bloc.dart' as _i809;
import '../../features/werd/data/repositories/werd_repository_impl.dart'
    as _i472;
import '../../features/werd/domain/repositories/werd_repository.dart' as _i724;
import '../../features/werd/presentation/blocs/werd_bloc.dart' as _i1037;
import '../blocs/connectivity/connectivity_bloc.dart' as _i256;
import '../services/connectivity_service.dart' as _i47;
import '../services/download/download_manifest_service.dart' as _i188;
import '../services/export_import_service.dart' as _i1068;
import '../services/location_service.dart' as _i669;
import '../services/mushaf_download_service.dart' as _i700;
import '../services/notification/channel_manager.dart' as _i680;
import '../services/notification/prayer_scheduler.dart' as _i3;
import '../services/notification/sound_manager.dart' as _i1055;
import '../services/notification_service.dart' as _i941;
import '../services/prayer_time_service.dart' as _i552;
import '../services/voice_download_service.dart' as _i492;
import '../services/widget_update_service.dart' as _i682;
import '../utils/symbol_detector.dart' as _i433;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.prefs,
      preResolve: true,
    );
    gh.factory<_i47.ConnectivityService>(() => _i47.ConnectivityService());
    gh.factory<_i494.GetAvailableThemePresets>(
      () => _i494.GetAvailableThemePresets(),
    );
    gh.singleton<_i409.GlobalKey<_i409.NavigatorState>>(
      () => registerModule.navigatorKey,
    );
    gh.singleton<_i669.LocationService>(() => _i669.LocationService());
    gh.singleton<_i1055.SoundManager>(() => _i1055.SoundManager());
    gh.singleton<_i552.PrayerTimeService>(() => _i552.PrayerTimeService());
    gh.lazySingleton<_i519.Client>(() => registerModule.httpClient);
    gh.lazySingleton<_i163.FlutterLocalNotificationsPlugin>(
      () => registerModule.flutterLocalNotificationsPlugin,
    );
    await gh.factoryAsync<_i1055.Box<_i453.DailyRecordEntity>>(
      () => registerModule.dailyRecordsBox,
      instanceName: 'dailyRecordsBox',
      preResolve: true,
    );
    gh.lazySingleton<_i800.PrayerRepo>(
      () => _i107.PrayerRepoImpl(
        gh<_i1055.Box<_i453.DailyRecordEntity>>(
          instanceName: 'dailyRecordsBox',
        ),
      ),
    );
    gh.lazySingleton<_i303.QuranSymbolsRepository>(
      () => _i1014.QuranSymbolsRepositoryImpl(),
    );
    await gh.factoryAsync<_i1055.Box<int>>(
      () => registerModule.azkarBox,
      instanceName: 'azkarBox',
      preResolve: true,
    );
    gh.lazySingleton<_i724.WerdRepository>(
      () => _i472.WerdRepositoryImpl(gh<_i460.SharedPreferences>()),
    );
    await gh.factoryAsync<_i1055.Box<int>>(
      () => registerModule.tasbihProgressBox,
      instanceName: 'tasbihProgressBox',
      preResolve: true,
    );
    await gh.factoryAsync<_i1055.Box<int>>(
      () => registerModule.tasbihHistoryBox,
      instanceName: 'tasbihHistoryBox',
      preResolve: true,
    );
    await gh.factoryAsync<_i1055.Box<_i852.SurahEntity>>(
      () => registerModule.surahBox,
      instanceName: 'surahBox',
      preResolve: true,
    );
    await gh.factoryAsync<_i1055.Box<String>>(
      () => registerModule.tasbihPreferredDuaBox,
      instanceName: 'tasbihPreferredDuaBox',
      preResolve: true,
    );
    gh.lazySingleton<_i720.AudioPlayerService>(
      () => _i241.AudioPlayerServiceImpl(),
    );
    gh.lazySingleton<_i188.DownloadManifestService>(
      () => _i188.DownloadManifestServiceImpl(),
    );
    await gh.factoryAsync<_i1055.Box<_i800.BookmarkEntity>>(
      () => registerModule.bookmarkBox,
      instanceName: 'bookmarkBox',
      preResolve: true,
    );
    gh.factory<_i1037.WerdBloc>(
      () => _i1037.WerdBloc(
        gh<_i724.WerdRepository>(),
        gh<_i941.NotificationService>(),
      ),
    );
    gh.lazySingleton<_i307.SettingsStorage>(
      () => _i307.SettingsStorage(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i256.ConnectivityBloc>(
      () => _i256.ConnectivityBloc(
        connectivityService: gh<_i47.ConnectivityService>(),
      ),
    );
    gh.lazySingleton<_i433.SymbolDetectorService>(
      () => _i433.SymbolDetectorService(gh<_i303.QuranSymbolsRepository>()),
    );
    gh.singleton<_i700.MushafDownloadService>(
      () => _i700.MushafDownloadService(gh<_i188.DownloadManifestService>()),
    );
    gh.singleton<_i492.VoiceDownloadService>(
      () => _i492.VoiceDownloadService(gh<_i188.DownloadManifestService>()),
    );
    gh.factory<_i278.PrayerTrackerBloc>(
      () => _i278.PrayerTrackerBloc(
        gh<_i800.PrayerRepo>(),
        gh<_i460.SharedPreferences>(),
        gh<_i552.PrayerTimeService>(),
        gh<_i941.NotificationService>(),
      ),
    );
    gh.lazySingleton<_i331.QuranRemoteSource>(
      () => _i331.QuranRemoteSourceImpl(client: gh<_i519.Client>()),
    );
    gh.lazySingleton<_i674.SettingsRepository>(
      () => _i955.SettingsRepositoryImpl(gh<_i307.SettingsStorage>()),
    );
    gh.lazySingleton<_i451.AudioRepository>(
      () => _i757.AudioRepositoryImpl(client: gh<_i519.Client>()),
    );
    gh.factory<_i808.ApplyThemePreset>(
      () => _i808.ApplyThemePreset(gh<_i674.SettingsRepository>()),
    );
    gh.factory<_i1036.SaveCustomTheme>(
      () => _i1036.SaveCustomTheme(gh<_i674.SettingsRepository>()),
    );
    gh.factory<_i769.ToggleAfterSalahAzkarUseCase>(
      () => _i769.ToggleAfterSalahAzkarUseCase(gh<_i674.SettingsRepository>()),
    );
    gh.factory<_i6.UpdateCalculationMethodUseCase>(
      () => _i6.UpdateCalculationMethodUseCase(gh<_i674.SettingsRepository>()),
    );
    gh.singleton<_i682.WidgetUpdateService>(
      () => _i682.WidgetUpdateService(
        gh<_i552.PrayerTimeService>(),
        gh<_i460.SharedPreferences>(),
        gh<_i674.SettingsRepository>(),
      ),
    );
    gh.lazySingleton<_i33.BookmarkRepository>(
      () => _i215.BookmarkRepositoryImpl(
        gh<_i1055.Box<_i800.BookmarkEntity>>(instanceName: 'bookmarkBox'),
      ),
    );
    gh.singleton<_i680.ChannelManager>(
      () => _i680.ChannelManager(gh<_i1055.SoundManager>()),
    );
    gh.lazySingleton<_i1027.IAzkarSource>(
      () =>
          _i1004.AzkarRepository(gh<_i1055.Box<int>>(instanceName: 'azkarBox')),
    );
    gh.factory<_i288.AudioPlayerBloc>(
      () => _i288.AudioPlayerBloc(
        audioRepository: gh<_i451.AudioRepository>(),
        playerService: gh<_i720.AudioPlayerService>(),
        settingsRepository: gh<_i674.SettingsRepository>(),
      ),
    );
    gh.lazySingleton<_i1068.ExportImportService>(
      () => _i1068.ExportImportService(
        gh<_i800.PrayerRepo>(),
        gh<_i724.WerdRepository>(),
      ),
    );
    gh.singleton<_i3.PrayerNotificationScheduler>(
      () => _i3.PrayerNotificationScheduler(
        gh<_i552.PrayerTimeService>(),
        gh<_i1027.IAzkarSource>(),
        gh<_i680.ChannelManager>(),
        gh<_i1055.SoundManager>(),
        gh<_i674.SettingsRepository>(),
      ),
    );
    gh.lazySingleton<_i352.TasbihRepository>(
      () => _i196.TasbihRepositoryImpl(
        gh<_i738.Box<int>>(instanceName: 'tasbihProgressBox'),
        gh<_i738.Box<int>>(instanceName: 'tasbihHistoryBox'),
        gh<_i738.Box<String>>(instanceName: 'tasbihPreferredDuaBox'),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.factory<_i47.SyncLocationSettings>(
      () => _i47.SyncLocationSettings(
        gh<_i669.LocationService>(),
        gh<_i674.SettingsRepository>(),
      ),
    );
    gh.lazySingleton<_i733.QuranLocalSource>(
      () => _i733.QuranLocalSourceImpl(
        gh<_i1055.Box<_i852.SurahEntity>>(instanceName: 'surahBox'),
      ),
    );
    gh.lazySingleton<_i498.QuranRepository>(
      () => _i82.QuranRepositoryImpl(
        remoteSource: gh<_i331.QuranRemoteSource>(),
        localSource: gh<_i733.QuranLocalSource>(),
        sharedPreferences: gh<_i460.SharedPreferences>(),
      ),
    );
    gh.factory<_i218.WatchBookmarks>(
      () => _i218.WatchBookmarks(gh<_i33.BookmarkRepository>()),
    );
    gh.factory<_i1008.PlayAudio>(
      () => _i1008.PlayAudio(
        audioRepository: gh<_i451.AudioRepository>(),
        playerService: gh<_i720.AudioPlayerService>(),
      ),
    );
    gh.factory<_i588.UpdateLastRead>(
      () => _i588.UpdateLastRead(
        gh<_i498.QuranRepository>(),
        gh<_i724.WerdRepository>(),
      ),
    );
    gh.factory<_i1037.AzkarBloc>(
      () => _i1037.AzkarBloc(gh<_i1027.IAzkarSource>()),
    );
    gh.singleton<_i941.NotificationService>(
      () => _i941.NotificationService(
        gh<_i1055.SoundManager>(),
        gh<_i680.ChannelManager>(),
        gh<_i3.PrayerNotificationScheduler>(),
        gh<_i163.FlutterLocalNotificationsPlugin>(),
        gh<_i682.WidgetUpdateService>(),
        gh<_i674.SettingsRepository>(),
        gh<_i460.SharedPreferences>(),
      ),
    );
    gh.factory<_i809.TasbihBloc>(
      () => _i809.TasbihBloc(gh<_i352.TasbihRepository>()),
    );
    gh.factory<_i177.GetAllSurahs>(
      () => _i177.GetAllSurahs(gh<_i498.QuranRepository>()),
    );
    gh.factory<_i451.GetPage>(() => _i451.GetPage(gh<_i498.QuranRepository>()));
    gh.factory<_i941.GetSurah>(
      () => _i941.GetSurah(gh<_i498.QuranRepository>()),
    );
    gh.factory<_i289.GetTafsir>(
      () => _i289.GetTafsir(gh<_i498.QuranRepository>()),
    );
    gh.factory<_i623.SearchQuran>(
      () => _i623.SearchQuran(gh<_i498.QuranRepository>()),
    );
    gh.factory<_i358.WatchLastRead>(
      () => _i358.WatchLastRead(gh<_i498.QuranRepository>()),
    );
    gh.lazySingleton<_i224.AudioDownloadService>(
      () => _i779.AudioDownloadServiceImpl(
        gh<_i451.AudioRepository>(),
        gh<_i519.Client>(),
        gh<_i941.NotificationService>(),
        gh<_i674.SettingsRepository>(),
        gh<_i188.DownloadManifestService>(),
      ),
    );
    gh.factory<_i760.SyncNotificationSchedule>(
      () => _i760.SyncNotificationSchedule(
        gh<_i941.NotificationService>(),
        gh<_i1027.IAzkarSource>(),
      ),
    );
    gh.factory<_i1060.ReaderBloc>(
      () => _i1060.ReaderBloc(
        getSurah: gh<_i941.GetSurah>(),
        getPage: gh<_i451.GetPage>(),
        updateLastRead: gh<_i588.UpdateLastRead>(),
        watchLastRead: gh<_i358.WatchLastRead>(),
        bookmarkRepository: gh<_i33.BookmarkRepository>(),
        quranRepository: gh<_i498.QuranRepository>(),
      ),
    );
    gh.factory<_i730.ReciterManagerBloc>(
      () => _i730.ReciterManagerBloc(
        audioRepository: gh<_i451.AudioRepository>(),
        downloadService: gh<_i224.AudioDownloadService>(),
      ),
    );
    gh.factory<_i573.SettingsCubit>(
      () => _i573.SettingsCubit(
        gh<_i674.SettingsRepository>(),
        gh<_i669.LocationService>(),
        gh<_i47.SyncLocationSettings>(),
        gh<_i760.SyncNotificationSchedule>(),
        gh<_i769.ToggleAfterSalahAzkarUseCase>(),
        gh<_i6.UpdateCalculationMethodUseCase>(),
        gh<_i808.ApplyThemePreset>(),
        gh<_i1036.SaveCustomTheme>(),
        gh<_i494.GetAvailableThemePresets>(),
        gh<_i682.WidgetUpdateService>(),
      ),
    );
    gh.factory<_i733.QuranBloc>(
      () => _i733.QuranBloc(
        gh<_i498.QuranRepository>(),
        gh<_i358.WatchLastRead>(),
        gh<_i33.BookmarkRepository>(),
      ),
    );
    gh.factory<_i352.AudioDownloadCubit>(
      () => _i352.AudioDownloadCubit(gh<_i224.AudioDownloadService>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
