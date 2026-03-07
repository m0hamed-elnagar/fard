import 'dart:io';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/widgets/custom_toggle.dart';
import 'package:fard/features/azkar/presentation/screens/main_navigation_screen.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isQadaEnabled = true;
  bool _isDownloading = false;
  final int _totalPages = 5;

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    
    if (mounted) {
      if (!_isQadaEnabled) {
        context.read<SettingsCubit>().toggleQadaEnabled();
      }
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MainNavigationScreen(showAddQadaOnStart: _isQadaEnabled),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 120;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    _OnboardingPage(
                      title: l10n.onboardingTitle1,
                      description: l10n.onboardingDesc1,
                      icon: Icons.auto_graph_rounded,
                      bottomPadding: bottomPadding,
                    ),
                    _OnboardingPage(
                      title: l10n.onboardingTitle2,
                      description: l10n.onboardingDesc2,
                      icon: Icons.history_rounded,
                      bottomPadding: bottomPadding,
                    ),
                    _LocationPrayerPage(state: state, bottomPadding: bottomPadding),
                    _AzanSelectionPage(
                      state: state, 
                      isDownloading: _isDownloading,
                      onDownloadingChanged: (val) => setState(() => _isDownloading = val),
                      bottomPadding: bottomPadding,
                    ),
                    _QadaSelectionPage(
                      isEnabled: _isQadaEnabled,
                      onChanged: (val) => setState(() => _isQadaEnabled = val),
                      bottomPadding: bottomPadding,
                    ),
                  ],
                );
              },
            ),
            Positioned(
              top: 16.0,
              right: 16.0,
              child: IconButton(
                onPressed: () => context.read<SettingsCubit>().toggleLocale(),
                icon: const Icon(Icons.language_rounded, color: AppTheme.accent),
                tooltip: l10n.switchLanguage,
              ),
            ),
            Positioned(
              bottom: 24.0,
              left: 24.0,
              right: 24.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _totalPages,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8.0,
                        width: _currentPage == index ? 24.0 : 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.accent
                              : AppTheme.textSecondary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    height: 56.0,
                    child: ElevatedButton(
                      onPressed: _isDownloading ? null : (_currentPage == _totalPages - 1
                          ? _completeOnboarding
                          : () => _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryLight,
                        foregroundColor: AppTheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      child: _isDownloading 
                        ? const SizedBox(
                            height: 24, 
                            width: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            _currentPage == _totalPages - 1 ? l10n.getStarted : l10n.next,
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
      ),
    );
  }
}

class _LocationPrayerPage extends StatelessWidget {
  final SettingsState state;
  final double bottomPadding;

  const _LocationPrayerPage({required this.state, required this.bottomPadding});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SettingsCubit>();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.0, 40.0, 24.0, bottomPadding),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.location_on_rounded, size: 64.0, color: AppTheme.primaryLight),
          ),
          const SizedBox(height: 32.0),
          Text(
            l10n.prayerSettings,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: AppTheme.textPrimary,
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            l10n.locationDesc,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 16.0,
            ),
          ),
          const SizedBox(height: 32.0),
          _SettingsDropdown(
            label: l10n.currentLocation,
            value: state.cityName ?? l10n.locationNotSet,
            icon: Icons.my_location_rounded,
            onTap: () => cubit.refreshLocation(),
          ),
          const SizedBox(height: 16.0),
          _SettingsDropdownSelector(
            label: l10n.calculationMethod,
            value: state.calculationMethod,
            options: {
              'muslim_league': l10n.muslimWorldLeague,
              'egyptian': l10n.egyptianGeneralAuthority,
              'karachi': l10n.universityOfIslamicSciencesKarachi,
              'umm_al_qura': l10n.ummAlQuraUniversityMakkah,
              'dubai': l10n.dubai,
              'qatar': l10n.qatar,
              'kuwait': l10n.kuwait,
              'singapore': l10n.singapore,
              'turkey': l10n.turkey,
              'tehran': l10n.instituteOfGeophysicsTehran,
              'north_america': l10n.isnaNorthAmerica,
            },
            onChanged: (val) => cubit.updateCalculationMethod(val!),
          ),
          const SizedBox(height: 16.0),
          _SettingsDropdownSelector(
            label: l10n.madhab,
            value: state.madhab,
            options: {
              'shafi': l10n.shafiMadhab,
              'hanafi': l10n.hanafiMadhab,
            },
            onChanged: (val) => cubit.updateMadhab(val!),
          ),
        ],
      ),
    );
  }
}

class _AzanSelectionPage extends StatelessWidget {
  final SettingsState state;
  final bool isDownloading;
  final ValueChanged<bool> onDownloadingChanged;
  final double bottomPadding;

  const _AzanSelectionPage({
    required this.state, 
    required this.isDownloading,
    required this.onDownloadingChanged,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<SettingsCubit>();
    final isAzanEnabled = state.salaahSettings.any((s) => s.isAzanEnabled);
    final currentSound = state.salaahSettings.first.azanSound;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.0, 40.0, 24.0, bottomPadding),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_active_rounded, size: 64.0, color: AppTheme.primaryLight),
          ),
          const SizedBox(height: 32.0),
          Text(
            l10n.azanSettings,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: AppTheme.textPrimary,
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.enableAzan,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: isAzanEnabled ? AppTheme.accent : AppTheme.textSecondary,
                  ),
                ),
                CustomToggle(
                  value: isAzanEnabled,
                  onChanged: (val) => cubit.updateAllAzanEnabled(val),
                ),
              ],
            ),
          ),
          if (isAzanEnabled) ...[
            const SizedBox(height: 16.0),
            _SettingsDropdownSelector(
              label: l10n.azanVoice,
              value: _getDisplayName(currentSound) ?? l10n.defaultVal,
              options: {
                l10n.defaultVal: l10n.defaultVal,
                ...VoiceDownloadService.azanVoices.map((k, v) => MapEntry(k, k)),
              },
              onChanged: (val) async {
                if (val == null || val == l10n.defaultVal) {
                  cubit.updateAllAzanSound(null);
                  return;
                }
                onDownloadingChanged(true);
                final downloader = getIt<VoiceDownloadService>();
                final path = await downloader.downloadAzan(val);
                if (path != null) {
                  cubit.updateAllAzanSound(path);
                }
                onDownloadingChanged(false);
              },
            ),
            const SizedBox(height: 16.0),
            TextButton.icon(
              onPressed: isDownloading ? null : () => getIt<NotificationService>().testAzan(Salaah.fajr, currentSound, settings: state),
              icon: const Icon(Icons.play_circle_filled_rounded),
              label: Text(l10n.testAzan),
              style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
            ),
          ],
        ],
      ),
    );
  }

  String? _getDisplayName(String? path) {
    if (path == null || path == 'default') return null;
    final fileName = path.split(Platform.isWindows ? '\\' : '/').last;
    for (var entry in VoiceDownloadService.azanVoices.entries) {
      final uri = Uri.parse(entry.value);
      if (fileName == 'voice_${uri.pathSegments.last}') {
        return entry.key;
      }
    }
    return null;
  }
}

class _SettingsDropdown extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _SettingsDropdown({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.refresh_rounded, size: 20, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}

class _SettingsDropdownSelector extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> options;
  final ValueChanged<String?> onChanged;

  const _SettingsDropdownSelector({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              label,
              style: GoogleFonts.outfit(fontSize: 12, color: AppTheme.textSecondary),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.containsKey(value) ? value : options.keys.first,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.accent),
              items: options.entries.map((e) {
                return DropdownMenuItem(
                  value: e.key,
                  child: Text(
                    e.value,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _QadaSelectionPage extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;
  final double bottomPadding;

  const _QadaSelectionPage({
    required this.isEnabled,
    required this.onChanged,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.0, 40.0, 24.0, bottomPadding),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 64.0,
              color: AppTheme.primaryLight,
            ),
          ),
          const SizedBox(height: 32.0),
          Text(
            l10n.qadaOnboardingTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: AppTheme.textPrimary,
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            l10n.qadaOnboardingDesc,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 16.0,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEnabled ? l10n.enableQada : l10n.disableQada,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: isEnabled ? AppTheme.accent : AppTheme.textSecondary,
                  ),
                ),
                CustomToggle(
                  value: isEnabled,
                  onChanged: onChanged,
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
  final double bottomPadding;

  const _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.0, 40.0, 24.0, bottomPadding),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64.0, color: AppTheme.primaryLight),
          ),
          const SizedBox(height: 32.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: AppTheme.textPrimary,
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: AppTheme.textSecondary,
              fontSize: 16.0,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
