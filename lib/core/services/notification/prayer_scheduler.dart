import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/azkar/domain/azkar_item.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'channel_manager.dart';
import 'sound_manager.dart';

@singleton
class PrayerNotificationScheduler {
  final PrayerTimeService _prayerTimeService;
  final AzkarRepository _azkarRepository;
  final ChannelManager _channelManager;
  final SoundManager _soundManager;

  // Notification ID Ranges
  static const int azkarReminderIdStart = 100;
  static const int azanIdStart = 200;
  static const int prayerReminderIdStart = 300;
  static const int afterSalahAzkarIdStart = 400;

  // Max counts for cancellation
  static const int maxAzkarReminders = 50;
  static const int maxScheduledDays = 7;
  static const int prayersPerDay = 5;
  static const int maxPrayerNotificationIds = maxScheduledDays * prayersPerDay;

  PrayerNotificationScheduler(
    this._prayerTimeService,
    this._azkarRepository,
    this._channelManager,
    this._soundManager,
  );

  Future<void> schedulePrayerNotifications(
    FlutterLocalNotificationsPlugin notificationsPlugin, {
    required SettingsState settings,
  }) async {
    await _channelManager.createNotificationChannels(notificationsPlugin, settings: settings);

    if (settings.latitude == null || settings.longitude == null) return;

    // Cancel previous prayer notifications in known ranges
    await _cancelNotificationRanges(notificationsPlugin, [
      azanIdStart,
      prayerReminderIdStart,
      afterSalahAzkarIdStart,
    ], maxPrayerNotificationIds);

    final now = tz.TZDateTime.now(tz.local);
    final allAzkar = await _azkarRepository.getAllAzkar();
    final List<Future<void>> scheduleFutures = [];

    for (int day = 0; day < maxScheduledDays; day++) {
      final date = DateTime.now().add(Duration(days: day));
      final prayerTimes = _prayerTimeService.getPrayerTimes(
        latitude: settings.latitude!,
        longitude: settings.longitude!,
        method: settings.calculationMethod,
        madhab: settings.madhab,
        date: date,
      );

      for (final salaahSetting in settings.salaahSettings) {
        final salaahTime = _prayerTimeService.getTimeForSalaah(prayerTimes, salaahSetting.salaah);
        if (salaahTime == null) continue;

        final tzSalaahTime = tz.TZDateTime.from(salaahTime, tz.local);
        final dayOffset = day * prayersPerDay + salaahSetting.salaah.index;

        // 1. Schedule Azan
        if (salaahSetting.isAzanEnabled && tzSalaahTime.isAfter(now)) {
          scheduleFutures.add(_scheduleAzan(
            notificationsPlugin,
            id: azanIdStart + dayOffset,
            salaah: salaahSetting.salaah,
            scheduledDate: tzSalaahTime,
            sound: salaahSetting.azanSound,
          ));
        }

        // 2. Schedule Reminder
        if (salaahSetting.isReminderEnabled && salaahSetting.reminderMinutesBefore > 0) {
          final reminderTime = tzSalaahTime.subtract(Duration(minutes: salaahSetting.reminderMinutesBefore));
          if (reminderTime.isAfter(now.subtract(const Duration(seconds: 10)))) {
            scheduleFutures.add(_schedulePrayerReminder(
              notificationsPlugin,
              id: prayerReminderIdStart + dayOffset,
              salaah: salaahSetting.salaah,
              scheduledDate: reminderTime.isBefore(now) ? now.add(const Duration(seconds: 1)) : reminderTime,
              minutesBefore: salaahSetting.reminderMinutesBefore,
            ));
          }
        }

        // 3. Schedule After Salah Azkar
        if (settings.isAfterSalahAzkarEnabled && salaahSetting.isAfterSalahAzkarEnabled) {
          final azkarTime = tzSalaahTime.add(const Duration(minutes: 15));
          if (azkarTime.isAfter(now)) {
            scheduleFutures.add(_scheduleAfterSalahAzkar(
              notificationsPlugin,
              id: afterSalahAzkarIdStart + dayOffset,
              scheduledDate: azkarTime,
              allAzkar: allAzkar,
            ));
          }
        }
      }
    }
    await Future.wait(scheduleFutures);
  }

  Future<void> scheduleAzkarReminders(
    FlutterLocalNotificationsPlugin notificationsPlugin, {
    required SettingsState settings, 
    required List<AzkarItem> allAzkar,
  }) async {
    await _cancelNotificationRanges(notificationsPlugin, [azkarReminderIdStart], maxAzkarReminders);

    final now = DateTime.now();
    final List<Future<void>> scheduleFutures = [];
    
    for (int i = 0; i < min(settings.reminders.length, maxAzkarReminders); i++) {
      final reminder = settings.reminders[i];
      if (!reminder.isEnabled) continue;

      final scheduledDateTime = _parseTime(reminder.time, now);
      final zekrBody = _getRandomZekr(allAzkar, reminder.category);

      scheduleFutures.add(_scheduleDailyNotification(
        notificationsPlugin,
        id: azkarReminderIdStart + i,
        title: reminder.title.isNotEmpty ? reminder.title : reminder.category,
        body: zekrBody,
        scheduledDate: scheduledDateTime,
        payload: 'category:${reminder.category}',
      ));
    }
    await Future.wait(scheduleFutures);
  }

  Future<void> _cancelNotificationRanges(
    FlutterLocalNotificationsPlugin notificationsPlugin,
    List<int> starts,
    int count,
  ) async {
    final List<Future<void>> cancelFutures = [];
    for (final start in starts) {
      for (int i = 0; i < count; i++) {
        cancelFutures.add(notificationsPlugin.cancel(id: start + i));
      }
    }
    await Future.wait(cancelFutures);
  }

  Future<void> _scheduleDailyNotification(
    FlutterLocalNotificationsPlugin notificationsPlugin, {
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

    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTzDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'azkar_reminders',
          'Azkar Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  Future<void> _scheduleAfterSalahAzkar(
    FlutterLocalNotificationsPlugin notificationsPlugin, {
    required int id,
    required tz.TZDateTime scheduledDate,
    required List<AzkarItem> allAzkar,
  }) async {
    const String category = 'الأذكار بعد السلام من الصلاة';
    final String zekrBody = _getRandomZekr(allAzkar, category);
    
    await notificationsPlugin.zonedSchedule(
      id: id,
      title: 'أذكار بعد الصلاة',
      body: zekrBody,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'azkar_reminders',
          'Azkar Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'category:$category',
    );
  }

  DateTime _parseTime(String timeStr, DateTime now) {
    try {
      final parts = timeStr.split(':');
      return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
    } catch (_) {
      return now;
    }
  }

  Future<void> _scheduleAzan(
    FlutterLocalNotificationsPlugin notificationsPlugin, {
    required int id,
    required Salaah salaah,
    required tz.TZDateTime scheduledDate,
    String? sound,
  }) async {
    final String salaahName = _getSalaahName(salaah);
    final String soundPath = sound ?? 'default';
    final String channelId = _channelManager.getChannelId(salaah.name, soundPath);
    
    await _channelManager.ensureChannelExists(
      notificationsPlugin,
      channelId: channelId,
      salaahId: salaah.name,
      sound: soundPath,
    );

    final String? soundUri = await _soundManager.getSoundUriForChannel(soundPath);
    AndroidNotificationSound? notificationSound;
    
    if (soundPath != 'default') {
      if (soundUri != null) {
        notificationSound = UriAndroidNotificationSound(soundUri);
      } else {
        notificationSound = RawResourceAndroidNotificationSound(soundPath.split('.').first);
      }
    }
    
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      'Azan ${salaah.name.toUpperCase()}',
      channelDescription: 'Azan notifications for ${salaah.name.toUpperCase()}',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      playSound: true,
      sound: notificationSound,
      visibility: NotificationVisibility.public,
      autoCancel: true,
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

    await notificationsPlugin.zonedSchedule(
      id: id,
      title: 'حان وقت صلاة $salaahName',
      body: 'أقم الصلاة يرحمك الله',
      scheduledDate: scheduledDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> _schedulePrayerReminder(
    FlutterLocalNotificationsPlugin notificationsPlugin, {
    required int id,
    required Salaah salaah,
    required tz.TZDateTime scheduledDate,
    required int minutesBefore,
  }) async {
    final String salaahName = _getSalaahName(salaah);

    await notificationsPlugin.zonedSchedule(
      id: id,
      title: 'تذكير بصلاة $salaahName',
      body: 'باقي $minutesBefore دقيقة على الأذان',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          ChannelManager.reminderChannelId,
          'Prayer Reminders',
          channelDescription: 'Notifications before prayer time',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          visibility: NotificationVisibility.public,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        windows: WindowsNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
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

  String _getRandomZekr(List<AzkarItem> azkar, String category) {
    final filtered = azkar.where((e) => e.category == category || e.category.contains(category)).toList();
    if (filtered.isEmpty) return 'حان وقت الأذكار';
    final item = filtered[Random().nextInt(filtered.length)];
    return item.zekr.length > 100 ? '${item.zekr.substring(0, 100)}...' : item.zekr;
  }
}
