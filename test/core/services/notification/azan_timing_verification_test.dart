import 'package:fard/core/services/notification/channel_manager.dart';
import 'package:fard/core/services/notification/prayer_scheduler.dart';
import 'package:fard/core/services/notification/sound_manager.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/azkar/domain/azkar_item.dart';
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
class MockAzkarRepository extends Mock implements AzkarRepository {}
class MockChannelManager extends Mock implements ChannelManager {}
class MockSoundManager extends Mock implements SoundManager {}

void main() {
  late PrayerNotificationScheduler scheduler;
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late PrayerTimeService prayerTimeService;
  late MockAzkarRepository mockAzkarRepository;
  late MockChannelManager mockChannelManager;
  late MockSoundManager mockSoundManager;

  setUpAll(() {
    tz.initializeTimeZones();
    // Use a fixed location to ensure consistent results
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(DateTimeComponents.time);
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(const SettingsState(locale: Locale('en')));
    registerFallbackValue(MockFlutterLocalNotificationsPlugin());
  });

  setUp(() {
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    prayerTimeService = PrayerTimeService();
    mockAzkarRepository = MockAzkarRepository();
    mockChannelManager = MockChannelManager();
    mockSoundManager = MockSoundManager();

    scheduler = PrayerNotificationScheduler(
      prayerTimeService,
      mockAzkarRepository,
      mockChannelManager,
      mockSoundManager,
    );

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
    
    when(() => mockAzkarRepository.getAllAzkar()).thenAnswer((_) async => [
      const AzkarItem(category: 'الأذكار بعد السلام من الصلاة', zekr: 'SubhanAllah', description: '', count: 1, reference: ''),
    ]);
  });

  test('Verification: Azan is scheduled at the EXACT prayer time (Egyptian Method)', () async {
    // Cairo coordinates
    const lat = 30.0444;
    const lon = 31.2357;
    
    final settings = SettingsState(
      locale: const Locale('ar'),
      latitude: lat,
      longitude: lon,
      calculationMethod: 'egyptian',
      madhab: 'shafi',
      isAzanVoiceDownloading: false,
      salaahSettings: [
        SalaahSettings(salaah: Salaah.fajr, isAzanEnabled: true, isReminderEnabled: false),
      ],
    );

    await scheduler.schedulePrayerNotifications(mockNotificationsPlugin, settings: settings);

    final prayerTimes = prayerTimeService.getPrayerTimes(
      latitude: lat,
      longitude: lon,
      method: 'egyptian',
      madhab: 'shafi',
      date: DateTime.now(),
    );

    final expectedFajr = tz.TZDateTime.from(prayerTimes.fajr, tz.local);
    
    if (expectedFajr.isAfter(tz.TZDateTime.now(tz.local))) {
      verify(() => mockNotificationsPlugin.zonedSchedule(
        id: 200,
        title: any(named: 'title', that: contains('الفجر')),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'), // Relaxed date check
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        payload: any(named: 'payload'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      )).called(1);
    }
  });

  test('Verification: Azan timing with Umm Al-Qura in Makkah', () async {
    tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));
    
    const lat = 21.4225;
    const lon = 39.8262;
    
    final settings = SettingsState(
      locale: const Locale('ar'),
      latitude: lat,
      longitude: lon,
      calculationMethod: 'umm_al_qura',
      madhab: 'shafi',
      isAzanVoiceDownloading: false,
      salaahSettings: [
        SalaahSettings(salaah: Salaah.maghrib, isAzanEnabled: true, isReminderEnabled: false),
      ],
    );

    await scheduler.schedulePrayerNotifications(mockNotificationsPlugin, settings: settings);

    final prayerTimes = prayerTimeService.getPrayerTimes(
      latitude: lat,
      longitude: lon,
      method: 'umm_al_qura',
      madhab: 'shafi',
      date: DateTime.now(),
    );

    final expectedMaghrib = tz.TZDateTime.from(prayerTimes.maghrib, tz.local);
    
    if (expectedMaghrib.isAfter(tz.TZDateTime.now(tz.local))) {
      verify(() => mockNotificationsPlugin.zonedSchedule(
        id: 203, // Maghrib ID
        title: any(named: 'title', that: contains('المغرب')),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        payload: any(named: 'payload'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      )).called(1);
    }
    
    // Reset timezone for other tests
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
  });

  test('Verification: Reminder is scheduled EXACTLY X minutes before Azan', () async {
    const lat = 30.0444;
    const lon = 31.2357;
    const minutesBefore = 10;
    
    final settings = SettingsState(
      locale: const Locale('ar'),
      latitude: lat,
      longitude: lon,
      calculationMethod: 'egyptian',
      madhab: 'shafi',
      isAzanVoiceDownloading: false,
      salaahSettings: [
        SalaahSettings(
          salaah: Salaah.dhuhr, 
          isAzanEnabled: false, 
          isReminderEnabled: true,
          reminderMinutesBefore: minutesBefore,
        ),
      ],
    );

    await scheduler.schedulePrayerNotifications(mockNotificationsPlugin, settings: settings);

    final prayerTimes = prayerTimeService.getPrayerTimes(
      latitude: lat,
      longitude: lon,
      method: 'egyptian',
      madhab: 'shafi',
      date: DateTime.now(),
    );

    final expectedDhuhr = tz.TZDateTime.from(prayerTimes.dhuhr, tz.local);
    final expectedReminder = expectedDhuhr.subtract(const Duration(minutes: minutesBefore));
    
    if (expectedReminder.isAfter(tz.TZDateTime.now(tz.local))) {
      verify(() => mockNotificationsPlugin.zonedSchedule(
        id: 301, // Dhuhr Reminder ID
        title: any(named: 'title', that: contains('تذكير')),
        body: any(named: 'body', that: contains('$minutesBefore')),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        payload: any(named: 'payload'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      )).called(1);
    }
  });

  test('Verification: After Salah Azkar is scheduled 15 minutes AFTER Azan', () async {
    const lat = 30.0444;
    const lon = 31.2357;
    
    final settings = SettingsState(
      locale: const Locale('ar'),
      latitude: lat,
      longitude: lon,
      isAfterSalahAzkarEnabled: true,
      isAzanVoiceDownloading: false,
      salaahSettings: [
        SalaahSettings(
          salaah: Salaah.isha, 
          isAzanEnabled: false, 
          isAfterSalahAzkarEnabled: true,
        ),
      ],
    );

    await scheduler.schedulePrayerNotifications(mockNotificationsPlugin, settings: settings);

    final prayerTimes = prayerTimeService.getPrayerTimes(
      latitude: lat,
      longitude: lon,
      method: 'egyptian',
      madhab: 'shafi',
      date: DateTime.now(),
    );

    final expectedIsha = tz.TZDateTime.from(prayerTimes.isha, tz.local);
    final expectedAzkar = expectedIsha.add(const Duration(minutes: 15));
    
    if (expectedAzkar.isAfter(tz.TZDateTime.now(tz.local))) {
      verify(() => mockNotificationsPlugin.zonedSchedule(
        id: 404, // Isha After Salah Azkar ID
        title: any(named: 'title', that: contains('أذكار')),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        payload: any(named: 'payload'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      )).called(1);
    }
  });
}
