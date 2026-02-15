import 'package:fard/core/di/injection.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/azkar/presentation/screens/main_navigation_screen.dart';
import 'package:fard/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SplashScreenNavigate()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100.0,
              height: 100.0,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryLight, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(24.0),
              ),
              child: Icon(Icons.mosque_rounded, color: AppTheme.onPrimary, size: 50.0),
            ),
            const SizedBox(height: 24.0),
            Text(
              'Fard',
              style: GoogleFonts.amiri(
                color: AppTheme.textPrimary,
                fontSize: 32.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48.0),
            const CircularProgressIndicator(
              color: AppTheme.primaryLight,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

class SplashScreenNavigate extends StatelessWidget {
  const SplashScreenNavigate({super.key});

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
