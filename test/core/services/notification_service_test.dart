import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/notification/channel_manager.dart';
import 'package:fard/core/services/notification/prayer_scheduler.dart';
import 'package:fard/core/services/notification/sound_manager.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class MockSoundManager extends Mock implements SoundManager {}

class MockChannelManager extends Mock implements ChannelManager {}

class MockPrayerNotificationScheduler extends Mock
    implements PrayerNotificationScheduler {}

class MockWidgetUpdateService extends Mock implements WidgetUpdateService {}

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
        android: AndroidInitializationSettings('ic_launcher'),
      ),
    );
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue((NotificationResponse details) {});
    registerFallbackValue(MockFlutterLocalNotificationsPlugin());
    registerFallbackValue(const SettingsState(locale: Locale('en')));
  });

  setUp(() {
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    mockSoundManager = MockSoundManager();
    mockChannelManager = MockChannelManager();
    mockPrayerScheduler = MockPrayerNotificationScheduler();
    mockWidgetUpdateService = MockWidgetUpdateService();

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
      ),
    ).thenAnswer((_) async => true);

    when(() => mockSoundManager.init()).thenAnswer((_) async {});
    when(
      () => mockChannelManager.createNotificationChannels(
        any(),
        settings: any(named: 'settings'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockWidgetUpdateService.updateWidget(any()),
    ).thenAnswer((_) async {});

    notificationService = NotificationService(
      mockSoundManager,
      mockChannelManager,
      mockPrayerScheduler,
      mockNotificationsPlugin,
      mockWidgetUpdateService,
    );
  });

  group('NotificationService', () {
    test(
      'init initializes plugin, sound manager, and creates channels',
      () async {
        await notificationService.init();

        verify(() => mockSoundManager.init()).called(1);
        verify(
          () => mockNotificationsPlugin.initialize(
            settings: any(named: 'settings'),
            onDidReceiveNotificationResponse: any(
              named: 'onDidReceiveNotificationResponse',
            ),
          ),
        ).called(1);
      },
    );

    test(
      'schedulePrayerNotifications delegates to scheduler and updates widget',
      () async {
        final settings = SettingsState(
          locale: const Locale('ar'),
          latitude: 30.0,
          longitude: 31.0,
          isAzanVoiceDownloading: false,
          salaahSettings: [],
        );

        when(
          () => mockPrayerScheduler.schedulePrayerNotifications(
            any(),
            settings: any(named: 'settings'),
          ),
        ).thenAnswer((_) async {});

        await notificationService.schedulePrayerNotifications(
          settings: settings,
        );

        verify(() => mockWidgetUpdateService.updateWidget(settings)).called(1);
        verify(
          () => mockPrayerScheduler.schedulePrayerNotifications(
            mockNotificationsPlugin,
            settings: settings,
          ),
        ).called(1);
      },
    );
  });
}
