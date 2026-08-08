import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/notification/channel_manager.dart';
import 'package:fard/core/services/notification/prayer_scheduler.dart';
import 'package:fard/core/services/notification/sound_manager.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/presentation/blocs/theme_state.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:fard/features/prayer_tracking/data/daily_record_entity.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockFlutterLocalNotificationsPlatform extends Mock
    implements FlutterLocalNotificationsPlatform {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    with MockPlatformInterfaceMixin
    implements AndroidFlutterLocalNotificationsPlugin {}

class MockSoundManager extends Mock implements SoundManager {}

class MockChannelManager extends Mock implements ChannelManager {}

class MockPrayerNotificationScheduler extends Mock
    implements PrayerNotificationScheduler {}

class MockWidgetUpdateService extends Mock implements WidgetUpdateService {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_timezone');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
        if (methodCall.method == 'getLocalTimezone') {
          return 'UTC';
        }
        return null;
      });

  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;
  late MockSoundManager mockSoundManager;
  late MockChannelManager mockChannelManager;
  late MockPrayerNotificationScheduler mockPrayerScheduler;
  late MockWidgetUpdateService mockWidgetUpdateService;
  late MockSettingsRepository mockSettingsRepository;
  late MockSharedPreferences mockSharedPreferences;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(DateTimeComponents.time);
    registerFallbackValue(const AndroidNotificationChannel('id', 'name'));
    registerFallbackValue(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue((NotificationResponse details) {});
    registerFallbackValue(MockFlutterLocalNotificationsPlugin());
    registerFallbackValue((NotificationResponse details) async {});
    registerFallbackValue(const ThemeState(locale: Locale('en')));
    registerFallbackValue(MockSettingsRepository());
  });

  int mockPermissionStatus = 1;

  setUp(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DailyRecordEntityAdapter());
    }

    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    mockSoundManager = MockSoundManager();
    mockChannelManager = MockChannelManager();
    mockPrayerScheduler = MockPrayerNotificationScheduler();
    mockWidgetUpdateService = MockWidgetUpdateService();
    mockSettingsRepository = MockSettingsRepository();
    mockSharedPreferences = MockSharedPreferences();
    mockPermissionStatus = 1;

    // Mock SharedPreferences
    when(() => mockSharedPreferences.getString(any())).thenReturn(null);
    when(
      () => mockSharedPreferences.setString(any(), any()),
    ).thenAnswer((_) async => true);

    when(
      () => mockNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >(),
    ).thenReturn(mockAndroidPlugin);
    when(
      () => mockAndroidPlugin.requestNotificationsPermission(),
    ).thenAnswer((_) async => true);
    when(
      () => mockAndroidPlugin.requestExactAlarmsPermission(),
    ).thenAnswer((_) async => true);
    when(
      () => mockAndroidPlugin.canScheduleExactNotifications(),
    ).thenAnswer((_) async => true);
    when(
      () => mockAndroidPlugin.createNotificationChannel(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockAndroidPlugin.getNotificationChannels(),
    ).thenAnswer((_) async => []);

    when(
      () => mockNotificationsPlugin.initialize(
        settings: any(named: 'settings'),
        onDidReceiveNotificationResponse: any(
          named: 'onDidReceiveNotificationResponse',
        ),
        onDidReceiveBackgroundNotificationResponse: any(
          named: 'onDidReceiveBackgroundNotificationResponse',
        ),
      ),
    ).thenAnswer((_) async => true);

    when(
      () => mockChannelManager.createNotificationChannels(
        any(),
        settings: any(named: 'settings'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockWidgetUpdateService.updateWidget()).thenAnswer((_) async {});

    when(() => mockSettingsRepository.locale).thenReturn(const Locale('en'));

    notificationService = NotificationService(
      mockSoundManager,
      mockChannelManager,
      mockPrayerScheduler,
      mockNotificationsPlugin,
      mockWidgetUpdateService,
      mockSettingsRepository,
      mockSharedPreferences,
      GlobalKey<NavigatorState>(),
    );

    // Mock FlutterTimezone
    const MethodChannel channel = MethodChannel('flutter_timezone');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getLocalTimezone') {
        return 'UTC';
      }
      return null;
    });

    // Mock permission_handler MethodChannel
    const MethodChannel permissionChannel =
        MethodChannel('flutter.baseflow.com/permissions/methods');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(permissionChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'requestPermissions') {
        final List<dynamic> permissions = methodCall.arguments;
        final map = <int, int>{};
        for (final p in permissions) {
          map[p as int] = mockPermissionStatus;
        }
        return map;
      }
      return null;
    });

    await notificationService.init();
  });

  group('NotificationService', () {
    test('init initializes plugin and creates channels', () async {
      await notificationService.init();

      verify(
        () => mockNotificationsPlugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse: any(
            named: 'onDidReceiveNotificationResponse',
          ),
          onDidReceiveBackgroundNotificationResponse: any(
            named: 'onDidReceiveBackgroundNotificationResponse',
          ),
        ),
      ).called(1);
    });

    test(
      'schedulePrayerNotifications delegates to scheduler and updates widget',
      () async {
        when(
          () => mockPrayerScheduler.schedulePrayerNotifications(any()),
        ).thenAnswer((_) async {});

        await notificationService.schedulePrayerNotifications();

        verify(() => mockWidgetUpdateService.updateWidget()).called(1);
        verify(
          () => mockPrayerScheduler.schedulePrayerNotifications(
            mockNotificationsPlugin,
          ),
        ).called(1);
      },
    );

    test('requestPermissions returns notificationGranted status even if exact alarms fail', () async {
      when(() => mockAndroidPlugin.requestNotificationsPermission()).thenAnswer((_) async => true);
      when(() => mockAndroidPlugin.requestExactAlarmsPermission()).thenAnswer((_) async => false);
      mockPermissionStatus = 1;

      final result = await notificationService.requestPermissions();

      expect(result, isTrue);
    });

    test('requestPermissions returns false if notification permission is denied', () async {
      when(() => mockAndroidPlugin.requestNotificationsPermission()).thenAnswer((_) async => false);
      when(() => mockAndroidPlugin.requestExactAlarmsPermission()).thenAnswer((_) async => true);
      mockPermissionStatus = 0;

      final result = await notificationService.requestPermissions();

      expect(result, isFalse);
    });

    test('notificationTapBackground updates SharedPreferences in the background', () async {
      SharedPreferences.setMockInitialValues({
        'pending_completed_prayers': '',
        'completed_today': '',
        'locale': 'en',
        'latitude': 30.0,
        'longitude': 31.0,
      });

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('dev.fluttercommunity.plus/package_info'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'getAll') {
                return {
                  'appName': 'Fard',
                  'packageName': 'com.khwarizmi.fard',
                  'version': '1.0.0',
                  'buildNumber': '1',
                };
              }
              return null;
            },
          );

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('dexterous.com/flutter/plugins/flutter_local_notifications'),
            (MethodCall methodCall) async {
              return null;
            },
          );

      FlutterLocalNotificationsPlatform.instance = mockAndroidPlugin;
      when(() => mockAndroidPlugin.canScheduleExactNotifications()).thenAnswer((_) async => true);
      when(() => mockAndroidPlugin.getNotificationChannels()).thenAnswer((_) async => []);
      when(() => mockAndroidPlugin.cancel(id: any(named: 'id'))).thenAnswer((_) async {});
      
      when(
        () => mockAndroidPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).thenAnswer((_) async {});

      when(
        () => mockAndroidPlugin.zonedSchedule(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).thenAnswer((_) async {});

      final todayStr = "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";
      final response = NotificationResponse(
        id: 1,
        actionId: 'action_mark_previous_prayed',
        payload: 'mark_prayed:dhuhr:$todayStr',
        notificationResponseType: NotificationResponseType.selectedNotificationAction,
      );
      
      await notificationTapBackground(response);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('flutter.prayer_done_dhuhr_$todayStr'), isTrue);
      expect(prefs.getString('completed_today'), 'dhuhr');

      final box = Hive.box<DailyRecordEntity>('daily_records');
      expect(box.values.length, 1);
      expect(box.values.first.completedIndices, contains(1)); // Dhuhr index is 1
    });
  });
}
