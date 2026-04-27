import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/widgets/custom_toggle.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/prayer_reminder_type.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/presentation/blocs/settings_cubit.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fard/core/mixins/notification_permission_mixin.dart';

class RemindersSettingsScreen extends StatefulWidget {
  const RemindersSettingsScreen({super.key});

  @override
  State<RemindersSettingsScreen> createState() => _RemindersSettingsScreenState();
}

class _RemindersSettingsScreenState extends State<RemindersSettingsScreen> with NotificationPermissionMixin {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.remindersNotifications,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: context.onSurfaceColor,
        centerTitle: true,
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 40.0),
            children: [
              _buildAzanSection(context, state, l10n),
              _buildPrayerRemindersSection(context, state, l10n),
              _buildWerdReminderSection(context, state, l10n),
              _buildSalawatReminderSection(context, state, l10n),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAzanSection(BuildContext context, SettingsState state, AppLocalizations l10n) {
    final cubit = context.read<SettingsCubit>();
    // Use first prayer as proxy for global toggle
    final bool allAzanEnabled = state.salaahSettings.every((s) => s.isAzanEnabled);
    final String? commonVoice = _getCommonVoice(state.salaahSettings);

    return _buildSection(
      context,
      title: l10n.azan,
      icon: Icons.volume_up_rounded,
      accentColor: context.primaryColor,
      children: [
        _buildToggleItem(
          title: l10n.enableAzan,
          value: allAzanEnabled,
          onChanged: (val) async {
            if (val) {
              final granted = await checkAndRequestNotificationPermissions(context);
              if (!granted) return;
            }
            cubit.updateAllAzanEnabled(val);
          },
        ),
        if (allAzanEnabled) ...[
          const SizedBox(height: 16),
          _buildVoiceDropdown(context, commonVoice, l10n, (val) {
            cubit.updateAllAzanSound(val);
          }),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: _isDownloading
                  ? null
                  : () => getIt<NotificationService>().testAzan(
                        Salaah.fajr,
                        commonVoice,
                      ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(l10n.testAzan),
              style: TextButton.styleFrom(foregroundColor: context.secondaryColor),
            ),
          ),
          const Divider(height: 24),
          Text(
            l10n.individualSettings,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...state.salaahSettings.map((s) => _buildIndividualAzanTile(context, s, l10n)),
        ],
      ],
    );
  }

  Widget _buildIndividualAzanTile(BuildContext context, SalaahSettings s, AppLocalizations l10n) {
    final cubit = context.read<SettingsCubit>();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(_getLocalizedSalaahName(s.salaah, l10n)),
      trailing: CustomToggle(
        value: s.isAzanEnabled,
        onChanged: (val) {
          cubit.updateSalaahSettings(s.copyWith(isAzanEnabled: val));
        },
      ),
      onTap: () => _showIndividualAzanDialog(context, s, l10n),
    );
  }

  Widget _buildPrayerRemindersSection(BuildContext context, SettingsState state, AppLocalizations l10n) {
    final cubit = context.read<SettingsCubit>();

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
  }

  Widget _buildWerdReminderSection(BuildContext context, SettingsState state, AppLocalizations l10n) {
    final cubit = context.read<SettingsCubit>();

    return _buildSection(
      context,
      title: l10n.werdReminder,
      icon: Icons.menu_book_rounded,
      accentColor: Colors.deepPurpleAccent,
      children: [
        _buildToggleItem(
          title: l10n.enable,
          value: state.isWerdReminderEnabled,
          onChanged: (val) async {
            if (val) {
              final granted = await checkAndRequestNotificationPermissions(context);
              if (!granted) return;
            }
            cubit.toggleWerdReminder(val);
          },
        ),
        if (state.isWerdReminderEnabled)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.time),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                state.werdReminderTime,
                style: TextStyle(
                  color: context.secondaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            onTap: () async {
              final time = await _selectTime(context, state.werdReminderTime);
              if (time != null) cubit.setWerdReminderTime(time);
            },
          ),
      ],
    );
  }

  Widget _buildSalawatReminderSection(BuildContext context, SettingsState state, AppLocalizations l10n) {
    final cubit = context.read<SettingsCubit>();

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
  }

  // Helper Methods
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                  style: GoogleFonts.amiri(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: context.onSurfaceColor,
                  ),
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

  Widget _buildSettingItem({required String title, required String description, required Widget trailing}) {
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

  String? _getCommonVoice(List<SalaahSettings> settings) {
    if (settings.isEmpty) return null;
    final first = settings.first.azanSound;
    return settings.every((s) => s.azanSound == first) ? first : null;
  }

  Widget _buildVoiceDropdown(BuildContext context, String? currentVoice, AppLocalizations l10n, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String?>(
      initialValue: _resolveVoiceKey(currentVoice),
      decoration: InputDecoration(
        labelText: l10n.azanVoice,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: context.surfaceContainerHighestColor,
      ),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.defaultVal)),
        ...VoiceDownloadService.azanVoices.keys.map((v) {
          final parts = v.split(' - ');
          final displayName = l10n.localeName == 'ar' ? (parts.length > 1 ? parts[1] : parts[0]) : parts[0];
          return DropdownMenuItem(value: v, child: Text(displayName));
        }),
      ],
      onChanged: (val) async {
        if (val == null) {
          onChanged(null);
          return;
        }
        final downloader = getIt<VoiceDownloadService>();
        if (!(await downloader.isDownloaded(val))) {
          setState(() => _isDownloading = true);
          final path = await downloader.downloadAzan(val);
          setState(() => _isDownloading = false);
          if (path != null) {
            onChanged(await downloader.getAccessiblePath(val));
          }
        } else {
          onChanged(await downloader.getAccessiblePath(val));
        }
      },
    );
  }

  String? _resolveVoiceKey(String? path) {
    if (path == null) return null;
    for (var entry in VoiceDownloadService.azanVoices.entries) {
      if (path == entry.key) return entry.key;
      final uri = Uri.parse(entry.value);
      if (path.contains('voice_${uri.pathSegments.last}')) return entry.key;
      final sanitized = entry.key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
      if (path.contains('${sanitized}_azan.mp3')) return entry.key;
    }
    return null;
  }

  void _showIndividualAzanDialog(BuildContext context, SalaahSettings s, AppLocalizations l10n) {
    final cubit = context.read<SettingsCubit>();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_getLocalizedSalaahName(s.salaah, l10n)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildVoiceDropdown(context, s.azanSound, l10n, (val) {
              cubit.updateSalaahSettings(s.copyWith(azanSound: val));
            }),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.close)),
        ],
      ),
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
