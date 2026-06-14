import 'package:adhan/adhan.dart';
import 'package:fard/core/services/notification/channel_manager.dart';
import 'package:fard/core/services/notification/prayer_scheduler.dart';
import 'package:fard/core/services/notification/sound_manager.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/azkar/domain/azkar_item.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/azkar_reminder.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/presentation/blocs/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockPrayerTimeService extends Mock implements PrayerTimeService {}

class MockAzkarRepository extends Mock implements AzkarRepository {}

class MockChannelManager extends Mock implements ChannelManager {}

class MockSoundManager extends Mock implements SoundManager {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class FakePrayerTimes extends Fake implements PrayerTimes {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PrayerNotificationScheduler scheduler;
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late MockPrayerTimeService mockPrayerTimeService;
  late MockAzkarRepository mockAzkarRepository;
  late MockChannelManager mockChannelManager;
  late MockSoundManager mockSoundManager;
  late MockSettingsRepository mockSettingsRepository;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;

  setUpAll(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));

    // Mock Workmanager MethodChannel
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
    registerFallbackValue(AndroidScheduleMode.inexactAllowWhileIdle);
    registerFallbackValue(DateTimeComponents.time);
    registerFallbackValue(const AndroidNotificationChannel('id', 'name'));
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(const ThemeState(locale: Locale('en')));
    registerFallbackValue(MockFlutterLocalNotificationsPlugin());
    registerFallbackValue(FakePrayerTimes());
    registerFallbackValue(MockSettingsRepository());
  });

  setUp(() {
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockPrayerTimeService = MockPrayerTimeService();
    mockAzkarRepository = MockAzkarRepository();
    mockChannelManager = MockChannelManager();
    mockSoundManager = MockSoundManager();
    mockSettingsRepository = MockSettingsRepository();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();

    scheduler = PrayerNotificationScheduler(
      mockPrayerTimeService,
      mockAzkarRepository,
      mockChannelManager,
      mockSoundManager,
      mockSettingsRepository,
    );

    when(
      () => mockNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >(),
    ).thenReturn(mockAndroidPlugin);
    
    when(
      () => mockAndroidPlugin.canScheduleExactNotifications(),
    ).thenAnswer((_) async => true);
    
    when(() => mockChannelManager.createNotificationChannels(any(), settings: any(named: 'settings')))
        .thenAnswer((_) async {});
        
    when(() => mockNotificationsPlugin.cancel(id: any(named: 'id')))
        .thenAnswer((_) async {});
        
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

    // Default SettingsRepository stubs (everything disabled)
    when(() => mockSettingsRepository.latitude).thenReturn(30.0);
    when(() => mockSettingsRepository.longitude).thenReturn(31.0);
    when(() => mockSettingsRepository.calculationMethod).thenReturn('muslim_league');
    when(() => mockSettingsRepository.madhab).thenReturn('shafi');
    when(() => mockSettingsRepository.isWerdReminderEnabled).thenReturn(false);
    when(() => mockSettingsRepository.werdReminderTime).thenReturn('20:00');
    when(() => mockSettingsRepository.isSalawatReminderEnabled).thenReturn(false);
    when(() => mockSettingsRepository.salawatStartTime).thenReturn('10:00');
    when(() => mockSettingsRepository.salawatEndTime).thenReturn('20:00');
    when(() => mockSettingsRepository.salawatFrequencyHours).thenReturn(3);
    when(() => mockSettingsRepository.locale).thenReturn(const Locale('ar'));
    when(() => mockSettingsRepository.reminders).thenReturn([]);
    when(() => mockSettingsRepository.isAfterSalahAzkarEnabled).thenReturn(false);
    when(() => mockSettingsRepository.salaahSettings).thenReturn(
      Salaah.values.map((s) => SalaahSettings(
        salaah: s, 
        isAzanEnabled: false, 
        isReminderEnabled: false,
        isAfterSalahAzkarEnabled: false,
      )).toList()
    );
    when(() => mockSettingsRepository.enabledSalahReminders).thenReturn({});
    when(() => mockSettingsRepository.isSalahReminderEnabled).thenReturn(false);
    when(() => mockSettingsRepository.salahReminderOffsetMinutes).thenReturn(15);

    when(() => mockAzkarRepository.getAllAzkar()).thenAnswer((_) async => []);
    when(() => mockPrayerTimeService.getPrayerTimes(
      latitude: any(named: 'latitude'),
      longitude: any(named: 'longitude'),
      method: any(named: 'method'),
      madhab: any(named: 'madhab'),
      date: any(named: 'date'),
    )).thenReturn(FakePrayerTimes());
    
    when(() => mockPrayerTimeService.getTimeForSalaah(any(), any()))
        .thenReturn(DateTime.now().add(const Duration(hours: 2)));
    
    when(() => mockSoundManager.getSoundUriForChannel(any()))
        .thenAnswer((_) async => null);
        
    when(() => mockChannelManager.getChannelId(any(), any()))
        .thenReturn('test_channel');
    
    when(() => mockChannelManager.ensureChannelExists(any(), 
      channelId: any(named: 'channelId'),
      salaahId: any(named: 'salaahId'),
      sound: any(named: 'sound'),
    )).thenAnswer((_) async {});
  });

  group('PrayerNotificationScheduler Toggle Scenarios', () {
    test('Scenario: All Notifications Disabled', () async {
      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);

      // Verify range cancellations
      verify(() => mockNotificationsPlugin.cancel(id: 200)).called(1);
      verify(() => mockNotificationsPlugin.cancel(id: 300)).called(1);
      verify(() => mockNotificationsPlugin.cancel(id: 400)).called(1);
      verify(() => mockNotificationsPlugin.cancel(id: 500)).called(1);
      verify(() => mockNotificationsPlugin.cancel(id: 600)).called(1); // Werd
      verify(() => mockNotificationsPlugin.cancel(id: 700)).called(2); // Salawat (range + specific else)
      
      // Ensure NO scheduling happened
      verifyNever(() => mockNotificationsPlugin.zonedSchedule(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
      ));
    });

    test('Scenario: Only Fajr Adhan Enabled', () async {
      when(() => mockSettingsRepository.salaahSettings).thenReturn(
        Salaah.values.map((s) => SalaahSettings(
          salaah: s, 
          isAzanEnabled: s == Salaah.fajr, 
        )).toList()
      );

      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);

      // Verify Fajr Adhan scheduled (ID 200 for day 0, 205 for day 1, 210 for day 2)
      verify(() => mockNotificationsPlugin.zonedSchedule(
        id: 200,
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: any(named: 'payload'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      )).called(1);

      verifyNever(() => mockNotificationsPlugin.zonedSchedule(
        id: 201,
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: any(named: 'androidScheduleMode'),
      ));
    });

    test('Scenario: Post-Prayer Reminder Enabled for Maghrib Only', () async {
      when(() => mockSettingsRepository.isSalahReminderEnabled).thenReturn(true);
      when(() => mockSettingsRepository.enabledSalahReminders).thenReturn({Salaah.maghrib});

      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);

      // Maghrib is index 3. ID = 503.
      verify(() => mockNotificationsPlugin.zonedSchedule(
        id: 503,
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: any(named: 'payload'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      )).called(1);
    });

    test('Scenario: Pre-Prayer Reminder Enabled for Dhuhr', () async {
      when(() => mockSettingsRepository.salaahSettings).thenReturn(
        Salaah.values.map((s) => SalaahSettings(
          salaah: s, 
          isReminderEnabled: s == Salaah.dhuhr, 
          reminderMinutesBefore: 10,
        )).toList()
      );

      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);

      // Dhuhr is index 1. ID = 301.
      verify(() => mockNotificationsPlugin.zonedSchedule(
        id: 301,
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: any(named: 'payload'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      )).called(1);
    });

    test('Scenario: After-Salah Azkar Enabled globally but disabled for Asr', () async {
      when(() => mockSettingsRepository.isAfterSalahAzkarEnabled).thenReturn(true);
      when(() => mockSettingsRepository.salaahSettings).thenReturn(
        Salaah.values.map((s) => SalaahSettings(
          salaah: s, 
          isAfterSalahAzkarEnabled: s != Salaah.asr, 
        )).toList()
      );

      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);

      // Fajr is index 0. ID = 400.
      verify(() => mockNotificationsPlugin.zonedSchedule(
        id: 400,
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: any(named: 'payload'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      )).called(1);
    });

    test('Scenario: Werd Reminder Toggled ON then OFF', () async {
      // 1. ON
      when(() => mockSettingsRepository.isWerdReminderEnabled).thenReturn(true);
      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);
      verify(() => mockNotificationsPlugin.zonedSchedule(
        id: 600,
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: any(named: 'payload'),
        matchDateTimeComponents: DateTimeComponents.time,
      )).called(1);

      // 2. OFF
      when(() => mockSettingsRepository.isWerdReminderEnabled).thenReturn(false);
      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);
      
      // ID 600 should be cancelled in the second call
      verify(() => mockNotificationsPlugin.cancel(id: 600)).called(1); 
    });

    test('Scenario: Salawat Reminders Enabled', () async {
      when(() => mockSettingsRepository.isSalawatReminderEnabled).thenReturn(true);
      
      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);

      verify(() => mockNotificationsPlugin.zonedSchedule(
        id: 700,
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: any(named: 'payload'),
        matchDateTimeComponents: any(named: 'matchDateTimeComponents'),
      )).called(greaterThanOrEqualTo(1));
    });

    test('Scenario: Azkar Reminders (Custom)', () async {
      when(() => mockSettingsRepository.reminders).thenReturn([
        const AzkarReminder(category: 'test', time: '10:00', isEnabled: true),
      ]);

      await scheduler.scheduleAzkarReminders(mockNotificationsPlugin, allAzkar: [
        AzkarItem(category: 'test', zekr: 'test zekr', description: '', count: 1, reference: ''),
      ]);

      verify(() => mockNotificationsPlugin.zonedSchedule(
        id: 100,
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledDate: any(named: 'scheduledDate'),
        notificationDetails: any(named: 'notificationDetails'),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: any(named: 'payload'),
        matchDateTimeComponents: DateTimeComponents.time,
      )).called(1);
    });
  });
}
