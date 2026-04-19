import 'dart:math';
import 'package:fard/features/azkar/data/azkar_source.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/core/utils/rtl_text_util.dart';
import 'package:fard/core/utils/app_identifiers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/azkar/domain/azkar_item.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'channel_manager.dart';
import 'sound_manager.dart';
import 'package:flutter/foundation.dart';

@singleton
class PrayerNotificationScheduler {
  final PrayerTimeService _prayerTimeService;
  final IAzkarSource _azkarSource;
  final ChannelManager _channelManager;
  final SoundManager _soundManager;
  final SettingsRepository _settingsProvider;

  static String get groupKey => AppIdentifiers.notificationGroupKey;
  static const String widgetTaskKey = 'widget_refresh_task';

  // Notification ID Ranges
  static const int azkarReminderIdStart = 100;
  static const int azanIdStart = 200;
  static const int prayerReminderIdStart = 300;
  static const int afterSalahAzkarIdStart = 400;

  String _applyRtl(String text) {
    return RtlTextUtil.applyRtlFromSettings(text, _settingsProvider);
  }

  // Max counts for cancellation
  static const int maxAzkarReminders = 50;
  static const int maxScheduledDays = 2;
  static const int prayersPerDay = 5;
  static const int maxPrayerNotificationIds = maxScheduledDays * prayersPerDay;

  PrayerNotificationScheduler(
    this._prayerTimeService,
    this._azkarSource,
    this._channelManager,
    this._soundManager,
    this._settingsProvider,
  );

  Future<void> schedulePrayerNotifications(
    FlutterLocalNotificationsPlugin notificationsPlugin,
  ) async {
    await _channelManager.createNotificationChannels(
      notificationsPlugin,
      settings: _settingsProvider,
    );

    if (_settingsProvider.latitude == null ||
        _settingsProvider.longitude == null) {
      return;
    }

    // Cancel previous prayer notifications in known ranges
    await _cancelNotificationRanges(notificationsPlugin, [
      azanIdStart,
      prayerReminderIdStart,
      afterSalahAzkarIdStart,
    ], maxPrayerNotificationIds);

    final now = tz.TZDateTime.now(tz.local);
    final allAzkar = await _azkarSource.getAllAzkar();

    // 🏎️ Pre-resolve sound URIs for all unique sounds used to avoid redundant I/O in the loop
    final uniqueSounds = _settingsProvider.salaahSettings
        .map((s) => s.azanSound ?? 'default')
        .toSet();
    final Map<String, String?> soundUriMap = {};
    for (final sound in uniqueSounds) {
      soundUriMap[sound] = await _soundManager.getSoundUriForChannel(sound);
    }

    final List<
      ({DateTime time, bool isAzan, Future<void> Function(int?) schedule})
    > events = [];

    // Track the latest missed Azan (within 1 min) to avoid firing multiple old ones
    ({DateTime time, Future<void> Function(int?) schedule})? latestMissedAzan;

    for (int day = 0; day < maxScheduledDays; day++) {
      final date = DateTime.now().add(Duration(days: day));
      final prayerTimes = _prayerTimeService.getPrayerTimes(
        latitude: _settingsProvider.latitude!,
        longitude: _settingsProvider.longitude!,
        method: _settingsProvider.calculationMethod,
        madhab: _settingsProvider.madhab,
        date: date,
      );

      for (final salaahSetting in _settingsProvider.salaahSettings) {
        final salaahTime = _prayerTimeService.getTimeForSalaah(
          prayerTimes,
          salaahSetting.salaah,
        );
        if (salaahTime == null) continue;

        final tzSalaahTime = tz.TZDateTime.from(salaahTime, tz.local);
        final dayOffset = day * prayersPerDay + salaahSetting.salaah.index;

        // 1. Azan Event
        if (salaahSetting.isAzanEnabled) {
          if (tzSalaahTime.isAfter(now)) {
            // Future Azan
            events.add((
              time: tzSalaahTime,
              isAzan: true,
              schedule: (int? timeout) async {
                try {
                  await _scheduleAzan(
                    notificationsPlugin,
                    id: azanIdStart + dayOffset,
                    salaah: salaahSetting.salaah,
                    scheduledDate: tzSalaahTime,
                    sound: salaahSetting.azanSound,
                    soundUri: soundUriMap[salaahSetting.azanSound ?? 'default'],
                    timeoutAfter: timeout,
                  );

                  Workmanager()
                      .registerOneOffTask(
                        "widget_refresh_${salaahSetting.salaah.name}_$day",
                        widgetTaskKey,
                        initialDelay: tzSalaahTime.difference(now),
                        existingWorkPolicy: ExistingWorkPolicy.replace,
                      )
                      .catchError((e) {
                    debugPrint(
                      'PrayerNotificationScheduler: Workmanager error: $e',
                    );
                  });
                } catch (e) {
                  debugPrint(
                    'PrayerNotificationScheduler: Error scheduling Azan: $e',
                  );
                }
              },
            ));
          } else {
            // Missed Azan? Check if it was very recent (< 1 min)
            final bool isVeryRecentPast =
                now.difference(tzSalaahTime).inMinutes < 1;

            if (isVeryRecentPast) {
              final scheduledTime = now.add(const Duration(seconds: 1));
              if (latestMissedAzan == null ||
                  tzSalaahTime.isAfter(latestMissedAzan.time)) {
                latestMissedAzan = (
                  time: tzSalaahTime,
                  schedule: (int? timeout) async {
                    try {
                      await _scheduleAzan(
                        notificationsPlugin,
                        id: azanIdStart + dayOffset,
                        salaah: salaahSetting.salaah,
                        scheduledDate: scheduledTime,
                        sound: salaahSetting.azanSound,
                        soundUri:
                            soundUriMap[salaahSetting.azanSound ?? 'default'],
                        timeoutAfter: timeout,
                      );
                    } catch (e) {
                      debugPrint(
                        'PrayerNotificationScheduler: Error scheduling catch-up Azan: $e',
                      );
                    }
                  },
                );
              }
            }
          }
        }

        // 2. Reminder Event
        if (salaahSetting.isReminderEnabled &&
            salaahSetting.reminderMinutesBefore > 0) {
          final reminderTime = tzSalaahTime.subtract(
            Duration(minutes: salaahSetting.reminderMinutesBefore),
          );
          if (reminderTime.isAfter(now.subtract(const Duration(minutes: 1)))) {
            final scheduledTime = reminderTime.isBefore(now)
                ? now.add(const Duration(seconds: 5))
                : reminderTime;
            events.add((
              time: scheduledTime,
              isAzan: false,
              schedule: (int? timeout) async {
                try {
                  await _schedulePrayerReminder(
                    notificationsPlugin,
                    id: prayerReminderIdStart + dayOffset,
                    salaah: salaahSetting.salaah,
                    scheduledDate: scheduledTime,
                    minutesBefore: salaahSetting.reminderMinutesBefore,
                    timeoutAfter: timeout,
                  );
                } catch (e) {
                  debugPrint(
                    'PrayerNotificationScheduler: Error scheduling reminder: $e',
                  );
                }
              },
            ));
          }
        }

    // 3. After Salah Azkar Event
        if (_settingsProvider.isAfterSalahAzkarEnabled &&
            salaahSetting.isAfterSalahAzkarEnabled) {
          final azkarTime = tzSalaahTime.add(
            Duration(minutes: salaahSetting.afterSalaahAzkarMinutes),
          );
          if (azkarTime.isAfter(now)) {
            events.add((
              time: azkarTime,
              isAzan: false,
              schedule: (int? timeout) async {
                try {
                  await _scheduleAfterSalahAzkar(
                    notificationsPlugin,
                    id: afterSalahAzkarIdStart + dayOffset,
                    scheduledDate: azkarTime,
                    allAzkar: allAzkar,
                    timeoutAfter: timeout,
                  );
                } catch (e) {
                  debugPrint('PrayerNotificationScheduler: Error scheduling After-Salah Azkar: $e');
                }
              },
            ));
          }
        }
      }
    }

    // Add the single most recent missed Azan if one exists
    if (latestMissedAzan != null) {
      events.add((
        time: now.add(const Duration(seconds: 1)),
        isAzan: true,
        schedule: latestMissedAzan.schedule,
      ));
    }

    // Sort events by time
    events.sort((a, b) => a.time.compareTo(b.time));

    // Schedule events with timeouts
    for (int i = 0; i < events.length; i++) {
      int? timeout;
      if (i < events.length - 1) {
        final nextTime = events[i + 1].time;
        final duration = nextTime.difference(events[i].time);
        if (duration.isNegative) {
          timeout = null;
        } else {
          timeout = duration.inMilliseconds;
        }
      } else {
        timeout = const Duration(hours: 8).inMilliseconds;
      }

      // 🛡️ Special handling for Azan: Don't let it timeout too quickly
      // Even if another event (like After-Salah Azkar) is scheduled soon,
      // the Adhan notification should stay visible for at least 2 hours.
      if (events[i].isAzan) {
        final minAzanTimeout = const Duration(hours: 2).inMilliseconds;
        if (timeout == null || timeout < minAzanTimeout) {
          timeout = minAzanTimeout;
        }
      }

      await events[i].schedule(timeout);
    }
  }

  Future<void> scheduleAzkarReminders(
    FlutterLocalNotificationsPlugin notificationsPlugin, {
    required List<AzkarItem> allAzkar,
  }) async {
    await _cancelNotificationRanges(notificationsPlugin, [
      azkarReminderIdStart,
    ], maxAzkarReminders);

    final now = DateTime.now();
    final List<Future<void>> scheduleFutures = [];

    for (
      int i = 0;
      i < min(_settingsProvider.reminders.length, maxAzkarReminders);
      i++
    ) {
      final reminder = _settingsProvider.reminders[i];
      if (!reminder.isEnabled) continue;

      final scheduledDateTime = _parseTime(reminder.time, now);
      final zekrBody = _getRandomZekr(allAzkar, reminder.category);

      scheduleFutures.add(
        _scheduleDailyNotification(
          notificationsPlugin,
          id: azkarReminderIdStart + i,
          title: reminder.title.isNotEmpty ? reminder.title : reminder.category,
          body: zekrBody,
          scheduledDate: scheduledDateTime,
          payload: 'category:${reminder.category}',
        ),
      );
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
    int? timeoutAfter,
  }) async {
    var scheduledTzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    if (scheduledTzDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledTzDate = scheduledTzDate.add(const Duration(days: 1));
    }

    await notificationsPlugin.zonedSchedule(
      id: id,
      title: _applyRtl(title),
      body: _applyRtl(body),
      scheduledDate: scheduledTzDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'azkar_reminders',
          _applyRtl('Azkar Reminders'),
          importance: Importance.max,
          priority: Priority.high,
          groupKey: groupKey,
          ticker: _applyRtl(title),
          subText: _applyRtl(title),
          timeoutAfter: timeoutAfter,
        ),
      ),
      // 🛡️ Standard alarm (allowWhileIdle) for non-essential notifications
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  Future<void> _scheduleAfterSalahAzkar(
    FlutterLocalNotificationsPlugin notificationsPlugin, {
    required int id,
    required tz.TZDateTime scheduledDate,
    required List<AzkarItem> allAzkar,
    int? timeoutAfter,
  }) async {
    const String category = 'الأذكار بعد السلام من الصلاة';
    final String zekrBody = _getRandomZekr(allAzkar, category);
    final String title = 'أذكار بعد الصلاة';

    await notificationsPlugin.zonedSchedule(
      id: id,
      title: _applyRtl(title),
      body: _applyRtl(zekrBody),
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'azkar_reminders',
          _applyRtl('Azkar Reminders'),
          importance: Importance.max,
          priority: Priority.high,
          groupKey: groupKey,
          ticker: _applyRtl(title),
          subText: _applyRtl(title),
          timeoutAfter: timeoutAfter,
        ),
      ),
      // 🛡️ Standard alarm (allowWhileIdle) for non-essential notifications
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'category:$category',
    );
  }

  DateTime _parseTime(String timeStr, DateTime now) {
    try {
      final parts = timeStr.split(':');
      return DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
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
    String? soundUri,
    int? timeoutAfter,
  }) async {
    final String salaahName = _getSalaahName(salaah);
    final String soundPath = sound ?? 'default';
    final String channelId = _channelManager.getChannelId(
      salaah.name,
      soundPath,
    );

    // ensureChannelExists already checks if it exists, but it's good to keep it deterministic
    await _channelManager.ensureChannelExists(
      notificationsPlugin,
      channelId: channelId,
      salaahId: salaah.name,
      sound: soundPath,
    );

    AndroidNotificationSound? notificationSound;

    if (soundPath != 'default') {
      if (soundUri != null) {
        notificationSound = UriAndroidNotificationSound(soundUri);
      } else {
        // Fallback to resource if URI failed, but only if it's not a path
        if (!soundPath.contains('/') && !soundPath.contains('\\')) {
          notificationSound = RawResourceAndroidNotificationSound(
            soundPath.split('.').first,
          );
        }
      }
    }

    final String title = 'حان وقت صلاة $salaahName';
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          channelId,
          _applyRtl('Azan ${salaah.name.toUpperCase()}'),
          channelDescription: _applyRtl(
            'Azan notifications for ${salaah.name.toUpperCase()}',
          ),
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          playSound: true,
          sound: notificationSound,
          visibility: NotificationVisibility.public,
          autoCancel: true,
          groupKey: groupKey,
          ticker: _applyRtl(title),
          subText: _applyRtl(title),
          timeoutAfter: timeoutAfter,
          // 🛡️ High reliability for Azan
          fullScreenIntent: true,
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
      title: _applyRtl(title),
      body: _applyRtl('أقم الصلاة يرحمك الله'),
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
    int? timeoutAfter,
  }) async {
    final String salaahName = _getSalaahName(salaah);
    final String title = 'تذكير بصلاة $salaahName';

    await notificationsPlugin.zonedSchedule(
      id: id,
      title: _applyRtl(title),
      body: _applyRtl('باقي $minutesBefore دقيقة على الأذان'),
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          ChannelManager.reminderChannelId,
          _applyRtl('Prayer Reminders'),
          channelDescription: _applyRtl('Notifications before prayer time'),
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          visibility: NotificationVisibility.public,
          groupKey: groupKey,
          ticker: _applyRtl(title),
          subText: _applyRtl(title),
          timeoutAfter: timeoutAfter,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
        windows: const WindowsNotificationDetails(),
      ),
      // 🛡️ Standard alarm (allowWhileIdle) for non-essential notifications
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  String _getSalaahName(Salaah salaah) {
    switch (salaah) {
      case Salaah.fajr:
        return 'الفجر';
      case Salaah.dhuhr:
        return 'الظهر';
      case Salaah.asr:
        return 'العصر';
      case Salaah.maghrib:
        return 'المغرب';
      case Salaah.isha:
        return 'العشاء';
    }
  }

  String _getRandomZekr(List<AzkarItem> azkar, String category) {
    final filtered = azkar
        .where((e) => e.category == category || e.category.contains(category))
        .toList();
    if (filtered.isEmpty) return 'حان وقت الأذكار';
    final item = filtered[Random().nextInt(filtered.length)];
    return item.zekr.length > 100
        ? '${item.zekr.substring(0, 100)}...'
        : item.zekr;
  }
}
