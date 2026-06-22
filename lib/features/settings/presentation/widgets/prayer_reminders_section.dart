import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_toggle.dart';
import '../../../../core/widgets/expandable_section_card.dart';
import '../../../../core/mixins/notification_permission_mixin.dart';
import '../../../../core/extensions/salaah_extension.dart';
import '../../../prayer_tracking/domain/salaah.dart';
import '../blocs/daily_reminders_cubit.dart';
import '../blocs/daily_reminders_state.dart';

class PrayerRemindersSection extends StatelessWidget
    with NotificationPermissionMixin {
  const PrayerRemindersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    return BlocBuilder<DailyRemindersCubit, DailyRemindersState>(
      builder: (context, state) {
        final cubit = context.read<DailyRemindersCubit>();
        return ExpandableSectionCard(
          title: l10n.reminder,
          icon: Icons.notification_important_rounded,
          accentColor: context.secondaryColor,
          children: [
            // Before Azan Reminder Card
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: state.isBeforeSalahReminderEnabled
                    ? context.primaryColor.withValues(alpha: 0.04)
                    : context.surfaceContainerHighestColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: state.isBeforeSalahReminderEnabled
                      ? context.primaryColor.withValues(alpha: 0.15)
                      : context.outlineColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildToggleItem(
                    title: isAr ? 'تذكير قبل الأذان' : 'Before Azan Reminder',
                    subtitle: isAr
                        ? 'تنبيهك قبل دخول وقت الصلاة'
                        : 'Get notified before the prayer time starts',
                    value: state.isBeforeSalahReminderEnabled,
                    onChanged: (val) async {
                      if (val) {
                        final granted = await checkAndRequestNotificationPermissions(context);
                        if (!granted) return;
                      }
                      cubit.toggleBeforeSalahReminder(val);
                    },
                    context: context,
                  ),
                  if (state.isBeforeSalahReminderEnabled) ...[
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      isAr ? 'تذكير لصلوات:' : 'Remind me for:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: context.onSurfaceColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: Salaah.values.map((s) {
                        final isEnabled = state.enabledBeforeSalahReminders.contains(s);
                        return FilterChip(
                          label: Text(_getLocalizedSalaahName(s, l10n)),
                          selected: isEnabled,
                          onSelected: (_) => cubit.toggleSpecificBeforeSalahReminder(s),
                          selectedColor: context.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: context.primaryColor,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isEnabled
                                ? context.primaryColor
                                : context.onSurfaceColor,
                            fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            
            // Grouped After Salah Azkar Container Card
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: state.isAfterSalahAzkarEnabled
                    ? context.primaryColor.withValues(alpha: 0.04)
                    : context.surfaceContainerHighestColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: state.isAfterSalahAzkarEnabled
                      ? context.primaryColor.withValues(alpha: 0.15)
                      : context.outlineColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildToggleItem(
                    title: l10n.afterSalahAzkar,
                    subtitle: l10n.afterSalahAzkarDesc,
                    value: state.isAfterSalahAzkarEnabled,
                    onChanged: (val) async {
                      if (val) {
                        final granted = await checkAndRequestNotificationPermissions(context);
                        if (!granted) return;
                      }
                      cubit.toggleAfterSalahAzkar();
                    },
                    context: context,
                  ),
                  if (state.isAfterSalahAzkarEnabled) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.hourglass_top_rounded,
                          size: 14,
                          color: context.onSurfaceVariantColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${l10n.offset}: ${state.salahReminderOffsetMinutes} ${l10n.werdMinSuffix}",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: context.onSurfaceColor.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3.0,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                      ),
                      child: Slider(
                        value: state.salahReminderOffsetMinutes.toDouble(),
                        min: 5,
                        max: 60,
                        divisions: 11,
                        activeColor: context.secondaryColor,
                        inactiveColor: context.outlineColor.withValues(alpha: 0.2),
                        label: state.salahReminderOffsetMinutes.toString(),
                        onChanged: (val) => cubit.setSalahReminderOffset(val.round()),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      isAr ? 'تذكير لصلوات:' : 'Remind me for:',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: context.onSurfaceColor.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: Salaah.values.map((s) {
                        final isEnabled = state.enabledSalahReminders.contains(s);
                        return FilterChip(
                          label: Text(_getLocalizedSalaahName(s, l10n)),
                          selected: isEnabled,
                          onSelected: (_) => cubit.toggleSpecificSalahReminder(s),
                          selectedColor: context.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          checkmarkColor: context.primaryColor,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: isEnabled
                                ? context.primaryColor
                                : context.onSurfaceColor,
                            fontWeight: isEnabled ? FontWeight.bold : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }



  Widget _buildToggleItem({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required BuildContext context,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.onSurfaceColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.onSurfaceVariantColor,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        CustomToggle(value: value, onChanged: onChanged),
      ],
    );
  }

  String _getLocalizedSalaahName(Salaah salaah, AppLocalizations l10n) {
    return salaah.localizedName(l10n);
  }
}
