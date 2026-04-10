import 'package:fard/features/settings/domain/repositories/settings_repository.dart';
import 'package:fard/core/utils/app_identifiers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'sound_manager.dart';

@singleton
class ChannelManager {
  final SoundManager _soundManager;

  ChannelManager(this._soundManager);

  static const String reminderChannelId = 'prayer_reminders_v1';

  String getChannelId(String salaahId, String sound) {
    if (sound == 'default') return 'azan_channel_$salaahId';

    // Use the filename as a key to make it deterministic but unique to the sound
    final String fileName = sound
        .split(RegExp(r'[/\\]'))
        .last
        .replaceAll('.mp3', '');
    return 'azan_${salaahId}_$fileName';
  }

  Future<void> createNotificationChannels(
    FlutterLocalNotificationsPlugin notificationsPlugin, {
    SettingsRepository? settings,
  }) async {
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;

    // Salah specific channels for Azan
    if (settings != null) {
      for (final salaahSetting in settings.salaahSettings) {
        final String salaahId = salaahSetting.salaah.name;
        final String sound = salaahSetting.azanSound ?? 'default';
        final String channelId = getChannelId(salaahId, sound);

        await ensureChannelExists(
          notificationsPlugin,
          channelId: channelId,
          salaahId: salaahId,
          sound: sound,
        );
      }
    }

    const reminderChannel = AndroidNotificationChannel(
      reminderChannelId,
      'Prayer Reminders',
      description: 'Notifications before prayer time',
      importance: Importance.max,
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
    );

    await androidPlugin.createNotificationChannel(reminderChannel);

    final azkarChannel = AndroidNotificationChannel(
      AppIdentifiers.azkarChannelId,
      'Azkar Reminders',
      description: 'Daily Azkar notifications',
      importance: Importance.max,
      playSound: true,
    );

    await androidPlugin.createNotificationChannel(azkarChannel);
  }

  Future<void> ensureChannelExists(
    FlutterLocalNotificationsPlugin notificationsPlugin, {
    required String channelId,
    required String salaahId,
    required String sound,
    bool isTest = false,
  }) async {
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin == null) return;

    final channels = await androidPlugin.getNotificationChannels();

    final bool exists = channels?.any((c) => c.id == channelId) ?? false;
    if (exists && !isTest) return;

    // Create new channel with proper sound
    final String? soundUri = await _soundManager.getSoundUriForChannel(sound);

    final androidChannel = AndroidNotificationChannel(
      channelId,
      isTest ? 'Azan Test' : 'Azan ${salaahId.toUpperCase()}',
      description: isTest
          ? 'Temporary channel for Azan testing'
          : 'Azan notifications for ${salaahId.toUpperCase()}',
      importance: Importance.max,
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      sound: sound == 'default'
          ? null
          : (soundUri != null
                ? UriAndroidNotificationSound(soundUri)
                : RawResourceAndroidNotificationSound(sound.split('.').first)),
    );

    await androidPlugin.createNotificationChannel(androidChannel);
  }
}
