import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

@singleton
class SoundManager {
  PackageInfo? _packageInfo;

  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  Future<String?> getSoundUriForChannel(String sound) async {
    if (sound == 'default') return null;

    // Check if it's a local file path
    final bool isLocalFile =
        sound.startsWith('/') || (sound.length > 1 && sound[1] == ':');
    if (!isLocalFile) return null;

    final file = File(sound);
    if (!await file.exists()) return null;

    try {
      if (Platform.isAndroid) {
        return await _prepareAndroidSoundUri(file);
      }
      return Uri.file(sound).toString();
    } catch (e) {
      debugPrint('Error preparing sound URI: $e');
      return Uri.file(sound).toString();
    }
  }

  Future<String?> _prepareAndroidSoundUri(File file) async {
    final externalDir = await getExternalStorageDirectory();
    if (externalDir == null) return null;

    // Standardize path separator for extraction regardless of current platform (during tests)
    final String fileName = file.path.split(RegExp(r'[/\\]')).last;
    final azanDir = Directory('${externalDir.path}/azan_sounds');

    if (!await azanDir.exists()) {
      await azanDir.create(recursive: true);
    }

    final destFile = File('${azanDir.path}/$fileName');

    // Copy if file doesn't exist or size differs
    if (!await destFile.exists() ||
        (await destFile.length() != await file.length())) {
      await file.copy(destFile.path);
    }

    final String authority =
        '${_packageInfo?.packageName ?? 'com.qada.fard'}.fileprovider';
    return 'content://$authority/external_azan/$fileName';
  }
}
