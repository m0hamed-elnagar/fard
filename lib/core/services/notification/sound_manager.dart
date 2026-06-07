import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:fard/core/utils/app_identifiers.dart';
import 'package:fard/core/di/injection.dart';
import 'package:fard/core/services/voice_download_service.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@singleton
class SoundManager {
  static const MethodChannel _channel = MethodChannel(
    'com.khwarizmi.fard/widget_theme',
  );

  /// Resolves a sound string (key or path) into a platform-appropriate URI.
  Future<String?> getSoundUriForChannel(String sound) async {
    if (sound == 'default') return null;

    String? finalPath = sound;

    // 1. If it's a voice key (no path separators), resolve it via downloader
    if (!sound.contains('/') && !sound.contains('\\')) {
      debugPrint('SoundManager: Resolving voice key: $sound');
      final downloader = getIt<VoiceDownloadService>();
      finalPath = await downloader.getAccessiblePath(sound);
      if (finalPath == null) {
        debugPrint('SoundManager: Could not resolve voice key to path: $sound');
        return null;
      }
    }

    // 2. Check if the file actually exists
    final file = File(finalPath);
    if (!await file.exists() || await file.length() == 0) {
      debugPrint(
        'SoundManager: File does not exist or is empty at path: $finalPath',
      );
      return null;
    }

    // 3. Platform specific URI preparation
    try {
      if (Platform.isAndroid) {
        return await _prepareAndroidSoundUri(file);
      }
      return Uri.file(finalPath).toString();
    } catch (e) {
      debugPrint('SoundManager: Error preparing sound URI: $e');
      return Uri.file(finalPath).toString();
    }
  }

  Future<String?> _prepareAndroidSoundUri(File file) async {
    // 🛡️ Ensure AppIdentifiers is initialized to avoid authority mismatch
    await AppIdentifiers.initialize();

    try {
      // Use native bridge to get authenticated content URI and grant permissions
      final String? contentUri = await _channel.invokeMethod<String>(
        'getNotificationSoundUri',
        {'filePath': file.absolute.path},
      );

      if (contentUri != null) {
        debugPrint('SoundManager: NATIVE Android Content URI: $contentUri');
        return contentUri;
      }
    } catch (e) {
      debugPrint('SoundManager: Native URI resolution failed: $e');
    }

    // Fallback: Manually construct URI for external files (highly reliable for notifications)
    try {
      final String fileName = file.path.split(RegExp(r'[/\\]')).last;
      final externalDir = await getExternalStorageDirectory();

      if (externalDir != null) {
        // Match the 'external_azan' path in file_paths.xml which points to 'azan_sounds'
        final azanDir = Directory('${externalDir.path}/azan_sounds');
        if (!await azanDir.exists()) await azanDir.create(recursive: true);

        final destFile = File('${azanDir.path}/$fileName');

        // Ensure file exists in the external path mapped by FileProvider
        if (!await destFile.exists() ||
            (await destFile.length() != await file.length())) {
          await file.copy(destFile.path);
        }

        final String authority = AppIdentifiers.fileProviderAuthority;
        final String fallbackUri =
            'content://$authority/external_azan/$fileName';
        debugPrint('SoundManager: FALLBACK Android Content URI: $fallbackUri');
        return fallbackUri;
      }
    } catch (e) {
      debugPrint('SoundManager: Fallback URI construction failed: $e');
    }

    // Last resort: File URI (often fails on newer Android, but better than nothing)
    return Uri.file(file.absolute.path).toString();
  }
}
