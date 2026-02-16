# Adhan (Azan) & Prayer Reminders Feature Report

This report provides a comprehensive overview of the Adhan and Prayer Reminders implementation in the Fard application. It covers the architecture, service logic, UI integration, and current status.

## 1. Feature Overview
The Adhan feature allows users to:
- Automatically calculate prayer times based on their geolocation.
- Choose between different calculation methods (e.g., Umm Al-Qura, Muslim World League).
- Enable/Disable Adhan (full call to prayer) and Reminders (short notification before prayer) for each Salah individually.
- Download and select from various Adhan voices.
- Test the Adhan sound directly from the settings.
- Receive full-screen notifications (on supported Android versions) even when the app is closed.

## 2. Architecture & Components

### A. Domain Models
- **Salaah**: Enum representing the five daily prayers (`fajr`, `dhuhr`, `asr`, `maghrib`, `isha`).
- **SalaahSettings**: Freezed class storing per-prayer configurations (enabled status, reminder timing, selected sound).

### B. Core Services
- **PrayerTimeService**: Wraps the `adhan` dart package to calculate precise prayer times.
- **VoiceDownloadService**: Manages the downloading of Adhan MP3 files from remote URLs to local storage.
- **NotificationService**: Handles the scheduling of local notifications, creation of Android notification channels with custom sounds, and "Test Azan" functionality.

### C. State Management
- **SettingsCubit**: Manages the persistence of user preferences using `SharedPreferences` and triggers re-scheduling of notifications whenever settings change.

---

## 3. Implementation Details (Code)

### PrayerTimeService (`lib/core/services/prayer_time_service.dart`)
Calculates prayer times using coordinates and calculation parameters.
```dart
// (Code truncated for brevity in this summary, but available in source)
// Uses adhan package to get PrayerTimes object based on Latitude, Longitude, and Method.
```

### VoiceDownloadService (`lib/core/services/voice_download_service.dart`)
Handles async downloads and file management for custom Adhan sounds.
```dart
// (Code snippet)
Future<String?> downloadAzan(String voiceName) async {
  final url = azanVoices[voiceName];
  // Downloads and saves to application documents directory
  // Copies to external directory for Android system accessibility if needed
}
```

### NotificationService (`lib/core/services/notification_service.dart`)
The most critical part for reliable notifications. It uses `flutter_local_notifications`.
```dart
// Key Logic: Dynamic Channel Creation for Custom Sounds
Future<void> _createNotificationChannels({SettingsState? settings}) async {
  // On Android, notification sounds are bound to the channel. 
  // To change sounds, we create unique channels based on the sound's hash.
  final String channelId = 'azan_channel_${salaahId}_${sound.hashCode.abs()}';
  // ... create AndroidNotificationChannel with UriAndroidNotificationSound
}
```

---

## 4. Current Progress & Status

| Task | Status | Notes |
| :--- | :---: | :--- |
| **Prayer Time Calculation** | ✅ | Integrated with `adhan` package. |
| **Settings UI** | ✅ | Per-prayer settings and voice selection implemented. |
| **Voice Downloading** | ✅ | Works with multiple sources; handles redirection. |
| **Notification Scheduling** | ✅ | Schedules 7 days of prayers in advance. |
| **Android Custom Sounds** | ✅ | Implemented via dynamic channels and URI paths. |
| **Test Azan Button** | ✅ | Implemented in Settings to verify sound/volume. |
| **Test Reminder Button** | ✅ | Implemented in Settings to verify pre-prayer alerts. |
| **Permissions Handling** | ✅ | Requests POST_NOTIFICATIONS and EXACT_ALARM. |
| **Placeholder Sounds** | ❌ | `android/app/src/main/res/raw` is currently empty. |
| **iOS Integration** | ⚠️ | Basic scheduling implemented, needs further testing. |

## 5. Known Issues & Future Improvements
1. **Raw Resources**: While dynamic downloads work, adding a default `azan.mp3` in the `raw` folder would provide a better out-of-the-box experience without requiring internet.
2. **Battery Optimization**: Users on some Android devices may need to manually disable battery optimization for reliable "exact alarms". A UI prompt for this could be added.
3. **Download Progress**: The UI could show a progress bar during voice download instead of just a loading state.

## 6. Recent Fixes (Reminder & Timezone)
- **Timezone Support**: Added `flutter_timezone` to ensure notifications are scheduled according to the device's local time, not UTC.
- **Reminder Channel**: Updated prayer reminders to use `AudioAttributesUsage.alarm` and `AndroidNotificationCategory.alarm` for better reliability.
- **Full Screen Intent**: Added full-screen intent permission and capability for reminders to ensure they are seen.
- **Test Functionality**: Added a dedicated "Test Reminder" button in the Salah settings dialog.

## 7. Full Service Code for Analysis

### PrayerTimeService
```dart
import 'package:adhan/adhan.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';

class PrayerTimeService {
  PrayerTimes getPrayerTimes({
    required double latitude,
    required double longitude,
    required String method,
    required String madhab,
    DateTime? date,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = _getParams(method);
    params.madhab = madhab == 'hanafi' ? Madhab.hanafi : Madhab.shafi;
    
    return PrayerTimes(
      coordinates,
      DateComponents.from(date ?? DateTime.now()),
      params,
    );
  }

  CalculationParameters _getParams(String method) {
    switch (method) {
      case 'muslim_league':
        return CalculationMethod.muslim_world_league.getParameters();
      case 'egyptian':
        return CalculationMethod.egyptian.getParameters();
      case 'karachi':
        return CalculationMethod.karachi.getParameters();
      case 'umm_al_qura':
        return CalculationMethod.umm_al_qura.getParameters();
      case 'dubai':
        return CalculationMethod.dubai.getParameters();
      case 'moonsighting_committee':
        return CalculationMethod.moon_sighting_committee.getParameters();
      case 'north_america':
        return CalculationMethod.north_america.getParameters();
      case 'kuwait':
        return CalculationMethod.kuwait.getParameters();
      case 'qatar':
        return CalculationMethod.qatar.getParameters();
      case 'singapore':
        return CalculationMethod.singapore.getParameters();
      case 'tehran':
        return CalculationMethod.tehran.getParameters();
      case 'turkey':
        return CalculationMethod.turkey.getParameters();
      default:
        return CalculationMethod.muslim_world_league.getParameters();
    }
  }

  DateTime? getTimeForSalaah(PrayerTimes prayerTimes, Salaah salaah) {
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
  }
}
```

### VoiceDownloadService
```dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class VoiceDownloadService {
  static const Map<String, String> azanVoices = {
    'Makkah - Abdul Basit (Aladhan)': 'https://download.aladhan.com/adhan/Abdul-Basit.mp3',
    'Mishary Rashid Alafasy (Aladhan)': 'https://download.aladhan.com/adhan/Mishary%20Rashid%20Alafasy.mp3',
    'Makkah - Fajr (IslamCan)': 'http://www.islamcan.com/audio/adhan/azan16.mp3',
    'Madinah - Ali Ahmed Mala (IslamCan)': 'http://www.islamcan.com/audio/adhan/azan20.mp3',
    'Egypt - Al-Minshawi (IslamCan)': 'http://www.islamcan.com/audio/adhan/azan1.mp3',
    'Al-Aqsa (IslamCan)': 'http://www.islamcan.com/audio/adhan/azan2.mp3',
    'Turkey (IslamCan)': 'http://www.islamcan.com/audio/adhan/azan3.mp3',
    'Dubai - Mishary Rashid (Aladhan)': 'https://download.aladhan.com/adhan/Mishary%20Rashid%20Alafasy%20Dubai%20One%20TV.mp3',
  };

  String _getFileName(String voiceName) {
    return '${voiceName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}_azan.mp3';
  }

  Future<String?> downloadAzan(String voiceName) async {
    final url = azanVoices[voiceName];
    if (url == null) return null;

    try {
      // Use a client that follows redirects
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 45));
      
      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final fileName = _getFileName(voiceName);
        final file = File('${directory.path}/$fileName');
        
        // Ensure directory exists
        if (!(await directory.exists())) {
          await directory.create(recursive: true);
        }

        await file.writeAsBytes(response.bodyBytes);
        
        if (response.bodyBytes.length < 1000) {
          debugPrint('Warning: Downloaded file for $voiceName is very small (${response.bodyBytes.length} bytes)');
        }
        
        debugPrint('Successfully downloaded $voiceName to ${file.path}');
        return file.path;
      } else {
        debugPrint('Failed to download azan: Server returned status ${response.statusCode} for $url');
      }
    } catch (e) {
      debugPrint('Exception during azan download ($voiceName) from $url: $e');
    }
    return null;
  }

  Future<bool> isDownloaded(String voiceName) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _getFileName(voiceName);
    return File('${directory.path}/$fileName').exists();
  }
  
  Future<String> getLocalPath(String voiceName) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _getFileName(voiceName);
    return '${directory.path}/$fileName';
  }

  Future<String?> getAccessiblePath(String voiceName) async {
    final fileName = _getFileName(voiceName);
    final localPath = await getLocalPath(voiceName);
    final file = File(localPath);
    if (!(await file.exists())) return null;

    try {
      // For Android, we often need the file in a directory that the system notification service can access
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        final dir = Directory('${externalDir.path}/azan_sounds');
        if (!(await dir.exists())) await dir.create(recursive: true);
        
        final accessibleFile = File('${dir.path}/$fileName');
        if (!(await accessibleFile.exists())) {
          await file.copy(accessibleFile.path);
        }
        return accessibleFile.path;
      }
      return localPath;
    } catch (e) {
      debugPrint('Error getting accessible path: $e');
      return localPath;
    }
  }
}
```

### NotificationService
```dart
import 'dart:math';
import 'dart:io';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../../features/settings/presentation/blocs/settings_state.dart';
import '../../features/azkar/domain/azkar_item.dart';
import '../../features/azkar/presentation/screens/azkar_list_screen.dart';
import '../di/injection.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;

  NotificationService([FlutterLocalNotificationsPlugin? notificationsPlugin])
      : _notificationsPlugin = notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const WindowsInitializationSettings initializationSettingsWindows =
        WindowsInitializationSettings(
      appName: 'Fard',
      appUserModelId: 'com.nagar.fard',
      guid: 'f0c0f0f0-0f0f-0f0f-0f0f-0f0f0f0f0f0f',
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      windows: initializationSettingsWindows,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final navigatorKey = getIt<GlobalKey<NavigatorState>>();
          if (navigatorKey.currentState != null) {
            if (details.payload!.startsWith('category:')) {
              final category = details.payload!.replaceFirst('category:', '');
              navigatorKey.currentState!.push(
                MaterialPageRoute(
                  builder: (_) => AzkarListScreen(category: category),
                ),
              );
            }
          }
        }
      },
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    await _createNotificationChannels();
  }

  String _getSoundUri(String soundPath) {
    if (soundPath == 'default') return 'default';
    final bool isLocalFile = soundPath.startsWith('/') || (soundPath.length > 1 && soundPath[1] == ':');
    if (!isLocalFile) return soundPath;

    try {
      final file = File(soundPath);
      return Uri.file(file.absolute.path).toString();
    } catch (e) {
      return 'file://$soundPath';
    }
  }

  Future<void> _createNotificationChannels({SettingsState? settings}) async {
    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    if (settings != null) {
      for (final salaahSetting in settings.salaahSettings) {
        final String salaahId = salaahSetting.salaah.name;
        final String sound = salaahSetting.azanSound ?? 'default';
        final String channelId = 'azan_channel_${salaahId}_${sound.hashCode.abs()}';
        
        final String soundUri = _getSoundUri(sound);
        final bool isLocalFile = soundUri.startsWith('file:');

        final azanChannel = AndroidNotificationChannel(
          channelId,
          'Azan ${salaahId.toUpperCase()}',
          description: 'Channel for Azan calls for ${salaahId.toUpperCase()}',
          importance: Importance.max,
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          sound: sound == 'default' 
            ? null 
            : (isLocalFile ? UriAndroidNotificationSound(soundUri) : RawResourceAndroidNotificationSound(sound.split('.').first)),
        );

        await androidPlugin.createNotificationChannel(azanChannel);
      }
    }
    // ... other channels (prayer_reminders, azkar_reminders)
  }

  Future<void> schedulePrayerNotifications({
    required SettingsState settings,
  }) async {
    await _createNotificationChannels(settings: settings);
    if (settings.latitude == null || settings.longitude == null) return;

    // ... Cancellation logic ...

    final prayerTimeService = getIt<PrayerTimeService>();
    final now = DateTime.now();

    for (int day = 0; day < 7; day++) {
      final date = now.add(Duration(days: day));
      final prayerTimes = prayerTimeService.getPrayerTimes(
        latitude: settings.latitude!,
        longitude: settings.longitude!,
        method: settings.calculationMethod,
        madhab: settings.madhab,
        date: date,
      );

      for (final salaahSetting in settings.salaahSettings) {
        final salaahTime = prayerTimeService.getTimeForSalaah(prayerTimes, salaahSetting.salaah);
        if (salaahTime == null) continue;

        final tzSalaahTime = tz.TZDateTime.from(salaahTime, tz.local);
        if (tzSalaahTime.isBefore(tz.TZDateTime.now(tz.local))) continue;

        final dayOffset = day * 5 + salaahSetting.salaah.index;

        if (salaahSetting.isAzanEnabled) {
          await _scheduleAzan(
            id: 200 + dayOffset,
            salaah: salaahSetting.salaah,
            scheduledDate: tzSalaahTime,
            sound: salaahSetting.azanSound,
          );
        }
        // ... Schedule Reminders ...
      }
    }
  }

  Future<void> _scheduleAzan({
    required int id,
    required Salaah salaah,
    required tz.TZDateTime scheduledDate,
    String? sound,
  }) async {
    final String soundPath = sound ?? 'default';
    final String channelId = 'azan_channel_${salaah.name}_${soundPath.hashCode.abs()}';
    final String soundUri = _getSoundUri(soundPath);
    final bool isLocalFile = soundUri.startsWith('file:');
    
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      'Azan ${salaah.name.toUpperCase()}',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      playSound: true,
      sound: soundPath == 'default' 
        ? null 
        : (isLocalFile ? UriAndroidNotificationSound(soundUri) : RawResourceAndroidNotificationSound(soundPath.split('.').first)),
    );

    await _notificationsPlugin.zonedSchedule(
      id: id,
      title: 'حان وقت صلاة ${_getSalaahName(salaah)}',
      body: 'أقم الصلاة يرحمك الله',
      scheduledDate: scheduledDate,
      notificationDetails: NotificationDetails(android: androidPlatformChannelSpecifics),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
```
