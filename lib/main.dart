import 'package:fard/core/di/injection.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/azkar/presentation/screens/main_navigation_screen.dart';
import 'package:fard/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  final prefs = getIt<SharedPreferences>();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
  runApp(
    BlocProvider(
      create: (_) => getIt<SettingsCubit>(),
      child: QadaTrackerApp(onboardingComplete: onboardingComplete),
    ),
  );
}

class QadaTrackerApp extends StatelessWidget {
  final bool onboardingComplete;
  const QadaTrackerApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return MaterialApp(
          locale: state.locale,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: onboardingComplete ? const MainNavigationScreen() : const OnboardingScreen(),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}
