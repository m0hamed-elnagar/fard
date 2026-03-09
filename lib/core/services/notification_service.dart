import 'dart:io';
import 'package:fard/features/azkar/domain/azkar_item.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_list_screen.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:injectable/injectable.dart';
import '../di/injection.dart';
import 'notification/channel_manager.dart';
import 'notification/prayer_scheduler.dart';
import 'notification/sound_manager.dart';

@singleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final SoundManager _soundManager;
  final ChannelManager _channelManager;
  final PrayerNotificationScheduler _prayerScheduler;

  NotificationService(
    this._soundManager,
    this._channelManager,
    this._prayerScheduler,
    this._notificationsPlugin,
  );

  static const String reminderChannelId = ChannelManager.reminderChannelId;
  static const String testAzanChannelId = 'azan_test_channel';

  Future<void> init() async {
    debugPrint('NotificationService: init starting');
    
    // Initialize delegates
    await _soundManager.init();

    try {
      tz.initializeTimeZones();
      debugPrint('NotificationService: getting local timezone...');
      final rawTimeZone = await FlutterTimezone.getLocalTimezone().timeout(const Duration(seconds: 5));
      String timeZoneName = rawTimeZone.toString();
      
      // On some platforms (like Windows), flutter_timezone might return "TimezoneInfo(Name, ...)"
      if (timeZoneName.contains('(') && timeZoneName.contains(')')) {
        final startIndex = timeZoneName.indexOf('(') + 1;
        final endIndex = timeZoneName.indexOf(',');
        if (endIndex != -1 && endIndex > startIndex) {
          timeZoneName = timeZoneName.substring(startIndex, endIndex).trim();
        } else {
          final closeIndex = timeZoneName.indexOf(')');
          if (closeIndex > startIndex) {
            timeZoneName = timeZoneName.substring(startIndex, closeIndex).trim();
          }
        }
      }
      
      tz.setLocalLocation(tz.getLocation(timeZoneName));
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

    debugPrint('NotificationService: initializing plugin...');
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
    if (Platform.isAndroid) {
      debugPrint('NotificationService: requesting Android permissions...');
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestExactAlarmsPermission();

      // Create notification channels for Android (using default/empty settings initially if needed, 
      // but usually we wait for schedulePrayerNotifications to create specific channels)
      // We can just create the static ones here.
      await _channelManager.createNotificationChannels(_notificationsPlugin);

      // Check exact alarm permission state
      final canSchedule = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.canScheduleExactNotifications();
      debugPrint('Can schedule exact notifications: $canSchedule');
    }
    debugPrint('NotificationService: init complete');
  }

  Future<void> handleInitialNotification() async {
    debugPrint('NotificationService: handleInitialNotification starting');
    try {
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails().timeout(const Duration(seconds: 5));
      
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
    } catch (e) {
      debugPrint('Error handling initial notification: $e');
    }
    debugPrint('NotificationService: handleInitialNotification complete');
  }

  Future<bool> canScheduleExactNotifications() async {
    return await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.canScheduleExactNotifications() ?? true;
  }

  Future<void> schedulePrayerNotifications({
    required SettingsState settings,
  }) async {
    await _prayerScheduler.schedulePrayerNotifications(_notificationsPlugin, settings: settings);
  }

  Future<void> testAzan(Salaah salaah, String? sound, {SettingsState? settings}) async {
    final String salaahName = _getSalaahName(salaah);
    final String soundPath = sound ?? 'default';
    
    // Use a more stable but still unique-ish channel ID for testing to allow sound updates
    final String soundHash = soundPath.hashCode.abs().toString().substring(0, 4);
    final String channelId = 'azan_test_channel_$soundHash';
    
    debugPrint('Testing Azan with channel: $channelId, sound: $soundPath');

    await _channelManager.ensureChannelExists(
      _notificationsPlugin,
      channelId: channelId,
      salaahId: salaah.name,
      sound: soundPath,
      isTest: true,
    );

    // Small delay to ensure channel is ready
    await Future.delayed(const Duration(milliseconds: 600));
    final String? soundUri = await _soundManager.getSoundUriForChannel(soundPath);
    
    String diagnosticInfo = '';
    if (soundUri != null && soundUri.startsWith('content:')) {
      diagnosticInfo = '\nتم استخدام FileProvider بنجاح';
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
      'Azan Test',
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
      notificationDetails: NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: DarwinNotificationDetails(
          sound: sound,
          presentAlert: true,
          presentSound: true,
        ),
      ),
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
    await _prayerScheduler.scheduleAzkarReminders(
      _notificationsPlugin, 
      settings: settings, 
      allAzkar: allAzkar,
    );
  }
}
