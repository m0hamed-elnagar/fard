import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:injectable/injectable.dart';
import 'package:fard/core/l10n/app_localizations.dart';

@lazySingleton
class InAppUpdateService {
  StreamSubscription<InstallStatus>? _updateSubscription;

  /// Silently check for flexible updates on Android startup.
  /// Does not show modal dialogs. Listens for InstallStatus.downloaded
  /// to show a SnackBar offering restart & install.
  Future<void> checkForUpdateSilently(
    BuildContext context, {
    @visibleForTesting Future<AppUpdateInfo> Function()? customUpdateInfoFetcher,
    @visibleForTesting Stream<InstallStatus>? customInstallStream,
    @visibleForTesting bool isTestEnvironment = false,
  }) async {
    if (!isTestEnvironment && !Platform.isAndroid) return;

    try {
      final info = customUpdateInfoFetcher != null
          ? await customUpdateInfoFetcher()
          : await InAppUpdate.checkForUpdate();
      if (!context.mounted) return;

      if (info.updateAvailability == UpdateAvailability.updateAvailable &&
          info.flexibleUpdateAllowed) {
        _listenForDownload(context, customStream: customInstallStream);
        if (!isTestEnvironment) {
          await InAppUpdate.startFlexibleUpdate();
        }
      } else if (info.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        _listenForDownload(context, customStream: customInstallStream);
      }
    } catch (e) {
      debugPrint('[InAppUpdateService] Silent update check error: $e');
    }
  }

  /// Handles AppLifecycleState.resumed checks to prevent update stalls.
  /// Strictly gated on developerTriggeredUpdateInProgress.
  Future<bool> onResumeCheck(
    BuildContext context, {
    @visibleForTesting Future<AppUpdateInfo> Function()? customUpdateInfoFetcher,
    @visibleForTesting Stream<InstallStatus>? customInstallStream,
    @visibleForTesting bool isTestEnvironment = false,
  }) async {
    if (!isTestEnvironment && !Platform.isAndroid) return false;

    try {
      final info = customUpdateInfoFetcher != null
          ? await customUpdateInfoFetcher()
          : await InAppUpdate.checkForUpdate();
      if (!context.mounted) return false;

      if (info.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        _listenForDownload(context, customStream: customInstallStream);
        return true;
      }
    } catch (e) {
      debugPrint('[InAppUpdateService] onResume update check error: $e');
    }
    return false;
  }

  /// User-initiated manual check from Settings screen.
  Future<void> checkForUpdateManually(
    BuildContext context, {
    @visibleForTesting Future<AppUpdateInfo> Function()? customUpdateInfoFetcher,
    @visibleForTesting Stream<InstallStatus>? customInstallStream,
    @visibleForTesting bool isTestEnvironment = false,
  }) async {
    if (!isTestEnvironment && !Platform.isAndroid) {
      _showSnackBar(
        context,
        AppLocalizations.of(context)?.noUpdatesAvailable ??
            'You are using the latest version of Fard.',
      );
      return;
    }

    try {
      final info = customUpdateInfoFetcher != null
          ? await customUpdateInfoFetcher()
          : await InAppUpdate.checkForUpdate();
      if (!context.mounted) return;

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.flexibleUpdateAllowed) {
          _listenForDownload(context, customStream: customInstallStream);
          if (!isTestEnvironment) {
            await InAppUpdate.startFlexibleUpdate();
          }
        } else if (info.immediateUpdateAllowed) {
          if (!isTestEnvironment) {
            await InAppUpdate.performImmediateUpdate();
          }
        }
      } else {
        _showSnackBar(
          context,
          AppLocalizations.of(context)?.noUpdatesAvailable ??
              'You are using the latest version of Fard.',
        );
      }
    } catch (e) {
      debugPrint('[InAppUpdateService] Manual update check error: $e');
      if (context.mounted) {
        _showSnackBar(
          context,
          AppLocalizations.of(context)?.noUpdatesAvailable ??
              'You are using the latest version of Fard.',
        );
      }
    }
  }

  void _listenForDownload(
    BuildContext context, {
    Stream<InstallStatus>? customStream,
  }) {
    final stream = customStream ?? InAppUpdate.installUpdateListener;
    _updateSubscription?.cancel();
    _updateSubscription = stream.listen((status) {
      if (status == InstallStatus.downloaded) {
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.updateDownloaded ??
                    'An update has been downloaded. Restart to install?',
              ),
              duration: const Duration(seconds: 15),
              action: SnackBarAction(
                label: l10n?.restartAndInstall ?? 'Restart & Install',
                onPressed: () {
                  InAppUpdate.completeFlexibleUpdate().catchError((e) {
                    debugPrint(
                      '[InAppUpdateService] Error completing update: $e',
                    );
                  });
                },
              ),
            ),
          );
        }
      }
    });
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

