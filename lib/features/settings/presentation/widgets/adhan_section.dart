import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/voice_download_service.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/widgets/custom_toggle.dart';
import '../../../../core/widgets/fard_list_tile.dart';
import '../../../../core/widgets/expandable_section_card.dart';
import '../../../../core/mixins/notification_permission_mixin.dart';
import '../../../prayer_tracking/domain/salaah.dart';
import '../../domain/salaah_settings.dart';
import '../blocs/adhan_cubit.dart';
import '../blocs/adhan_state.dart';

enum RingerStatus { normal, silent, dnd, silentAndDnd }

class AdhanSection extends StatefulWidget {
  const AdhanSection({super.key});

  @override
  State<AdhanSection> createState() => _AdhanSectionState();
}

class _AdhanSectionState extends State<AdhanSection>
    with NotificationPermissionMixin, WidgetsBindingObserver {
  bool _isDownloading = false;
  Set<String> _downloadedVoices = {};
  bool _isOffline = false;
  StreamSubscription? _connectivitySubscription;
  bool _dndBannerDismissed = false;
  RingerStatus _ringerStatus = RingerStatus.normal;
  bool _pendingVoiceUpdate = false;
  String? _optimisticVoiceKey;
  bool _isLoadingVoices = true;
  bool _areIndividualSettingsExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Synchronously read pre-resolved SharedPreferences
    final prefs = getIt<SharedPreferences>();
    _dndBannerDismissed = prefs.getBool('dnd_banner_dismissed') ?? false;

    _isLoadingVoices = true;
    _loadDownloadedVoices().then((_) {
      if (mounted) {
        setState(() {
          _isLoadingVoices = false;
        });
      }
    });

    _refreshRingerStatus();
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
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshRingerStatus();
      context.read<AdhanCubit>().refreshPermissions();
    }
  }

  Future<void> _refreshRingerStatus() async {
    final ns = getIt<NotificationService>();
    final status = await ns.checkSoundStatus();
    if (mounted) {
      setState(() {
        _ringerStatus = _mapToRingerStatus(status);
      });
    }
  }

  RingerStatus _mapToRingerStatus(Map<String, bool> status) {
    final silent = status['silentMode'] ?? false;
    final dnd = status['dndMode'] ?? false;
    if (silent && dnd) {
      return RingerStatus.silentAndDnd;
    } else if (dnd) {
      return RingerStatus.dnd;
    } else if (silent) {
      return RingerStatus.silent;
    } else {
      return RingerStatus.normal;
    }
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

  String _getVoiceBaseName(String voiceKey, AppLocalizations l10n) {
    final parts = voiceKey.split(' - ');
    return l10n.localeName == 'ar'
        ? (parts.length > 1 ? parts[1] : parts[0])
        : parts[0];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AdhanCubit, AdhanState>(
      builder: (context, state) {
        final cubit = context.read<AdhanCubit>();
        final bool anyAzanEnabled = state.salaahSettings.any(
          (s) => s.isAzanEnabled,
        );
        final String? commonVoice = _getCommonVoice(state.salaahSettings);
        final String? displayedVoiceKey = _pendingVoiceUpdate
            ? _optimisticVoiceKey
            : _resolveVoiceKey(commonVoice);
        final bool notificationsDisabled = !state.notificationsEnabled;
        final bool exactAlarmsDisabled = !state.exactAlarmsEnabled;
        final bool isVoiceDownloaded = displayedVoiceKey == null || _downloadedVoices.contains(displayedVoiceKey);

        return ExpandableSectionCard(
          title: l10n.azan,
          icon: Icons.volume_up_rounded,
          accentColor: context.primaryColor,
          initiallyExpanded: true,
          children: [
            if (notificationsDisabled)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.notificationsRequiredDesc,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          final granted =
                              await checkAndRequestNotificationPermissions(
                            context,
                          );
                          if (granted) {
                            cubit.refreshPermissions();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(l10n.enable),
                      ),
                    ),
                  ],
                ),
              ),
            if (!notificationsDisabled && exactAlarmsDisabled && anyAzanEnabled)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.exactAlarmPermissionRequiredDesc,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          await getIt<NotificationService>().requestExactAlarmsPermission();
                          final currentlyGranted = await getIt<NotificationService>().canScheduleExactNotifications();
                          if (currentlyGranted) {
                            cubit.toggleUseExactAlarmClock(true);
                          }
                          cubit.refreshPermissions();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(l10n.grantPermission),
                      ),
                    ),
                  ],
                ),
              ),
            // Standalone master switch
            _buildToggleItem(
              title: l10n.enableAzan,
              value: anyAzanEnabled,
              onChanged: (val) async {
                if (val && (notificationsDisabled || exactAlarmsDisabled)) {
                  if (!context.mounted) return;
                  if (notificationsDisabled) {
                    final granted = await checkAndRequestNotificationPermissions(
                      context,
                    );
                    if (!granted) return;
                    cubit.refreshPermissions();
                  }
                  if (exactAlarmsDisabled) {
                    await getIt<NotificationService>().requestExactAlarmsPermission();
                    final currentlyGranted = await getIt<NotificationService>().canScheduleExactNotifications();
                    if (!currentlyGranted) return;
                    cubit.toggleUseExactAlarmClock(true);
                    cubit.refreshPermissions();
                  }
                }
                cubit.updateAllAzanEnabled(val);
              },
              context: context,
            ),
            if (anyAzanEnabled) ...[
              const SizedBox(height: 12),
              // Alarm Precision Group
              _buildToggleGroup(
                context,
                l10n.alarmPrecision,
                [
                  _buildToggleItem(
                    title: l10n.useExactAlarmClock,
                    subtitle: l10n.useExactAlarmClockDesc,
                    value: state.useExactAlarmClock,
                    onChanged: (val) async {
                      if (val) {
                        final exactAlarms = await getIt<NotificationService>().canScheduleExactNotifications();
                        if (!exactAlarms) {
                          final granted = await getIt<NotificationService>().requestExactAlarmsPermission();
                          if (!granted) return;
                          cubit.refreshPermissions();
                        }
                      }
                      cubit.toggleUseExactAlarmClock(val);
                    },
                    context: context,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Quiet Hours Group
              _buildToggleGroup(
                context,
                l10n.quietHours,
                [
                  _buildToggleItem(
                    title: l10n.respectSilentDndModeTitle,
                    subtitle: l10n.respectSilentDndModeDesc,
                    value: state.respectSilentDndMode,
                    onChanged: (val) {
                      cubit.toggleRespectSilentDndMode(val);
                    },
                    context: context,
                  ),
                  _RingerStatusChip(
                    status: _ringerStatus,
                    respectDndEnabled: state.respectSilentDndMode,
                  ),
                  if (state.respectSilentDndMode && !_dndBannerDismissed)
                    _InfoBanner(
                      text: l10n.respectSilentDndModeBannerText,
                      onDismiss: () async {
                        final prefs = getIt<SharedPreferences>();
                        await prefs.setBool('dnd_banner_dismissed', true);
                        if (mounted) setState(() => _dndBannerDismissed = true);
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
              _buildVoiceDropdown(context, commonVoice, l10n, (val) {
                cubit.updateAllAzanSound(val);
              }),
              if (_isOffline && !isVoiceDownloaded) ...[
                const SizedBox(height: 8),
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
              const SizedBox(height: 8),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: (_isDownloading || !isVoiceDownloaded)
                          ? null
                          : () async {
                              final granted =
                                  await checkAndRequestNotificationPermissions(
                                context,
                              );
                              if (!granted) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.notificationsRequiredDesc),
                                      behavior: SnackBarBehavior.floating,
                                      action: SnackBarAction(
                                        label: l10n.enable,
                                        onPressed: () =>
                                            getIt<NotificationService>()
                                                .openNotificationSettings(),
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }

                              final ns = getIt<NotificationService>();
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

                              await ns.testAzan(
                                Salaah.fajr,
                                displayedVoiceKey,
                              );
                            },
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: Text(l10n.testAzan),
                    ),
                    if (kDebugMode)
                      OutlinedButton.icon(
                        onPressed: (_isDownloading || !isVoiceDownloaded)
                            ? null
                            : () async {
                                final granted =
                                    await checkAndRequestNotificationPermissions(
                                  context,
                                );
                                if (!granted) return;

                                final ns = getIt<NotificationService>();
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

                                await ns.testAzan(
                                  Salaah.fajr,
                                  displayedVoiceKey,
                                  isTest: false,
                                );
                              },
                        icon: const Icon(Icons.bug_report_rounded),
                        label: const Text('Test Muting (Debug)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 24),
              InkWell(
                onTap: () {
                  setState(() {
                    _areIndividualSettingsExpanded = !_areIndividualSettingsExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: context.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.individualSettings,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: context.onSurfaceColor,
                            ),
                          ),
                        ],
                      ),
                      AnimatedRotation(
                        turns: _areIndividualSettingsExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: context.onSurfaceVariantColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_areIndividualSettingsExpanded) ...[
                const SizedBox(height: 8),
                ...state.salaahSettings.map(
                  (s) => _buildIndividualAzanTile(context, s, l10n),
                ),
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildIndividualAzanTile(
    BuildContext context,
    SalaahSettings s,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<AdhanCubit>();
    return FardListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        _getLocalizedSalaahName(s.salaah, l10n),
        style: TextStyle(color: context.onSurfaceColor),
      ),
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.tune_rounded,
            size: 14,
            color: context.primaryColor,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              s.azanSound == null ? l10n.defaultVal : _getVoiceBaseName(s.azanSound!, l10n),
              style: TextStyle(
                fontSize: 12,
                color: context.onSurfaceVariantColor,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      trailing: CustomToggle(
        value: s.isAzanEnabled,
        onChanged: (val) {
          cubit.updateSalaahSettings(s.copyWith(isAzanEnabled: val));
        },
      ),
      onTap: () => _showIndividualAzanBottomSheet(context, s, l10n),
    );
  }

  void _showIndividualAzanBottomSheet(
    BuildContext context,
    SalaahSettings initialSettings,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<AdhanCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<AdhanCubit, AdhanState>(
          builder: (context, state) {
            final s = state.salaahSettings.firstWhere(
              (setting) => setting.salaah == initialSettings.salaah,
              orElse: () => initialSettings,
            );
            return Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                top: 16,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: context.outlineColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${l10n.localeName == 'ar' ? 'صوت الأذان لـ' : 'Adhan voice for '}${_getLocalizedSalaahName(s.salaah, l10n)}',
                            style: GoogleFonts.amiri(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: context.onSurfaceColor,
                            ),
                          ),
                        ),
                        CustomToggle(
                          value: s.isAzanEnabled,
                          onChanged: (val) {
                            cubit.updateSalaahSettings(s.copyWith(isAzanEnabled: val));
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildVoiceDropdown(context, s.azanSound, l10n, (val) {
                      cubit.updateSalaahSettings(s.copyWith(azanSound: val));
                    }),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    BuildContext? context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: context?.onSurfaceColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: (context?.onSurfaceColor ?? Colors.grey).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        CustomToggle(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildToggleGroup(
    BuildContext context,
    String title,
    List<Widget> children, {
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.surfaceContainerHighestColor.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.outlineColor.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: context.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  String? _getCommonVoice(List<SalaahSettings> settings) {
    if (settings.isEmpty) return null;
    final first = settings.first.azanSound;
    return settings.every((s) => s.azanSound == first) ? first : null;
  }

  Widget _buildVoiceDropdown(
    BuildContext context,
    String? currentVoice,
    AppLocalizations l10n,
    ValueChanged<String?> onChanged,
  ) {
    if (_isLoadingVoices) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: context.surfaceContainerHighestColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            children: [
              const SizedBox(width: 16),
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.loadingVoices,
                style: TextStyle(
                  color: context.onSurfaceColor.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final String? displayedVoiceKey = _pendingVoiceUpdate
        ? _optimisticVoiceKey
        : _resolveVoiceKey(currentVoice);

    return DropdownButtonFormField<String?>(
      key: ValueKey(displayedVoiceKey),
      initialValue: displayedVoiceKey,
      isExpanded: true,
      icon: _isDownloading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : null,
      decoration: InputDecoration(
        labelText: l10n.azanVoice,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: context.surfaceContainerHighestColor,
        helperText: _isDownloading ? l10n.downloadingVoice : null,
        helperStyle: TextStyle(color: context.primaryColor),
      ),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.defaultVal)),
        ...VoiceDownloadService.azanVoices.keys.map((v) {
          final baseName = _getVoiceBaseName(v, l10n);
          final isDownloaded = _downloadedVoices.contains(v);
          
          return DropdownMenuItem(
            value: v,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    baseName,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isDownloaded)
                  Icon(
                    Icons.cloud_done_rounded,
                    size: 18,
                    color: context.primaryColor,
                  ),
              ],
            ),
          );
        }),
      ],
      onChanged: _isDownloading
          ? null
          : (val) async {
              if (val == null) {
                setState(() {
                  _pendingVoiceUpdate = false;
                  _optimisticVoiceKey = null;
                });
                onChanged(null);
                return;
              }

              if (_downloadedVoices.contains(val)) {
                setState(() {
                  _pendingVoiceUpdate = false;
                  _optimisticVoiceKey = null;
                });
                onChanged(val);
                return;
              }

              setState(() {
                _pendingVoiceUpdate = true;
                _optimisticVoiceKey = val;
                _isDownloading = true;
              });

              try {
                final hasNet = await getIt<ConnectivityService>().hasNetwork();
                if (!hasNet) {
                  if (mounted) {
                    setState(() {
                      _isDownloading = false;
                    });
                  }
                  return;
                }

                if (!mounted) return;
                final downloader = getIt<VoiceDownloadService>();
                final path = await downloader.downloadAzan(val);

                if (path != null) {
                  if (mounted) {
                    setState(() {
                      _downloadedVoices.add(val);
                      _pendingVoiceUpdate = false;
                      _optimisticVoiceKey = null;
                    });
                  }
                  onChanged(val);
                } else {
                  if (mounted) {
                    setState(() {
                      _pendingVoiceUpdate = false;
                      _optimisticVoiceKey = null;
                    });
                  }
                  if (mounted && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.azanDownloadError),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              } catch (e) {
                debugPrint('AdhanSection: Error selecting azan: $e');
                if (mounted) {
                  setState(() {
                    _pendingVoiceUpdate = false;
                    _optimisticVoiceKey = null;
                  });
                }
                if (mounted && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.azanDownloadError),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isDownloading = false);
                }
              }
            },
    );
  }

  String? _resolveVoiceKey(String? path) {
    if (path == null) return null;
    for (var entry in VoiceDownloadService.azanVoices.entries) {
      if (path == entry.key) return entry.key;
      final uri = Uri.parse(entry.value);
      if (path.contains('voice_${uri.pathSegments.last}')) return entry.key;
      final sanitized = entry.key.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]'),
        '_',
      );
      if (path.contains('${sanitized}_azan.mp3')) return entry.key;
    }
    return null;
  }

  String _getLocalizedSalaahName(Salaah salaah, AppLocalizations l10n) {
    switch (salaah) {
      case Salaah.fajr:
        return l10n.fajr;
      case Salaah.dhuhr:
        return l10n.dhuhr;
      case Salaah.asr:
        return l10n.asr;
      case Salaah.maghrib:
        return l10n.maghrib;
      case Salaah.isha:
        return l10n.isha;
    }
  }
}

class _RingerStatusChip extends StatelessWidget {
  final RingerStatus status;
  final bool respectDndEnabled;

  const _RingerStatusChip({
    required this.status,
    required this.respectDndEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final IconData icon;
    final Color color;
    final String message;

    switch (status) {
      case RingerStatus.normal:
        icon = Icons.volume_up_rounded;
        color = Colors.green;
        message = l10n.ringerExplanationNormal;
        break;
      case RingerStatus.silent:
        icon = Icons.volume_mute_rounded;
        color = respectDndEnabled ? context.primaryColor : Colors.orange;
        message = respectDndEnabled
            ? l10n.ringerExplanationSilentToggleOn
            : l10n.ringerExplanationSilentToggleOff;
        break;
      case RingerStatus.dnd:
        icon = Icons.do_not_disturb_on_rounded;
        color = respectDndEnabled ? context.primaryColor : Colors.orange;
        message = respectDndEnabled
            ? l10n.ringerExplanationDndToggleOn
            : l10n.ringerExplanationDndToggleOff;
        break;
      case RingerStatus.silentAndDnd:
        icon = Icons.volume_off_rounded;
        color = respectDndEnabled ? context.primaryColor : Colors.orange;
        message = respectDndEnabled
            ? l10n.ringerExplanationBothToggleOn
            : l10n.ringerExplanationBothToggleOff;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final String text;
  final VoidCallback onDismiss;

  const _InfoBanner({
    required this.text,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: context.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: context.onSurfaceColor.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(
              Icons.close_rounded,
              color: context.onSurfaceColor.withValues(alpha: 0.6),
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
