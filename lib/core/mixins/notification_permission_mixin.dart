import 'package:fard/core/di/injection.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

mixin NotificationPermissionMixin {
  Future<bool> checkAndRequestNotificationPermissions(
    BuildContext context,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final notificationService = getIt<NotificationService>();

    final isEnabled = await notificationService.areNotificationsEnabled();
    final canSchedule = await notificationService.canScheduleExactNotifications();

    if (isEnabled && canSchedule) {
      return true;
    }

    // If not enabled, show a dialog explaining why we need it
    if (!context.mounted) return false;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.notificationsRequiredTitle,
          style: GoogleFonts.amiri(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.notificationsRequiredDesc,
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.later),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.enable),
          ),
        ],
      ),
    );

    if (result == true) {
      return await notificationService.requestPermissions();
    }

    return false;
  }
}
