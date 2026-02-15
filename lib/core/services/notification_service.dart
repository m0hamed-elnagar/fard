import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../features/settings/presentation/blocs/settings_state.dart';
import '../../features/azkar/domain/azkar_item.dart';
import '../../features/azkar/presentation/screens/azkar_list_screen.dart';
import '../di/injection.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
      appName: 'Fard',
      appUserModelId: 'com.nagar.fard',
      guid: 'f0c0f0f0-0f0f-0f0f-0f0f-0f0f0f0f0f0f',
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      windows: initializationSettingsWindows,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final navigatorKey = getIt<GlobalKey<NavigatorState>>();
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (_) => AzkarListScreen(category: details.payload!),
              ),
            );
          }
        }
      },
    );
  }

  Future<void> scheduleAzkarReminders({
    required SettingsState settings, 
    required List<AzkarItem> allAzkar,
  }) async {
    // Cancel previous azkar notifications in the range we use
    for (int i = 0; i < 50; i++) {
      await _notificationsPlugin.cancel(id: 100 + i);
    }

    final now = DateTime.now();
    
    for (int i = 0; i < settings.reminders.length; i++) {
      if (i >= 50) break; // Limit to 50 reminders for safety with IDs
      
      final reminder = settings.reminders[i];
      if (!reminder.isEnabled) continue;

      DateTime scheduledDateTime = _parseTime(reminder.time, now);
      
      // Try to find the exact category or one that contains it
      final matchedCategory = allAzkar.firstWhere(
        (e) => e.category == reminder.category || e.category.contains(reminder.category),
        orElse: () => AzkarItem(category: reminder.category, zekr: '', description: '', count: 1, reference: ''),
      ).category;

      final zekrBody = _getRandomZekr(allAzkar, reminder.category);

      await _scheduleDailyNotification(
        id: 100 + i,
        title: reminder.title.isNotEmpty ? reminder.title : matchedCategory,
        body: zekrBody,
        scheduledDate: scheduledDateTime,
        payload: matchedCategory,
      );
    }
  }

  Future<void> _scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    var scheduledTzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    
    if (scheduledTzDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledTzDate = scheduledTzDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTzDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'azkar_reminders',
          'Azkar Reminders',
          channelDescription: 'Daily Azkar notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
        windows: WindowsNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  String _getRandomZekr(List<AzkarItem> azkar, String category) {
    final filtered = azkar.where((e) => e.category == category || e.category.contains(category)).toList();
    if (filtered.isEmpty) return 'حان وقت الأذكار';
    // Use a simple zekr if it's too long for a notification body
    final item = filtered[Random().nextInt(filtered.length)];
    return item.zekr.length > 100 ? item.zekr.substring(0, 100) + '...' : item.zekr;
  }

  DateTime _parseTime(String timeStr, DateTime now) {
    try {
      final parts = timeStr.split(':');
      return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
    } catch (_) {
      return now;
    }
  }
}
