import 'package:fard/core/services/notification/channel_manager.dart';
import 'package:fard/core/services/notification/sound_manager.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:fard/features/settings/domain/salaah_settings.dart';
import 'package:fard/features/settings/presentation/blocs/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class MockSoundManager extends Mock implements SoundManager {}

void main() {
  late ChannelManager channelManager;
  late MockSoundManager mockSoundManager;
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;

  setUpAll(() {
    registerFallbackValue(const AndroidNotificationChannel('id', 'name'));
  });

  setUp(() {
    mockSoundManager = MockSoundManager();
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();

    channelManager = ChannelManager(mockSoundManager);

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
  });

  group('ChannelManager', () {
    test('getChannelId returns correct IDs', () {
      expect(
        channelManager.getChannelId('fajr', 'default'),
        'azan_channel_fajr',
      );
      expect(
        channelManager.getChannelId('fajr', 'path/to/sound.mp3'),
        'azan_fajr_sound',
      );
    });

    test('ensureChannelExists creates channel if missing', () async {
      when(
        () => mockSoundManager.getSoundUriForChannel('sound.mp3'),
      ).thenAnswer((_) async => 'file:///sound.mp3');

      await channelManager.ensureChannelExists(
        mockNotificationsPlugin,
        channelId: 'test_channel',
        salaahId: 'fajr',
        sound: 'sound.mp3',
      );

      verify(
        () => mockAndroidPlugin.createNotificationChannel(
          any(
            that: isA<AndroidNotificationChannel>()
                .having((c) => c.id, 'id', 'test_channel')
                .having((c) => c.name, 'name', 'Azan FAJR')
                .having(
                  (c) => c.sound,
                  'sound',
                  isA<UriAndroidNotificationSound>(),
                ),
          ),
        ),
      ).called(1);
    });

    test('createNotificationChannels creates channels for settings', () async {
      final settings = SettingsState(
        locale: const Locale('en'),
        salaahSettings: [
          SalaahSettings(salaah: Salaah.fajr, azanSound: 'fajr.mp3'),
        ],
      );

      when(
        () => mockSoundManager.getSoundUriForChannel('fajr.mp3'),
      ).thenAnswer((_) async => null); // Resource sound

      await channelManager.createNotificationChannels(
        mockNotificationsPlugin,
        settings: settings,
      );

      // 1 for Fajr, 1 for Reminder, 1 for Azkar = 3
      verify(
        () => mockAndroidPlugin.createNotificationChannel(any()),
      ).called(3);
    });
  });
}
