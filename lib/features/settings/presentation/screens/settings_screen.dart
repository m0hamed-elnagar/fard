import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/azkar/presentation/blocs/azkar_bloc.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<AzkarBloc>().add(const AzkarEvent.loadCategories());
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
              _buildSection(
                context,
                title: l10n.locationSettings,
                icon: Icons.location_on_rounded,
                children: [
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
            activeColor: AppTheme.accent,
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
                    // Category Selection
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: l10n.localeName == 'ar' ? 'الفئة' : 'Category',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      value: selectedCategory.isNotEmpty && azkarState.categories.contains(selectedCategory) 
                        ? selectedCategory 
                        : (azkarState.categories.isNotEmpty ? azkarState.categories.first : null),
                      items: azkarState.categories.map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Text(cat, style: const TextStyle(fontSize: 14)),
                      )).toList(),
                      onChanged: (val) => selectedCategory = val ?? '',
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
                    StatefulBuilder(
                      builder: (context, setState) {
                        return _buildTimeSettingItem(
                          context: context,
                          title: l10n.localeName == 'ar' ? 'الوقت' : 'Time',
                          time: selectedTime,
                          onTap: () async {
                            final time = await _selectTime(context, selectedTime);
                            if (time != null) {
                              setState(() => selectedTime = time);
                            }
                          },
                        );
                      }
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
