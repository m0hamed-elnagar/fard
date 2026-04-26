import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/extensions/salaah_extension.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class RemindersSettingsDialog extends StatelessWidget {
  const RemindersSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const RemindersSettingsDialog(),
    );
  }

  void _showReminderSnackBar(
    BuildContext context,
    String title,
    bool enabled, {
    String? customMessage,
  }) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final String status =
        enabled ? (isAr ? 'مفعل' : 'Enabled') : (isAr ? 'معطل' : 'Disabled');

    final String message =
        customMessage ?? (enabled ? '$title: $status' : '$title: $status');

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              enabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: context.secondaryColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.amiri(
                  color: context.onSurfaceColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: context.surfaceContainerHighestColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Dialog(
          backgroundColor: context.surfaceColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                Text(
                  isAr ? 'إعدادات التذكيرات' : 'Reminders Settings',
                  style: GoogleFonts.amiri(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: context.onSurfaceColor,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle(
                          isAr ? 'تذكيرات الصلاة' : 'Salah Reminders',
                          context,
                        ),
                        _buildSwitchTile(
                          isAr
                              ? 'تفعيل التذكير بعد الصلاة'
                              : 'Post-Prayer Reminders',
                          isAr
                              ? 'تذكير لتسجيل الصلاة في المتتبع'
                              : 'Reminder to log prayer in tracker',
                          state.isSalahReminderEnabled,
                          (val) {
                            context
                                .read<SettingsCubit>()
                                .toggleSalahReminder(val);
                            _showReminderSnackBar(
                              context,
                              isAr ? 'تذكيرات الصلاة' : 'Salah Reminders',
                              val,
                              customMessage: val
                                  ? (isAr
                                      ? 'سنذكرك بتسجيل صلواتك بعد الأذان بـ ${state.salahReminderOffsetMinutes} دقيقة'
                                      : 'We will remind you to log prayers ${state.salahReminderOffsetMinutes}m after Azan')
                                  : (isAr
                                      ? 'تم إيقاف تذكيرات تسجيل الصلاة'
                                      : 'Post-prayer logging reminders disabled'),
                            );
                          },
                          context,
                        ),
                        if (state.isSalahReminderEnabled) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAr
                                      ? 'التذكير بعد ${state.salahReminderOffsetMinutes} دقيقة'
                                      : 'Remind after ${state.salahReminderOffsetMinutes} minutes',
                                  style: TextStyle(
                                    color: context.onSurfaceVariantColor,
                                    fontSize: 13,
                                  ),
                                ),
                                Slider(
                                  value:
                                      state.salahReminderOffsetMinutes
                                          .toDouble(),
                                  min: 5,
                                  max: 60,
                                  divisions: 11,
                                  activeColor: context.secondaryColor,
                                  onChanged:
                                      (val) => context
                                          .read<SettingsCubit>()
                                          .setSalahReminderOffset(val.round()),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Wrap(
                              spacing: 8,
                              children:
                                  Salaah.values.map((s) {
                                    final isEnabled = state
                                        .enabledSalahReminders
                                        .contains(s);
                                    return FilterChip(
                                      label: Text(s.localizedName(l10n)),
                                      selected: isEnabled,
                                      onSelected: (val) {
                                        context
                                            .read<SettingsCubit>()
                                            .toggleSpecificSalahReminder(s);
                                        _showReminderSnackBar(
                                          context,
                                          s.localizedName(l10n),
                                          val,
                                          customMessage:
                                              val
                                                  ? (isAr
                                                      ? 'سنذكرك بتسجيل ${s.localizedName(l10n)} بعد الأذان'
                                                      : 'We will remind you to log ${s.localizedName(l10n)} after Azan')
                                                  : (isAr
                                                      ? 'تم إيقاف تذكير ${s.localizedName(l10n)}'
                                                      : 'Reminder for ${s.localizedName(l10n)} disabled'),
                                        );
                                      },
                                      selectedColor: context.secondaryColor
                                          .withValues(alpha: 0.2),
                                      checkmarkColor: context.secondaryColor,
                                      labelStyle: TextStyle(
                                        fontSize: 12,
                                        color:
                                            isEnabled
                                                ? context.secondaryColor
                                                : context.onSurfaceColor,
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ],
                        const Divider(height: 32),
                        _buildSectionTitle(
                          isAr ? 'الورد اليومي' : 'Daily Werd',
                          context,
                        ),
                        _buildSwitchTile(
                          isAr ? 'تذكير الورد اليومي' : 'Werd Reminder',
                          isAr
                              ? 'تذكير بقراءة وردك اليومي'
                              : 'Reminder to read your daily werd',
                          state.isWerdReminderEnabled,
                          (val) {
                            context
                                .read<SettingsCubit>()
                                .toggleWerdReminder(val);
                            _showReminderSnackBar(
                              context,
                              isAr ? 'تذكير الورد' : 'Werd Reminder',
                              val,
                              customMessage:
                                  val
                                      ? (isAr
                                          ? 'سنذكرك بوردك اليومي في الساعة ${state.werdReminderTime}'
                                          : 'Daily Werd reminder set for ${state.werdReminderTime}')
                                      : (isAr
                                          ? 'تم إيقاف تذكير الورد اليومي'
                                          : 'Daily Werd reminder disabled'),
                            );
                          },
                          context,
                        ),
                        if (state.isWerdReminderEnabled)
                          ListTile(
                            title: Text(isAr ? 'وقت التذكير' : 'Reminder Time'),
                            subtitle: Text(state.werdReminderTime),
                            trailing: const Icon(Icons.access_time_rounded),
                            onTap: () async {
                              final time = await _selectTime(
                                context,
                                state.werdReminderTime,
                              );
                              if (time != null && context.mounted) {
                                context
                                    .read<SettingsCubit>()
                                    .setWerdReminderTime(time);
                                _showReminderSnackBar(
                                  context,
                                  isAr ? 'وقت الورد' : 'Werd Time',
                                  true,
                                  customMessage:
                                      isAr
                                          ? 'تم تحديث وقت تذكير الورد إلى $time'
                                          : 'Werd reminder time updated to $time',
                                );
                              }
                            },
                          ),
                        const Divider(height: 32),
                        _buildSectionTitle(
                          isAr ? 'الصلاة على النبي ﷺ' : 'Salawat Reminders',
                          context,
                        ),
                        _buildSwitchTile(
                          isAr
                              ? 'تفعيل تذكير الصلاة على النبي'
                              : 'Salawat Reminders',
                          isAr
                              ? 'تذكير دوري بالصلاة على النبي ﷺ'
                              : 'Periodic reminders to send Salawat',
                          state.isSalawatReminderEnabled,
                          (val) {
                            context
                                .read<SettingsCubit>()
                                .toggleSalawatReminder(val);
                            _showReminderSnackBar(
                              context,
                              isAr ? 'الصلاة على النبي' : 'Salawat Reminder',
                              val,
                              customMessage:
                                  val
                                      ? (isAr
                                          ? 'تذكير دوري بالصلاة على النبي ﷺ كل ${state.salawatFrequencyHours} ساعات'
                                          : 'Periodic Salawat reminders enabled every ${state.salawatFrequencyHours} hours')
                                      : (isAr
                                          ? 'تم إيقاف تذكير الصلاة على النبي'
                                          : 'Salawat reminders disabled'),
                            );
                          },
                          context,
                        ),
                      if (state.isSalawatReminderEnabled) ...[
                        ListTile(
                          title: Text(isAr ? 'التكرار كل' : 'Frequency'),
                          subtitle: Text(
                            isAr
                                ? '${state.salawatFrequencyHours} ساعات'
                                : 'Every ${state.salawatFrequencyHours} hours',
                          ),
                          trailing: DropdownButton<int>(
                            value: state.salawatFrequencyHours,
                            underline: const SizedBox(),
                            items: [1, 2, 3, 4, 6].map((h) => DropdownMenuItem(
                              value: h,
                              child: Text(isAr ? '$h ساعات' : '$h hours'),
                            )).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                context
                                    .read<SettingsCubit>()
                                    .setSalawatFrequency(val);
                              }
                            },
                          ),
                        ),
                        ListTile(
                          title: Text(isAr ? 'من وقت' : 'Start Time'),
                          subtitle: Text(state.salawatStartTime),
                          trailing: const Icon(Icons.access_time_rounded),
                          onTap: () async {
                            final time = await _selectTime(
                              context,
                              state.salawatStartTime,
                            );
                            if (time != null && context.mounted) {
                              context
                                  .read<SettingsCubit>()
                                  .setSalawatStartTime(time);
                            }
                          },
                        ),
                        ListTile(
                          title: Text(isAr ? 'إلى وقت' : 'End Time'),
                          subtitle: Text(state.salawatEndTime),
                          trailing: const Icon(Icons.access_time_rounded),
                          onTap: () async {
                            final time = await _selectTime(
                              context,
                              state.salawatEndTime,
                            );
                            if (time != null && context.mounted) {
                              context
                                  .read<SettingsCubit>()
                                  .setSalawatEndTime(time);
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.amiri(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.secondaryColor,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    BuildContext context,
  ) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: context.onSurfaceVariantColor, fontSize: 12),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: context.secondaryColor,
    );
  }

  Future<String?> _selectTime(BuildContext context, String current) async {
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return null;
    return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
  }
}
