import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/background_service.dart';
import 'package:fard/core/services/migration_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/quran/presentation/bloc/quran_bloc.dart';
import 'package:fard/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/audio/presentation/blocs/audio_bloc.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  final startupTimer = Stopwatch()..start();

  debugPrint('[STARTUP] App starting...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint(
      '[STARTUP] WidgetsFlutterBinding initialized (${startupTimer.elapsedMilliseconds}ms)');

  // 1. CRITICAL: Configure Dependencies (Hive, GetIt, SharedPreferences)
  // This must finish before runApp because widgets depend on getIt.
  await configureDependencies();
  debugPrint(
      '[STARTUP] Dependencies configured (${startupTimer.elapsedMilliseconds}ms)');

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

      // Notification Service
      getIt<NotificationService>().init().then((_) {
        getIt<NotificationService>().handleInitialNotification();
      }),

      // JustAudio & Workmanager
      if (Platform.isAndroid || Platform.isIOS) ...[
        JustAudioBackground.init(
          androidNotificationChannelId: 'com.nagar.fard.channel.audio',
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
      getIt<SettingsCubit>().initReminders();
      // Force widget update on app start to ensure fresh prayer times
      await _updateWidgetOnStart();
    });
  }

  /// Updates widget on app start to ensure fresh prayer times after time change.
  Future<void> _updateWidgetOnStart() async {
    try {
      final settings = getIt<SettingsCubit>().state;
      if (settings.latitude != null && settings.longitude != null) {
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
        BlocProvider(create: (_) => getIt<SettingsCubit>()),
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
        BlocProvider(create: (_) => getIt<AudioBloc>()),
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
          return BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (previous, current) => previous.locale != current.locale,
            builder: (context, state) {
              return MaterialApp(
                navigatorKey: getIt<GlobalKey<NavigatorState>>(),
                locale: state.locale,
                onGenerateTitle: (context) => 'Fard',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.darkTheme,
                home: const RootScreen(),
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                builder: (context, child) {
                  final textDirection = state.locale.languageCode == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr;
                  return Localizations.override(
                    context: context,
                    locale: state.locale,
                    child: Directionality(
                      textDirection: textDirection,
                      child: child!,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
