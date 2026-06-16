import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toggle.dart';
import '../../../../core/widgets/fard_list_tile.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:fard/features/audio/presentation/screens/offline_audio_screen.dart';
import '../blocs/daily_reminders_cubit.dart';
import '../blocs/daily_reminders_state.dart';
import '../screens/privacy_policy_screen.dart';

class GeneralSection extends StatefulWidget {
  final bool initiallyExpanded;
  const GeneralSection({super.key, this.initiallyExpanded = false});

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
        _version = '${info.version}+${info.buildNumber}';
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
          title: l10n.aboutApp,
          subtitle: l10n.aboutAppDesc,
          icon: Icons.info_outline_rounded,
          onTap: () {
            HapticFeedback.lightImpact();
            _showAboutDialog(context, l10n);
          },
        ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.mosque_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              l10n.aboutAppTitle,
              style: GoogleFonts.amiri(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.aboutAppMessage,
              style: GoogleFonts.amiri(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.developedBy,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version $_version',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                l10n.contactDevHint,
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(
                  context,
                  icon: SvgPicture.string(
                    _whatsappSvg,
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
                  ),
                  tooltip: l10n.whatsapp,
                  onTap: () => _launchUrl('https://wa.me/201017713257'),
                  color: Colors.green,
                ),
                const SizedBox(width: 20),
                _buildSocialIcon(
                  context,
                  icon: Icon(
                    Icons.email_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  tooltip: l10n.contactUs,
                  onTap: () => _launchUrl('mailto:mohamed.3lnagar@gmail.com?subject=Fard%20App%20Feedback'),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              MaterialLocalizations.of(context).closeButtonLabel,
            ),
          ),
        ],
      ),
    );
  }

  static const String _whatsappSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
  <path d="M13.601 2.326A7.85 7.85 0 0 0 7.994 0C3.627 0 .068 3.558.064 7.926c0 1.399.366 2.76 1.057 3.965L0 16l4.204-1.102a7.9 7.9 0 0 0 3.79.965h.004c4.368 0 7.926-3.558 7.93-7.93A7.9 7.9 0 0 0 13.6 2.326zM7.994 14.521a6.6 6.6 0 0 1-3.356-.92l-.24-.144-2.494.654.666-2.433-.156-.251a6.56 6.56 0 0 1-1.007-3.505c0-3.626 2.957-6.584 6.591-6.584a6.56 6.56 0 0 1 4.66 1.931 6.56 6.56 0 0 1 1.928 4.66c-.004 3.639-2.961 6.592-6.592 6.592m3.615-4.934c-.197-.099-1.17-.578-1.353-.646-.182-.065-.315-.099-.445.099-.133.197-.513.646-.627.775-.114.133-.232.148-.43.05-.197-.1-.836-.308-1.592-.985-.59-.525-.985-1.175-1.103-1.372-.114-.198-.011-.304.088-.403.087-.088.197-.232.296-.346.1-.114.133-.198.198-.33.065-.134.034-.248-.015-.347-.05-.099-.445-1.076-.612-1.47-.16-.389-.323-.335-.445-.34-.114-.007-.247-.007-.38-.007a.73.73 0 0 0-.529.247c-.182.198-.691.677-.691 1.654s.71 1.916.81 2.049c.098.133 1.394 2.132 3.383 2.992.47.205.84.326 1.129.418.475.152.904.129 1.246.08.38-.058 1.171-.48 1.338-.943.164-.464.164-.86.114-.943-.049-.084-.182-.133-.38-.232"/>
</svg>
''';

  Widget _buildSocialIcon(
    BuildContext context, {
    required Widget icon,
    required String tooltip,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1.0,
            ),
          ),
          child: icon,
        ),
      ),
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
      onTap: onTap,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }
}
