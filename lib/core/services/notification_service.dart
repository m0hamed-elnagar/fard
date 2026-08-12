import 'dart:async';
import 'dart:io';
import 'package:fard/features/azkar/domain/azkar_item.dart';
import 'package:fard/features/azkar/presentation/screens/azkar_list_screen.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/core/l10n/app_localizations.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/core/utils/rtl_text_util.dart';
import 'package:fard/core/utils/app_identifiers.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/notification/channel_manager.dart';
import 'package:fard/core/services/notification/prayer_scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/core/services/background_service.dart';
import 'package:fard/core/services/background_azkar_source.dart';
import 'package:fard/core/services/settings_loader.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:fard/core/services/background_prayer_sync_service.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'notification/sound_manager.dart';
import 'widget_update_service.dart';

@lazySingleton
class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final SoundManager _soundManager;
  final ChannelManager _channelManager;
  final PrayerNotificationScheduler _prayerScheduler;
  final WidgetUpdateService _widgetUpdateService;
  final SettingsRepository _settingsProvider;
  final SharedPreferences _prefs;
  final GlobalKey<NavigatorState> _navigatorKey;

  final Completer<void> _initCompleter = Completer<void>();
  final _markPrayedController = StreamController<Salaah>.broadcast();
  Stream<Salaah> get onMarkPrayed => _markPrayedController.stream;

  NotificationService(
    this._soundManager,
    this._channelManager,
    this._prayerScheduler,
    this._notificationsPlugin,
    this._widgetUpdateService,
    this._settingsProvider,
    this._prefs,
    this._navigatorKey,
  );

  /// Waits until the service is fully initialized.
  Future<void> ensureInitialized() => _initCompleter.future;

  static const String reminderChannelId = ChannelManager.reminderChannelId;
  static const String testAzanChannelId = 'azan_test_channel';
  static String get downloadChannelId => AppIdentifiers.downloadChannelId;
  static String get groupKey => AppIdentifiers.notificationGroupKey;

  String _applyRtl(String text) {
    return RtlTextUtil.applyRtlFromSettings(text, _settingsProvider);
  }

  Future<void> init() async {
    if (_initCompleter.isCompleted) return;
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
        debugPrint(
          'NotificationService: Error/Timeout getting local timezone: $e',
        );
        if (cachedTimezone != null) {
          debugPrint(
            'NotificationService: Using cached timezone: $cachedTimezone',
          );
          timeZoneName = cachedTimezone;
        } else {
          debugPrint(
            'NotificationService: No cached timezone found, defaulting to UTC',
          );
          timeZoneName = 'UTC';
        }
      }

      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('Local timezone set to: $timeZoneName');

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
            if (_navigatorKey.currentState != null) {
              if (details.payload!.startsWith('category:')) {
                final category = details.payload!.replaceFirst('category:', '');
                _navigatorKey.currentState!.push(
                  MaterialPageRoute(
                    builder: (_) => AzkarListScreen(category: category),
                  ),
                );
              }
            }
          }
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // Create notification channels for Android initially
      if (Platform.isAndroid) {
        await _channelManager.createNotificationChannels(_notificationsPlugin);
        
        final adhanChannel = MethodChannel(AppIdentifiers.adhanChannelName);
        adhanChannel.setMethodCallHandler((call) async {
          if (call.method == 'onMarkPrayedFromNotification') {
            final String prayerName = call.arguments as String;
            debugPrint('NotificationService: received onMarkPrayedFromNotification: $prayerName');
            _handleMarkPrayed(prayerName);
          }
        });

        final pending = _prefs.getString('pending_mark_prayed');
        if (pending != null) {
          debugPrint('NotificationService: found pending mark prayed in prefs: $pending');
          await _prefs.remove('pending_mark_prayed');
          Future.delayed(const Duration(milliseconds: 500), () {
            _handleMarkPrayed(pending);
          });
        }
      }
    } catch (e) {
      debugPrint('NotificationService initialization error: $e');
    } finally {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
      debugPrint('NotificationService: init complete');
    }
  }

  /// Request only basic notification permissions.
  /// Useful for first-open or when the user interacts with a toggle.
  Future<bool> requestNotificationPermission() async {
    debugPrint('NotificationService: requesting notification permission...');
    final status = await Permission.notification.request();
    debugPrint('Notification permission status: $status');
    return status.isGranted;
  }

  /// Request all required permissions for notifications and exact alarms.
  /// Returns true if all critical permissions are granted.
  Future<bool> requestPermissions() async {
    debugPrint('NotificationService: requesting permissions...');

    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final notificationGranted =
          await androidPlugin?.requestNotificationsPermission() ?? false;
      final alarmGranted =
          await androidPlugin?.requestExactAlarmsPermission() ?? false;

      debugPrint(
        'Permissions result: Notifications=$notificationGranted, Alarms=$alarmGranted',
      );

      if (notificationGranted) {
        // Re-create channels to ensure they are properly registered now that we have permission
        await ensureInitialized();
        await _channelManager.createNotificationChannels(
          _notificationsPlugin,
          settings: _settingsProvider,
        );
      }

      return notificationGranted;
    } else {
      // iOS / Other platforms
      final notificationStatus = await Permission.notification.request();
      debugPrint('Permissions result: Notifications=$notificationStatus');
      return notificationStatus.isGranted;
    }
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
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      return await Permission.notification.isGranted;
    }
    return true;
  }

  Future<bool> canScheduleExactNotifications() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidPlugin?.canScheduleExactNotifications() ?? false;
    }
    return true;
  }

  Future<bool> isCountdownChannelBlocked() async {
    if (!Platform.isAndroid) return false;
    
    // First check overall notification permissions
    final enabled = await areNotificationsEnabled();
    if (!enabled) return true;

    // Then query our custom native MethodChannel to check if the specific channel is blocked
    try {
      final adhanChannel = MethodChannel(AppIdentifiers.adhanChannelName);
      final bool isBlocked = await adhanChannel.invokeMethod<bool>(
        'checkChannelBlocked',
        {'channelId': 'salah_countdown_channel'},
      ) ?? false;
      return isBlocked;
    } catch (e) {
      debugPrint('Failed to check channel block status natively: $e');
      return false;
    }
  }

  Future<bool> requestExactAlarmsPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await androidPlugin?.requestExactAlarmsPermission() ?? false;
    }
    return true;
  }

  Future<bool> isBatteryOptimizationIgnored() async {
    if (Platform.isAndroid) {
      try {
        final adhanChannel = MethodChannel(AppIdentifiers.adhanChannelName);
        return await adhanChannel.invokeMethod<bool>('isBatteryOptimizationIgnored') ?? false;
      } catch (e) {
        debugPrint('Failed to check battery optimization status natively: $e');
        return true;
      }
    }
    return true;
  }

  Future<void> requestIgnoreBatteryOptimizations() async {
    if (Platform.isAndroid) {
      try {
        final adhanChannel = MethodChannel(AppIdentifiers.adhanChannelName);
        await adhanChannel.invokeMethod('requestIgnoreBatteryOptimizations');
      } catch (e) {
        debugPrint('Failed to request ignore battery optimization natively: $e');
        await openAppSettings();
      }
    }
  }

  Future<void> schedulePrayerNotifications() async {
    await ensureInitialized();
    // Update widget data
    await _widgetUpdateService.updateWidget();

    await _prayerScheduler.schedulePrayerNotifications(_notificationsPlugin);
    if (Platform.isAndroid) {
      try {
        final adhanChannel = MethodChannel(AppIdentifiers.adhanChannelName);
        await adhanChannel.invokeMethod('updateCountdownNotification');
      } catch (e) {
        debugPrint('Failed to trigger updateCountdownNotification: $e');
      }
    }
  }

  Future<void> testAzan(Salaah salaah, String? sound, {bool isTest = true}) async {
    await ensureInitialized();
    try {
      // 1. Check permissions first
      final bool enabled = await areNotificationsEnabled();
      final bool canSchedule = await canScheduleExactNotifications();

      if (!enabled || !canSchedule) {
        debugPrint(
          'testAzan: Permissions missing. Enabled: $enabled, CanSchedule: $canSchedule',
        );
        // The UI handles user feedback for missing permissions.
      }

      final String salaahName = _getSalaahName(salaah);
      final String soundPath = sound ?? 'default';

      final bool isAndroid = !kIsWeb && Platform.isAndroid;
      final bool useNativeAdhan = isAndroid && soundPath != 'default';

      if (useNativeAdhan) {
        String rawPath = soundPath;
        if (!soundPath.contains('/') && !soundPath.contains('\\')) {
          try {
            final downloader = getIt<VoiceDownloadService>();
            final path = await downloader.getAccessiblePath(soundPath);
            rawPath = path ?? '';
          } catch (e) {
            debugPrint('testAzan: Error resolving voice key: $e');
          }
        }
        
        try {
          final adhanChannel = MethodChannel(AppIdentifiers.adhanChannelName);
          await adhanChannel.invokeMethod('startAdhanService', {
            'prayerName': _getSalaahName(salaah),
            'audioFilePath': rawPath,
            'isTest': isTest,
          });
        } catch (e) {
          debugPrint('testAzan: Error starting native Adhan service: $e');
        }
        return;
      }

      // Delete any old test channels to prevent Android from restoring cached sound configurations
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        final channels = await androidPlugin.getNotificationChannels();
        for (final channel in channels ?? []) {
          if (channel.id.startsWith('azan_test_')) {
            await androidPlugin.deleteNotificationChannel(
              channelId: channel.id,
            );
          }
        }
      }

      // Use a completely unique channel ID for each test to bypass the Android channel cache bug.
      // Since we delete old ones above, this won't leak channels.
      final String channelId =
          'azan_test_${DateTime.now().millisecondsSinceEpoch}';

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
          // Fallback for raw resources
          if (!soundPath.contains('/') && !soundPath.contains('\\')) {
            final resourceName = soundPath.split('.').first;
            notificationSound = RawResourceAndroidNotificationSound(
              resourceName,
            );
            diagnosticInfo = '\nمحاولة استخدام مورد داخلي: $resourceName';
          }
        }
      }

      final bool isDefault = soundPath == 'default';
      AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            channelId,
            _applyRtl('Azan Test'),
            channelDescription: _applyRtl('Temporary channel for Azan testing'),
            icon: '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
            category: isDefault ? null : AndroidNotificationCategory.alarm,
            audioAttributesUsage: isDefault ? AudioAttributesUsage.notification : AudioAttributesUsage.alarm,
            playSound: true,
            sound: notificationSound,
            groupKey: groupKey,
            fullScreenIntent: false,
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
          windows: const WindowsNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('NotificationService: Error in testAzan: $e');
    }
  }

  Future<void> testReminder(Salaah salaah, int minutesBefore) async {
    await ensureInitialized();
    try {
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
            icon: '@mipmap/ic_launcher',
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
          windows: const WindowsNotificationDetails(),
        ),
      );
    } catch (e) {
      debugPrint('NotificationService: Error in testReminder: $e');
    }
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
          icon: '@mipmap/ic_launcher',
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

    results['notifications_enabled'] = await areNotificationsEnabled();
    results['exact_alarm_permission'] = await canScheduleExactNotifications();
    results['battery_optimization_ignored'] =
        await isBatteryOptimizationIgnored();
    results['device_manufacturer'] = await getDeviceManufacturer();

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

  Future<void> scheduleSalawatReminders() async {
    await _prayerScheduler.scheduleSalawatReminders(_notificationsPlugin);
  }

  Future<void> cancelPrayerReminder(
    Salaah salaah, {
    bool forTodayOnly = true,
  }) async {
    // Current day only for smart cancellation
    final dayOffset = salaah.index;

    // Cancel pre-prayer reminder
    await _notificationsPlugin.cancel(
      id: PrayerNotificationScheduler.prayerReminderIdStart + dayOffset,
    );

    // Cancel post-prayer reminder (both legacy logging and new Azkar)
    await _notificationsPlugin.cancel(
      id: PrayerNotificationScheduler.postPrayerReminderIdStart + dayOffset,
    );
    await _notificationsPlugin.cancel(
      id: PrayerNotificationScheduler.afterSalahAzkarIdStart + dayOffset,
    );
  }

  Future<void> cancelWerdReminder({bool forTodayOnly = false}) async {
    // If forTodayOnly, we would need to know the specific day's ID
    // Since werdReminderId is currently a single repeating ID,
    // we just cancel it.
    // TODO: If we move to non-repeating for rolling window, use day-specific IDs.
    await _notificationsPlugin.cancel(
      id: PrayerNotificationScheduler.werdReminderId,
    );
  }

  static const List<String> oemManufacturers = [
    'xiaomi',
    'redmi',
    'poco',
    'huawei',
    'honor',
    'oppo',
    'realme',
    'vivo',
    'oneplus',
  ];

  Future<String> getDeviceManufacturer() async {
    if (!Platform.isAndroid) return 'none';
    try {
      final adhanChannel = MethodChannel(AppIdentifiers.adhanChannelName);
      final String? manufacturer = await adhanChannel.invokeMethod<String>('getDeviceManufacturer');
      return manufacturer ?? 'none';
    } catch (e) {
      debugPrint('Error getting device manufacturer: $e');
      return 'none';
    }
  }

  Future<bool> isOemDeviceForAutostart() async {
    if (!Platform.isAndroid) return false;
    final manufacturer = (await getDeviceManufacturer()).toLowerCase();
    return oemManufacturers.any((oem) => manufacturer.contains(oem));
  }

  Future<void> openAutostartSettings() async {
    if (!Platform.isAndroid) return;
    try {
      final adhanChannel = MethodChannel(AppIdentifiers.adhanChannelName);
      await adhanChannel.invokeMethod('openAutostartSettings');
    } catch (e) {
      debugPrint('Error opening autostart settings: $e');
    }
  }

  Future<Map<String, bool>> checkSoundStatus() async {
    if (!Platform.isAndroid) {
      return {
        'silentMode': false,
        'dndMode': false,
        'isMuted': false,
      };
    }
    try {
      final adhanChannel = MethodChannel(AppIdentifiers.adhanChannelName);
      final result = await adhanChannel.invokeMapMethod<String, bool>('checkSoundStatus');
      if (result != null) {
        return {
          'silentMode': result['silentMode'] ?? false,
          'dndMode': result['dndMode'] ?? false,
          'isMuted': result['isMuted'] ?? false,
        };
      }
    } catch (e) {
      debugPrint('Error checking sound status: $e');
    }
    return {
      'silentMode': false,
      'dndMode': false,
      'isMuted': false,
    };
  }

  void _handleMarkPrayed(String arabicName) {
    Salaah? salaah;
    if (arabicName == 'الفجر') {
      salaah = Salaah.fajr;
    } else if (arabicName == 'الظهر') {
      salaah = Salaah.dhuhr;
    } else if (arabicName == 'العصر') {
      salaah = Salaah.asr;
    } else if (arabicName == 'المغرب') {
      salaah = Salaah.maghrib;
    } else if (arabicName == 'العشاء') {
      salaah = Salaah.isha;
    }
    if (salaah != null) {
      debugPrint('NotificationService: triggering onMarkPrayed for $salaah');
      _markPrayedController.add(salaah);
    } else {
      debugPrint('NotificationService: unknown prayer name: $arabicName');
    }
  }
}

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse details) async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('BackgroundIsolate: notificationTapBackground called. actionId=${details.actionId}, payload=${details.payload}');
  
  if (details.actionId == 'action_mark_previous_prayed' && details.payload != null) {
    final parts = details.payload!.split(':');
    if (parts.length == 3 && parts[0] == 'mark_prayed') {
      final prayerKey = parts[1];
      final dateStr = parts[2];
      debugPrint('BackgroundIsolate: marking $prayerKey as completed on $dateStr');

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      try {
        await Hive.initFlutter();
      } catch (e) {
        debugPrint('BackgroundIsolate: Hive already initialized or failed: $e');
      }

      final prayer = Salaah.values.firstWhere(
        (s) => s.name.toLowerCase() == prayerKey.toLowerCase(),
        orElse: () => Salaah.fajr,
      );
      final date = DateTime.parse(dateStr);

      await BackgroundPrayerSyncService.markPrayerAsPrayed(date, prayer, prefs);

      // Cancel/hide the post-Salah notification that was clicked
      if (details.id != null) {
        final notificationsPlugin = FlutterLocalNotificationsPlugin();
        await notificationsPlugin.cancel(id: details.id!);
        debugPrint('BackgroundIsolate: cancelled notification ${details.id}');
      }

      try {
        await AppIdentifiers.initialize();
      } catch (e) {
        debugPrint('BackgroundIsolate: Failed to initialize AppIdentifiers: $e');
      }

      tz_data.initializeTimeZones();
      try {
        final timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
      } catch (_) {}

      final settings = SettingsLoader.loadSettings(prefs);
      final settingsProvider = BackgroundSettingsProvider(settings);
      final prayerTimeService = PrayerTimeService();
      
      final widgetUpdateService = WidgetUpdateService(
        prayerTimeService,
        prefs,
        settingsProvider,
      );
      await widgetUpdateService.updateWidget();

      final soundManager = SoundManager();
      final channelManager = ChannelManager(soundManager);
      final scheduler = PrayerNotificationScheduler(
        prayerTimeService,
        BackgroundAzkarSource(),
        channelManager,
        soundManager,
        settingsProvider,
      );

      final notificationsPlugin = FlutterLocalNotificationsPlugin();
      await scheduler.schedulePrayerNotifications(notificationsPlugin);
      debugPrint('BackgroundIsolate: finished scheduling notifications');
    }
  }
}
