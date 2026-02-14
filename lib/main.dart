import 'package:fard/core/di/injection.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fard/core/l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QadaTrackerApp());
}

class QadaTrackerApp extends StatefulWidget {
  final String? hivePath;
  const QadaTrackerApp({super.key, this.hivePath});

  @override
  State<QadaTrackerApp> createState() => _QadaTrackerAppState();
}

class _QadaTrackerAppState extends State<QadaTrackerApp> {
  bool _initialized = false;

  void _onInitialized() {
    setState(() {
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: SplashScreen(
          onInitialized: _onInitialized,
          hivePath: widget.hivePath,
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SettingsCubit>()),
        BlocProvider(create: (_) => getIt<AzkarBloc>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return MaterialApp(
            locale: state.locale,
            onGenerateTitle: (context) => 'Fard',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const SplashScreenNavigate(), // Helper to decide where to go
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
