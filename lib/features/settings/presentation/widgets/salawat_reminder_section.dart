import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toggle.dart';
import '../../../../core/widgets/fard_list_tile.dart';
import '../../../../core/widgets/expandable_section_card.dart';
import '../../../../core/mixins/notification_permission_mixin.dart';
import '../../../../core/utils/time_utils.dart';
import '../blocs/daily_reminders_cubit.dart';
import '../blocs/daily_reminders_state.dart';

class SalawatReminderSection extends StatelessWidget
    with NotificationPermissionMixin {
  const SalawatReminderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<DailyRemindersCubit, DailyRemindersState>(
      builder: (context, state) {
        final cubit = context.read<DailyRemindersCubit>();
        return ExpandableSectionCard(
          title: l10n.salawatReminder,
          icon: Icons.favorite_rounded,
          accentColor: Colors.teal,
          children: [
            _buildToggleItem(
              title: l10n.enable,
              value: state.isSalawatReminderEnabled,
              onChanged: (val) async {
                cubit.toggleSalawatReminder(val);
                if (val) {
                  final granted = await checkAndRequestNotificationPermissions(
                    context,
                  );
                  if (!granted) {
                    if (context.mounted) {
                      cubit.toggleSalawatReminder(false);
                    }
                  }
                }
              },
              context: context,
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
                  onChanged: (val) =>
                      val != null ? cubit.setSalawatFrequency(val) : null,
                  underline: const SizedBox(),
                ),
              ),
              const Divider(height: 24),
              Text(
                l10n.activeWindow,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: context.onSurfaceColor,
                ),
              ),
              Text(
                l10n.activeWindowDesc,
                style: TextStyle(
                  fontSize: 12,
                  color: context.onSurfaceVariantColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: FardListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.startTime,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.onSurfaceColor,
                        ),
                      ),
                      subtitle: Text(
                        TimeUtils.formatTo12Hour(state.salawatStartTime),
                        style: TextStyle(
                          color: context.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        final time = await _selectTime(
                          context,
                          state.salawatStartTime,
                        );
                        if (time != null) cubit.setSalawatStartTime(time);
                      },
                    ),
                  ),
                  Expanded(
                    child: FardListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.endTime,
                        style: TextStyle(
                          fontSize: 13,
                          color: context.onSurfaceColor,
                        ),
                      ),
                      subtitle: Text(
                        TimeUtils.formatTo12Hour(state.salawatEndTime),
                        style: TextStyle(
                          color: context.secondaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () async {
                        final time = await _selectTime(
                          context,
                          state.salawatEndTime,
                        );
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



  Widget _buildToggleItem({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    BuildContext? context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: context?.onSurfaceColor,
          ),
        ),
        CustomToggle(value: value, onChanged: onChanged),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required String description,
    required Widget trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: context.onSurfaceVariantColor,
                ),
              ),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  Future<String?> _selectTime(BuildContext context, String currentTime) async {
    final parts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }
}
