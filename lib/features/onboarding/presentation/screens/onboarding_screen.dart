import 'dart:async';
import 'dart:io';
import 'package:fard/features/settings/presentation/blocs/adhan_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/adhan_state.dart';
import 'package:fard/features/settings/presentation/blocs/daily_reminders_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/widgets/custom_toggle.dart';
import 'package:fard/features/azkar/presentation/screens/main_navigation_screen.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/connectivity_service.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';

import 'package:fard/core/mixins/notification_permission_mixin.dart';
import 'package:fard/core/utils/location_dialog_helper.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with NotificationPermissionMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isQadaEnabled = true;
  bool _isDownloading = false;
  final int _totalPages = 5;
  Set<String> _downloadedVoices = {};
  bool _isOffline = false;
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadDownloadedVoices();
    _checkConnectivity();
    _connectivitySubscription = getIt<ConnectivityService>()
        .onConnectivityChanged
        .listen((results) {
      final isOffline = results.every((r) => r == ConnectivityResult.none);
      if (mounted) {
        setState(() {
          _isOffline = isOffline;
        });
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final hasNet = await getIt<ConnectivityService>().hasNetwork();
    if (mounted) {
      setState(() {
        _isOffline = !hasNet;
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadDownloadedVoices() async {
    if (!getIt.isRegistered<VoiceDownloadService>()) return;
    final downloader = getIt<VoiceDownloadService>();
    final List<String> downloaded = [];
    for (var voice in VoiceDownloadService.azanVoices.keys) {
      if (await downloader.isDownloaded(voice)) {
        downloaded.add(voice);
      }
    }
    if (mounted) {
      setState(() {
        _downloadedVoices = downloaded.toSet();
      });
    }
  }

  bool _isSoundMuted = false;
  bool _isDndActive = false;
  bool _isSilentMode = false;

  Future<void> _checkPhoneSoundStatus() async {
    final ns = getIt<NotificationService>();
    final status = await ns.checkSoundStatus();
    if (mounted) {
      setState(() {
        _isSoundMuted = status['isMuted'] ?? false;
        _isDndActive = status['dndMode'] ?? false;
        _isSilentMode = status['silentMode'] ?? false;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    // If Azan is enabled, make one last check for permissions
    final adhanState = context.read<AdhanCubit>().state;
    if (adhanState.salaahSettings.any((s) => s.isAzanEnabled)) {
      await checkAndRequestNotificationPermissions(context);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      if (!_isQadaEnabled) {
        context.read<DailyRemindersCubit>().toggleQadaEnabled();
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              MainNavigationScreen(showAddQadaOnStart: _isQadaEnabled),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 120;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentPage > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<LocationPrayerCubit, LocationPrayerState>(
            listenWhen: (prev, curr) =>
                curr.lastLocationStatus != null &&
                curr.lastLocationStatus != prev.lastLocationStatus,
            listener: (context, state) {
              LocationDialogHelper.showLocationStatusDialog(
                context,
                state.lastLocationStatus!,
              );
            },
            child: Stack(
              children: [
                BlocBuilder<LocationPrayerCubit, LocationPrayerState>(
                  builder: (context, locationState) {
                    return BlocBuilder<AdhanCubit, AdhanState>(
                      builder: (context, adhanState) {
                        return PageView(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentPage = index);
                            if (index == 2) {
                              final state = context.read<LocationPrayerCubit>().state;
                              if (state.latitude == null && state.longitude == null) {
                                context.read<LocationPrayerCubit>().refreshLocation();
                              }
                            } else if (index == 3) {
                              _checkPhoneSoundStatus();
                            }
                          },
                          children: [
                            _AnimatedPageTransition(
                              child: _OnboardingPage(
                                title: l10n.onboardingTitle1,
                                description: l10n.onboardingDesc1,
                                icon: Icons.auto_graph_rounded,
                                bottomPadding: bottomPadding,
                              ),
                            ),
                            _AnimatedPageTransition(
                              child: _OnboardingPage(
                                title: l10n.onboardingTitle2,
                                description: l10n.onboardingDesc2,
                                icon: Icons.history_rounded,
                                bottomPadding: bottomPadding,
                              ),
                            ),
                            _AnimatedPageTransition(
                              child: _LocationPrayerPage(
                                state: locationState,
                                bottomPadding: bottomPadding,
                              ),
                            ),
                            _AnimatedPageTransition(
                              child: _AzanSelectionPage(
                                state: adhanState,
                                isDownloading: _isDownloading,
                                onDownloadingChanged: (val) =>
                                    setState(() => _isDownloading = val),
                                downloadedVoices: _downloadedVoices,
                                onVoiceDownloaded: (val) {
                                  setState(() {
                                    _downloadedVoices.add(val);
                                  });
                                },
                                isOffline: _isOffline,
                                isSoundMuted: _isSoundMuted,
                                isDndActive: _isDndActive,
                                isSilentMode: _isSilentMode,
                                onRefreshSoundStatus: _checkPhoneSoundStatus,
                                bottomPadding: bottomPadding,
                              ),
                            ),
                            _AnimatedPageTransition(
                              child: _QadaSelectionPage(
                                isEnabled: _isQadaEnabled,
                                onChanged: (val) =>
                                    setState(() => _isQadaEnabled = val),
                                bottomPadding: bottomPadding,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
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
                                  ? colorScheme.secondary
                                  : (textTheme.bodyMedium?.color ?? colorScheme.onSurface).withValues(alpha: 0.3),
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
                          onPressed: _isDownloading
                              ? null
                              : (_currentPage == _totalPages - 1
                                    ? _completeOnboarding
                                    : () => _pageController.nextPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      )),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                          child: _isDownloading
                              ? SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: colorScheme.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _currentPage == _totalPages - 1
                                      ? l10n.getStarted
                                      : l10n.next,
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
                Positioned(
                  top: 16.0,
                  left: 16.0,
                  right: 16.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _currentPage > 0
                          ? IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded),
                              color: colorScheme.onSurface,
                              onPressed: _isDownloading
                                  ? null
                                  : () {
                                      _pageController.previousPage(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                            )
                          : const SizedBox.shrink(),
                      _currentPage < _totalPages - 1
                          ? TextButton(
                              onPressed: _isDownloading ? null : _completeOnboarding,
                              child: Text(
                                l10n.skipOnboarding,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationPrayerPage extends StatelessWidget {
  final LocationPrayerState state;
  final double bottomPadding;

  const _LocationPrayerPage({required this.state, required this.bottomPadding});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<LocationPrayerCubit>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.0, 40.0, 24.0, bottomPadding),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on_rounded,
              size: 64.0,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32.0),
          Text(
            l10n.prayerSettings,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: colorScheme.onSurface,
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            l10n.locationDesc,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: textTheme.bodyMedium?.color ?? colorScheme.onSurface.withValues(alpha: 0.7),
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
            options: {'shafi': l10n.shafiMadhab, 'hanafi': l10n.hanafiMadhab},
            onChanged: (val) => cubit.updateMadhab(val!),
          ),
        ],
      ),
    );
  }
}

class _AzanSelectionPage extends StatelessWidget {
  final AdhanState state;
  final bool isDownloading;
  final ValueChanged<bool> onDownloadingChanged;
  final Set<String> downloadedVoices;
  final ValueChanged<String> onVoiceDownloaded;
  final bool isOffline;
  final bool isSoundMuted;
  final bool isDndActive;
  final bool isSilentMode;
  final VoidCallback onRefreshSoundStatus;
  final double bottomPadding;

  const _AzanSelectionPage({
    required this.state,
    required this.isDownloading,
    required this.onDownloadingChanged,
    required this.downloadedVoices,
    required this.onVoiceDownloaded,
    required this.isOffline,
    required this.isSoundMuted,
    required this.isDndActive,
    required this.isSilentMode,
    required this.onRefreshSoundStatus,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<AdhanCubit>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isAzanEnabled = state.salaahSettings.any((s) => s.isAzanEnabled);
    final currentSound = state.salaahSettings.isNotEmpty
        ? state.salaahSettings.first.azanSound
        : null;
    final String? resolvedKey = _getDisplayName(currentSound);
    final bool isVoiceDownloaded = resolvedKey == null || downloadedVoices.contains(resolvedKey);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.0, 40.0, 24.0, bottomPadding),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active_rounded,
              size: 64.0,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32.0),
          Text(
            l10n.azanSettings,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: colorScheme.onSurface,
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.enableAzan,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: isAzanEnabled
                        ? colorScheme.secondary
                        : (textTheme.bodyMedium?.color ?? colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                ),
                CustomToggle(
                  value: isAzanEnabled,
                  onChanged: (val) async {
                    if (val) {
                      final granted =
                          await (context
                                      .findAncestorStateOfType<
                                        _OnboardingScreenState
                                      >()
                                  as _OnboardingScreenState)
                              .checkAndRequestNotificationPermissions(context);
                      if (!granted) return;
                    }
                    cubit.updateAllAzanEnabled(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.showSalahCountdownNotification,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          color: state.showSalahCountdownNotification
                              ? colorScheme.secondary
                              : (textTheme.bodyMedium?.color ??
                                  colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.showSalahCountdownNotificationDesc,
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                CustomToggle(
                  value: state.showSalahCountdownNotification,
                  onChanged: (val) async {
                    if (val) {
                      final granted =
                          await (context
                                      .findAncestorStateOfType<
                                        _OnboardingScreenState
                                      >()
                                  as _OnboardingScreenState)
                              .checkAndRequestNotificationPermissions(context);
                      if (!granted) return;
                    }
                    cubit.toggleShowSalahCountdownNotification(val);
                  },
                ),
              ],
            ),
          ),
          if (isAzanEnabled && isSoundMuted) ...[
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.volume_off_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDndActive && isSilentMode
                              ? l10n.phoneMutedTitleBoth
                              : isDndActive
                                  ? l10n.phoneMutedTitleDnd
                                  : l10n.phoneMutedTitleSilent,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.phoneMutedDesc,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: Colors.orange.shade900,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    onPressed: onRefreshSoundStatus,
                  ),
                ],
              ),
            ),
          ],
          if (isAzanEnabled) ...[
            const SizedBox(height: 16.0),
            _SettingsDropdownSelector(
              label: l10n.azanVoice,
              value: _getDisplayName(currentSound) ?? l10n.defaultVal,
              downloadedKeys: downloadedVoices,
              isDownloading: isDownloading,
              options: {
                l10n.defaultVal: l10n.defaultVal,
                ...VoiceDownloadService.azanVoices.map(
                  (k, v) => MapEntry(k, k),
                ),
              },
              onChanged: (val) async {
                if (val == null || val == l10n.defaultVal) {
                  cubit.updateAllAzanSound(null);
                  return;
                }

                // Already downloaded — select immediately
                if (downloadedVoices.contains(val)) {
                  cubit.updateAllAzanSound(val);
                  return;
                }

                // Not downloaded — start download flow immediately
                // to disable the UI during async operations
                onDownloadingChanged(true);

                try {
                  final hasNet = await getIt<ConnectivityService>().hasNetwork();
                  if (!hasNet) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.noInternetConnection),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                    return;
                  }

                  final downloader = getIt<VoiceDownloadService>();
                  final path = await downloader.downloadAzan(val);

                  if (path != null) {
                    onVoiceDownloaded(val);
                    cubit.updateAllAzanSound(val);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.azanDownloadError),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  debugPrint('Onboarding: Error selecting azan: $e');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.azanDownloadError),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } finally {
                  onDownloadingChanged(false);
                }
              },
            ),
            if (isOffline && !isVoiceDownloaded) ...[
              const SizedBox(height: 8.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.offlineVoiceSelectionHint,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16.0),
            TextButton.icon(
              onPressed: (isDownloading || !isVoiceDownloaded)
                  ? null
                  : () async {
                      final ns = getIt<NotificationService>();
                      if (!await ns.requestPermissions()) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.errorOccurred)),
                          );
                        }
                        return;
                      }
                      final soundStatus = await ns.checkSoundStatus();
                      if (soundStatus['isMuted'] == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              soundStatus['dndMode'] == true && soundStatus['silentMode'] == true
                                  ? l10n.phoneMutedTitleBoth
                                  : soundStatus['dndMode'] == true
                                      ? l10n.phoneMutedTitleDnd
                                      : l10n.phoneMutedTitleSilent,
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                      await ns.testAzan(Salaah.fajr, currentSound);
                    },
              icon: const Icon(Icons.play_circle_filled_rounded),
              label: Text(l10n.testAzan),
              style: TextButton.styleFrom(foregroundColor: colorScheme.secondary),
            ),
          ],
        ],
      ),
    );
  }

  String? _getDisplayName(String? path) {
    if (path == null || path == 'default') return null;

    // Check if it's already a key
    if (VoiceDownloadService.azanVoices.containsKey(path)) return path;

    // Fallback: Resolve key from path (for backward compatibility)
    final fileName = path.split(Platform.isWindows ? '\\' : '/').last;
    for (var entry in VoiceDownloadService.azanVoices.entries) {
      final uri = Uri.parse(entry.value);
      if (fileName == 'voice_${uri.pathSegments.last}' ||
          path.contains(
            entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_'),
          )) {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardTheme.color ?? colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: textTheme.bodyMedium?.color ?? colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.refresh_rounded,
              size: 20,
              color: textTheme.bodyMedium?.color ?? colorScheme.onSurface.withValues(alpha: 0.7),
            ),
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
  final Set<String> downloadedKeys;
  final bool isDownloading;

  const _SettingsDropdownSelector({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.downloadedKeys = const {},
    this.isDownloading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: textTheme.bodyMedium?.color ?? colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: options.containsKey(value) ? value : options.keys.first,
              isExpanded: true,
              icon: isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: colorScheme.secondary,
                    ),
              items: options.entries.map((e) {
                final isDownloaded = downloadedKeys.contains(e.key);
                return DropdownMenuItem(
                  value: e.key,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.value,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isDownloaded)
                        Icon(
                          Icons.cloud_done_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: isDownloading ? null : onChanged,
            ),
          ),
          if (isDownloading) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                AppLocalizations.of(context)!.downloadingVoice,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.0, 40.0, 24.0, bottomPadding),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 64.0,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32.0),
          Text(
            l10n.qadaOnboardingTitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: colorScheme.onSurface,
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            l10n.qadaOnboardingDesc,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: textTheme.bodyMedium?.color ?? colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 16.0,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEnabled ? l10n.enableQada : l10n.disableQada,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: isEnabled
                        ? colorScheme.secondary
                        : (textTheme.bodyMedium?.color ?? colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                ),
                CustomToggle(value: isEnabled, onChanged: onChanged),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.0, 40.0, 24.0, bottomPadding),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 64.0, color: colorScheme.primary),
          ),
          const SizedBox(height: 32.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.amiri(
              color: colorScheme.onSurface,
              fontSize: 28.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            description,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: textTheme.bodyMedium?.color ?? colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 16.0,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedPageTransition extends StatefulWidget {
  final Widget child;
  const _AnimatedPageTransition({required this.child});

  @override
  State<_AnimatedPageTransition> createState() => _AnimatedPageTransitionState();
}

class _AnimatedPageTransitionState extends State<_AnimatedPageTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}
