import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/voice_download_service.dart';
import '../../../../core/widgets/custom_toggle.dart';
import '../../../../core/widgets/fard_list_tile.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<AdhanCubit, AdhanState>(
      builder: (context, state) {
        final cubit = context.read<AdhanCubit>();
        final bool allAzanEnabled = state.salaahSettings.every(
          (s) => s.isAzanEnabled,
        );
        final String? commonVoice = _getCommonVoice(state.salaahSettings);
        final bool notificationsDisabled =
            !state.notificationsEnabled || !state.exactAlarmsEnabled;

        return _buildSection(
          context,
          title: l10n.azan,
          icon: Icons.volume_up_rounded,
          accentColor: context.primaryColor,
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
              value: allAzanEnabled,
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
            if (allAzanEnabled) ...[
              const SizedBox(height: 16),
              _buildVoiceDropdown(context, commonVoice, l10n, (val) {
                cubit.updateAllAzanSound(val);
              }),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _isDownloading
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

                          await getIt<NotificationService>().testAzan(
                            Salaah.fajr,
                            commonVoice,
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
      onTap: () => _showIndividualAzanDialog(context, s, l10n),
    );
  }

  void _showIndividualAzanDialog(
    BuildContext context,
    SalaahSettings s,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<AdhanCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _getLocalizedSalaahName(s.salaah, l10n),
          style: TextStyle(color: context.onSurfaceColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVoiceDropdown(context, s.azanSound, l10n, (val) {
              cubit.updateSalaahSettings(s.copyWith(azanSound: val));
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? accentColor,
  }) {
    final effectiveAccentColor = accentColor ?? context.primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceContainerColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: context.outlineColor.withValues(alpha: 0.15),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: effectiveAccentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: effectiveAccentColor, size: 22),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: GoogleFonts.amiri(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: context.onSurfaceColor,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
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
      key: ValueKey(_resolveVoiceKey(currentVoice)),
      initialValue: _resolveVoiceKey(currentVoice),
      decoration: InputDecoration(
        labelText: l10n.azanVoice,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: context.surfaceContainerHighestColor,
      ),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.defaultVal)),
        ...VoiceDownloadService.azanVoices.keys.map((v) {
          final parts = v.split(' - ');
          final displayName = l10n.localeName == 'ar'
              ? (parts.length > 1 ? parts[1] : parts[0])
              : parts[0];
          return DropdownMenuItem(value: v, child: Text(displayName));
        }),
      ],
      onChanged: (val) async {
        if (val == null) {
          onChanged(null);
          return;
        }

        try {
          final downloader = getIt<VoiceDownloadService>();
          if (!(await downloader.isDownloaded(val))) {
            if (!mounted) return;
            setState(() => _isDownloading = true);
            final path = await downloader.downloadAzan(val);

            if (path != null) {
              onChanged(val);
            } else {
              if (mounted && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.azanDownloadError),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          } else {
            onChanged(val);
          }
        } catch (e) {
          debugPrint('AdhanSection: Error selecting azan: $e');
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
