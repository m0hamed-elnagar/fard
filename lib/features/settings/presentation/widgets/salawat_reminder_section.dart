import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toggle.dart';
import '../../../../core/mixins/notification_permission_mixin.dart';
import '../blocs/daily_reminders_cubit.dart';
import '../blocs/daily_reminders_state.dart';

class SalawatReminderSection extends StatelessWidget with NotificationPermissionMixin {
  const SalawatReminderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<DailyRemindersCubit, DailyRemindersState>(
      builder: (context, state) {
        final cubit = context.read<DailyRemindersCubit>();
        return _buildSection(
          context,
          title: l10n.salawatReminder,
          icon: Icons.favorite_rounded,
          accentColor: Colors.teal,
          children: [
            _buildToggleItem(
              title: l10n.enable,
              value: state.isSalawatReminderEnabled,
              onChanged: (val) async {
                if (val) {
                  final granted = await checkAndRequestNotificationPermissions(context);
                  if (!granted) return;
                }
                cubit.toggleSalawatReminder(val);
              },
            ),
            if (state.isSalawatReminderEnabled) ...[
              const SizedBox(height: 12),
              _buildSettingItem(
                context,
                title: l10n.frequency,
                description: l10n.salawatReminderDesc,
                trailing: DropdownButton<int>(
                  value: state.salawatFrequencyHours,
                  items: [1, 2, 3, 5, 8, 12].map((h) {
                    return DropdownMenuItem(
                      value: h,
                      child: Text(l10n.everyHour(h)),
                    );
                  }).toList(),
                  onChanged: (val) => val != null ? cubit.setSalawatFrequency(val) : null,
                  underline: const SizedBox(),
                ),
              ),
              const Divider(height: 24),
              Text(l10n.activeWindow, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(l10n.activeWindowDesc, style: TextStyle(fontSize: 12, color: context.onSurfaceVariantColor)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.startTime, style: const TextStyle(fontSize: 13)),
                      subtitle: Text(state.salawatStartTime, style: TextStyle(color: context.secondaryColor, fontWeight: FontWeight.bold)),
                      onTap: () async {
                        final time = await _selectTime(context, state.salawatStartTime);
                        if (time != null) cubit.setSalawatStartTime(time);
                      },
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.endTime, style: const TextStyle(fontSize: 13)),
                      subtitle: Text(state.salawatEndTime, style: TextStyle(color: context.secondaryColor, fontWeight: FontWeight.bold)),
                      onTap: () async {
                        final time = await _selectTime(context, state.salawatEndTime);
                        if (time != null) cubit.setSalawatEndTime(time);
                      },
                    ),
                  ),
                ],
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

  Widget _buildSettingItem(BuildContext context, {required String title, required String description, required Widget trailing}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(description, style: TextStyle(fontSize: 12, color: context.onSurfaceVariantColor)),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  Future<String?> _selectTime(BuildContext context, String currentTime) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    final picked = await showTimePicker(context: context, initialTime: initialTime);
    if (picked != null) {
      return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }
}
