import 'dart:math';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../features/settings/presentation/blocs/settings_state.dart';
import '../../features/azkar/domain/azkar_item.dart';
import '../../features/azkar/presentation/screens/azkar_list_screen.dart';
import '../di/injection.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotificationService([FlutterLocalNotificationsPlugin? notificationsPlugin])
      : _notificationsPlugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin();

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
            if (details.payload!.startsWith('category:')) {
              final category = details.payload!.replaceFirst('category:', '');
              navigatorKey.currentState!.push(
                MaterialPageRoute(
                  builder: (_) => AzkarListScreen(category: category),
                ),
              );
            }
          }
        }
      },
    );

    // Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    const androidPlatformChannelSpecifics = AndroidNotificationChannel(
      'azan_channel',
      'Azan Notifications',
      description: 'Channel for Azan calls',
      importance: Importance.max,
      playSound: true,
      // Sound will be set per notification for custom Azan
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidPlatformChannelSpecifics);
        
    const reminderChannel = AndroidNotificationChannel(
      'prayer_reminders',
      'Prayer Reminders',
      description: 'Notifications before prayer time',
      importance: Importance.high,
      playSound: true,
    );
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderChannel);
  }

  Future<void> schedulePrayerNotifications({
    required SettingsState settings,
  }) async {
    if (settings.latitude == null || settings.longitude == null) return;

    // Cancel previous prayer notifications
    // IDs: 200-299 for Azan, 300-399 for Reminders
    for (int i = 0; i < 100; i++) {
      await _notificationsPlugin.cancel(id: 200 + i);
      await _notificationsPlugin.cancel(id: 300 + i);
    }

    final prayerTimeService = getIt<PrayerTimeService>();
    final now = DateTime.now();

    // Schedule for the next 7 days
    for (int day = 0; day < 7; day++) {
      final date = now.add(Duration(days: day));
      final prayerTimes = prayerTimeService.getPrayerTimes(
        latitude: settings.latitude!,
        longitude: settings.longitude!,
        method: settings.calculationMethod,
        madhab: settings.madhab,
        date: date,
      );

      for (final salaahSetting in settings.salaahSettings) {
        final salaahTime = prayerTimeService.getTimeForSalaah(prayerTimes, salaahSetting.salaah);
        if (salaahTime == null) continue;

        final tzSalaahTime = tz.TZDateTime.from(salaahTime, tz.local);
        
        // Skip if already passed
        if (tzSalaahTime.isBefore(tz.TZDateTime.now(tz.local))) continue;

        final dayOffset = day * 5 + salaahSetting.salaah.index;

        // Schedule Azan
        if (salaahSetting.isAzanEnabled) {
          await _scheduleAzan(
            id: 200 + dayOffset,
            salaah: salaahSetting.salaah,
            scheduledDate: tzSalaahTime,
            sound: salaahSetting.azanSound,
          );
        }

        // Schedule Reminder
        if (salaahSetting.isReminderEnabled) {
          final reminderTime = tzSalaahTime.subtract(Duration(minutes: salaahSetting.reminderMinutesBefore));
          if (reminderTime.isAfter(tz.TZDateTime.now(tz.local))) {
            await _schedulePrayerReminder(
              id: 300 + dayOffset,
              salaah: salaahSetting.salaah,
              scheduledDate: reminderTime,
              minutesBefore: salaahSetting.reminderMinutesBefore,
            );
          }
        }
      }
    }
  }

  Future<void> _scheduleAzan({
    required int id,
    required Salaah salaah,
    required tz.TZDateTime scheduledDate,
    String? sound,
  }) async {
    final String salaahName = _getSalaahName(salaah);
    
    // Note: For custom sounds to work on Android, add the audio files (e.g. azan1.mp3)
    // to android/app/src/main/res/raw/ directory.
    // For local files downloaded at runtime, we might need a different approach 
    // but flutter_local_notifications supports RawResourceAndroidNotificationSound for assets.
    // For external files, we use UriAndroidNotificationSound if available or just the path.
    
    final bool isUri = sound != null && (sound.startsWith('/') || sound.contains(':'));

    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'azan_channel',
      'Azan Notifications',
      channelDescription: 'Channel for Azan calls',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      sound: sound != null 
        ? (isUri ? UriAndroidNotificationSound(sound) : RawResourceAndroidNotificationSound(sound.split('.').first)) 
        : null,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        sound: sound,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: 'حان وقت صلاة $salaahName',
      body: 'أقم الصلاة يرحمك الله',
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _schedulePrayerReminder({
    required int id,
    required Salaah salaah,
    required tz.TZDateTime scheduledDate,
    required int minutesBefore,
  }) async {
    final String salaahName = _getSalaahName(salaah);

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: 'تذكير بصلاة $salaahName',
      body: 'باقي $minutesBefore دقيقة على الأذان',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_reminders',
          'Prayer Reminders',
          channelDescription: 'Notifications before prayer time',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> testAzan(Salaah salaah, String? sound) async {
    final String salaahName = _getSalaahName(salaah);
    final bool isUri = sound != null && (sound.startsWith('/') || sound.contains(':'));
    
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'azan_channel',
      'Azan Notifications',
      channelDescription: 'Channel for Azan calls',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      playSound: true,
      sound: sound != null 
        ? (isUri ? UriAndroidNotificationSound(sound) : RawResourceAndroidNotificationSound(sound.split('.').first)) 
        : null,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(
        sound: sound,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      id: 999,
      title: 'تجربة الأذان: $salaahName',
      body: 'هذا تنبيه تجريبي لصوت الأذان',
      notificationDetails: platformChannelSpecifics,
    );
  }

  String _getSalaahName(Salaah salaah) {
    switch (salaah) {
      case Salaah.fajr: return 'الفجر';
      case Salaah.dhuhr: return 'الظهر';
      case Salaah.asr: return 'العصر';
      case Salaah.maghrib: return 'المغرب';
      case Salaah.isha: return 'العشاء';
    }
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
        payload: 'category:$matchedCategory',
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
    return item.zekr.length > 100 ? '${item.zekr.substring(0, 100)}...' : item.zekr;
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
