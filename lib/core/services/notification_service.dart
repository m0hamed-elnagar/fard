import 'dart:math';
import 'dart:io';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path_provider/path_provider.dart';
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

  static const String reminderChannelId = 'prayer_reminders_v1';

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
      debugPrint('Local timezone set to: $timeZoneName');
    } catch (e) {
      debugPrint('Could not get local timezone, defaulting to UTC: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
    
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

    // Check exact alarm permission state
    final canSchedule = await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.canScheduleExactNotifications();
    debugPrint('Can schedule exact notifications: $canSchedule');
  }

  Future<void> handleInitialNotification() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      final payload = notificationAppLaunchDetails?.notificationResponse?.payload;
      if (payload != null && payload.startsWith('category:')) {
        final category = payload.replaceFirst('category:', '');
        final navigatorKey = getIt<GlobalKey<NavigatorState>>();
        
        // Wait for the navigator to be ready if needed, though usually it is after splash
        Future.delayed(const Duration(seconds: 2), () {
          if (navigatorKey.currentState != null) {
            navigatorKey.currentState!.push(
              MaterialPageRoute(
                builder: (_) => AzkarListScreen(category: category),
              ),
            );
          }
        });
      }
    }
  }

  String _getChannelId(String salaahId, String sound) {
    if (sound == 'default') return 'azan_channel_$salaahId';
    
    // Use the filename as a key to make it deterministic but unique to the sound
    final String fileName = sound.split(Platform.isWindows ? '\\' : '/').last.replaceAll('.mp3', '');
    return 'azan_${salaahId}_$fileName';
  }

  Future<String?> _getSoundUriForChannel(String sound) async {
    if (sound == 'default') return null;
    
    // Check if it's a local file path
    final bool isLocalFile = sound.startsWith('/') || (sound.length > 1 && sound[1] == ':');
    if (isLocalFile) {
      final file = File(sound);
      if (!await file.exists()) return null;
      
      try {
        if (Platform.isAndroid) {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            // Path relative to external storage
            final String fileName = sound.split(Platform.isWindows ? '\\' : '/').last;
            final azanDir = Directory('${externalDir.path}/azan_sounds');
            if (!await azanDir.exists()) await azanDir.create(recursive: true);
            
            final destFile = File('${azanDir.path}/$fileName');
            if (!await destFile.exists() || (await destFile.length() != await file.length())) {
              await file.copy(destFile.path);
            }
            
            // The authority MUST match ${applicationId}.fileprovider in AndroidManifest.xml
            final String authority = 'com.qada.fard.fileprovider';
            final String contentUri = 'content://$authority/external_azan/$fileName';
            
            debugPrint('Using content URI for Azan: $contentUri');
            return contentUri;
          }
        }
      } catch (e) {
        debugPrint('Error preparing sound URI: $e');
      }
      return Uri.file(sound).toString();
    }
    
    return null; // For raw resources
  }

  Future<void> _ensureChannelExists({
    required String channelId,
    required String salaahId,
    required String sound,
  }) async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    final channels = await androidPlugin.getNotificationChannels();
    final bool exists = channels?.any((c) => c.id == channelId) ?? false;

    if (exists) return;

    // Create new channel with proper sound
    final String? soundUri = await _getSoundUriForChannel(sound);
    
    final androidChannel = AndroidNotificationChannel(
      channelId,
      'Azan ${salaahId.toUpperCase()}',
      description: 'Azan notifications for ${salaahId.toUpperCase()}',
      importance: Importance.max,
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      sound: sound == 'default' 
          ? null 
          : (soundUri != null 
              ? UriAndroidNotificationSound(soundUri) 
              : RawResourceAndroidNotificationSound(sound.split('.').first)),
    );

    await androidPlugin.createNotificationChannel(androidChannel);
  }

  Future<void> _createNotificationChannels({SettingsState? settings}) async {
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    // Salah specific channels for Azan
    if (settings != null) {
      for (final salaahSetting in settings.salaahSettings) {
        final String salaahId = salaahSetting.salaah.name;
        final String sound = salaahSetting.azanSound ?? 'default';
        final String channelId = _getChannelId(salaahId, sound);
        
        await _ensureChannelExists(
          channelId: channelId,
          salaahId: salaahId,
          sound: sound,
        );
      }
    }

    const reminderChannel = AndroidNotificationChannel(
      reminderChannelId,
      'Prayer Reminders',
      description: 'Notifications before prayer time',
      importance: Importance.max,
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );
    
    await androidPlugin.createNotificationChannel(reminderChannel);

    const azkarChannel = AndroidNotificationChannel(
      'azkar_reminders',
      'Azkar Reminders',
      description: 'Daily Azkar notifications',
      importance: Importance.max,
      playSound: true,
    );
    
    await androidPlugin.createNotificationChannel(azkarChannel);
  }

  Future<bool> canScheduleExactNotifications() async {
    return await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.canScheduleExactNotifications() ?? true;
  }

  Future<void> schedulePrayerNotifications({
    required SettingsState settings,
  }) async {
    // Recreate channels to ensure sound changes are applied (Android limitation)
    await _createNotificationChannels(settings: settings);

    if (settings.latitude == null || settings.longitude == null) return;

    // Cancel previous prayer notifications
    // IDs: 200-299 for Azan, 300-399 for Reminders
    for (int i = 0; i < 100; i++) {
      await _notificationsPlugin.cancel(id: 200 + i);
      await _notificationsPlugin.cancel(id: 300 + i);
    }

    final prayerTimeService = getIt<PrayerTimeService>();
    final now = tz.TZDateTime.now(tz.local);

    // Schedule for the next 7 days
    for (int day = 0; day < 7; day++) {
      final date = DateTime.now().add(Duration(days: day));
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
        final dayOffset = day * 5 + salaahSetting.salaah.index;

        // Schedule Azan
        if (salaahSetting.isAzanEnabled) {
          if (tzSalaahTime.isAfter(now)) {
            await _scheduleAzan(
              id: 200 + dayOffset,
              salaah: salaahSetting.salaah,
              scheduledDate: tzSalaahTime,
              sound: salaahSetting.azanSound,
            );
          }
        }

        // Schedule Reminder
        if (salaahSetting.isReminderEnabled && salaahSetting.reminderMinutesBefore > 0) {
          final reminderTime = tzSalaahTime.subtract(Duration(minutes: salaahSetting.reminderMinutesBefore));
          
          // Allow a small buffer (10 seconds) for "immediate" firing if user is testing
          if (reminderTime.isAfter(now.subtract(const Duration(seconds: 10)))) {
            debugPrint('Scheduling reminder for ${salaahSetting.salaah.name} at $reminderTime (${salaahSetting.reminderMinutesBefore} mins before)');
            await _schedulePrayerReminder(
              id: 300 + dayOffset,
              salaah: salaahSetting.salaah,
              scheduledDate: reminderTime.isBefore(now) ? now.add(const Duration(seconds: 1)) : reminderTime,
              minutesBefore: salaahSetting.reminderMinutesBefore,
            );
          } else {
            debugPrint('Reminder for ${salaahSetting.salaah.name} at $reminderTime is too far in the past, skipping');
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
    final String soundPath = sound ?? 'default';
    final String channelId = _getChannelId(salaah.name, soundPath);
    
    await _ensureChannelExists(
      channelId: channelId,
      salaahId: salaah.name,
      sound: soundPath,
    );

    final String? soundUri = await _getSoundUriForChannel(soundPath);
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
          reminderChannelId,
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

  Future<void> testAzan(Salaah salaah, String? sound, {SettingsState? settings}) async {
    final String salaahName = _getSalaahName(salaah);
    final String soundPath = sound ?? 'default';
    final String channelId = '${_getChannelId(salaah.name, soundPath)}_test_${DateTime.now().millisecondsSinceEpoch}';
    
    await _ensureChannelExists(
      channelId: channelId,
      salaahId: salaah.name,
      sound: soundPath,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    final String? soundUri = await _getSoundUriForChannel(soundPath);
    
    String diagnosticInfo = '';
    if (soundUri != null && soundUri.startsWith('file:')) {
      try {
        final actualPath = Uri.parse(soundUri).toFilePath();
        final file = File(actualPath);
        if (await file.exists()) {
          final bytes = await file.length();
          diagnosticInfo = '\nحجم الملف: ${(bytes / 1024).toStringAsFixed(1)} KB';
        }
      } catch (_) {}
    }

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
      'Azan Test ${salaah.name.toUpperCase()}',
      channelDescription: 'Temporary channel for Azan testing',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      playSound: true,
      sound: notificationSound,
    );

    await _notificationsPlugin.show(
      id: 999,
      title: 'تجربة الأذان: $salaahName',
      body: 'هذا تنبيه تجريبي لصوت الأذان$diagnosticInfo',
      notificationDetails: NotificationDetails(android: androidPlatformChannelSpecifics),
    );
  }

  Future<void> testReminder(Salaah salaah, int minutesBefore) async {
    final String salaahName = _getSalaahName(salaah);
    
    await _notificationsPlugin.show(
      id: 998,
      title: 'تجربة التنبيه: $salaahName',
      body: 'هذا تنبيه تجريبي: باقي $minutesBefore دقيقة على الأذان',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          reminderChannelId,
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
      ),
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

  Future<Map<String, dynamic>> runDiagnostics() async {
    final results = <String, dynamic>{};
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    results['notifications_enabled'] = await androidPlugin?.areNotificationsEnabled() ?? false;
    results['exact_alarm_permission'] = await androidPlugin?.canScheduleExactNotifications() ?? false;
    
    final channels = await androidPlugin?.getNotificationChannels() ?? [];
    results['channels_count'] = channels.length;
    results['channels'] = channels.map((c) => {
      'id': c.id,
      'name': c.name,
      'importance': c.importance.toString(),
      'sound': c.sound?.toString(),
    }).toList();
    
    _printDiagnosticReport(results);
    return results;
  }

  void _printDiagnosticReport(Map<String, dynamic> results) {
    debugPrint('''
╔════════════════════════════════════════════════════════════╗
║           AZAN NOTIFICATION DIAGNOSTIC REPORT              ║
╠════════════════════════════════════════════════════════════╣
  Permissions:
    • Notifications: ${results['notifications_enabled'] ? '✅' : '❌'}
    • Exact Alarms:  ${results['exact_alarm_permission'] ? '✅' : '❌'}
  
  Channels: ${results['channels_count']} channel(s)
${(results['channels'] as List).map((c) => '    • ${c['id']} (${c['importance']})').join('\n')}
╚════════════════════════════════════════════════════════════╝
''');
  }

  Future<void> scheduleAzkarReminders({
    required SettingsState settings, 
    required List<AzkarItem> allAzkar,
  }) async {
    for (int i = 0; i < 50; i++) {
      await _notificationsPlugin.cancel(id: 100 + i);
    }

    final now = DateTime.now();
    for (int i = 0; i < settings.reminders.length; i++) {
      if (i >= 50) break;
      final reminder = settings.reminders[i];
      if (!reminder.isEnabled) continue;

      DateTime scheduledDateTime = _parseTime(reminder.time, now);
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
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  String _getRandomZekr(List<AzkarItem> azkar, String category) {
    final filtered = azkar.where((e) => e.category == category || e.category.contains(category)).toList();
    if (filtered.isEmpty) return 'حان وقت الأذكار';
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
