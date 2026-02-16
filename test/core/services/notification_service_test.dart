import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:adhan/adhan.dart';

class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}
class MockVoiceDownloadService extends Mock implements VoiceDownloadService {}
class MockAndroidFlutterLocalNotificationsPlugin extends Mock implements AndroidFlutterLocalNotificationsPlugin {}
class MockAzkarRepository extends Mock implements AzkarRepository {}
class FakePrayerTimes extends Fake implements PrayerTimes {}

void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late MockPrayerTimeService mockPrayerTimeService;
  late MockVoiceDownloadService mockVoiceDownloadService;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;
  late MockAzkarRepository mockAzkarRepository;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(DateTimeComponents.time);
    registerFallbackValue(const AndroidNotificationChannel('id', 'name'));
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(FakePrayerTimes());
  });

  setUp(() async {
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockPrayerTimeService = MockPrayerTimeService();
    mockVoiceDownloadService = MockVoiceDownloadService();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    mockAzkarRepository = MockAzkarRepository();

    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerSingleton<PrayerTimeService>(mockPrayerTimeService);
    getIt.registerSingleton<VoiceDownloadService>(mockVoiceDownloadService);
    getIt.registerSingleton<AzkarRepository>(mockAzkarRepository);
    getIt.registerSingleton<GlobalKey<NavigatorState>>(GlobalKey<NavigatorState>());

    notificationService = NotificationService(mockNotificationsPlugin);

    when(() => mockAzkarRepository.getAllAzkar()).thenAnswer((_) async => []);

    when(() => mockNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidPlugin);
    when(() => mockAndroidPlugin.requestNotificationsPermission()).thenAnswer((_) async => true);
    when(() => mockAndroidPlugin.requestExactAlarmsPermission()).thenAnswer((_) async => true);
    when(() => mockAndroidPlugin.canScheduleExactNotifications()).thenAnswer((_) async => true);
    when(() => mockAndroidPlugin.createNotificationChannel(any())).thenAnswer((_) async {});
    when(() => mockAndroidPlugin.getNotificationChannels()).thenAnswer((_) async => []);
    when(() => mockNotificationsPlugin.initialize(settings: any(named: 'settings'), onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse')))
        .thenAnswer((_) async => true);
    when(() => mockNotificationsPlugin.cancel(id: any(named: 'id'))).thenAnswer((_) async {});
    when(() => mockNotificationsPlugin.zonedSchedule(
      id: any(named: 'id'),
      title: any(named: 'title'),
      body: any(named: 'body'),
      scheduledDate: any(named: 'scheduledDate'),
      notificationDetails: any(named: 'notificationDetails'),
      androidScheduleMode: any(named: 'androidScheduleMode'),
    )).thenAnswer((_) async {});
  });

  group('NotificationService', () {
    test('init initializes plugin and creates channels', () async {
      await notificationService.init();
      verify(() => mockNotificationsPlugin.initialize(settings: any(named: 'settings'), onDidReceiveNotificationResponse: any(named: 'onDidReceiveNotificationResponse'))).called(1);
      // prayer_reminders, azkar_reminders (default azan is skipped because settings is null)
      verify(() => mockAndroidPlugin.createNotificationChannel(any())).called(2);
    });

    test('schedulePrayerNotifications schedules all 5 prayers', () async {
      final settings = SettingsState(
        locale: const Locale('ar'),
        latitude: 30.0,
        longitude: 31.0,
        isAzanVoiceDownloading: false,
        salaahSettings: Salaah.values.map((s) => SalaahSettings(
          salaah: s, 
          isAzanEnabled: true, 
          isReminderEnabled: false
        )).toList(),
      );

      final now = DateTime.now().toUtc();
      
      when(() => mockPrayerTimeService.getPrayerTimes(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        method: any(named: 'method'),
        madhab: any(named: 'madhab'),
        date: any(named: 'date'),
      )).thenReturn(MockPrayerTimes());

      when(() => mockPrayerTimeService.getTimeForSalaah(any(), any()))
          .thenReturn(now.add(const Duration(hours: 1)));

      await notificationService.schedulePrayerNotifications(settings: settings);

      // 5 prayers * 7 days = 35 azan notifications
      verify(() => mockNotificationsPlugin.zonedSchedule(
        id: any(named: 'id', that: greaterThanOrEqualTo(200)),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
      )).called(35);
    });
  });
}

class MockPrayerTimes extends Mock implements PrayerTimes {}
