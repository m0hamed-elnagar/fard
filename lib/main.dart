import 'dart:io';

import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/navigation/theme_update_observer.dart';
import 'package:fard/core/services/background_service.dart';
import 'package:fard/core/services/migration_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/core/theme/theme_presets.dart';
import 'package:fard/core/utils/app_identifiers.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';

import 'core/blocs/connectivity/connectivity_bloc.dart';
import 'features/audio/presentation/blocs/manager/reciter_manager_bloc.dart';
import 'features/audio/presentation/blocs/player/audio_player_bloc.dart';
import 'features/settings/presentation/blocs/adhan_cubit.dart';
import 'features/settings/presentation/blocs/daily_reminders_cubit.dart';
import 'features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'features/settings/presentation/blocs/theme_cubit.dart';
import 'features/settings/presentation/blocs/theme_state.dart';
import 'features/settings/presentation/manager/widget_sync_coordinator.dart';

void main() async {
  final startupTimer = Stopwatch()..start();

  debugPrint('[STARTUP] App starting...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint(
      '[STARTUP] WidgetsFlutterBinding initialized (${startupTimer.elapsedMilliseconds}ms)');

  // 0. Initialize app-specific identifiers (for debug/release separation)
  await AppIdentifiers.initialize();
  debugPrint(
      '[STARTUP] App identifiers initialized: ${AppIdentifiers.packageName} (${startupTimer.elapsedMilliseconds}ms)');

  // 1. CRITICAL: Configure Dependencies (Hive, GetIt, SharedPreferences)
  // This must finish before runApp because widgets depend on getIt.
  await configureDependencies();
  debugPrint(
      '[STARTUP] Dependencies configured (${startupTimer.elapsedMilliseconds}ms)');

  // 1.5 Initialize Widget Sync Coordinator
  getIt<WidgetSyncCoordinator>().init();

  // 2. NON-CRITICAL: Launch non-blocking services in parallel
  // We don't 'await' this so the app can start immediately.
  _initializeBackgroundServices(startupTimer);

  debugPrint('[STARTUP] Running app...');
  runApp(const QadaTrackerApp());
  debugPrint('[STARTUP] runApp called (${startupTimer.elapsedMilliseconds}ms)');

  startupTimer.stop();
  debugPrint(
      '[STARTUP] ===== Critical startup path finished: ${startupTimer.elapsedMilliseconds}ms =====');
}

/// Initializes services that don't need to block the initial UI frame.
Future<void> _initializeBackgroundServices(Stopwatch timer) async {
  try {
    await Future.wait([
      // Asset migration (now optimized with flags)
      MigrationService.migrateAssets(),
      MigrationService.migrateToSupport(),

      // Cleanup orphaned temp files from failed downloads
      _cleanupTempFiles(),

      // Notification Service
      getIt<NotificationService>().init().then((_) {
        getIt<NotificationService>().handleInitialNotification();
      }),

      // JustAudio & Workmanager
      if (Platform.isAndroid || Platform.isIOS) ...[
        JustAudioBackground.init(
          androidNotificationChannelId: AppIdentifiers.audioNotificationChannelId,
          androidNotificationChannelName: 'Quran Audio Playback',
          androidNotificationOngoing: true,
          androidNotificationIcon: 'mipmap/ic_launcher',
        ),
        BackgroundService.initialize(),
      ],
    ]);
    debugPrint(
        '[STARTUP] All background services initialized (${timer.elapsedMilliseconds}ms)');
  } catch (e) {
    debugPrint('[STARTUP] Background initialization error: $e');
  }
}

class QadaTrackerApp extends StatefulWidget {
  final String? hivePath;
  const QadaTrackerApp({super.key, this.hivePath});

  @override
  State<QadaTrackerApp> createState() => _QadaTrackerAppState();
}

class _QadaTrackerAppState extends State<QadaTrackerApp> {
  @override
  void initState() {
    super.initState();
    // Initialize reminders and update widget after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getIt<DailyRemindersCubit>().refresh();
      // Force widget update on app start to ensure fresh prayer times
      await _updateWidgetOnStart();
    });
  }

  /// Updates widget on app start to ensure fresh prayer times after time change.
  Future<void> _updateWidgetOnStart() async {
    try {
      final locationState = getIt<LocationPrayerCubit>().state;
      if (locationState.latitude != null && locationState.longitude != null) {
        debugPrint('MainActivity: Forcing widget update on app start');
        await getIt<WidgetUpdateService>().updateWidget();
      }
    } catch (e) {
      debugPrint('MainActivity: Failed to update widget on start: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<ConnectivityBloc>(),
        ),
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
        BlocProvider(create: (_) => getIt<LocationPrayerCubit>()),
        BlocProvider(create: (_) => getIt<AdhanCubit>()),
        BlocProvider(create: (_) => getIt<DailyRemindersCubit>()),
        BlocProvider(
          create: (_) {
            final bloc = getIt<AzkarBloc>();
            // Delay event to after first frame to reduce startup jank
            Future.delayed(Duration.zero, () {
              bloc.add(const AzkarEvent.loadCategories());
            });
            return bloc;
          },
        ),
        BlocProvider(create: (_) => getIt<AudioPlayerBloc>()),
        BlocProvider(create: (_) => getIt<ReciterManagerBloc>()),
        BlocProvider(
          create: (_) {
            final bloc = getIt<QuranBloc>();
            // Delay event to after first frame to reduce startup jank
            Future.delayed(Duration.zero, () {
              bloc.add(const QuranEvent.loadSurahs());
            });
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) {
            final bloc = getIt<WerdBloc>();
            // Delay event to after first frame to reduce startup jank
            Future.delayed(Duration.zero, () {
              bloc.add(const WerdEvent.load());
            });
            return bloc;
          },
        ),
        BlocProvider(
          create: (_) {
            final bloc = getIt<PrayerTrackerBloc>();
            // Delay event to after first frame to reduce startup jank
            Future.delayed(Duration.zero, () {
              bloc.add(const PrayerTrackerEvent.checkMissedDays());
            });
            return bloc;
          },
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return const _MaterialAppWithReactiveTheme();
        },
      ),
    );
  }
}

/// A StatefulWidget that manages the reactive theme and locale.
/// 
/// Listens to ThemeCubit and updates the theme/locale via setState.
/// MaterialApp.theme changes trigger smooth AnimatedTheme transitions.
class _MaterialAppWithReactiveTheme extends StatefulWidget {
  const _MaterialAppWithReactiveTheme();

  @override
  State<_MaterialAppWithReactiveTheme> createState() =>
      _MaterialAppWithReactiveThemeState();
}

class _MaterialAppWithReactiveThemeState
    extends State<_MaterialAppWithReactiveTheme> {
  final _themeObserver = ThemeUpdateObserver();
  ThemeData _theme = ThemePresets.buildThemeData(ThemePresets.emerald);
  Locale _locale = const Locale('ar');
  ThemeState? _pendingThemeState;

  @override
  void initState() {
    super.initState();
    _initFromCurrentState();
    _themeObserver.onAllRoutesSettled = _applyPendingTheme;
    context.read<ThemeCubit>().stream.listen(_onThemeChanged);
  }

  void _initFromCurrentState() {
    final state = context.read<ThemeCubit>().state;
    _theme = _buildTheme(state);
    _locale = state.locale;
  }

  void _onThemeChanged(ThemeState state) {
    if (!mounted) return;

    _pendingThemeState = state;

    if (!_themeObserver.hasActiveAnimations) {
      _applyPendingTheme();
    }
    // If animations are active, onAllRoutesSettled will fire automatically
  }

  void _applyPendingTheme() {
    final state = _pendingThemeState;
    if (state == null || !mounted) return;
    _pendingThemeState = null;
    setState(() {
      _theme = _buildTheme(state);
      _locale = state.locale;
    });
  }

  ThemeData _buildTheme(ThemeState state) {
    return state.themePresetId == 'custom' && state.customThemeColors != null
        ? ThemePresets.buildCustomThemeData(
            state.customThemeColors!.map(
              (key, value) => MapEntry(
                key,
                Color(
                  int.parse(
                    'FF${value.replaceFirst('#', '')}',
                    radix: 16,
                  ),
                ),
              ),
            ),
          )
        : ThemePresets.buildThemeData(ThemePresets.getById(state.themePresetId));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: getIt<GlobalKey<NavigatorState>>(),
      navigatorObservers: [_themeObserver],
      locale: _locale,
      onGenerateTitle: (context) => 'Fard',
      debugShowCheckedModeBanner: false,
      theme: _theme,
      home: const RootScreen(),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

/// Removes orphaned .tmp files from audio and mushaf directories.
Future<void> _cleanupTempFiles() async {
  try {
    final directory = await getApplicationSupportDirectory();
    final dirs = [
      Directory('${directory.path}/audio'),
      Directory('${directory.path}/mushaf_pages'),
    ];

    for (final dir in dirs) {
      if (await dir.exists()) {
        await for (final entity in dir.list(recursive: true)) {
          if (entity is File && entity.path.endsWith('.tmp')) {
            debugPrint('[CLEANUP] Removing orphaned temp file: ${entity.path}');
            await entity.delete();
          }
        }
      }
    }
  } catch (e) {
    debugPrint('[CLEANUP] Error cleaning up temp files: $e');
  }
}
