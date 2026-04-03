import 'package:fard/core/services/export_import_service.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/prayer_tracking/presentation/blocs/prayer_tracker_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_bloc.dart';
import 'package:fard/features/werd/presentation/blocs/werd_event.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/location_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/core/widgets/custom_toggle.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/audio/presentation/screens/offline_audio_screen.dart';
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
        foregroundColor: AppTheme.textPrimary,
        centerTitle: true,
        actions: [
          BlocBuilder<SettingsCubit, SettingsState>(
            buildWhen: (previous, current) => previous.locale != current.locale,
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: state.locale.languageCode,
                      icon: const Icon(
                        Icons.language_rounded,
                        size: 20,
                        color: AppTheme.accent,
                      ),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          HapticFeedback.selectionClick();
                          context.read<SettingsCubit>().updateLocale(
                            Locale(newValue),
                          );
                        }
                      },
                      items: [
                        const DropdownMenuItem(
                          value: 'ar',
                          child: Text(
                            'العربية',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        const DropdownMenuItem(
                          value: 'en',
                          child: Text(
                            'English',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                      dropdownColor: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
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
                        color: AppTheme.textSecondary,
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
                              ? AppTheme.accent
                              : AppTheme.missed,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          context.read<SettingsCubit>().refreshLocation();
                        },
                        icon: const Icon(Icons.my_location, size: 18),
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
                  title: l10n.globalSettings,
                  icon: Icons.settings_suggest_rounded,
                  children: [
                    Text(
                      l10n.globalSettingsDesc,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.applyToAll),
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _showGlobalSettingsDialog(context, state, l10n);
                        },
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: Text(l10n.edit),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSection(
                  context,
                  title: l10n.individualSettings,
                  icon: Icons.notifications_active_rounded,
                  children: [
                    Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          l10n.editEachPrayer,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        children: state.salaahSettings.map((salaahSetting) {
                          return _buildSalaahSettingItem(
                            context: context,
                            settings: salaahSetting,
                            l10n: l10n,
                          );
                        }).toList(),
                      ),
                    ),
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
                              color: AppTheme.textSecondary,
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
                          icon: const Icon(Icons.add, size: 20),
                          label: Text(l10n.add),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.accent,
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
                                color: AppTheme.textSecondary.withValues(
                                  alpha: 0.3,
                                ),
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.noRemindersSet,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
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
                      trailing: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
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
                      trailing: const Icon(
                        Icons.share_rounded,
                        size: 20,
                        color: AppTheme.accent,
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
                      trailing: const Icon(
                        Icons.file_upload_rounded,
                        size: 20,
                        color: AppTheme.accent,
                      ),
                    ),
                  ],
                ),
                // Debug: Widget Refresh Section
                const SizedBox(height: 20),
                _buildSection(
                  context,
                  title: 'Debug: Widget',
                  icon: Icons.bug_report_rounded,
                  children: [
                    Text(
                      'Force refresh the home screen widget. Use this for testing.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
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
                          getIt<WidgetUpdateService>().updateWidget(
                            context.read<SettingsCubit>().state,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Widget refresh triggered!'),
                              backgroundColor: AppTheme.primaryLight,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh, size: 18),
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
        color: AppTheme.missed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.missed.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: isSmall
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.missed, size: isSmall ? 20 : 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.missed,
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
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: (val) {
          HapticFeedback.selectionClick();
          onChanged(val);
        },
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        dropdownColor: AppTheme.surfaceLight,
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
                                fillColor: AppTheme.surfaceLight,
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
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: LinearProgressIndicator(
                                  color: AppTheme.accent,
                                ),
                              ),
                            TextButton.icon(
                              onPressed: isDownloading
                                  ? null
                                  : () => getIt<NotificationService>().testAzan(
                                      Salaah.fajr,
                                      selectedVoice,
                                      settings: context
                                          .read<SettingsCubit>()
                                          .state,
                                    ),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(l10n.testAzan),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.accent,
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
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: AppTheme.missed,
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
                                    color: AppTheme.surfaceLight,
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
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppTheme.primaryLight,
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
                              icon: const Icon(
                                Icons.notification_important_rounded,
                              ),
                              label: Text(l10n.testReminder),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.accent,
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
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: AppTheme.missed,
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
                                color: AppTheme.surfaceLight,
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
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: AppTheme.primaryLight,
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
                    style: const TextStyle(color: AppTheme.textSecondary),
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
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: AppTheme.textSecondary,
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
                                fillColor: AppTheme.surfaceLight,
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
                                            backgroundColor: AppTheme.missed,
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
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: LinearProgressIndicator(
                                  color: AppTheme.accent,
                                ),
                              ),
                            TextButton.icon(
                              onPressed: isDownloading
                                  ? null
                                  : () => getIt<NotificationService>().testAzan(
                                      settings.salaah,
                                      selectedVoice,
                                      settings: context
                                          .read<SettingsCubit>()
                                          .state,
                                    ),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(l10n.testAzan),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.accent,
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
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: AppTheme.missed,
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
                                    color: AppTheme.surfaceLight,
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
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppTheme.primaryLight,
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
                              icon: const Icon(
                                Icons.notification_important_rounded,
                              ),
                              label: Text(l10n.testReminder),
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.accent,
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
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: AppTheme.missed,
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
                                    color: AppTheme.surfaceLight,
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
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: AppTheme.primaryLight,
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
                    style: const TextStyle(color: AppTheme.textSecondary),
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
              ? AppTheme.textPrimary
              : AppTheme.textSecondary,
        ),
      ),
      subtitle: Text(
        reminder.time,
        style: const TextStyle(
          color: AppTheme.accent,
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
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: AppTheme.textSecondary,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showAddReminderDialog(context, index: index, reminder: reminder);
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: AppTheme.missed,
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
                              suffixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: AppTheme.surfaceLight,
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
                            fillColor: AppTheme.surfaceLight,
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
                        style: const TextStyle(color: AppTheme.textSecondary),
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
      backgroundColor: AppTheme.surface,
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
                      color: AppTheme.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.searchCategory,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: AppTheme.surfaceLight,
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

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
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
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primaryLight, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
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
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
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
            color: AppTheme.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
          ),
          child: Text(
            time,
            style: const TextStyle(
              color: AppTheme.accent,
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
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accent,
              onPrimary: Colors.black,
              surface: AppTheme.surfaceLight,
              onSurface: AppTheme.textPrimary,
              secondary: AppTheme.accent,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppTheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
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
