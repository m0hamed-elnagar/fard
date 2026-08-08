import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fard/core/utils/app_identifiers.dart';

@lazySingleton
class InAppReviewService {
  static const String _hasBeenPromptedKey = 'has_been_prompted_for_review';
  final SharedPreferences _prefs;

  InAppReviewService(this._prefs);

  /// Automatic review check triggered at high-satisfaction moments (e.g. 7-day streak).
  ///
  /// Criteria required:
  /// 1. Android or iOS platform (not desktop).
  /// 2. User has never been prompted before ([_hasBeenPromptedKey] is false).
  /// 3. App installed for at least 7 days (via OS-reported installTime).
  /// 4. User has achieved a streak of at least 7 days.
  Future<void> checkAndPromptReviewIfEligible({
    required int currentStreak,
    @visibleForTesting DateTime? customInstallTime,
    @visibleForTesting InAppReview? customInAppReview,
    @visibleForTesting bool isTestEnvironment = false,
  }) async {
    if (!isTestEnvironment && (kIsWeb || (!Platform.isAndroid && !Platform.isIOS))) return;

    final hasPrompted = _prefs.getBool(_hasBeenPromptedKey) ?? false;
    if (hasPrompted) return;

    if (currentStreak < 7) return;

    try {
      DateTime? installTime = customInstallTime;
      if (installTime == null) {
        final packageInfo = await PackageInfo.fromPlatform();
        installTime = packageInfo.installTime;
      }

      if (installTime != null) {
        final daysInstalled = DateTime.now().difference(installTime).inDays;
        if (daysInstalled < 7) return;
      }

      // Set once-ever flag immediately before triggering prompt to prevent multiple prompts
      await _prefs.setBool(_hasBeenPromptedKey, true);

      final inAppReview = customInAppReview ?? InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
      }
    } catch (e) {
      debugPrint('[InAppReviewService] Error checking review eligibility: $e');
    }
  }

  /// User-initiated manual review action from Settings screen.
  /// Bypasses requestReview() and goes directly to the release store page.
  Future<void> openStoreListingManually() async {
    try {
      final String releasePackageName = AppIdentifiers.packageName
          .replaceAll('.debug', '')
          .replaceAll('.benchmark', '');

      final Uri marketUri = Uri.parse('market://details?id=$releasePackageName');
      final Uri webUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=$releasePackageName',
      );

      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } else {
        final inAppReview = InAppReview.instance;
        await inAppReview.openStoreListing();
      }
    } catch (e) {
      debugPrint('[InAppReviewService] Error opening store listing: $e');
    }
  }
}
