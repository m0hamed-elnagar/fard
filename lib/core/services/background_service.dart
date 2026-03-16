import 'dart:io';
import 'package:fard/core/services/background_azkar_source.dart';
import 'package:fard/core/services/notification/channel_manager.dart';
import 'package:fard/core/services/notification/prayer_scheduler.dart';
import 'package:fard/core/services/notification/sound_manager.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/settings_loader.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

const String _backgroundTaskUniqueName = 'com.nagar.fard.prayer_scheduler_task';
const String _backgroundTaskKey = 'prayer_scheduler_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('Background Service: Starting task $task');

    try {
      if (task == _backgroundTaskKey) {
        // 1. Initialize Bindings
        WidgetsFlutterBinding.ensureInitialized();

        // 2. Initialize Timezone
        tz.initializeTimeZones();
        try {
          // On Android/background, FlutterTimezone might fail or return native string.
          // We can try to get it, or default to local if platform channel is active.
          // In background isolate, platform channels are available after ensureInitialized.
          final timeZoneName = await FlutterTimezone.getLocalTimezone();
          tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
        } catch (e) {
          debugPrint('Background Service: Failed to get timezone: $e');
          // Fallback to UTC or a default if safe, but local is better.
          // tz.local is usually UTC if not set.
        }

        // 3. Load Settings
        final prefs = await SharedPreferences.getInstance();
        final settings = SettingsLoader.loadSettings(prefs);

        if (settings.latitude == null || settings.longitude == null) {
          debugPrint('Background Service: Location not set, skipping.');
          return Future.value(true);
        }

        // 4. Initialize Dependencies
        final prayerTimeService = PrayerTimeService();
        final soundManager = SoundManager();
        await soundManager.init(); // Important for package info
        final channelManager = ChannelManager(soundManager);
        final azkarSource = BackgroundAzkarSource();
        final scheduler = PrayerNotificationScheduler(
          prayerTimeService,
          azkarSource,
          channelManager,
          soundManager,
        );

        final notificationsPlugin = FlutterLocalNotificationsPlugin();

        // Initialize notifications plugin (minimal init for background)
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');
            
        const DarwinInitializationSettings initializationSettingsDarwin =
            DarwinInitializationSettings();
            
        const InitializationSettings initializationSettings = InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );
        
        await notificationsPlugin.initialize(settings: initializationSettings);

        // 5. Schedule Notifications
        debugPrint('Background Service: Scheduling notifications...');
        await scheduler.schedulePrayerNotifications(
          notificationsPlugin,
          settings: settings,
        );
        
        // Also schedule azkar reminders if needed
        final allAzkar = await azkarSource.getAllAzkar();
        await scheduler.scheduleAzkarReminders(
          notificationsPlugin, 
          settings: settings, 
          allAzkar: allAzkar
        );
        
        debugPrint('Background Service: Task completed successfully.');
      }
    } catch (e, stack) {
      debugPrint('Background Service: Error executing task: $e');
      debugPrint(stack.toString());
      // Return true to avoid retry loops if it's a permanent error, 
      // or false to retry. For now true to be safe.
      return Future.value(true);
    }

    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    debugPrint('Background Service: Initializing Workmanager...');
    await Workmanager().initialize(
      callbackDispatcher,
      // isInDebugMode: kDebugMode, // Deprecated
    );
    
    // Register periodic task
    if (Platform.isAndroid || Platform.isIOS) {
      debugPrint('Background Service: Registering periodic task...');
      await Workmanager().registerPeriodicTask(
        _backgroundTaskUniqueName,
        _backgroundTaskKey,
        frequency: const Duration(hours: 12), // Minimum is 15 mins, but 12h is safe for daily updates
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        backoffPolicy: BackoffPolicy.linear,
        initialDelay: const Duration(seconds: 10),
      );
    }
  }
}
