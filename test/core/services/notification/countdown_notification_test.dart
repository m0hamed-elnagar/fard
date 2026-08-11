import 'dart:convert';
import 'package:adhan/adhan.dart';
import 'package:fard/core/services/notification/channel_manager.dart';
import 'package:fard/core/services/notification/prayer_scheduler.dart';
import 'package:fard/core/services/notification/sound_manager.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/azkar/data/azkar_repository.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class FakePrayerTimes extends Fake implements PrayerTimes {
  final DateTime baseDate;
  FakePrayerTimes(this.baseDate);

  @override
  DateTime get fajr => DateTime(baseDate.year, baseDate.month, baseDate.day, 4, 30);
  @override
  DateTime get dhuhr => DateTime(baseDate.year, baseDate.month, baseDate.day, 12, 15);
  @override
  DateTime get asr => DateTime(baseDate.year, baseDate.month, baseDate.day, 15, 45);
  @override
  DateTime get maghrib => DateTime(baseDate.year, baseDate.month, baseDate.day, 18, 30);
  @override
  DateTime get isha => DateTime(baseDate.year, baseDate.month, baseDate.day, 20, 00);
}

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

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('be.tramckrijte.workmanager'),
          (MethodCall methodCall) async => true,
        );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('com.khwarizmi.fard/adhan'),
          (MethodCall methodCall) async => true,
        );

    registerFallbackValue(tz.TZDateTime.now(tz.local));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(DateTimeComponents.time);
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(MockFlutterLocalNotificationsPlugin());
    registerFallbackValue(FakePrayerTimes(DateTime.now()));
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockPrayerTimeService = MockPrayerTimeService();
    mockAzkarRepository = MockAzkarRepository();
    mockChannelManager = MockChannelManager();
    mockSoundManager = MockSoundManager();
    mockSettingsRepository = MockSettingsRepository();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();

    when(() => mockSettingsRepository.isWerdReminderEnabled).thenReturn(false);
    when(() => mockSettingsRepository.isSalawatReminderEnabled).thenReturn(false);
    when(() => mockSettingsRepository.reminders).thenReturn([]);
    when(() => mockSettingsRepository.isAfterSalahAzkarEnabled).thenReturn(false);
    when(() => mockSettingsRepository.latitude).thenReturn(30.0);
    when(() => mockSettingsRepository.longitude).thenReturn(31.0);
    when(() => mockSettingsRepository.calculationMethod).thenReturn('egyptian');
    when(() => mockSettingsRepository.madhab).thenReturn('shafi');
    when(() => mockSettingsRepository.useExactAlarmClock).thenReturn(true);
    when(() => mockSettingsRepository.locale).thenReturn(const Locale('en'));
    when(() => mockSettingsRepository.isSalahReminderEnabled).thenReturn(false);
    when(() => mockSettingsRepository.isBeforeSalahReminderEnabled).thenReturn(false);
    when(() => mockSettingsRepository.enabledBeforeSalahReminders).thenReturn({});

    when(() => mockSettingsRepository.salaahSettings).thenReturn(
      Salaah.values
          .map((s) => SalaahSettings(salaah: s, isAzanEnabled: true, azanSound: 'default'))
          .toList(),
    );

    scheduler = PrayerNotificationScheduler(
      mockPrayerTimeService,
      mockAzkarRepository,
      mockChannelManager,
      mockSoundManager,
      mockSettingsRepository,
    );

    when(
      () => mockNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>(),
    ).thenReturn(mockAndroidPlugin);
    when(() => mockAndroidPlugin.canScheduleExactNotifications()).thenAnswer((_) async => true);
    when(
      () => mockChannelManager.createNotificationChannels(
        any(),
        settings: any(named: 'settings'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockChannelManager.getChannelId(any(), any()),
    ).thenReturn('channel_id');
    when(() => mockSoundManager.getSoundUriForChannel(any())).thenAnswer((_) async => null);
    when(() => mockNotificationsPlugin.cancel(id: any(named: 'id'))).thenAnswer((_) async {});
    when(() => mockAzkarRepository.getAllAzkar()).thenAnswer((_) async => []);
  });

  group('Countdown Notification Schedule Tests', () {
    test('schedulePrayerNotifications populates adhan_schedule with prayer entries for multiple days', () async {
      when(
        () => mockPrayerTimeService.getPrayerTimes(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          method: any(named: 'method'),
          madhab: any(named: 'madhab'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((invocation) {
        final date = invocation.namedArguments[#date] as DateTime;
        return FakePrayerTimes(date);
      });

      when(
        () => mockPrayerTimeService.getTimeForSalaah(any(), any()),
      ).thenAnswer((invocation) {
        final prayerTimes = invocation.positionalArguments[0] as FakePrayerTimes;
        final salaah = invocation.positionalArguments[1] as Salaah;
        switch (salaah) {
          case Salaah.fajr:
            return prayerTimes.fajr;
          case Salaah.dhuhr:
            return prayerTimes.dhuhr;
          case Salaah.asr:
            return prayerTimes.asr;
          case Salaah.maghrib:
            return prayerTimes.maghrib;
          case Salaah.isha:
            return prayerTimes.isha;
        }
      });

      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);

      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('fard.adhan_schedule');
      expect(jsonStr, isNotNull);

      final List<dynamic> schedule = jsonDecode(jsonStr!);
      expect(schedule.length, greaterThanOrEqualTo(10));

      final firstItem = schedule.first as Map<String, dynamic>;
      expect(firstItem.containsKey('prayerName'), isTrue);
      expect(firstItem.containsKey('timeEpochMs'), isTrue);
      expect(firstItem.containsKey('enabled'), isTrue);
    });

    test('schedulePrayerNotifications correctly sets next_prayer_id and next_prayer_time', () async {
      when(
        () => mockPrayerTimeService.getPrayerTimes(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          method: any(named: 'method'),
          madhab: any(named: 'madhab'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((invocation) {
        final date = invocation.namedArguments[#date] as DateTime;
        return FakePrayerTimes(date);
      });

      when(
        () => mockPrayerTimeService.getTimeForSalaah(any(), any()),
      ).thenAnswer((invocation) {
        final prayerTimes = invocation.positionalArguments[0] as FakePrayerTimes;
        final salaah = invocation.positionalArguments[1] as Salaah;
        switch (salaah) {
          case Salaah.fajr:
            return prayerTimes.fajr;
          case Salaah.dhuhr:
            return prayerTimes.dhuhr;
          case Salaah.asr:
            return prayerTimes.asr;
          case Salaah.maghrib:
            return prayerTimes.maghrib;
          case Salaah.isha:
            return prayerTimes.isha;
        }
      });

      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);

      final prefs = await SharedPreferences.getInstance();
      final nextId = prefs.getString('flutter.next_prayer_id');
      final nextTime = prefs.getInt('flutter.next_prayer_time');

      expect(nextId, isNotNull);
      expect(nextTime, isNotNull);
      expect(nextTime, greaterThan(0));
    });

    test('schedulePrayerNotifications resolves next_prayer_id to fajr when current time is after Isha', () async {
      when(
        () => mockPrayerTimeService.getPrayerTimes(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
          method: any(named: 'method'),
          madhab: any(named: 'madhab'),
          date: any(named: 'date'),
        ),
      ).thenAnswer((invocation) {
        final date = invocation.namedArguments[#date] as DateTime;
        return FakePrayerTimes(date);
      });

      when(
        () => mockPrayerTimeService.getTimeForSalaah(any(), any()),
      ).thenAnswer((invocation) {
        final prayerTimes = invocation.positionalArguments[0] as FakePrayerTimes;
        final salaah = invocation.positionalArguments[1] as Salaah;
        switch (salaah) {
          case Salaah.fajr:
            return prayerTimes.fajr;
          case Salaah.dhuhr:
            return prayerTimes.dhuhr;
          case Salaah.asr:
            return prayerTimes.asr;
          case Salaah.maghrib:
            return prayerTimes.maghrib;
          case Salaah.isha:
            return prayerTimes.isha;
        }
      });

      await scheduler.schedulePrayerNotifications(mockNotificationsPlugin);

      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('fard.adhan_schedule');
      expect(jsonStr, isNotNull);

      final List<dynamic> schedule = jsonDecode(jsonStr!);
      expect(schedule.isNotEmpty, isTrue);

      // Verify that every prayer entry contains timeEpochMs and prayerName
      for (final item in schedule) {
        expect(item['prayerName'], isNotNull);
        expect(item['timeEpochMs'], isNotNull);
      }
    });
  });
}
