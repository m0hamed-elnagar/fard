import 'dart:io';
import 'package:fard/core/services/background_azkar_source.dart';
import 'package:fard/core/services/notification/channel_manager.dart';
import 'package:fard/core/services/notification/prayer_scheduler.dart';
import 'package:fard/core/services/notification/sound_manager.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/settings_loader.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/core/utils/app_identifiers.dart';
import 'package:fard/features/settings/domain/app_settings.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/entities/custom_theme.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/audio/domain/repositories/audio_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Minimal SettingsRepository implementation for background isolates.
/// Wraps the [AppSettings] loaded from SharedPreferences.
class _BackgroundSettingsProvider implements SettingsRepository {
  final AppSettings _settings;

  _BackgroundSettingsProvider(this._settings);

  @override
  Locale get locale => _settings.locale;

  @override
  double? get latitude => _settings.latitude;

  @override
  double? get longitude => _settings.longitude;

  @override
  String? get cityName => _settings.cityName;

  @override
  String get calculationMethod => _settings.calculationMethod;

  @override
  String get madhab => _settings.madhab;

  @override
  String get morningAzkarTime => _settings.morningAzkarTime;

  @override
  String get eveningAzkarTime => _settings.eveningAzkarTime;

  @override
  bool get isAfterSalahAzkarEnabled => _settings.isAfterSalahAzkarEnabled;

  @override
  List<SalaahSettings> get salaahSettings => _settings.salaahSettings;

  @override
  List<AzkarReminder> get reminders => _settings.reminders;

  @override
  bool get isQadaEnabled => _settings.isQadaEnabled;

  @override
  int get hijriAdjustment => _settings.hijriAdjustment;

  @override
  String get themePresetId => _settings.themePresetId;

  @override
  Map<String, String>? get customThemeColors => _settings.customThemeColors;

  @override
  List<CustomTheme> get savedCustomThemes => const [];

  @override
  String? get activeCustomThemeId => null;

  @override
  AudioQuality get audioQuality => _settings.audioQuality;

  @override
  bool get isAudioPlayerExpanded => _settings.isAudioPlayerExpanded;

  // Write operations are not supported in background isolate
  @override
  Future<void> updateLocale(Locale locale) => Future.value();

  @override
  Future<void> updateLocation({
    double? latitude,
    double? longitude,
    String? cityName,
  }) => Future.value();

  @override
  Future<void> updateCalculationMethod(String method) => Future.value();

  @override
  Future<void> updateMadhab(String madhab) => Future.value();

  @override
  Future<void> updateMorningAzkarTime(String time) => Future.value();

  @override
  Future<void> updateEveningAzkarTime(String time) => Future.value();

  @override
  Future<void> updateAfterSalahAzkarEnabled(bool enabled) => Future.value();

  @override
  Future<void> updateSalaahSettings(List<SalaahSettings> settings) =>
      Future.value();

  @override
  Future<void> toggleQadaEnabled() => Future.value();

  @override
  Future<void> updateHijriAdjustment(int adjustment) => Future.value();

  @override
  Future<void> addReminder(AzkarReminder reminder) => Future.value();

  @override
  Future<void> removeReminder(int index) => Future.value();

  @override
  Future<void> updateReminder(int index, AzkarReminder reminder) =>
      Future.value();

  @override
  Future<void> toggleReminder(int index) => Future.value();

  @override
  Future<void> updateAllAzanEnabled(bool enabled) => Future.value();

  @override
  Future<void> updateAllReminderEnabled(bool enabled) => Future.value();

  @override
  Future<void> updateAllAzanSound(String? sound) => Future.value();

  @override
  Future<void> updateAllReminderMinutes(int minutes) => Future.value();

  @override
  Future<void> updateAllAfterSalahMinutes(int minutes) => Future.value();

  @override
  Future<void> updateThemePreset(String presetId) => Future.value();

  @override
  Future<void> saveCustomTheme(Map<String, String> colors) => Future.value();

  @override
  Future<void> addCustomTheme(CustomTheme theme) => Future.value();

  @override
  Future<void> updateCustomTheme(String themeId, Map<String, String> colors) => Future.value();

  @override
  Future<void> deleteCustomTheme(String themeId) => Future.value();

  @override
  Future<void> setActiveCustomTheme(String? themeId) => Future.value();

  @override
  Future<void> updateAudioQuality(AudioQuality quality) => Future.value();

  @override
  Future<void> updateAudioPlayerExpanded(bool expanded) => Future.value();
}

/// WorkManager task unique names (initialized when needed).
String get _backgroundTaskUniqueName => AppIdentifiers.prayerSchedulerTaskName;
const String _backgroundTaskKey = 'prayer_scheduler_task';
String get _widgetTaskUniqueName => AppIdentifiers.widgetRefreshTaskName;
const String _widgetTaskKey = 'widget_refresh_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint('Background Service: Starting task $task');

    try {
      if (task == _backgroundTaskKey || task == _widgetTaskKey) {
        // 1. Initialize Bindings
        WidgetsFlutterBinding.ensureInitialized();

        // 2. Initialize Timezone
        tz.initializeTimeZones();
        try {
          final timeZoneName = await FlutterTimezone.getLocalTimezone();
          tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
        } catch (e) {
          debugPrint('Background Service: Failed to get timezone: $e');
        }

        // 3. Load Settings
        final prefs = await SharedPreferences.getInstance();
        final settings = SettingsLoader.loadSettings(prefs);

        if (settings.latitude == null || settings.longitude == null) {
          debugPrint('Background Service: Location not set, skipping.');
          return Future.value(true);
        }

        final prayerTimeService = PrayerTimeService();
        final settingsProvider = _BackgroundSettingsProvider(settings);
        final widgetUpdateService = WidgetUpdateService(
          prayerTimeService,
          prefs,
          settingsProvider,
        );

        // 4. Initialize Dependencies for scheduling
        final soundManager = SoundManager();
        final channelManager = ChannelManager(soundManager);
        final azkarSource = BackgroundAzkarSource();
        final scheduler = PrayerNotificationScheduler(
          prayerTimeService,
          azkarSource,
          channelManager,
          soundManager,
          settingsProvider,
        );

        final notificationsPlugin = FlutterLocalNotificationsPlugin();
        const AndroidInitializationSettings initializationSettingsAndroid =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const InitializationSettings initializationSettings =
            InitializationSettings(
              android: initializationSettingsAndroid,
              iOS: DarwinInitializationSettings(),
            );

        await notificationsPlugin.initialize(
          settings: initializationSettings,
          onDidReceiveNotificationResponse: (_) {},
        );

        if (task == _widgetTaskKey) {
          debugPrint(
            'Background Service: Refreshing widget data and notifications (safety net)...',
          );
          await widgetUpdateService.updateWidget();

          // 🛡️ Safety net: also reschedule notifications during widget refresh
          // This ensures that even if the 12h task fails, the 15m task keeps us covered.
          await scheduler.schedulePrayerNotifications(notificationsPlugin);
          final allAzkar = await azkarSource.getAllAzkar();
          await scheduler.scheduleAzkarReminders(
            notificationsPlugin,
            allAzkar: allAzkar,
          );

          return Future.value(true);
        }

        // 5. Schedule Notifications (Main 12h Task)
        debugPrint('Background Service: Scheduling notifications (Main)...');
        await scheduler.schedulePrayerNotifications(notificationsPlugin);

        final allAzkar = await azkarSource.getAllAzkar();
        await scheduler.scheduleAzkarReminders(
          notificationsPlugin,
          allAzkar: allAzkar,
        );

        // Also update widget during the main task
        await widgetUpdateService.updateWidget();

        debugPrint('Background Service: Task completed successfully.');
      }
    } catch (e) {
      debugPrint('Background Service: Error executing task: $e');
      return Future.value(true);
    }

    return Future.value(true);
  });
}

class BackgroundService {
  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);

    if (Platform.isAndroid || Platform.isIOS) {
      await Workmanager().registerPeriodicTask(
        _backgroundTaskUniqueName,
        _backgroundTaskKey,
        frequency: const Duration(hours: 12),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
        constraints: Constraints(networkType: NetworkType.notRequired),
      );

      // Register fallback widget refresh task (every 15 mins)
      await Workmanager().registerPeriodicTask(
        _widgetTaskUniqueName,
        _widgetTaskKey,
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
        constraints: Constraints(networkType: NetworkType.notRequired),
      );
    }
  }
}
