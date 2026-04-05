import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/notification_service.dart';
import '../../../azkar/data/azkar_source.dart';

/// Use case: Syncs the notification schedule for prayers + azkar reminders.
///
/// Encapsulates:
/// 1. Fetching all azkar from the repository
/// 2. Scheduling azkar reminders
/// 3. Scheduling prayer time notifications
@injectable
class SyncNotificationSchedule {
  final NotificationService _notificationService;
  final IAzkarSource _azkarRepository;

  SyncNotificationSchedule(this._notificationService, this._azkarRepository);

  /// Schedules both prayer notifications and azkar reminders.
  Future<void> execute() async {
    final azkar = await _azkarRepository.getAllAzkar();
    await _notificationService.scheduleAzkarReminders(allAzkar: azkar);
    await _notificationService.schedulePrayerNotifications();
  }

  /// Initializes reminders with a small delay to avoid blocking the main thread.
  Future<void> init() async {
    try {
      // Short delay to avoid blocking UI transitions
      await Future.delayed(const Duration(milliseconds: 50));
      await execute();
    } catch (e) {
      debugPrint('Error initializing reminders: $e');
    }
  }
}
