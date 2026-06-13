import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// A thin wrapper around [FirebaseAnalytics] that provides strongly-typed
/// event logging methods for meaningful in-app actions.
///
/// All methods are no-ops if Analytics has not been initialised or if the
/// current platform does not support it. This keeps the rest of the codebase
/// completely decoupled from Firebase.
///
/// Registered manually in [configureDependencies] as a lazy singleton because
/// it depends on the Firebase SDK which is not part of the injectable graph.
class AnalyticsService {
  FirebaseAnalytics? _analytics;

  /// Call once after [Firebase.initializeApp] succeeds.
  /// Disables data collection in debug mode to keep the Firebase Console clean.
  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      // Disable collection in debug builds to avoid polluting production data.
      await _analytics!.setAnalyticsCollectionEnabled(!kDebugMode);
      debugPrint('[Analytics] Initialized. Collection enabled: ${!kDebugMode}');
    } catch (e) {
      debugPrint('[Analytics] Initialization warning: $e');
      _analytics = null;
    }
  }

  // ---------------------------------------------------------------------------
  // Prayer Tracking Events
  // ---------------------------------------------------------------------------

  /// Logged when a user marks a prayer as prayed (Fard or Qada).
  Future<void> logPrayerMarked({
    required String prayerName,
    required bool isQada,
  }) async {
    await _log('prayer_marked', {
      'prayer_name': prayerName,
      'is_qada': isQada.toString(),
    });
  }

  /// Logged when a Qada prayer is decremented/completed.
  Future<void> logQadaCompleted({required String prayerName}) async {
    await _log('qada_completed', {'prayer_name': prayerName});
  }

  // ---------------------------------------------------------------------------
  // Quran Events
  // ---------------------------------------------------------------------------

  /// Logged when a user opens the Quran reader.
  Future<void> logQuranOpened() async {
    await _log('quran_opened');
  }

  /// Logged when a user starts audio playback for a surah.
  Future<void> logQuranAudioStarted({required String surahName}) async {
    await _log('quran_audio_started', {'surah_name': surahName});
  }

  // ---------------------------------------------------------------------------
  // Azkar Events
  // ---------------------------------------------------------------------------

  /// Logged when a user completes an Azkar session.
  Future<void> logAzkarCompleted({required String categoryName}) async {
    await _log('azkar_completed', {'category_name': categoryName});
  }

  // ---------------------------------------------------------------------------
  // Settings Events
  // ---------------------------------------------------------------------------

  /// Logged when a user changes the app theme.
  Future<void> logThemeChanged({required String themeId}) async {
    await _log('theme_changed', {'theme_id': themeId});
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  Future<void> _log(
    String eventName, [
    Map<String, Object>? parameters,
  ]) async {
    if (_analytics == null) return;
    try {
      await _analytics!.logEvent(name: eventName, parameters: parameters);
    } catch (e) {
      debugPrint('[Analytics] Failed to log "$eventName": $e');
    }
  }
}
