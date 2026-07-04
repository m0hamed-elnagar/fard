import 'package:fard/core/utils/app_identifiers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppIdentifiers tests', () {
    test('Release build identification and base values', () async {
      // Mock release package name
      PackageInfo.setMockInitialValues(
        appName: 'Fard',
        packageName: 'com.khwarizmi.fard',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: 'sig',
      );

      await AppIdentifiers.initialize();

      expect(AppIdentifiers.packageName, equals('com.khwarizmi.fard'));
      expect(AppIdentifiers.isReleaseBuild, isTrue);

      // Verify channel names and paths match release values
      expect(
        AppIdentifiers.notificationGroupKey,
        equals('com.khwarizmi.fard.NOTIFICATIONS'),
      );
      expect(
        AppIdentifiers.windowsAppUserModelId,
        equals('com.khwarizmi.fard'),
      );
      expect(
        AppIdentifiers.audioNotificationChannelId,
        equals('com.khwarizmi.fard.channel.audio'),
      );
      expect(
        AppIdentifiers.instantUpdatesChannelName,
        equals('com.khwarizmi.fard/instant_updates'),
      );
      expect(
        AppIdentifiers.widgetThemeChannelName,
        equals('com.khwarizmi.fard/widget_theme'),
      );
      expect(
        AppIdentifiers.adhanChannelName,
        equals('com.khwarizmi.fard/adhan'),
      );
      expect(
        AppIdentifiers.prayerSchedulerTaskName,
        equals('com.khwarizmi.fard.prayer_scheduler_task'),
      );
      expect(
        AppIdentifiers.widgetRefreshTaskName,
        equals('com.khwarizmi.fard.widget_refresh_task'),
      );
    });

    test('Debug build identification and package-specific suffixes', () async {
      // Mock debug package name
      PackageInfo.setMockInitialValues(
        appName: 'Fard (Debug)',
        packageName: 'com.khwarizmi.fard.debug',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: 'sig',
      );

      await AppIdentifiers.initialize();

      expect(AppIdentifiers.packageName, equals('com.khwarizmi.fard.debug'));
      expect(AppIdentifiers.isReleaseBuild, isFalse);

      // Verify channels and tasks are customized for debug
      expect(
        AppIdentifiers.notificationGroupKey,
        equals('com.khwarizmi.fard.debug.NOTIFICATIONS'),
      );
      expect(
        AppIdentifiers.windowsAppUserModelId,
        equals('com.khwarizmi.fard.debug'),
      );
      expect(
        AppIdentifiers.audioNotificationChannelId,
        equals('com.khwarizmi.fard.debug.channel.audio'),
      );
      expect(
        AppIdentifiers.instantUpdatesChannelName,
        equals('com.khwarizmi.fard.debug/instant_updates'),
      );
      expect(
        AppIdentifiers.widgetThemeChannelName,
        equals('com.khwarizmi.fard.debug/widget_theme'),
      );
      expect(
        AppIdentifiers.adhanChannelName,
        equals('com.khwarizmi.fard.debug/adhan'),
      );
      expect(
        AppIdentifiers.prayerSchedulerTaskName,
        equals('com.khwarizmi.fard.debug.prayer_scheduler_task'),
      );
      expect(
        AppIdentifiers.widgetRefreshTaskName,
        equals('com.khwarizmi.fard.debug.widget_refresh_task'),
      );
    });
  });
}
