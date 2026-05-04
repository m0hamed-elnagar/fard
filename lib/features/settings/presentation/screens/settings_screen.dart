import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/mixins/notification_permission_mixin.dart';
import 'package:fard/core/services/location_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/core/theme/theme_presets.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/location_prayer_state.dart';
import 'package:fard/features/settings/presentation/screens/reminders_settings_screen.dart';
import 'package:fard/features/settings/presentation/widgets/appearance_section.dart';
import 'package:fard/features/settings/presentation/widgets/azkar_section.dart';
import 'package:fard/features/settings/presentation/widgets/general_section.dart';
import 'package:fard/features/settings/presentation/widgets/location_section.dart';
import 'package:fard/features/settings/presentation/widgets/widget_preview_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with NotificationPermissionMixin {
  bool _canScheduleExactAlarms = true;

  @override
  void initState() {
    super.initState();
    context.read<AzkarBloc>().add(const AzkarEvent.loadCategories());
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final notificationService = getIt<NotificationService>();
    final diagnosticResults = await notificationService.runDiagnostics();

    if (mounted) {
      setState(() {
        _canScheduleExactAlarms =
            diagnosticResults['exact_alarm_permission'] ?? true;
      });
    }
  }

  void _handleLocationStatus(
    BuildContext context,
    LocationStatus status,
    AppLocalizations l10n,
  ) {
    if (status == LocationStatus.success) return;

    String title = '';
    String desc = '';
    String primaryBtnLabel = l10n.tryAgain;
    VoidCallback onPrimary = () =>
        context.read<LocationPrayerCubit>().refreshLocation();

    switch (status) {
      case LocationStatus.serviceDisabled:
        title = l10n.locationDisabledTitle;
        desc = l10n.locationDisabledDesc;
        primaryBtnLabel = l10n.enableGPS;
        onPrimary = () =>
            context.read<LocationPrayerCubit>().openLocationSettings();
        break;
      case LocationStatus.denied:
        title = l10n.locationDeniedTitle;
        desc = l10n.locationDeniedDesc;
        break;
      case LocationStatus.deniedForever:
        title = l10n.locationDeniedForeverTitle;
        desc = l10n.locationDeniedForeverDesc;
        primaryBtnLabel = l10n.openSettings;
        onPrimary = () => context.read<LocationPrayerCubit>().openAppSettings();
        break;
      default:
        title = l10n.errorOccurred;
        desc = l10n.errorOccurred;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        ),
        content: Text(desc, style: GoogleFonts.amiri()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.later),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onPrimary();
            },
            child: Text(primaryBtnLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: context.onSurfaceColor,
        centerTitle: true,
      ),
      body: BlocListener<LocationPrayerCubit, LocationPrayerState>(
        listenWhen: (prev, curr) =>
            curr.lastLocationStatus != null &&
            curr.lastLocationStatus != prev.lastLocationStatus,
        listener: (context, state) =>
            _handleLocationStatus(context, state.lastLocationStatus!, l10n),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 40.0),
          children: [
            if (!_canScheduleExactAlarms)
              _buildWarningCard(
                l10n.exactAlarmWarningTitle,
                l10n.exactAlarmWarningDesc,
                Icons.warning_amber_rounded,
                actionLabel: l10n.openSettings,
                onAction: () =>
                    getIt<NotificationService>().openNotificationSettings(),
              ),

            // Section 1: Appearance
            const AppearanceSection(),

            BlocBuilder<LocationPrayerCubit, LocationPrayerState>(
              builder: (context, state) {
                return WidgetPreviewSection(
                  localeCode: Localizations.localeOf(context).languageCode,
                  presets: ThemePresets.all,
                );
              },
            ),

            // Section 3: Reminders & Notifications (Clickable Card)
            _buildSectionTile(
              title: l10n.remindersNotifications,
              subtitle: l10n.azanSettingsDesc,
              icon: Icons.notifications_active_rounded,
              accentColor: context.tertiaryColor,
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RemindersSettingsScreen(),
                  ),
                );
              },
            ),

            // Section 4: Azkar
            const AzkarSection(),

            // Section 5: General
            const GeneralSection(),

            // Section 6: Data & Location
            const DataAndLocationSection(),

            // Debug: Widget Refresh Section (only in debug mode)
            if (!kReleaseMode) ...[
              _buildDebugWidgetSection(context, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDebugWidgetSection(BuildContext context, AppLocalizations l10n) {
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.errorColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.bug_report_rounded,
                      color: context.errorColor, size: 22),
                ),
                const SizedBox(width: 16),
                Text(
                  'Debug: Widget',
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
              children: [
                Text(
                  'Force refresh the home screen widget. Use this for testing.',
                  style: TextStyle(
                    color: context.onSurfaceVariantColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Refresh Widget'),
                  trailing: ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      getIt<WidgetUpdateService>().updateWidget();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Widget refresh triggered!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard(
    String title,
    String desc,
    IconData icon, {
    bool isSmall = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.errorColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: isSmall
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              Icon(icon, color: context.errorColor, size: isSmall ? 20 : 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: context.errorColor,
                        ),
                      ),
                    Text(desc, style: TextStyle(fontSize: isSmall ? 12 : 13)),
                  ],
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onAction, child: Text(actionLabel)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.amiri(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: context.onSurfaceColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.onSurfaceVariantColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: context.onSurfaceVariantColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
