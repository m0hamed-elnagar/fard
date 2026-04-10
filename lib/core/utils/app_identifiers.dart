import 'package:package_info_plus/package_info_plus.dart';

/// Generates app-specific identifiers based on the current package name.
/// This ensures debug and release builds use separate notification channels,
/// file providers, and other platform-specific identifiers.
///
/// **Backward Compatibility Note:**
/// Release builds continue using the original `com.nagar.fard` identifiers
/// to maintain compatibility with existing user installations.
/// Only debug/benchmark builds get dynamic identifiers.
class AppIdentifiers {
  static String? _packageName;
  static bool? _isReleaseBuild;

  /// Initialize with the current package name.
  /// Call this once during app startup.
  static Future<void> initialize() async {
    final packageInfo = await PackageInfo.fromPlatform();
    _packageName = packageInfo.packageName;
    // Release build uses com.qada.fard package name
    _isReleaseBuild = _packageName == 'com.qada.fard';
  }

  /// Get the current package name.
  /// Falls back to release package name if not initialized.
  static String get packageName {
    return _packageName ?? 'com.qada.fard';
  }

  /// Check if this is a release build.
  static bool get isReleaseBuild => _isReleaseBuild ?? false;

  /// Base identifier for notifications.
  /// Release builds use original identifiers for backward compatibility.
  /// Debug/benchmark builds use package-specific identifiers.
  static String get _notificationBase =>
      isReleaseBuild ? 'com.nagar.fard' : packageName;

  /// Notification group key for Android (package-specific).
  static String get notificationGroupKey => '$_notificationBase.NOTIFICATIONS';

  /// Windows AppUserModelId (package-specific).
  static String get windowsAppUserModelId => _notificationBase;

  /// File provider authority for Android (package-specific).
  static String get fileProviderAuthority => '$packageName.fileprovider';

  /// JustAudio background notification channel ID (package-specific).
  static String get audioNotificationChannelId =>
      '$_notificationBase.channel.audio';

  /// MethodChannel name for instant updates (package-specific).
  static String get instantUpdatesChannelName =>
      '$_notificationBase/instant_updates';

  /// WorkManager task names (package-specific).
  static String get prayerSchedulerTaskName =>
      '$_notificationBase.prayer_scheduler_task';

  static String get widgetRefreshTaskName =>
      '$_notificationBase.widget_refresh_task';

  /// Download notification channel ID (package-specific).
  static String get downloadChannelId => '$_notificationBase.download';

  /// Azkar reminders channel ID (package-specific).
  static String get azkarChannelId => '$_notificationBase.azkar_reminders';
}
