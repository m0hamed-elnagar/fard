import 'dart:io';
import 'package:fard/features/azkar/domain/azkar_item.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_list_screen.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/core/utils/rtl_text_util.dart';
import 'package:fard/core/utils/app_identifiers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:injectable/injectable.dart';
import '../di/injection.dart';
import 'notification/channel_manager.dart';
import 'notification/prayer_scheduler.dart';
import 'notification/sound_manager.dart';
import 'widget_update_service.dart';

@singleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final SoundManager _soundManager;
  final ChannelManager _channelManager;
  final PrayerNotificationScheduler _prayerScheduler;
  final WidgetUpdateService _widgetUpdateService;
  final SettingsRepository _settingsProvider;
  final SharedPreferences _prefs;

  NotificationService(
    this._soundManager,
    this._channelManager,
    this._prayerScheduler,
    this._notificationsPlugin,
    this._widgetUpdateService,
    this._settingsProvider,
    this._prefs,
  );

  static const String reminderChannelId = ChannelManager.reminderChannelId;
  static const String testAzanChannelId = 'azan_test_channel';
  static String get downloadChannelId => AppIdentifiers.downloadChannelId;
  static String get groupKey => AppIdentifiers.notificationGroupKey;

  String _applyRtl(String text) {
    return RtlTextUtil.applyRtlFromSettings(text, _settingsProvider);
  }

  Future<void> init() async {
    debugPrint('NotificationService: init starting');

    try {
      // Timezone already initialized in configureDependencies(), just get local timezone
      debugPrint('NotificationService: getting local timezone...');
      
      String timeZoneName;
      final cachedTimezone = _prefs.getString('last_known_timezone');

      try {
        final rawTimeZone = await FlutterTimezone.getLocalTimezone().timeout(
          const Duration(seconds: 10), // Increased timeout to 10s
        );
        timeZoneName = rawTimeZone.toString();
        
        // On some platforms (like Windows), flutter_timezone might return "TimezoneInfo(Name, ...)"
        if (timeZoneName.contains('(') && timeZoneName.contains(')')) {
          final startIndex = timeZoneName.indexOf('(') + 1;
          final endIndex = timeZoneName.indexOf(',');
          if (endIndex != -1 && endIndex > startIndex) {
            timeZoneName = timeZoneName.substring(startIndex, endIndex).trim();
          } else {
            final closeIndex = timeZoneName.indexOf(')');
            if (closeIndex > startIndex) {
              timeZoneName = timeZoneName
                  .substring(startIndex, closeIndex)
                  .trim();
            }
          }
        }
        
        // Cache successful timezone
        await _prefs.setString('last_known_timezone', timeZoneName);
      } catch (e) {
        debugPrint('NotificationService: Error/Timeout getting local timezone: $e');
        if (cachedTimezone != null) {
          debugPrint('NotificationService: Using cached timezone: $cachedTimezone');
          timeZoneName = cachedTimezone;
        } else {
          debugPrint('NotificationService: No cached timezone found, defaulting to UTC');
          timeZoneName = 'UTC';
        }
      }

      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('Local timezone set to: $timeZoneName');
    } catch (e) {
      debugPrint('Could not set local timezone location: $e');
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

    final initializationSettingsWindows = WindowsInitializationSettings(
      appName: 'Fard',
      appUserModelId: AppIdentifiers.windowsAppUserModelId,
      guid: 'f0c0f0f0-0f0f-0f0f-0f0f-0f0f0f0f0f0f',
    );

    final initializationSettings = InitializationSettings(
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

    // Create notification channels for Android initially
    if (Platform.isAndroid) {
      await _channelManager.createNotificationChannels(_notificationsPlugin);
    }
    debugPrint('NotificationService: init complete');
  }

  /// Request all required permissions for notifications and exact alarms.
  /// Returns true if all critical permissions are granted.
  Future<bool> requestPermissions() async {
    if (!Platform.isAndroid) return true;

    debugPrint('NotificationService: requesting Android permissions...');
    final notificationStatus = await Permission.notification.request();
    final alarmStatus = await Permission.scheduleExactAlarm.request();
    
    debugPrint('Permissions result: Notifications=$notificationStatus, Alarms=$alarmStatus');
    
    return notificationStatus.isGranted && alarmStatus.isGranted;
  }

  Future<void> handleInitialNotification() async {
    debugPrint('NotificationService: handleInitialNotification starting');
    try {
      final NotificationAppLaunchDetails? notificationAppLaunchDetails =
          await _notificationsPlugin.getNotificationAppLaunchDetails().timeout(
            const Duration(seconds: 5),
          );

      if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
        final payload =
            notificationAppLaunchDetails?.notificationResponse?.payload;
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

  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      return await Permission.notification.isGranted;
    }
    return await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        true;
  }

  Future<bool> canScheduleExactNotifications() async {
    if (Platform.isAndroid) {
      return await Permission.scheduleExactAlarm.isGranted;
    }
    return await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.canScheduleExactNotifications() ??
        true;
  }

  Future<bool> isBatteryOptimizationIgnored() async {
    if (Platform.isAndroid) {
      return await Permission.ignoreBatteryOptimizations.isGranted;
    }
    return true;
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    if (Platform.isAndroid) {
      if (await Permission.ignoreBatteryOptimizations.request().isGranted) {
        return;
      }
      // If direct request fails or isn't enough, open settings
      await openAppSettings();
    }
  }

  Future<void> schedulePrayerNotifications() async {
    // Update widget data
    await _widgetUpdateService.updateWidget();

    await _prayerScheduler.schedulePrayerNotifications(_notificationsPlugin);
  }

  Future<void> testAzan(Salaah salaah, String? sound) async {
    final String salaahName = _getSalaahName(salaah);
    final String soundPath = sound ?? 'default';

    // Use a more stable but still unique-ish channel ID for testing to allow sound updates
    final String soundHash = soundPath.hashCode.abs().toString().substring(
      0,
      4,
    );
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
    final String? soundUri = await _soundManager.getSoundUriForChannel(
      soundPath,
    );

    String diagnosticInfo = '';
    if (soundUri != null && soundUri.startsWith('content:')) {
      diagnosticInfo = '\nتم استخدام FileProvider بنجاح';
    }

    AndroidNotificationSound? notificationSound;
    if (soundPath != 'default') {
      if (soundUri != null) {
        notificationSound = UriAndroidNotificationSound(soundUri);
      } else {
        notificationSound = RawResourceAndroidNotificationSound(
          soundPath.split('.').first,
        );
      }
    }

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          channelId,
          _applyRtl('Azan Test'),
          channelDescription: _applyRtl('Temporary channel for Azan testing'),
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          playSound: true,
          sound: notificationSound,
          groupKey: groupKey,
        );

    await _notificationsPlugin.show(
      id: 999,
      title: _applyRtl('تجربة الأذان: $salaahName'),
      body: _applyRtl('تجربة صوت الأذان$diagnosticInfo'),
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
      title: _applyRtl('تجربة التذكير: $salaahName'),
      body: _applyRtl('تجربة تذكير: باقي $minutesBefore دقيقة على الأذان'),
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
    // Use Arabic name directly for test notifications (user-facing)
    // For localized names, use: salaah.localizedName(l10n)
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

  Future<void> showDownloadProgress({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
    bool isCompleted = false,
  }) async {
    final l10n = lookupAppLocalizations(_settingsProvider.locale);
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          downloadChannelId,
          _applyRtl(l10n.downloadsChannelName),
          channelDescription: _applyRtl(l10n.downloadsChannelDesc),
          importance: Importance.low,
          priority: Priority.low,
          onlyAlertOnce: true,
          showProgress: !isCompleted,
          maxProgress: maxProgress,
          progress: progress,
          ongoing: !isCompleted,
          autoCancel: isCompleted,
          groupKey: groupKey,
          ticker: _applyRtl(title),
          subText: _applyRtl(title),
        );

    await _notificationsPlugin.show(
      id: id,
      title: _applyRtl(title),
      body: _applyRtl(body),
      notificationDetails: NotificationDetails(
        android: androidPlatformChannelSpecifics,
      ),
    );
  }

  Future<void> cancelNotification({required int id}) async {
    await _notificationsPlugin.cancel(id: id);
  }

  Future<Map<String, dynamic>> runDiagnostics() async {
    final results = <String, dynamic>{};
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    results['notifications_enabled'] =
        await areNotificationsEnabled();
    results['exact_alarm_permission'] =
        await canScheduleExactNotifications();
    results['battery_optimization_ignored'] =
        await isBatteryOptimizationIgnored();

    final channels = await androidPlugin?.getNotificationChannels() ?? [];
    results['channels_count'] = channels.length;
    results['channels'] = channels
        .map(
          (c) => {
            'id': c.id,
            'name': c.name,
            'importance': c.importance.toString(),
            'sound': c.sound?.toString(),
          },
        )
        .toList();

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
    • Battery Opt:   ${results['battery_optimization_ignored'] ? '✅' : '❌'}
  
  Channels: ${results['channels_count']} channel(s)
${(results['channels'] as List).map((c) => '    • ${c['id']} (${c['importance']})').join('\n')}
╚════════════════════════════════════════════════════════════╝
''');
  }

  Future<void> openNotificationSettings() async {
    await openAppSettings();
  }

  Future<void> scheduleAzkarReminders({
    required List<AzkarItem> allAzkar,
  }) async {
    await _prayerScheduler.scheduleAzkarReminders(
      _notificationsPlugin,
      allAzkar: allAzkar,
    );
  }
}
