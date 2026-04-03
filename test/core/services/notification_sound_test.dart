import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/notification/channel_manager.dart';
import 'package:fard/core/services/notification/prayer_scheduler.dart';
import 'package:fard/core/services/notification/sound_manager.dart';
import 'package:fard/core/services/widget_update_service.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;
  late MockSoundManager mockSoundManager;
  late MockChannelManager mockChannelManager;
  late MockPrayerNotificationScheduler mockPrayerScheduler;
  late MockWidgetUpdateService mockWidgetUpdateService;

  setUpAll(() {
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(const AndroidNotificationChannel('id', 'name'));
    registerFallbackValue(Salaah.fajr);
    registerFallbackValue(MockFlutterLocalNotificationsPlugin());
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
      () => mockAndroidPlugin.createNotificationChannel(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockAndroidPlugin.getNotificationChannels(),
    ).thenAnswer((_) async => []);
    when(
      () => mockNotificationsPlugin.show(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: any(named: 'notificationDetails'),
      ),
    ).thenAnswer((_) async {});

    when(
      () => mockChannelManager.ensureChannelExists(
        any(),
        channelId: any(named: 'channelId'),
        salaahId: any(named: 'salaahId'),
        sound: any(named: 'sound'),
        isTest: any(named: 'isTest'),
      ),
    ).thenAnswer((_) async {});

    notificationService = NotificationService(
      mockSoundManager,
      mockChannelManager,
      mockPrayerScheduler,
      mockNotificationsPlugin,
      mockWidgetUpdateService,
    );
  });

  group('NotificationService Sound Testing', () {
    test(
      'testAzan uses UriAndroidNotificationSound when SoundManager returns URI',
      () async {
        const customPath = '/path/to/azan.mp3';
        const expectedUri = 'file:///path/to/azan.mp3';

        when(
          () => mockSoundManager.getSoundUriForChannel(customPath),
        ).thenAnswer((_) async => expectedUri);

        await notificationService.testAzan(Salaah.fajr, customPath);

        verify(
          () => mockSoundManager.getSoundUriForChannel(customPath),
        ).called(1);

        final capturedDetails =
            verify(
                  () => mockNotificationsPlugin.show(
                    id: 999,
                    title: any(named: 'title'),
                    body: any(named: 'body'),
                    notificationDetails: captureAny(
                      named: 'notificationDetails',
                    ),
                  ),
                ).captured.first
                as NotificationDetails;

        final androidDetails = capturedDetails.android;
        expect(androidDetails, isNotNull);
        expect(androidDetails!.sound, isA<UriAndroidNotificationSound>());

        final sound = androidDetails.sound as UriAndroidNotificationSound;
        expect(sound.sound, equals(expectedUri));
      },
    );

    test('testAzan handles default', () async {
      when(
        () => mockSoundManager.getSoundUriForChannel('default'),
      ).thenAnswer((_) async => null);

      await notificationService.testAzan(Salaah.fajr, 'default');

      final capturedDetails =
          verify(
                () => mockNotificationsPlugin.show(
                  id: 999,
                  title: any(named: 'title'),
                  body: any(named: 'body'),
                  notificationDetails: captureAny(named: 'notificationDetails'),
                ),
              ).captured.first
              as NotificationDetails;

      // Default sound logic in testAzan might result in no sound object or specific default
      // In current impl: if soundPath == 'default', notificationSound is null.
      expect(capturedDetails.android?.sound, isNull);
    });
  });
}
