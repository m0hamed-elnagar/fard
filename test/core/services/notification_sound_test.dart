import 'dart:io';
import 'package:fard/core/services/notification_service.dart';
import 'package:fard/core/services/prayer_time_service.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:fard/features/prayer_tracking/domain/salaah.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';

class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}
class MockAndroidFlutterLocalNotificationsPlugin extends Mock implements AndroidFlutterLocalNotificationsPlugin {}
class MockPrayerTimeService extends Mock implements PrayerTimeService {}
class MockVoiceDownloadService extends Mock implements VoiceDownloadService {}

void main() {
  late NotificationService notificationService;
  late MockFlutterLocalNotificationsPlugin mockNotificationsPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin mockAndroidPlugin;
  late MockVoiceDownloadService mockVoiceDownloadService;

  setUpAll(() {
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(const AndroidNotificationChannel('id', 'name'));
    registerFallbackValue(Salaah.fajr);
  });

  setUp(() async {
    mockNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockAndroidPlugin = MockAndroidFlutterLocalNotificationsPlugin();
    mockVoiceDownloadService = MockVoiceDownloadService();
    
    final getIt = GetIt.instance;
    await getIt.reset();
    getIt.registerSingleton<PrayerTimeService>(MockPrayerTimeService());
    getIt.registerSingleton<VoiceDownloadService>(mockVoiceDownloadService);
    getIt.registerSingleton<GlobalKey<NavigatorState>>(GlobalKey<NavigatorState>());

    notificationService = NotificationService(mockNotificationsPlugin);

    when(() => mockNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>())
        .thenReturn(mockAndroidPlugin);
    when(() => mockAndroidPlugin.canScheduleExactNotifications()).thenAnswer((_) async => true);
    when(() => mockAndroidPlugin.createNotificationChannel(any())).thenAnswer((_) async {});
    when(() => mockAndroidPlugin.getNotificationChannels()).thenAnswer((_) async => []);
    when(() => mockNotificationsPlugin.show(
      id: any(named: 'id'),
      title: any(named: 'title'),
      body: any(named: 'body'),
      notificationDetails: any(named: 'notificationDetails'),
    )).thenAnswer((_) async {});
  });

  group('NotificationService Sound Testing', () {
    test('testAzan uses UriAndroidNotificationSound for local files', () async {
      // Create a real temporary file to trigger the isLocalFile and exists logic
      final tempDir = await Directory.systemTemp.createTemp();
      final tempFile = File('${tempDir.path}/azan.mp3');
      await tempFile.writeAsBytes([0, 1, 2, 3]);
      
      final String customPath = tempFile.path;
      
      await notificationService.testAzan(Salaah.fajr, customPath);

      final capturedDetails = verify(() => mockNotificationsPlugin.show(
        id: 999,
        title: any(named: 'title'),
        body: captureAny(named: 'body'),
        notificationDetails: captureAny(named: 'notificationDetails'),
      )).captured;
      
      final body = capturedDetails[0] as String;
      final capturedNotificationDetails = capturedDetails[1] as NotificationDetails;

      expect(body, contains('حجم الملف: 0.0 KB')); // 4 bytes is 0.0 KB

      final androidDetails = capturedNotificationDetails.android;
      expect(androidDetails, isNotNull);
      expect(androidDetails!.sound, isA<UriAndroidNotificationSound>());
      
      final sound = androidDetails.sound as UriAndroidNotificationSound;
      expect(sound.sound, contains('azan.mp3'));
      
      await tempDir.delete(recursive: true);
    });

    test('testAzan handles paths with spaces correctly', () async {
      final tempDir = await Directory.systemTemp.createTemp();
      final tempFile = File('${tempDir.path}/azan voice.mp3');
      await tempFile.writeAsBytes([0, 1, 2, 3]);
      
      final String pathWithSpaces = tempFile.path;
      
      await notificationService.testAzan(Salaah.fajr, pathWithSpaces);

      final capturedDetails = verify(() => mockNotificationsPlugin.show(
        id: 999,
        title: any(named: 'title'),
        body: any(named: 'body'),
        notificationDetails: captureAny(named: 'notificationDetails'),
      )).captured.first as NotificationDetails;

      final androidDetails = capturedDetails.android;
      final sound = androidDetails!.sound as UriAndroidNotificationSound;
      
      expect(sound.sound, contains('azan%20voice.mp3'));
      print('Actual encoded sound URI: ${sound.sound}');
      
      await tempDir.delete(recursive: true);
    });
  });
}
