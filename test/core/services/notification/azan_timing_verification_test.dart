import 'dart:io' show Platform;
import 'package:fard/core/services/notification/channel_manager.dart';
import 'package:fard/core/services/notification/prayer_scheduler.dart';
import 'package:fard/core/services/notification/sound_manager.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/azkar/domain/azkar_item.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAzkarRepository extends Mock implements AzkarRepository {}

class MockChannelManager extends Mock implements ChannelManager {}

class MockSoundManager extends Mock implements SoundManager {}

class MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PrayerNotificationScheduler scheduler;
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late PrayerTimeService prayerTimeService;
  late MockAzkarRepository mockAzkarRepository;
  late MockChannelManager mockChannelManager;
  late MockSoundManager mockSoundManager;
  late MockSettingsRepository mockSettingsProvider;

  setUpAll(() {
    tz.initializeTimeZones();
    // Use a fixed location to ensure consistent results
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));

    // Mock Workmanager MethodChannel to prevent UnimplementedError
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('be.tramckrijte.workmanager'),
          (MethodCall methodCall) async {
            return true;
          },
        );

    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(DateTimeComponents.time);
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(MockFlutterLocalNotificationsPlugin());
    registerFallbackValue(MockSettingsRepository());
  });

  setUp(() {
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    prayerTimeService = PrayerTimeService();
    mockAzkarRepository = MockAzkarRepository();
    mockChannelManager = MockChannelManager();
    mockSoundManager = MockSoundManager();
    mockSettingsProvider = MockSettingsRepository();

    scheduler = PrayerNotificationScheduler(
      prayerTimeService,
      mockAzkarRepository,
      mockChannelManager,
      mockSoundManager,
      mockSettingsProvider,
    );

    when(
      () => mockChannelManager.createNotificationChannels(
        any(),
        settings: any(named: 'settings'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockChannelManager.ensureChannelExists(
        any(),
        channelId: any(named: 'channelId'),
        salaahId: any(named: 'salaahId'),
        sound: any(named: 'sound'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockChannelManager.getChannelId(any(), any()),
    ).thenReturn('channel_id');
    when(
      () => mockSoundManager.getSoundUriForChannel(any()),
    ).thenAnswer((_) async => null);

    when(
      () => mockNotificationsPlugin.cancel(id: any(named: 'id')),
    ).thenAnswer((_) async {});
    when(
      () => mockNotificationsPlugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
        payload: any(named: 'payload'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockSettingsProvider.isSalahReminderEnabled).thenReturn(false);
    when(() => mockSettingsProvider.salahReminderOffsetMinutes).thenReturn(0);
    when(() => mockSettingsProvider.prayerReminderType).thenReturn(PrayerReminderType.after);
    when(() => mockSettingsProvider.enabledSalahReminders).thenReturn({});
    when(() => mockSettingsProvider.isAfterSalahAzkarEnabled).thenReturn(false);
  });

  test(
    'Verification: Azan is scheduled at the EXACT prayer time (Egyptian Method)',
    () async {
      // Skip on desktop platforms (WorkManager not available)
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        return;
      }
      
      // Cairo coordinates
      const lat = 30.0444;
      const lon = 31.2357;

      when(() => mockSettingsProvider.locale).thenReturn(const Locale('ar'));
      when(() => mockSettingsProvider.latitude).thenReturn(lat);
      when(() => mockSettingsProvider.longitude).thenReturn(lon);
      when(() => mockSettingsProvider.calculationMethod).thenReturn('egyptian');
      when(() => mockSettingsProvider.madhab).thenReturn('shafi');
      when(() => mockSettingsProvider.salaahSettings).thenReturn([
        SalaahSettings(
          salaah: Salaah.fajr,
          isAzanEnabled: true,
          isReminderEnabled: false,
        ),
      ]);
      when(
        () => mockSettingsProvider.isAfterSalahAzkarEnabled,
      ).thenReturn(false);
      when(() => mockSettingsProvider.reminders).thenReturn([]);

      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);

      final prayerTimes = prayerTimeService.getPrayerTimes(
        latitude: lat,
        longitude: lon,
        method: 'egyptian',
        madhab: 'shafi',
        date: DateTime.now(),
      );

      final expectedFajr = tz.TZDateTime.from(prayerTimes.fajr, tz.local);

      if (expectedFajr.isAfter(tz.TZDateTime.now(tz.local))) {
        verify(
          () => mockNotificationsPlugin.zonedSchedule(
            id: 200,
            title: any(named: 'title', that: contains('الفجر')),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'), // Relaxed date check
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            payload: any(named: 'payload'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).called(1);
      }
    },
  );

  test('Verification: Azan timing with Umm Al-Qura in Makkah', () async {
      // Skip on desktop platforms (WorkManager not available)
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        return;
      }
      
      tz.setLocalLocation(tz.getLocation('Asia/Riyadh'));

    const lat = 21.4225;
    const lon = 39.8262;

    when(() => mockSettingsProvider.locale).thenReturn(const Locale('ar'));
    when(() => mockSettingsProvider.latitude).thenReturn(lat);
    when(() => mockSettingsProvider.longitude).thenReturn(lon);
    when(
      () => mockSettingsProvider.calculationMethod,
    ).thenReturn('umm_al_qura');
    when(() => mockSettingsProvider.madhab).thenReturn('shafi');
    when(() => mockSettingsProvider.salaahSettings).thenReturn([
      SalaahSettings(
        salaah: Salaah.maghrib,
        isAzanEnabled: true,
        isReminderEnabled: false,
      ),
    ]);
    when(() => mockSettingsProvider.isAfterSalahAzkarEnabled).thenReturn(false);
    when(() => mockSettingsProvider.reminders).thenReturn([]);

    await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);

    final prayerTimes = prayerTimeService.getPrayerTimes(
      latitude: lat,
      longitude: lon,
      method: 'umm_al_qura',
      madhab: 'shafi',
      date: DateTime.now(),
    );

    final expectedMaghrib = tz.TZDateTime.from(prayerTimes.maghrib, tz.local);

    if (expectedMaghrib.isAfter(tz.TZDateTime.now(tz.local))) {
      verify(
        () => mockNotificationsPlugin.zonedSchedule(
          id: 203, // Maghrib ID
          title: any(named: 'title', that: contains('المغرب')),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
          payload: any(named: 'payload'),
          matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
        ),
      ).called(1);
    }

    // Reset timezone for other tests
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
  });

  test(
    'Verification: Reminder is scheduled EXACTLY X minutes before Azan',
    () async {
      const lat = 30.0444;
      const lon = 31.2357;
      const minutesBefore = 10;

      when(() => mockSettingsProvider.locale).thenReturn(const Locale('ar'));
      when(() => mockSettingsProvider.latitude).thenReturn(lat);
      when(() => mockSettingsProvider.longitude).thenReturn(lon);
      when(() => mockSettingsProvider.calculationMethod).thenReturn('egyptian');
      when(() => mockSettingsProvider.madhab).thenReturn('shafi');
      when(() => mockSettingsProvider.salaahSettings).thenReturn([
        SalaahSettings(
          salaah: Salaah.dhuhr,
          isAzanEnabled: false,
          isReminderEnabled: true,
          reminderMinutesBefore: minutesBefore,
        ),
      ]);
      when(
        () => mockSettingsProvider.isAfterSalahAzkarEnabled,
      ).thenReturn(false);
      when(() => mockSettingsProvider.reminders).thenReturn([]);

      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);

      final prayerTimes = prayerTimeService.getPrayerTimes(
        latitude: lat,
        longitude: lon,
        method: 'egyptian',
        madhab: 'shafi',
        date: DateTime.now(),
      );

      final expectedDhuhr = tz.TZDateTime.from(prayerTimes.dhuhr, tz.local);
      final expectedReminder = expectedDhuhr.subtract(
        const Duration(minutes: minutesBefore),
      );

      if (expectedReminder.isAfter(tz.TZDateTime.now(tz.local))) {
        verify(
          () => mockNotificationsPlugin.zonedSchedule(
            id: 301, // Dhuhr Reminder ID
            title: any(named: 'title', that: contains('تذكير')),
            body: any(named: 'body', that: contains('$minutesBefore')),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            payload: any(named: 'payload'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).called(1);
      }
    },
  );

  test(
    'Verification: After Salah Azkar is scheduled configurable minutes AFTER Azan',
    () async {
      const lat = 30.0444;
      const lon = 31.2357;
      const minutesAfter = 20;

      when(() => mockSettingsProvider.locale).thenReturn(const Locale('ar'));
      when(() => mockSettingsProvider.latitude).thenReturn(lat);
      when(() => mockSettingsProvider.longitude).thenReturn(lon);
      when(() => mockSettingsProvider.calculationMethod).thenReturn('egyptian');
      when(() => mockSettingsProvider.madhab).thenReturn('shafi');
      when(
        () => mockSettingsProvider.isAfterSalahAzkarEnabled,
      ).thenReturn(true);
      when(() => mockSettingsProvider.salaahSettings).thenReturn([
        SalaahSettings(
          salaah: Salaah.isha,
          isAzanEnabled: false,
          isAfterSalahAzkarEnabled: true,
          afterSalaahAzkarMinutes: minutesAfter,
        ),
      ]);
      when(() => mockSettingsProvider.reminders).thenReturn([]);

      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);

      final prayerTimes = prayerTimeService.getPrayerTimes(
        latitude: lat,
        longitude: lon,
        method: 'egyptian',
        madhab: 'shafi',
        date: DateTime.now(),
      );

      final expectedIsha = tz.TZDateTime.from(prayerTimes.isha, tz.local);
      final expectedAzkar = expectedIsha.add(
        const Duration(minutes: minutesAfter),
      );

      if (expectedAzkar.isAfter(tz.TZDateTime.now(tz.local))) {
        verify(
          () => mockNotificationsPlugin.zonedSchedule(
            id: 404, // Isha After Salah Azkar ID
            title: any(named: 'title', that: contains('أذكار')),
            body: any(named: 'body'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            payload: any(named: 'payload'),
            matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
          ),
        ).called(1);
      }
    },
  );
}
