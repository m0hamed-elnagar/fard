import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/theme/app_colors.dart';
import 'package:fard/features/settings/presentation/widgets/adhan_section.dart';
import 'package:fard/features/settings/presentation/widgets/prayer_reminders_section.dart';
import 'package:fard/features/settings/presentation/widgets/werd_reminder_section.dart';
import 'package:fard/features/settings/presentation/widgets/salawat_reminder_section.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RemindersSettingsScreen extends StatelessWidget {
  const RemindersSettingsScreen({super.key});

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
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 40.0),
        children: const [
          AdhanSection(),
          PrayerRemindersSection(),
          WerdReminderSection(),
          SalawatReminderSection(),
        ],
      ),
    );
  }
}
