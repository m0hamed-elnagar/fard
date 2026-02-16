import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
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
    final canSchedule = await getIt<NotificationService>().canScheduleExactNotifications();
    if (mounted) {
      setState(() {
        _canScheduleExactAlarms = canSchedule;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (!_canScheduleExactAlarms)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.missed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.missed.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppTheme.missed),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'تنبيه: الأذان قد لا يعمل بدقة',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.missed),
                            ),
                            const Text(
                              'يرجى تفعيل "تنبيهات دقيقة" من إعدادات النظام لضمان عمل الأذان في وقته.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              _buildSection(
                context,
                title: l10n.locationSettings,
                icon: Icons.location_on_rounded,
                children: [
                  if (state.latitude == null || state.longitude == null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.missed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.missed.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_off_rounded, color: AppTheme.missed, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.locationWarning,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    l10n.locationDesc,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.currentLocation),
                    subtitle: Text(
                      state.cityName ?? l10n.locationNotSet,
                      style: TextStyle(color: state.cityName != null ? AppTheme.accent : AppTheme.missed),
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () => context.read<SettingsCubit>().refreshLocation(),
                      icon: const Icon(Icons.my_location, size: 18),
                      label: Text(l10n.refreshLocation),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: l10n.prayerSettings,
                icon: Icons.access_time_filled_rounded,
                children: [
                  _buildSettingItem(
                    title: l10n.calculationMethod,
                    description: l10n.calculationMethodDesc,
                    trailing: DropdownButton<String>(
                      value: state.calculationMethod,
                      underline: const SizedBox(),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<SettingsCubit>().updateCalculationMethod(value);
                        }
                      },
                      items: [
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
                        final displayName = method
                            .replaceAll('_', ' ')
                            .split(' ')
                            .map((str) => str[0].toUpperCase() + str.substring(1))
                            .join(' ');
                        return DropdownMenuItem(
                          value: method,
                          child: Text(
                            displayName,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 32),
                  _buildSettingItem(
                    title: l10n.madhab,
                    description: l10n.madhabDesc,
                    trailing: DropdownButton<String>(
                      value: state.madhab,
                      underline: const SizedBox(),
                      onChanged: (value) {
                        if (value != null) {
                          context.read<SettingsCubit>().updateMadhab(value);
                        }
                      },
                      items: [
                        DropdownMenuItem(
                          value: 'shafi',
                          child: Text(l10n.shafiMadhab, style: const TextStyle(fontSize: 12)),
                        ),
                        DropdownMenuItem(
                          value: 'hanafi',
                          child: Text(l10n.hanafiMadhab, style: const TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: l10n.azanSettings,
                icon: Icons.notifications_active_rounded,
                children: [
                  ...state.salaahSettings.map((salaahSetting) {
                    return _buildSalaahSettingItem(
                      context: context,
                      settings: salaahSetting,
                      l10n: l10n,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: l10n.language,
                icon: Icons.language_rounded,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(state.locale.languageCode == 'ar' ? 'العربية' : 'English'),
                    trailing: Switch(
                      value: state.locale.languageCode == 'en',
                      onChanged: (_) => context.read<SettingsCubit>().toggleLocale(),
                      activeThumbColor: AppTheme.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSection(
                context,
                title: l10n.azkarSettings,
                icon: Icons.notifications_active_rounded,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.azkarSettingsDesc,
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        ),
                      ),
                      TextButton.icon(
                        key: const Key('add_reminder_button'),
                        onPressed: () => _showAddReminderDialog(context),
                        icon: const Icon(Icons.add, size: 20),
                        label: Text(l10n.localeName == 'ar' ? 'إضافة' : 'Add'),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
                      ),
                    ],
                  ),
                  const Divider(height: 12),
                  if (state.reminders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          l10n.localeName == 'ar' ? 'لا توجد تذكيرات' : 'No reminders set',
                          style: const TextStyle(color: AppTheme.textSecondary),
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
              const SizedBox(height: 32),
            ],
          );
        },
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
          final sanitized = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
          if (settings.azanSound!.contains('${sanitized}_azan.mp3')) {
            voiceDisplayName = ' (${entry.key.split(' - ').first})';
            break;
          }
        }
      }
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(salaahName, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${settings.isAzanEnabled ? "${l10n.azan}$voiceDisplayName" : ""} ${settings.isAzanEnabled && settings.isReminderEnabled ? "&" : ""} ${settings.isReminderEnabled ? "${l10n.reminder} (${l10n.minutesBefore(settings.reminderMinutesBefore)})" : ""}',
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () => _showSalaahSettingsDialog(context, settings, l10n),
    );
  }

  String _getLocalizedSalaahName(Salaah salaah, AppLocalizations l10n) {
    switch (salaah) {
      case Salaah.fajr: return l10n.fajr;
      case Salaah.dhuhr: return l10n.dhuhr;
      case Salaah.asr: return l10n.asr;
      case Salaah.maghrib: return l10n.maghrib;
      case Salaah.isha: return l10n.isha;
    }
  }

  void _showSalaahSettingsDialog(BuildContext context, SalaahSettings settings, AppLocalizations l10n) {
    final cubit = context.read<SettingsCubit>();
    
    bool isAzanEnabled = settings.isAzanEnabled;
    bool isReminderEnabled = settings.isReminderEnabled;
    bool isAfterSalahAzkarEnabled = settings.isAfterSalahAzkarEnabled;
    int reminderMinutes = settings.reminderMinutesBefore;
    int afterSalaahMinutes = settings.afterSalaahAzkarMinutes;
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
                style: GoogleFonts.amiri(),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: Text(l10n.enableAzan),
                      value: isAzanEnabled,
                      onChanged: (val) => setDialogState(() => isAzanEnabled = val),
                      activeThumbColor: AppTheme.accent,
                      contentPadding: EdgeInsets.zero,
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
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              initialValue: () {
                                if (selectedVoice == null) return null;
                                for (var key in VoiceDownloadService.azanVoices.keys) {
                                  if (selectedVoice == key) return key;
                                  final sanitized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
                                  if (selectedVoice!.contains('${sanitized}_azan.mp3')) return key;
                                }
                                return null;
                              }(),
                              items: [
                                const DropdownMenuItem(value: null, child: Text('Default')),
                                ...VoiceDownloadService.azanVoices.keys.map((v) => DropdownMenuItem(value: v, child: Text(v))),
                              ],
                              onChanged: (val) async {
                                if (val != null) {
                                  final downloader = getIt<VoiceDownloadService>();
                                  if (!(await downloader.isDownloaded(val))) {
                                    setDialogState(() => isDownloading = true);
                                    final path = await downloader.downloadAzan(val);
                                    if (path != null) {
                                      final accessiblePath = await downloader.getAccessiblePath(val);
                                      setDialogState(() {
                                        isDownloading = false;
                                        if (accessiblePath != null) selectedVoice = accessiblePath;
                                      });
                                    } else {
                                      setDialogState(() => isDownloading = false);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('فشل تحميل صوت الأذان. تأكد من أن الموقع متاح أو حاول اختيار صوت آخر.'),
                                            backgroundColor: AppTheme.missed,
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    final accessiblePath = await downloader.getAccessiblePath(val);
                                    setDialogState(() => selectedVoice = accessiblePath);
                                  }
                                } else {
                                  setDialogState(() => selectedVoice = null);
                                }
                              },
                            ),
                            if (isDownloading)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: LinearProgressIndicator(),
                              ),
                            TextButton.icon(
                              onPressed: isDownloading ? null : () => getIt<NotificationService>().testAzan(settings.salaah, selectedVoice, settings: context.read<SettingsCubit>().state),
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('تجربة الصوت'),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 32),
                    SwitchListTile(
                      title: Text(l10n.enableReminder),
                      value: isReminderEnabled,
                      onChanged: (val) => setDialogState(() => isReminderEnabled = val),
                      activeThumbColor: AppTheme.accent,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (isReminderEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(l10n.minutesBefore(reminderMinutes))),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: reminderMinutes > 1 ? () => setDialogState(() => reminderMinutes--) : null,
                                ),
                                Text('$reminderMinutes'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: reminderMinutes < 60 ? () => setDialogState(() => reminderMinutes++) : null,
                                ),
                              ],
                            ),
                            TextButton.icon(
                              onPressed: () => getIt<NotificationService>().testReminder(settings.salaah, reminderMinutes),
                              icon: const Icon(Icons.notification_important_rounded),
                              label: const Text('تجربة التنبيه'),
                            ),
                          ],
                        ),
                      ),
                    const Divider(height: 32),
                    SwitchListTile(
                      title: Text(l10n.afterSalaahAzkar),
                      value: isAfterSalahAzkarEnabled,
                      onChanged: (val) => setDialogState(() => isAfterSalahAzkarEnabled = val),
                      activeThumbColor: AppTheme.accent,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (isAfterSalahAzkarEnabled)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(l10n.minutesAfter(afterSalaahMinutes))),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: afterSalaahMinutes > 0 ? () => setDialogState(() => afterSalaahMinutes--) : null,
                                ),
                                Text('$afterSalaahMinutes'),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: afterSalaahMinutes < 60 ? () => setDialogState(() => afterSalaahMinutes++) : null,
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
                  child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () {
                    cubit.updateSalaahSettings(settings.copyWith(
                      isAzanEnabled: isAzanEnabled,
                      isReminderEnabled: isReminderEnabled,
                      reminderMinutesBefore: reminderMinutes,
                      isAfterSalahAzkarEnabled: isAfterSalahAzkarEnabled,
                      afterSalaahAzkarMinutes: afterSalaahMinutes,
                      azanSound: selectedVoice,
                    ));
                    Navigator.pop(context);
                  },
                  child: Text(l10n.update),
                ),
              ],
            );
          }
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
          color: reminder.isEnabled ? AppTheme.textPrimary : AppTheme.textSecondary,
        ),
      ),
      subtitle: Text(
        reminder.time,
        style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: reminder.isEnabled,
            onChanged: (_) => cubit.toggleReminder(index),
            activeThumbColor: AppTheme.accent,
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: AppTheme.textSecondary),
            onPressed: () => _showAddReminderDialog(context, index: index, reminder: reminder),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.missed),
            onPressed: () => cubit.removeReminder(index),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context, {int? index, AzkarReminder? reminder}) {
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
                if (selectedCategory.isEmpty && azkarState.categories.isNotEmpty) {
                  selectedCategory = azkarState.categories.first;
                }

                return AlertDialog(
                  title: Text(
                    index == null
                      ? (l10n.localeName == 'ar' ? 'إضافة تذكير' : 'Add Reminder')
                      : (l10n.localeName == 'ar' ? 'تعديل التذكير' : 'Edit Reminder'),
                    style: GoogleFonts.amiri(),
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Searchable Category Selection
                        InkWell(
                          onTap: () => _showSearchableCategoryPicker(
                            context, 
                            azkarState.categories, 
                            (val) {
                              setDialogState(() {
                                selectedCategory = val;
                              });
                            }
                          ),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.localeName == 'ar' ? 'الفئة' : 'Category',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              suffixIcon: const Icon(Icons.search),
                            ),
                            child: Text(
                              selectedCategory.isEmpty ? l10n.selectCategory : selectedCategory,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Custom Title
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: l10n.localeName == 'ar' ? 'عنوان مخصص (اختياري)' : 'Custom Title (Optional)',
                            hintText: selectedCategory,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          initialValue: customTitle,
                          onChanged: (val) => customTitle = val,
                        ),
                        const SizedBox(height: 16),
                        // Time Selection
                        _buildTimeSettingItem(
                          context: context,
                          title: l10n.localeName == 'ar' ? 'الوقت' : 'Time',
                          time: selectedTime,
                          onTap: () async {
                            final time = await _selectTime(context, selectedTime);
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
                      child: Text(l10n.cancel, style: const TextStyle(color: AppTheme.textSecondary)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedCategory.isEmpty) return;

                        final newReminder = AzkarReminder(
                          category: selectedCategory,
                          time: selectedTime,
                          title: customTitle.isNotEmpty ? customTitle : selectedCategory,
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
          }
        );
      },
    );
  }

  void _showSearchableCategoryPicker(BuildContext context, List<String> categories, Function(String) onSelected) {
    final l10n = AppLocalizations.of(context)!;
    String sheetSearchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filteredCategories = categories.where((cat) => 
              sheetSearchQuery.isEmpty || cat.toLowerCase().contains(sheetSearchQuery)
            ).toList();

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.searchCategory,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                      itemCount: filteredCategories.length,
                      itemBuilder: (context, index) {
                        final cat = filteredCategories[index];
                        return ListTile(
                          title: Text(cat, textAlign: l10n.localeName == 'ar' ? TextAlign.right : TextAlign.left),
                          onTap: () {
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

  Widget _buildSection(BuildContext context, {required String title, required IconData icon, required List<Widget> children}) {   
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryLight, size: 20),
              const SizedBox(width: 8),
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
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem({required String title, required String description, required Widget trailing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
            trailing,
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
      ],
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
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
      trailing: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
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
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accent,
              ),
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
