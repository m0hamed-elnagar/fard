import 'package:fard/core/di/injection.dart';
import 'package:fard/features/azkar/presentation/screens/main_navigation_screen.dart';
import 'package:fard/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// RootScreen replaces the previous SplashScreen to provide an instant startup.
/// It immediately decides whether to show Onboarding or the Main App.
class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = getIt<SharedPreferences>();
    final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    
    if (onboardingComplete) {
      return const MainNavigationScreen();
    } else {
      return const OnboardingScreen();
    }
  }
}
