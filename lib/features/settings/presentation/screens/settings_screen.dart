import 'package:fard/core/services/export_import_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/features/settings/presentation/widgets/theme_editor_widget.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/location_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/core/widgets/custom_toggle.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/entities/custom_theme.dart';
import 'package:fard/features/settings/domain/entities/theme_preset.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/audio/presentation/screens/offline_audio_screen.dart';
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

class _SettingsScreenState extends State<SettingsScreen> {
  bool _canScheduleExactAlarms = true;

  @override
  void initState() {
    super.initState();
    context.read<AzkarBloc>().add(const AzkarEvent.loadCategories());
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final canSchedule = await getIt<NotificationService>()
        .canScheduleExactNotifications();
    if (mounted) {
      setState(() {
        _canScheduleExactAlarms = canSchedule;
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
        context.read<SettingsCubit>().refreshLocation();

    switch (status) {
      case LocationStatus.serviceDisabled:
        title = l10n.locationDisabledTitle;
        desc = l10n.locationDisabledDesc;
        primaryBtnLabel = l10n.enableGPS;
        onPrimary = () => context.read<SettingsCubit>().openLocationSettings();
        break;
      case LocationStatus.denied:
        title = l10n.locationDeniedTitle;
        desc = l10n.locationDeniedDesc;
        break;
      case LocationStatus.deniedForever:
        title = l10n.locationDeniedForeverTitle;
        desc = l10n.locationDeniedForeverDesc;
        primaryBtnLabel = l10n.openSettings;
        onPrimary = () => context.read<SettingsCubit>().openAppSettings();
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
      body: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (prev, curr) =>
            curr.lastLocationStatus != null &&
            curr.lastLocationStatus != prev.lastLocationStatus,
        listener: (context, state) =>
            _handleLocationStatus(context, state.lastLocationStatus!, l10n),
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, state) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              children: [
                if (!_canScheduleExactAlarms)
                  _buildWarningCard(
                    l10n.exactAlarmWarningTitle,
                    l10n.exactAlarmWarningDesc,
                    Icons.warning_amber_rounded,
                  ),
                _buildSection(
                  context,
                  title: l10n.locationSettings,
                  icon: Icons.location_on_rounded,
                  children: [
                    if (state.latitude == null || state.longitude == null)
                      _buildWarningCard(
                        '',
                        l10n.locationWarning,
                        Icons.location_off_rounded,
                        isSmall: true,
                      ),
                    Text(
                      l10n.locationDesc,
                      style: TextStyle(
                        color: context.onSurfaceVariantColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.currentLocation),
                      subtitle: Text(
                        state.cityName ?? l10n.locationNotSet,
                        style: TextStyle(
                          color: state.cityName != null
                              ? context.secondaryColor
                              : context.errorColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          context.read<SettingsCubit>().refreshLocation();
                        },
                        icon: Icon(Icons.my_location, size: 18),
                        label: Text(l10n.refreshLocation),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildThemeSection(context, state, l10n),
                const SizedBox(height: 20),
                _buildSection(
                  context,
                  title: l10n.prayerSettings,
                  icon: Icons.access_time_filled_rounded,
                  children: [
                    _buildSettingItem(
                      title: l10n.calculationMethod,
                      description: l10n.calculationMethodDesc,
                      trailing: _buildDropdown<String>(
                        value: state.calculationMethod,
                        items:
                            [
                              'muslim_league',
                              'egyptian',
                              'karachi',
                              'umm_al_qura',
                              'dubai',
                              'moonsighting_committee',
                              'north_america',
                              'kuwait',
                              'qatar',
                              'singapore',
                              'tehran',
                              'turkey',
                            ].map((method) {
                              String displayName;
                              switch (method) {
                                case 'muslim_league':
                                  displayName = l10n.muslimWorldLeague;
                                  break;
                                case 'egyptian':
                                  displayName = l10n.egyptianGeneralAuthority;
                                  break;
                                case 'karachi':
                                  displayName =
                                      l10n.universityOfIslamicSciencesKarachi;
                                  break;
                                case 'umm_al_qura':
                                  displayName = l10n.ummAlQuraUniversityMakkah;
                                  break;
                                case 'dubai':
                                  displayName = l10n.dubai;
                                  break;
                                case 'moonsighting_committee':
                                  displayName = l10n.moonsightingCommittee;
                                  break;
                                case 'north_america':
                                  displayName = l10n.isnaNorthAmerica;
                                  break;
                                case 'kuwait':
                                  displayName = l10n.kuwait;
                                  break;
                                case 'qatar':
                                  displayName = l10n.qatar;
                                  break;
                                case 'singapore':
                                  displayName = l10n.singapore;
                                  break;
                                case 'tehran':
                                  displayName =
                                      l10n.instituteOfGeophysicsTehran;
                                  break;
                                case 'turkey':
                                  displayName = l10n.turkey;
                                  break;
                                default:
                                  displayName = method
                                      .replaceAll('_', ' ')
                                      .split(' ')
                                      .map(
                                        (str) =>
                                            str[0].toUpperCase() +
                                            str.substring(1),
                                      )
                                      .join(' ');
                              }
                              return DropdownMenuItem(
                                value: method,
                                child: Text(
                                  displayName,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context
                                .read<SettingsCubit>()
                                .updateCalculationMethod(value);
                          }
                        },
                      ),
                    ),
                    const Divider(height: 32),
                    _buildSettingItem(
                      title: l10n.madhab,
                      description: l10n.madhabDesc,
                      trailing: _buildDropdown<String>(
                        value: state.madhab,
                        items: [
                          DropdownMenuItem(
                            value: 'shafi',
                            child: Text(
                              l10n.shafiMadhab,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'hanafi',
                            child: Text(
                              l10n.hanafiMadhab,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SettingsCubit>().updateMadhab(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  context,
                  title: l10n.azanNotifications,
                  icon: Icons.notifications_active_rounded,
                  children: [
                    Text(
                      l10n.azanSettingsDesc,
                      style: TextStyle(
                        color: context.onSurfaceVariantColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Global settings row
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.globalSettings),
                      subtitle: Text(
                        l10n.globalSettingsDesc,
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _showGlobalSettingsDialog(context, state, l10n);
                        },
                        icon: Icon(Icons.tune_rounded, size: 18),
                        label: Text(l10n.edit),
                      ),
                    ),
                    const Divider(height: 24),
                    // Per-prayer settings
                    Text(
                      l10n.editEachPrayer,
                      style: TextStyle(
                        color: context.onSurfaceVariantColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...state.salaahSettings.map((salaahSetting) {
                      return _buildSalaahSettingItem(
                        context: context,
                        settings: salaahSetting,
                        l10n: l10n,
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  context,
                  title: l10n.azkarSettings,
                  icon: Icons.auto_stories_rounded,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.azkarSettingsDesc,
                            style: TextStyle(
                              color: context.onSurfaceVariantColor,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        TextButton.icon(
                          key: const Key('add_reminder_button'),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _showAddReminderDialog(context);
                          },
                          icon: Icon(Icons.add, size: 20),
                          label: Text(l10n.add),
                          style: TextButton.styleFrom(
                            foregroundColor: context.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 12),
                    if (state.reminders.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                color: context.onSurfaceVariantColor.withValues(
                                  alpha: 0.3,
                                ),
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.noRemindersSet,
                                style: TextStyle(
                                  color: context.onSurfaceVariantColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...state.reminders.asMap().entries.map((entry) {
                        final index = entry.key;
                        final reminder = entry.value;
                        return Column(
                          children: [
                            _buildReminderItem(
                              context: context,
                              index: index,
                              reminder: reminder,
                            ),
                            if (index < state.reminders.length - 1)
                              const Divider(height: 1),
                          ],
                        );
                      }),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  context,
                  title: l10n.offlineAudio,
                  icon: Icons.offline_pin_rounded,
                  children: [
                    _buildSettingItem(
                      title: l10n.manageDownloads,
                      description: l10n.downloadRecitersOffline,
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: context.onSurfaceVariantColor,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OfflineAudioScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  context,
                  title: l10n.generalSettings,
                  icon: Icons.apps_rounded,
                  children: [
                    _buildSettingItem(
                      title: l10n.qadaTracker,
                      description: l10n.qadaTrackerDesc,
                      trailing: CustomToggle(
                        value: state.isQadaEnabled,
                        onChanged: (val) {
                          context.read<SettingsCubit>().toggleQadaEnabled();
                        },
                      ),
                    ),
                    const Divider(height: 32),
                    _buildSettingItem(
                      title: l10n.hijriAdjustment,
                      description: l10n.hijriAdjustmentDesc,
                      trailing: _buildDropdown<int>(
                        value: state.hijriAdjustment,
                        items: [-2, -1, 0, 1, 2].map((adj) {
                          return DropdownMenuItem(
                            value: adj,
                            child: Text(
                              adj == 0 ? '0' : (adj > 0 ? '+$adj' : '$adj'),
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            context.read<SettingsCubit>().updateHijriAdjustment(
                              value,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSection(
                  context,
                  title: l10n.dataBackup,
                  icon: Icons.backup_rounded,
                  children: [
                    _buildSettingItem(
                      title: l10n.exportBackup,
                      description: l10n.exportBackupDesc,
                      onTap: () async {
                        try {
                          await getIt<ExportImportService>().exportData();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.backupExportSuccess)),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${l10n.backupError}: $e'),
                              ),
                            );
                          }
                        }
                      },
                      trailing: Icon(
                        Icons.share_rounded,
                        size: 20,
                        color: context.secondaryColor,
                      ),
                    ),
                    const Divider(height: 32),
                    _buildSettingItem(
                      title: l10n.importBackup,
                      description: l10n.importBackupDesc,
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(l10n.importBackup),
                            content: Text(l10n.importWarning),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(l10n.cancel),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(l10n.yes),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true && context.mounted) {
                          try {
                            final success = await getIt<ExportImportService>()
                                .importData();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.backupImportSuccess),
                                ),
                              );
                              // Reload blocs to reflect new data
                              context.read<WerdBloc>().add(
                                const WerdEvent.load(),
                              );
                              final prayerBloc = context
                                  .read<PrayerTrackerBloc>();
                              prayerBloc.add(
                                PrayerTrackerEvent.load(DateTime.now()),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${l10n.backupError}: $e'),
                                ),
                              );
                            }
                          }
                        }
                      },
                      trailing: Icon(
                        Icons.file_upload_rounded,
                        size: 20,
                        color: context.secondaryColor,
                      ),
                    ),
                  ],
                ),
                // Debug: Widget Refresh Section (only in debug mode)
                if (!kReleaseMode) ...[
                  const SizedBox(height: 20),
                  _buildSection(
                    context,
                    title: 'Debug: Widget',
                    icon: Icons.bug_report_rounded,
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
                              SnackBar(
                                content: Text('Widget refresh triggered!'),
                                backgroundColor: context.primaryContainerColor,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: Icon(Icons.refresh, size: 18),
                          label: const Text('Refresh'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWarningCard(
    String title,
    String desc,
    IconData icon, {
    bool isSmall = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.errorColor.withValues(alpha: 0.2)),
      ),
      child: Row(
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
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: context.surfaceContainerHighestColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.outlineColor),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: (val) {
          HapticFeedback.selectionClick();
          onChanged(val);
        },
        underline: const SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        dropdownColor: context.surfaceContainerHighestColor,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  void _showGlobalSettingsDialog(
    BuildContext context,
    SettingsState state,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<SettingsCubit>();

    // Initial values from first prayer as proxy
    final first = state.salaahSettings.first;
    bool isAzanEnabled = first.isAzanEnabled;
    bool isReminderEnabled = first.isReminderEnabled;
    bool isAfterSalahAzkarEnabled = first.isAfterSalahAzkarEnabled;
    int reminderMinutes = first.reminderMinutesBefore;
    int afterSalahMinutes = first.afterSalaahAzkarMinutes;
    String? selectedVoice = first.azanSound;
    bool isDownloading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                l10n.globalSettings,
                style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleItem(
                      title: l10n.enableAzan,
                      value: isAzanEnabled,
                      onChanged: (val) =>
                          setDialogState(() => isAzanEnabled = val),
                    ),
                    if (isAzanEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n.azanVoice,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: context.surfaceContainerHighestColor,
                              ),
                              initialValue: () {
                                if (selectedVoice == null) {
                                  return null;
                                }
                                for (var entry
                                    in VoiceDownloadService
                                        .azanVoices
                                        .entries) {
                                  if (selectedVoice == entry.key) {
                                    return entry.key;
                                  }
                                  final uri = Uri.parse(entry.value);
                                  if (selectedVoice!.contains(
                                    'voice_${uri.pathSegments.last}',
                                  )) {
                                    return entry.key;
                                  }

                                  // Fallback for old naming
                                  final sanitized = entry.key
                                      .toLowerCase()
                                      .replaceAll(RegExp(r'[^a-z0-9]'), '_');
                                  if (selectedVoice!.contains(
                                    '${sanitized}_azan.mp3',
                                  )) {
                                    return entry.key;
                                  }
                                }
                                return null;
                              }(),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(l10n.defaultVal),
                                ),
                                ...VoiceDownloadService.azanVoices.keys.map((
                                  v,
                                ) {
                                  final parts = v.split(' - ');
                                  final displayName = l10n.localeName == 'ar'
                                      ? (parts.length > 1 ? parts[1] : parts[0])
                                      : parts[0];
                                  return DropdownMenuItem(
                                    value: v,
                                    child: Text(displayName),
                                  );
                                }),
                              ],
                              onChanged: (val) async {
                                HapticFeedback.selectionClick();
                                if (val != null) {
                                  final downloader =
                                      getIt<VoiceDownloadService>();
                                  if (!(await downloader.isDownloaded(val))) {
                                    setDialogState(() => isDownloading = true);
                                    final path = await downloader.downloadAzan(
                                      val,
                                    );
                                    if (path != null) {
                                      final accessiblePath = await downloader
                                          .getAccessiblePath(val);
                                      setDialogState(() {
                                        isDownloading = false;
                                        if (accessiblePath != null) {
                                          selectedVoice = accessiblePath;
                                        }
                                      });
                                    } else {
                                      setDialogState(
                                        () => isDownloading = false,
                                      );
                                    }
                                  } else {
                                    final accessiblePath = await downloader
                                        .getAccessiblePath(val);
                                    setDialogState(
                                      () => selectedVoice = accessiblePath,
                                    );
                                  }
                                } else {
                                  setDialogState(() => selectedVoice = null);
                                }
                              },
                            ),
                            if (isDownloading)
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: LinearProgressIndicator(
                                  color: context.secondaryColor,
                                ),
                              ),
                            TextButton.icon(
                              onPressed: isDownloading
                                  ? null
                                  : () => getIt<NotificationService>().testAzan(
                                      Salaah.fajr,
                                      selectedVoice,
                                    ),
                              icon: Icon(Icons.play_arrow_rounded),
                              label: Text(l10n.testAzan),
                              style: TextButton.styleFrom(
                                foregroundColor: context.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 32),
                    _buildToggleItem(
                      title: l10n.enableReminder,
                      value: isReminderEnabled,
                      onChanged: (val) =>
                          setDialogState(() => isReminderEnabled = val),
                    ),
                    if (isReminderEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.minutesBefore(reminderMinutes),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: context.errorColor,
                                  ),
                                  onPressed: reminderMinutes > 1
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          setDialogState(
                                            () => reminderMinutes--,
                                          );
                                        }
                                      : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainerHighestColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$reminderMinutes',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: context.primaryContainerColor,
                                  ),
                                  onPressed: reminderMinutes < 60
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          setDialogState(
                                            () => reminderMinutes++,
                                          );
                                        }
                                      : null,
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => getIt<NotificationService>()
                                  .testReminder(Salaah.fajr, reminderMinutes),
                              icon: Icon(
                                Icons.notification_important_rounded,
                              ),
                              label: Text(l10n.testReminder),
                              style: TextButton.styleFrom(
                                foregroundColor: context.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 32),
                    _buildToggleItem(
                      title: l10n.afterSalaahAzkar,
                      value: isAfterSalahAzkarEnabled,
                      onChanged: (val) =>
                          setDialogState(() => isAfterSalahAzkarEnabled = val),
                    ),
                    if (isAfterSalahAzkarEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(l10n.minutesAfter(afterSalahMinutes)),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: context.errorColor,
                              ),
                              onPressed: afterSalahMinutes > 0
                                  ? () {
                                      HapticFeedback.lightImpact();
                                      setDialogState(() => afterSalahMinutes--);
                                    }
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.surfaceContainerHighestColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$afterSalahMinutes',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: context.primaryContainerColor,
                              ),
                              onPressed: afterSalahMinutes < 60
                                  ? () {
                                      HapticFeedback.lightImpact();
                                      setDialogState(() => afterSalahMinutes++);
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(color: context.onSurfaceVariantColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    cubit.updateAllAzanEnabled(isAzanEnabled);
                    cubit.updateAllReminderEnabled(isReminderEnabled);
                    cubit.updateAllAzanSound(selectedVoice);
                    cubit.updateAllReminderMinutes(reminderMinutes);
                    cubit.updateAllAfterSalahMinutes(afterSalahMinutes);
                    Navigator.pop(context);
                  },
                  child: Text(l10n.applyToAll),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildToggleItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          CustomToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildSalaahSettingItem({
    required BuildContext context,
    required SalaahSettings settings,
    required AppLocalizations l10n,
  }) {
    final String salaahName = _getLocalizedSalaahName(settings.salaah, l10n);

    String voiceDisplayName = '';
    if (settings.isAzanEnabled) {
      if (settings.azanSound == null || settings.azanSound == 'default') {
        voiceDisplayName = ' (Default)';
      } else {
        // Try to find the voice name from the path
        for (var entry in VoiceDownloadService.azanVoices.entries) {
          final uri = Uri.parse(entry.value);
          if (settings.azanSound!.contains('voice_${uri.pathSegments.last}')) {
            voiceDisplayName = ' (${entry.key.split(' - ').first})';
            break;
          }

          // Fallback for old naming
          final sanitized = entry.key.toLowerCase().replaceAll(
            RegExp(r'[^a-z0-9]'),
            '_',
          );
          if (settings.azanSound!.contains('${sanitized}_azan.mp3')) {
            voiceDisplayName = ' (${entry.key.split(' - ').first})';
            break;
          }
        }
      }
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      title: Text(
        salaahName,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(
        '${settings.isAzanEnabled ? "${l10n.azan}$voiceDisplayName" : ""} ${settings.isAzanEnabled && settings.isReminderEnabled ? "&" : ""} ${settings.isReminderEnabled ? "${l10n.reminder} (${l10n.minutesBefore(settings.reminderMinutesBefore)})" : ""}',
        style: TextStyle(fontSize: 12, color: context.onSurfaceVariantColor),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: context.onSurfaceVariantColor,
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        _showSalaahSettingsDialog(context, settings, l10n);
      },
    );
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

  void _showSalaahSettingsDialog(
    BuildContext context,
    SalaahSettings settings,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<SettingsCubit>();

    bool isAzanEnabled = settings.isAzanEnabled;
    bool isReminderEnabled = settings.isReminderEnabled;
    bool isAfterSalahAzkarEnabled = settings.isAfterSalahAzkarEnabled;
    int reminderMinutes = settings.reminderMinutesBefore;
    int afterSalahMinutes = settings.afterSalaahAzkarMinutes;
    String? selectedVoice = settings.azanSound;
    bool isDownloading = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                _getLocalizedSalaahName(settings.salaah, l10n),
                style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleItem(
                      title: l10n.enableAzan,
                      value: isAzanEnabled,
                      onChanged: (val) =>
                          setDialogState(() => isAzanEnabled = val),
                    ),
                    if (isAzanEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: l10n.azanVoice,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: context.surfaceContainerHighestColor,
                              ),
                              initialValue: () {
                                if (selectedVoice == null) {
                                  return null;
                                }
                                for (var entry
                                    in VoiceDownloadService
                                        .azanVoices
                                        .entries) {
                                  if (selectedVoice == entry.key) {
                                    return entry.key;
                                  }
                                  final uri = Uri.parse(entry.value);
                                  if (selectedVoice!.contains(
                                    'voice_${uri.pathSegments.last}',
                                  )) {
                                    return entry.key;
                                  }

                                  // Fallback for old naming
                                  final sanitized = entry.key
                                      .toLowerCase()
                                      .replaceAll(RegExp(r'[^a-z0-9]'), '_');
                                  if (selectedVoice!.contains(
                                    '${sanitized}_azan.mp3',
                                  )) {
                                    return entry.key;
                                  }
                                }
                                return null;
                              }(),
                              items: [
                                DropdownMenuItem(
                                  value: null,
                                  child: Text(l10n.defaultVal),
                                ),
                                ...VoiceDownloadService.azanVoices.keys.map((
                                  v,
                                ) {
                                  final parts = v.split(' - ');
                                  final displayName = l10n.localeName == 'ar'
                                      ? (parts.length > 1 ? parts[1] : parts[0])
                                      : parts[0];
                                  return DropdownMenuItem(
                                    value: v,
                                    child: Text(displayName),
                                  );
                                }),
                              ],
                              onChanged: (val) async {
                                HapticFeedback.selectionClick();
                                if (val != null) {
                                  final downloader =
                                      getIt<VoiceDownloadService>();
                                  if (!(await downloader.isDownloaded(val))) {
                                    setDialogState(() => isDownloading = true);
                                    final path = await downloader.downloadAzan(
                                      val,
                                    );
                                    if (path != null) {
                                      final accessiblePath = await downloader
                                          .getAccessiblePath(val);
                                      setDialogState(() {
                                        isDownloading = false;
                                        if (accessiblePath != null) {
                                          selectedVoice = accessiblePath;
                                        }
                                      });
                                    } else {
                                      setDialogState(
                                        () => isDownloading = false,
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n.azanDownloadError,
                                            ),
                                            backgroundColor: context.errorColor,
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    final accessiblePath = await downloader
                                        .getAccessiblePath(val);
                                    setDialogState(
                                      () => selectedVoice = accessiblePath,
                                    );
                                  }
                                } else {
                                  setDialogState(() => selectedVoice = null);
                                }
                              },
                            ),
                            if (isDownloading)
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: LinearProgressIndicator(
                                  color: context.secondaryColor,
                                ),
                              ),
                            TextButton.icon(
                              onPressed: isDownloading
                                  ? null
                                  : () => getIt<NotificationService>().testAzan(
                                      settings.salaah,
                                      selectedVoice,
                                    ),
                              icon: Icon(Icons.play_arrow_rounded),
                              label: Text(l10n.testAzan),
                              style: TextButton.styleFrom(
                                foregroundColor: context.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 32),
                    _buildToggleItem(
                      title: l10n.enableReminder,
                      value: isReminderEnabled,
                      onChanged: (val) =>
                          setDialogState(() => isReminderEnabled = val),
                    ),
                    if (isReminderEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.minutesBefore(reminderMinutes),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: context.errorColor,
                                  ),
                                  onPressed: reminderMinutes > 1
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          setDialogState(
                                            () => reminderMinutes--,
                                          );
                                        }
                                      : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainerHighestColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$reminderMinutes',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: context.primaryContainerColor,
                                  ),
                                  onPressed: reminderMinutes < 60
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          setDialogState(
                                            () => reminderMinutes++,
                                          );
                                        }
                                      : null,
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  getIt<NotificationService>().testReminder(
                                    settings.salaah,
                                    reminderMinutes,
                                  ),
                              icon: Icon(
                                Icons.notification_important_rounded,
                              ),
                              label: Text(l10n.testReminder),
                              style: TextButton.styleFrom(
                                foregroundColor: context.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 32),
                    _buildToggleItem(
                      title: l10n.afterSalaahAzkar,
                      value: isAfterSalahAzkarEnabled,
                      onChanged: (val) =>
                          setDialogState(() => isAfterSalahAzkarEnabled = val),
                    ),
                    if (isAfterSalahAzkarEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.minutesAfter(afterSalahMinutes),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: context.errorColor,
                                  ),
                                  onPressed: afterSalahMinutes > 0
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          setDialogState(
                                            () => afterSalahMinutes--,
                                          );
                                        }
                                      : null,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.surfaceContainerHighestColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$afterSalahMinutes',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: context.primaryContainerColor,
                                  ),
                                  onPressed: afterSalahMinutes < 60
                                      ? () {
                                          HapticFeedback.lightImpact();
                                          setDialogState(
                                            () => afterSalahMinutes++,
                                          );
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: TextStyle(color: context.onSurfaceVariantColor),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    cubit.updateSalaahSettings(
                      settings.copyWith(
                        isAzanEnabled: isAzanEnabled,
                        isReminderEnabled: isReminderEnabled,
                        reminderMinutesBefore: reminderMinutes,
                        isAfterSalahAzkarEnabled: isAfterSalahAzkarEnabled,
                        afterSalaahAzkarMinutes: afterSalahMinutes,
                        azanSound: selectedVoice,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: Text(l10n.update),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildReminderItem({
    required BuildContext context,
    required int index,
    required AzkarReminder reminder,
  }) {
    final cubit = context.read<SettingsCubit>();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        reminder.title.isNotEmpty ? reminder.title : reminder.category,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: reminder.isEnabled
              ? context.onSurfaceColor
              : context.onSurfaceVariantColor,
        ),
      ),
      subtitle: Text(
        reminder.time,
        style: TextStyle(
          color: context.secondaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomToggle(
            value: reminder.isEnabled,
            onChanged: (val) => cubit.toggleReminder(index),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: context.onSurfaceVariantColor,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAddReminderDialog(context, index: index, reminder: reminder);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: context.errorColor,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              cubit.removeReminder(index);
            },
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(
    BuildContext context, {
    int? index,
    AzkarReminder? reminder,
  }) {
    final cubit = context.read<SettingsCubit>();
    final azkarBloc = context.read<AzkarBloc>();
    final l10n = AppLocalizations.of(context)!;

    String selectedCategory = reminder?.category ?? '';
    String selectedTime = reminder?.time ?? '05:00';
    String customTitle = reminder?.title ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return BlocBuilder<AzkarBloc, AzkarState>(
              bloc: azkarBloc,
              builder: (context, azkarState) {
                if (selectedCategory.isEmpty &&
                    azkarState.categories.isNotEmpty) {
                  selectedCategory = azkarState.categories.first;
                }

                return AlertDialog(
                  title: Text(
                    index == null ? l10n.addReminder : l10n.editReminder,
                    style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
                  ),
                  content: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Searchable Category Selection
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            _showSearchableCategoryPicker(
                              context,
                              azkarState.categories,
                              (val) {
                                setDialogState(() {
                                  selectedCategory = val;
                                });
                              },
                            );
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.category,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: Icon(Icons.search),
                              filled: true,
                              fillColor: context.surfaceContainerHighestColor,
                            ),
                            child: Text(
                              selectedCategory.isEmpty
                                  ? l10n.selectCategory
                                  : selectedCategory,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Custom Title
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: l10n.customTitleOptional,
                            hintText: selectedCategory,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: context.surfaceContainerHighestColor,
                          ),
                          initialValue: customTitle,
                          onChanged: (val) => customTitle = val,
                        ),
                        const SizedBox(height: 16),
                        // Time Selection
                        _buildTimeSettingItem(
                          context: context,
                          title: l10n.time,
                          time: selectedTime,
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            final time = await _selectTime(
                              context,
                              selectedTime,
                            );
                            if (time != null) {
                              setDialogState(() => selectedTime = time);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(color: context.onSurfaceVariantColor),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedCategory.isEmpty) return;
                        HapticFeedback.mediumImpact();

                        final newReminder = AzkarReminder(
                          category: selectedCategory,
                          time: selectedTime,
                          title: customTitle.isNotEmpty
                              ? customTitle
                              : selectedCategory,
                          isEnabled: reminder?.isEnabled ?? true,
                        );

                        if (index == null) {
                          cubit.addReminder(newReminder);
                        } else {
                          cubit.updateReminder(index, newReminder);
                        }
                        Navigator.pop(context);
                      },
                      child: Text(l10n.yes),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showSearchableCategoryPicker(
    BuildContext context,
    List<String> categories,
    Function(String) onSelected,
  ) {
    final l10n = AppLocalizations.of(context)!;
    String sheetSearchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.surfaceContainerColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredCategories = categories
                .where(
                  (cat) =>
                      sheetSearchQuery.isEmpty ||
                      cat.toLowerCase().contains(sheetSearchQuery),
                )
                .toList();

            return Container(
              padding: EdgeInsets.only(
                top: 12,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: context.outlineColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.searchCategory,
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: context.surfaceContainerHighestColor,
                    ),
                    onChanged: (val) {
                      setSheetState(() {
                        sheetSearchQuery = val.toLowerCase();
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final cat = filteredCategories[index];
                        return ListTile(
                          title: Text(
                            cat,
                            textAlign: l10n.localeName == 'ar'
                                ? TextAlign.right
                                : TextAlign.left,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onSelected(cat);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==================== THEME SECTION ====================

  Widget _buildThemeSection(
    BuildContext context,
    SettingsState state,
    AppLocalizations l10n,
  ) {
    final cubit = context.read<SettingsCubit>();
    final presets = cubit.getAvailablePresets();
    final currentPresetId = state.themePresetId;
    final localeCode = state.locale.languageCode;
    final savedThemes = state.savedCustomThemes;
    final activeThemeId = state.activeCustomThemeId;

    return _buildSection(
      context,
      title: l10n.theme,
      icon: Icons.palette_rounded,
      children: [
        // Built-in presets horizontal scroll
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: presets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final preset = presets[index];
              final isSelected = preset.id == currentPresetId;
              return _buildThemeCard(
                preset: preset,
                isSelected: isSelected,
                localeCode: localeCode,
                onTap: () => cubit.selectThemePreset(preset.id),
              );
            },
          ),
        ),
        // "Create New Theme" button
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showThemeEditorSheet(context, state, l10n, null),
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: Text(l10n.createNewTheme),
            style: OutlinedButton.styleFrom(
              foregroundColor: context.secondaryColor,
              side: BorderSide(color: context.secondaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        // Saved custom themes list
        if (savedThemes.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            l10n.savedThemes,
            style: GoogleFonts.amiri(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.onSurfaceColor,
            ),
          ),
          const SizedBox(height: 12),
          ...savedThemes.map((theme) {
            final isActive = currentPresetId == 'custom' && activeThemeId == theme.id;
            return _buildSavedThemeCard(
              theme: theme,
              isActive: isActive,
              l10n: l10n,
              onTap: () => cubit.activateCustomTheme(theme.id),
              onEdit: () => _showThemeEditorSheet(context, state, l10n, theme),
              onDelete: () => _confirmDeleteTheme(context, theme, l10n),
            );
          }),
        ],
        if (currentPresetId != 'emerald') ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              icon: Icon(Icons.restore, size: 18),
              label: Text(l10n.resetToDefault),
              onPressed: () => cubit.selectThemePreset('emerald'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildThemeCard({
    required ThemePreset preset,
    required bool isSelected,
    required String localeCode,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 150,
        decoration: BoxDecoration(
          color: preset.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? preset.primaryColor : preset.cardBorderColor,
            width: isSelected ? 3 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: preset.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      preset.primaryColor.withValues(alpha: 0.2),
                      preset.accentColor.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(preset.icon, color: preset.primaryColor, size: 36),
                  const Spacer(),
                  Text(
                    localeCode == 'ar' ? preset.nameAr : preset.name,
                    style: GoogleFonts.outfit(
                      color: preset.textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      CircleAvatar(radius: 6, backgroundColor: preset.primaryColor),
                      const SizedBox(width: 4),
                      CircleAvatar(radius: 6, backgroundColor: preset.accentColor),
                    ],
                  ),
                  const Spacer(),
                  if (isSelected)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(Icons.check_circle_rounded, color: preset.primaryColor, size: 24),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedThemeCard({
    required CustomTheme theme,
    required bool isActive,
    required AppLocalizations l10n,
    required VoidCallback onTap,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surfaceContainerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? context.secondaryColor : context.outlineColor,
          width: isActive ? 3 : 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Color swatches
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(int.parse(theme.primary.replaceFirst('#', '0xFF'))),
                        Color(int.parse(theme.accent.replaceFirst('#', '0xFF'))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              theme.name,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: context.onSurfaceColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive)
                            Icon(
                              Icons.check_circle_rounded,
                              color: context.secondaryColor,
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _colorDot(theme.primary),
                          const SizedBox(width: 4),
                          _colorDot(theme.accent),
                          const SizedBox(width: 4),
                          _colorDot(theme.background),
                          const SizedBox(width: 4),
                          _colorDot(theme.surface),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Edit button
                IconButton(
                  icon: Icon(Icons.edit_rounded, size: 20),
                  onPressed: onEdit,
                  color: context.onSurfaceVariantColor,
                  tooltip: l10n.edit,
                ),
                // Delete button
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, size: 20),
                  onPressed: onDelete,
                  color: context.errorColor,
                  tooltip: l10n.delete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _colorDot(String hex) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Color(int.parse(hex.replaceFirst('#', '0xFF'))),
        shape: BoxShape.circle,
        border: Border.all(color: context.outlineColor, width: 0.5),
      ),
    );
  }

  Future<void> _showThemeEditorSheet(
    BuildContext context,
    SettingsState state,
    AppLocalizations l10n,
    CustomTheme? existingTheme,
  ) async {
    final cubit = context.read<SettingsCubit>();
    final isEditing = existingTheme != null;

    final colors = isEditing
        ? existingTheme.toColorMap()
        : {
            'primary': '#2E7D32',
            'accent': '#FFD54F',
            'background': '#0D1117',
            'surface': '#161B22',
            'text': '#E6EDF3',
            'textSecondary': '#8B949E',
            'cardBorder': '#30363D',
            'surfaceLight': '#21262D',
          };

    final labels = {
      'primary': 'Primary',
      'accent': 'Accent',
      'background': 'Background',
      'surface': 'Surface',
      'text': 'Text',
      'textSecondary': 'Text Secondary',
      'cardBorder': 'Card Border',
      'surfaceLight': 'Surface Light',
    };

    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return ThemeEditorWidget(
          colors: colors,
          labels: labels,
          l10n: l10n,
          isEditing: isEditing,
        );
      },
    );

    if (result == null) return;

    if (isEditing) {
      cubit.updateCustomTheme(existingTheme.id, result);
    } else {
      if (!context.mounted) return;
      final name = await _showThemeNameDialog(context, l10n, state.savedCustomThemes);
      if (name == null) return;
      
      final theme = CustomTheme(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        primary: result['primary']!,
        accent: result['accent']!,
        background: result['background']!,
        surface: result['surface']!,
        text: result['text']!,
        textSecondary: result['textSecondary']!,
        cardBorder: result['cardBorder']!,
        surfaceLight: result['surfaceLight']!,
      );
      cubit.addCustomTheme(theme);
    }
  }

  Future<String?> _showThemeNameDialog(
    BuildContext context,
    AppLocalizations l10n,
    List<CustomTheme> existingThemes,
  ) async {
    // Generate a unique default name by incrementing if duplicates exist
    String defaultName = 'My Theme';
    int counter = 2;
    while (existingThemes.any((t) => t.name == defaultName)) {
      defaultName = 'My Theme $counter';
      counter++;
    }

    final controller = TextEditingController(text: defaultName);
    final focusNode = FocusNode();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        // Select all text when dialog opens for easy editing
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.requestFocus();
          controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          );
        });

        return AlertDialog(
          title: Text(l10n.nameYourTheme),
          content: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              hintText: l10n.themeNameHint,
              helperText: 'You can edit this name',
            ),
            onSubmitted: (val) {
              if (val.trim().isNotEmpty) Navigator.pop(dialogContext, val.trim());
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  Navigator.pop(dialogContext, controller.text.trim());
                }
              },
              child: Text(l10n.saveTheme),
            ),
          ],
        );
      },
    );
    controller.dispose();
    focusNode.dispose();
    return result;
  }

  Future<void> _confirmDeleteTheme(
    BuildContext context,
    CustomTheme theme,
    AppLocalizations l10n,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (d) => AlertDialog(
        title: Text(l10n.deleteTheme),
        content: Text(l10n.deleteThemeConfirm(theme.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(d), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(d, true),
            style: ElevatedButton.styleFrom(backgroundColor: context.errorColor),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      context.read<SettingsCubit>().deleteCustomTheme(theme.id);
    }
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceContainerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.outlineColor),
        boxShadow: [
          BoxShadow(
            color: context.outlineColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.primaryContainerColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: context.primaryContainerColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.onSurfaceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required String description,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          color: context.onSurfaceVariantColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                trailing,
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSettingItem({
    required BuildContext context,
    required String title,
    required String time,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      trailing: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: context.secondaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.secondaryColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            time,
            style: TextStyle(
              color: context.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Future<String?> _selectTime(BuildContext context, String currentTime) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: context.secondaryColor,
              onPrimary: context.onSurfaceColor,
              surface: context.surfaceContainerHighestColor,
              onSurface: context.onSurfaceColor,
              secondary: context.secondaryColor,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: context.surfaceContainerColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: context.secondaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedTime != null) {
      final String hour = selectedTime.hour.toString().padLeft(2, '0');
      final String minute = selectedTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
    return null;
  }
}
