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
    // We MUST include the sound name/key in the channel ID.
    // Android notification channels are IMMUTABLE once created. 
    // If we want to change the sound, we must create a brand new channel ID.
    
    if (sound == 'default') return 'azan_channel_$salaahId';

    // Use a clean identifier for the sound
    String identifier = sound.split(RegExp(r'[/\\]')).last.replaceAll('.mp3', '');
    
    // If it's a key with special characters (like Arabic), 
    // use a combination of a truncated clean version and its hash to keep it unique but valid for Android
    final String cleanPart = identifier
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')
        .split('_')
        .where((s) => s.isNotEmpty)
        .take(2)
        .join('_');
        
    final String hashPart = sound.hashCode.abs().toString().substring(0, 4);
    final String soundSuffix = '${cleanPart}_$hashPart';
        
    return 'azan_${salaahId}_$soundSuffix';
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
    AndroidNotificationSound? notificationSound;

    if (sound != 'default') {
      if (soundUri != null) {
        notificationSound = UriAndroidNotificationSound(soundUri);
      } else {
        // Fallback to resource if URI failed, but only if it's not a path
        if (!sound.contains('/') && !sound.contains('\\')) {
          notificationSound = RawResourceAndroidNotificationSound(
            sound.split('.').first,
          );
        }
      }
    }

    final androidChannel = AndroidNotificationChannel(
      channelId,
      isTest ? 'Azan Test' : 'Azan ${salaahId.toUpperCase()}',
      description: isTest
          ? 'Temporary channel for Azan testing'
          : 'Azan notifications for ${salaahId.toUpperCase()}',
      importance: Importance.max,
      playSound: true,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      sound: notificationSound,
    );

    await androidPlugin.createNotificationChannel(androidChannel);
  }
}
