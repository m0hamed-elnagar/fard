import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/azkar/presentation/screens/main_navigation_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              _OnboardingPage(
                title: l10n.onboardingTitle1,
                description: l10n.onboardingDesc1,
                icon: Icons.auto_graph_rounded,
              ),
              _OnboardingPage(
                title: l10n.onboardingTitle2,
                description: l10n.onboardingDesc2,
                icon: Icons.history_rounded,
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16.0,
            right: 16.0,
            child: IconButton(
              onPressed: () => context.read<SettingsCubit>().toggleLocale(),
              icon: const Icon(Icons.language_rounded, color: AppTheme.accent),
              tooltip: 'Switch Language / تغيير اللغة',
            ),
          ),
          Positioned(
            bottom: 48.0,
            left: 24.0,
            right: 24.0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    2,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 8.0,
                      width: _currentPage == index ? 24.0 : 8.0,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppTheme.accent
                            : AppTheme.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32.0),
                SizedBox(
                  width: double.infinity,
                  height: 56.0,
                  child: ElevatedButton(
                    onPressed: _currentPage == 1
                        ? _completeOnboarding
                        : () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    child: Text(
                      _currentPage == 1 ? l10n.getStarted : l10n.next,
                      style: GoogleFonts.outfit(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 80.0, color: AppTheme.primaryLight),
          ),
          const SizedBox(height: 48.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: AppTheme.textPrimary,
              fontSize: 32.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 18.0,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
