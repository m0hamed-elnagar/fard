import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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

class AdhanSection extends StatefulWidget {
  const AdhanSection({super.key});

  @override
  State<AdhanSection> createState() => _AdhanSectionState();
}

class _AdhanSectionState extends State<AdhanSection>
    with NotificationPermissionMixin {
  bool _isDownloading = false;
  Set<String> _downloadedVoices = {};
  bool _isOffline = false;
  StreamSubscription? _connectivitySubscription;
  String? _dropdownValue;
  /// True when the user selected a non-downloaded voice while offline.
  /// Prevents the build method from overwriting _dropdownValue with cubit state.
  bool _hasUserOverride = false;

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
          // When back online, clear the override so the dropdown
          // syncs back to the cubit state.
          if (!isOffline) _hasUserOverride = false;
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
        if (!_isDownloading && !_hasUserOverride) {
          _dropdownValue = _resolveVoiceKey(commonVoice);
        }
        final bool notificationsDisabled =
            !state.notificationsEnabled || !state.exactAlarmsEnabled;
        final bool isVoiceDownloaded = _dropdownValue == null || _downloadedVoices.contains(_dropdownValue);

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
            _buildToggleItem(
              title: l10n.enableAzan,
              value: anyAzanEnabled,
              onChanged: (val) async {
                if (val && notificationsDisabled) {
                  if (!context.mounted) return;
                  final granted = await checkAndRequestNotificationPermissions(
                    context,
                  );
                  if (!granted) return;
                  cubit.refreshPermissions();
                }
                cubit.updateAllAzanEnabled(val);
              },
              context: context,
            ),
            if (anyAzanEnabled) ...[
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
                child: TextButton.icon(
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
                            _dropdownValue,
                          );
                        },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(l10n.testAzan),
                  style: TextButton.styleFrom(
                    foregroundColor: context.secondaryColor,
                  ),
                ),
              ),
              const Divider(height: 24),
              Text(
                l10n.individualSettings,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: context.onSurfaceColor,
                ),
              ),
              const SizedBox(height: 8),
              ...state.salaahSettings.map(
                (s) => _buildIndividualAzanTile(context, s, l10n),
              ),
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
    SalaahSettings s,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<AdhanCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
            Text(
              '${l10n.localeName == 'ar' ? 'صوت الأذان لـ' : 'Adhan voice for '}${_getLocalizedSalaahName(s.salaah, l10n)}',
              style: GoogleFonts.amiri(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.onSurfaceColor,
              ),
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
  }



  Widget _buildToggleItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    BuildContext? context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: context?.onSurfaceColor,
          ),
        ),
        CustomToggle(value: value, onChanged: onChanged),
      ],
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
    return DropdownButtonFormField<String?>(
      key: ValueKey(_dropdownValue),
      initialValue: _dropdownValue,
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
          final parts = v.split(' - ');
          final baseName = l10n.localeName == 'ar'
              ? (parts.length > 1 ? parts[1] : parts[0])
              : parts[0];
          
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
            _dropdownValue = null;
            _hasUserOverride = false;
          });
          onChanged(null);
          return;
        }

        // Already downloaded — select immediately, no download needed
        if (_downloadedVoices.contains(val)) {
          setState(() {
            _dropdownValue = val;
            _hasUserOverride = false;
          });
          onChanged(val);
          return;
        }

        // Not downloaded — sync dropdown state and start download flow.
        // Setting _isDownloading = true prevents the build method from
        // overwriting _dropdownValue during async operations.
        setState(() {
          _dropdownValue = val;
          _isDownloading = true;
        });

        try {
          final hasNet = await getIt<ConnectivityService>().hasNetwork();
          if (!hasNet) {
            // Keep _dropdownValue as the user's selection so the
            // offline hint shows and the Test Sound button stays disabled.
            if (mounted) {
              setState(() {
                _hasUserOverride = true;
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
                _dropdownValue = val;
                _hasUserOverride = false;
              });
            }
            onChanged(val);
          } else {
            if (mounted) {
              setState(() {
                _dropdownValue = _resolveVoiceKey(currentVoice);
                _hasUserOverride = false;
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
              _dropdownValue = _resolveVoiceKey(currentVoice);
              _hasUserOverride = false;
            });
          }
          if (mounted && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('حدث خطأ أثناء تحميل الأذان'),
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
