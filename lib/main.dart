import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
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
  debugPrint('App starting...');
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('WidgetsFlutterBinding initialized');

  if (Platform.isAndroid || Platform.isIOS) {
    debugPrint('Initializing JustAudioBackground...');
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.nagar.fard.channel.audio',
      androidNotificationChannelName: 'Quran Audio Playback',
      androidNotificationOngoing: true,
    );
    debugPrint('JustAudioBackground initialized');
  }

  debugPrint('Configuring dependencies...');
  await configureDependencies();
  debugPrint('Dependencies configured');

  final notificationService = getIt<NotificationService>();
  debugPrint('Initializing NotificationService...');
  await notificationService.init();
  debugPrint('NotificationService initialized');
  
  debugPrint('Running app...');
  runApp(const QadaTrackerApp());
  
  // Handle notification that launched the app
  notificationService.handleInitialNotification();
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
    // Initialize reminders after first frame to ensure localization is ready if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<SettingsCubit>().initReminders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SettingsCubit>()),
        BlocProvider(create: (_) => getIt<AzkarBloc>()..add(const AzkarEvent.loadCategories())),
        BlocProvider(create: (_) => getIt<AudioBloc>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ScreenUtilInit(
            designSize: const Size(360, 690),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
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
                  return child!;
                },
              );
            },
          );
        },
      ),
    );
  }
}


