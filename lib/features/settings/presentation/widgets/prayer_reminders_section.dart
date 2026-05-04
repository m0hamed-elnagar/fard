import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toggle.dart';
import '../../../../core/mixins/notification_permission_mixin.dart';
import '../../../prayer_tracking/domain/salaah.dart';
import '../../domain/prayer_reminder_type.dart';
import '../blocs/daily_reminders_cubit.dart';
import '../blocs/daily_reminders_state.dart';

class PrayerRemindersSection extends StatelessWidget with NotificationPermissionMixin {
  const PrayerRemindersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<DailyRemindersCubit, DailyRemindersState>(
      builder: (context, state) {
        final cubit = context.read<DailyRemindersCubit>();
        return _buildSection(
          context,
          title: l10n.reminder,
          icon: Icons.notification_important_rounded,
          accentColor: context.secondaryColor,
          children: [
            _buildToggleItem(
              title: l10n.enableReminder,
              value: state.isSalahReminderEnabled,
              onChanged: (val) async {
                if (val) {
                  final granted = await checkAndRequestNotificationPermissions(context);
                  if (!granted) return;
                }
                cubit.toggleSalahReminder(val);
              },
            ),
            if (state.isSalahReminderEnabled) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.reminderType, style: const TextStyle(fontWeight: FontWeight.w500)),
                  SegmentedButton<PrayerReminderType>(
                    segments: [
                      ButtonSegment(
                        value: PrayerReminderType.before,
                        label: Text(l10n.beforeAzan),
                      ),
                      ButtonSegment(
                        value: PrayerReminderType.after,
                        label: Text(l10n.afterAzan),
                      ),
                    ],
                    selected: {state.prayerReminderType},
                    onSelectionChanged: (set) => cubit.setPrayerReminderType(set.first),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text("${l10n.offset}: ${state.salahReminderOffsetMinutes} ${l10n.werdMinSuffix}"),
              Slider(
                value: state.salahReminderOffsetMinutes.toDouble(),
                min: 0,
                max: 60,
                divisions: 12,
                label: state.salahReminderOffsetMinutes.toString(),
                onChanged: (val) => cubit.setSalahReminderOffset(val.toInt()),
              ),
              const Divider(height: 24),
              Wrap(
                spacing: 8,
                children: Salaah.values.map((s) {
                  final isEnabled = state.enabledSalahReminders.contains(s);
                  return FilterChip(
                    label: Text(_getLocalizedSalaahName(s, l10n)),
                    selected: isEnabled,
                    onSelected: (_) => cubit.toggleSpecificSalahReminder(s),
                    selectedColor: context.primaryContainerColor.withValues(alpha: 0.2),
                    checkmarkColor: context.primaryColor,
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
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
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
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

  Widget _buildToggleItem({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        CustomToggle(value: value, onChanged: onChanged),
      ],
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
}
