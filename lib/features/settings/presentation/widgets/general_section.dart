import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toggle.dart';
import '../../../../core/widgets/fard_list_tile.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:fard/features/audio/presentation/screens/offline_audio_screen.dart';
import '../blocs/daily_reminders_cubit.dart';
import '../blocs/daily_reminders_state.dart';
import 'dart:io';
import '../../../../core/di/injection.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/in_app_update_service.dart';
import '../../../../core/services/in_app_review_service.dart';
import '../screens/privacy_policy_screen.dart';
import 'about_dialog.dart';

class GeneralSection extends StatefulWidget {
  final bool initiallyExpanded;
  final bool isBatteryOptimizationIgnored;
  final bool isOemDevice;

  const GeneralSection({
    super.key,
    this.initiallyExpanded = false,
    required this.isBatteryOptimizationIgnored,
    required this.isOemDevice,
  });

  @override
  State<GeneralSection> createState() => _GeneralSectionState();
}

class _GeneralSectionState extends State<GeneralSection> {
  late bool _isExpanded;
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = info.version;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return _buildExpandableSection(
      context,
      title: l10n.generalSettings,
      icon: Icons.settings_rounded,
      accentColor: Colors.blueGrey,
      isExpanded: _isExpanded,
      onToggle: () => setState(() => _isExpanded = !_isExpanded),
      children: [
        if (Platform.isAndroid) ...[
          _buildActionTile(
            context,
            title: l10n.batteryOptimization,
            subtitle: widget.isBatteryOptimizationIgnored
                ? l10n.batteryUnrestricted
                : l10n.batteryOptimizationDesc,
            icon: Icons.battery_charging_full_rounded,
            trailing: widget.isBatteryOptimizationIgnored
                ? const Icon(Icons.check_circle_outline, color: Colors.green)
                : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: () async {
              HapticFeedback.lightImpact();
              if (widget.isBatteryOptimizationIgnored) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.batteryAlreadyUnrestricted),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else {
                _showInstructionDialog(
                  title: l10n.batteryInstructionTitle,
                  message: l10n.batteryInstructionDesc,
                  confirmLabel: l10n.disableRestrictions,
                  onConfirm: () async {
                    await getIt<NotificationService>().requestIgnoreBatteryOptimizations();
                  },
                );
              }
            },
          ),
          if (widget.isOemDevice) ...[
            const Divider(height: 1),
            _buildActionTile(
              context,
              title: l10n.autostartWarningTitle,
              subtitle: l10n.autostartSettingsDesc,
              icon: Icons.power_settings_new_rounded,
              onTap: () async {
                HapticFeedback.lightImpact();
                _showInstructionDialog(
                  title: l10n.autostartInstructionTitle,
                  message: l10n.autostartInstructionDesc,
                  confirmLabel: l10n.openSettings,
                  onConfirm: () async {
                    await getIt<NotificationService>().openAutostartSettings();
                  },
                );
              },
            ),
          ],
          const Divider(height: 1),
        ],
        BlocBuilder<DailyRemindersCubit, DailyRemindersState>(
          builder: (context, state) {
            return FardListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.analytics_outlined,
                color: context.onSurfaceVariantColor,
              ),
              title: Text(l10n.qadaTracker),
              subtitle: Text(l10n.qadaTrackerDesc),
              trailing: CustomToggle(
                value: state.isQadaEnabled,
                onChanged: (val) {
                  context.read<DailyRemindersCubit>().toggleQadaEnabled();
                },
              ),
            );
          },
        ),
        const Divider(height: 1),
        _buildActionTile(
          context,
          title: l10n.manageOfflineAudio,
          subtitle: l10n.downloadCenterDesc,
          icon: Icons.download_for_offline_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OfflineAudioScreen()),
            );
          },
        ),
        const Divider(height: 1),
        _buildActionTile(
          context,
          title: l10n.privacyPolicy,
          subtitle: l10n.privacyPolicyDesc,
          icon: Icons.security_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            );
          },
        ),
        const Divider(height: 1),
        _buildActionTile(
          context,
          title: l10n.rateApp,
          subtitle: l10n.rateAppDesc,
          icon: Icons.star_rate_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            if (getIt.isRegistered<InAppReviewService>()) {
              getIt<InAppReviewService>().openStoreListingManually();
            }
          },
        ),
        const Divider(height: 1),
        _buildActionTile(
          context,
          title: l10n.checkForUpdates,
          subtitle: l10n.checkForUpdatesDesc,
          icon: Icons.system_update_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            if (getIt.isRegistered<InAppUpdateService>()) {
              getIt<InAppUpdateService>().checkForUpdateManually(context);
            }
          },
        ),
        const Divider(height: 1),
        _buildActionTile(
          context,
          title: l10n.aboutApp,
          subtitle: l10n.aboutAppDesc,
          icon: Icons.info_outline_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            showAboutAppDialog(context, _version);
          },
        ),
      ],
    );
  }

  Widget _buildExpandableSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
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
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
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
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.amiri(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: context.onSurfaceColor,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
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
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return FardListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.onSurfaceVariantColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: context.onSurfaceVariantColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Future<void> _showInstructionDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            title,
            style: GoogleFonts.amiri(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Text(
                confirmLabel,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
