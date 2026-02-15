import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_theme.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        buildWhen: (previous, current) =>
            previous.cityName != current.cityName ||
            previous.calculationMethod != current.calculationMethod ||
            previous.madhab != current.madhab ||
            previous.locale != current.locale ||
            previous.morningAzkarTime != current.morningAzkarTime ||
            previous.eveningAzkarTime != current.eveningAzkarTime ||
            previous.autoAzkarTimes != current.autoAzkarTimes,
        builder: (context, state) {
          String morningTimeToShow = state.morningAzkarTime;
          String eveningTimeToShow = state.eveningAzkarTime;

          if (state.autoAzkarTimes && state.latitude != null && state.longitude != null) {
            try {
              final now = DateTime.now();
              final prayerTimes = getIt<PrayerTimeService>().getPrayerTimes(
                latitude: state.latitude!,
                longitude: state.longitude!,
                method: state.calculationMethod,
                madhab: state.madhab,
                date: now,
              );
              morningTimeToShow = DateFormat.Hm().format(prayerTimes.fajr);
              eveningTimeToShow = DateFormat.Hm().format(prayerTimes.asr);
            } catch (e) {
              // Fallback to state times if prayer times calculation fails
            }
          }

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
                  Text(
                    l10n.azkarSettingsDesc,
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.autoAzkarTimes, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
                    subtitle: Text(l10n.autoAzkarTimesDesc, style: const TextStyle(fontSize: 12)),
                    value: state.autoAzkarTimes,
                    onChanged: (_) => context.read<SettingsCubit>().toggleAutoAzkarTimes(),
                    activeThumbColor: AppTheme.accent,
                  ),
                  if (state.autoAzkarTimes) ...[
                    const Divider(height: 24),
                    _buildInfoItem(
                      title: l10n.morningAzkar,
                      time: morningTimeToShow,
                      icon: Icons.wb_sunny_rounded,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoItem(
                      title: l10n.eveningAzkar,
                      time: eveningTimeToShow,
                      icon: Icons.nightlight_round,
                    ),
                  ] else ...[
                    const Divider(height: 24),
                    _buildTimeSettingItem(
                      context: context,
                      title: l10n.morningAzkar,
                      time: state.morningAzkarTime,
                      onTap: () async {
                        final time = await _selectTime(context, state.morningAzkarTime);
                        if (time != null && context.mounted) {
                          context.read<SettingsCubit>().updateMorningAzkarTime(time);
                        }
                      },
                    ),
                    const Divider(height: 24),
                    _buildTimeSettingItem(
                      context: context,
                      title: l10n.eveningAzkar,
                      time: state.eveningAzkarTime,
                      onTap: () async {
                        final time = await _selectTime(context, state.eveningAzkarTime);
                        if (time != null && context.mounted) {
                          context.read<SettingsCubit>().updateEveningAzkarTime(time);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoItem({required String title, required String time, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const Spacer(),
          Text(
            time,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
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
      trailing: Container(
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
