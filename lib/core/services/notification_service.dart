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
    await _notificationsPlugin.cancel(id: 100); 
    await _notificationsPlugin.cancel(id: 101); 

    final now = DateTime.now();
    
    DateTime morningDateTime = _parseTime(settings.morningAzkarTime, now);
    DateTime eveningDateTime = _parseTime(settings.eveningAzkarTime, now);

    final morningCategory = allAzkar.firstWhere(
      (e) => e.category.contains('الصباح') || e.category.contains('Morning'),
      orElse: () => const AzkarItem(category: 'Morning Azkar', zekr: '', description: '', count: 1, reference: ''),
    ).category;

    final eveningCategory = allAzkar.firstWhere(
      (e) => e.category.contains('المساء') || e.category.contains('Evening'),
      orElse: () => const AzkarItem(category: 'Evening Azkar', zekr: '', description: '', count: 1, reference: ''),
    ).category;

    final morningZekr = _getRandomZekr(allAzkar, 'الصباح', 'Morning');
    final eveningZekr = _getRandomZekr(allAzkar, 'المساء', 'Evening');

    await _scheduleDailyNotification(
      id: 100,
      title: settings.locale.languageCode == 'ar' ? 'أذكار الصباح' : 'Morning Azkar',
      body: morningZekr,
      scheduledDate: morningDateTime,
      payload: morningCategory,
    );

    await _scheduleDailyNotification(
      id: 101,
      title: settings.locale.languageCode == 'ar' ? 'أذكار المساء' : 'Evening Azkar',
      body: eveningZekr,
      scheduledDate: eveningDateTime,
      payload: eveningCategory,
    );
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

  String _getRandomZekr(List<AzkarItem> azkar, String arKey, String enKey) {
    final filtered = azkar.where((e) => e.category.contains(arKey) || e.category.contains(enKey)).toList();
    if (filtered.isEmpty) return 'حان وقت الأذكار';
    return filtered[Random().nextInt(filtered.length)].zekr;
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
