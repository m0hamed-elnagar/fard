import 'package:fard/core/services/notification/channel_manager.dart';
import 'package:fard/core/services/notification/prayer_scheduler.dart';
import 'package:adhan/adhan.dart';
import 'package:fard/core/services/notification/sound_manager.dart';
import 'package:fard/features/azkar/domain/azkar_item.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}
class MockAzkarRepository extends Mock implements AzkarRepository {}
class MockChannelManager extends Mock implements ChannelManager {}
class MockSoundManager extends Mock implements SoundManager {}
class MockAndroidFlutterLocalNotificationsPlugin extends Mock implements AndroidFlutterLocalNotificationsPlugin {}
class FakePrayerTimes extends Fake implements PrayerTimes {}

void main() {
  late PrayerNotificationScheduler scheduler;
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late MockPrayerTimeService mockPrayerTimeService;
  late MockAzkarRepository mockAzkarRepository;
  late MockChannelManager mockChannelManager;
  late MockSoundManager mockSoundManager;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(DateTimeComponents.time);
    registerFallbackValue(const AndroidNotificationChannel('id', 'name'));
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(const SettingsState(locale: Locale('en')));
    registerFallbackValue(MockFlutterLocalNotificationsPlugin());
    registerFallbackValue(FakePrayerTimes());
  });

  setUp(() {
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockPrayerTimeService = MockPrayerTimeService();
    mockAzkarRepository = MockAzkarRepository();
    mockChannelManager = MockChannelManager();
    mockSoundManager = MockSoundManager();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();

    scheduler = PrayerNotificationScheduler(
      mockPrayerTimeService,
      mockAzkarRepository,
      mockChannelManager,
      mockSoundManager,
    );

    when(() => mockNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidPlugin);
    when(() => mockChannelManager.createNotificationChannels(any(), settings: any(named: 'settings')))
        .thenAnswer((_) async {});
    when(() => mockChannelManager.ensureChannelExists(any(), channelId: any(named: 'channelId'), salaahId: any(named: 'salaahId'), sound: any(named: 'sound')))
        .thenAnswer((_) async {});
    when(() => mockChannelManager.getChannelId(any(), any())).thenReturn('channel_id');
    when(() => mockSoundManager.getSoundUriForChannel(any())).thenAnswer((_) async => null);

    when(() => mockNotificationsPlugin.cancel(id: any(named: 'id'))).thenAnswer((_) async {});
    when(() => mockNotificationsPlugin.zonedSchedule(
      id: any(named: 'id'),
      title: any(named: 'title'),
      body: any(named: 'body'),
      scheduledDate: any(named: 'scheduledDate'),
      notificationDetails: any(named: 'notificationDetails'),
      androidScheduleMode: any(named: 'androidScheduleMode'),
      payload: any(named: 'payload'),
      matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
    )).thenAnswer((_) async {});
    
    when(() => mockAzkarRepository.getAllAzkar()).thenAnswer((_) async => []);
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

    await scheduler.schedulePrayerNotifications(mockNotificationsPlugin, settings: settings);

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

  test('scheduleAzkarReminders schedules reminders from settings', () async {
    final settings = SettingsState(
      locale: const Locale('en'),
      reminders: [
        const AzkarReminder(category: 'morning', time: '08:00', isEnabled: true),
        const AzkarReminder(category: 'evening', time: '18:00', isEnabled: true),
      ],
    );

    final azkarList = [
      AzkarItem(category: 'morning', zekr: 'SubhanAllah', description: '', count: 1, reference: ''),
      AzkarItem(category: 'evening', zekr: 'Alhamdulillah', description: '', count: 1, reference: ''),
    ];

    await scheduler.scheduleAzkarReminders(
      mockNotificationsPlugin, 
      settings: settings, 
      allAzkar: azkarList,
    );

    // Should cancel 50 IDs first (0-49 range check in loop)
    // Then schedule 2 reminders
    
    verify(() => mockNotificationsPlugin.zonedSchedule(
      id: any(named: 'id', that: greaterThanOrEqualTo(100)),
      title: any(named: 'title'),
      body: any(named: 'body'),
      scheduledDate: any(named: 'scheduledDate'),
      notificationDetails: any(named: 'notificationDetails'),
      androidScheduleMode: any(named: 'androidScheduleMode'),
      payload: any(named: 'payload'),
      matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
    )).called(2);
  });
}

class MockPrayerTimes extends Mock implements PrayerTimes {}
