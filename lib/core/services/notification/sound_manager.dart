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
    final bool isLocalFile = sound.startsWith('/') || (sound.length > 1 && sound[1] == ':');
    if (isLocalFile) {
      final file = File(sound);
      if (!await file.exists()) return null;
      
      try {
        if (Platform.isAndroid) {
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            // Path relative to external storage
            final String fileName = sound.split(Platform.isWindows ? '\\' : '/').last;
            final azanDir = Directory('${externalDir.path}/azan_sounds');
            if (!await azanDir.exists()) await azanDir.create(recursive: true);
            
            final destFile = File('${azanDir.path}/$fileName');
            if (!await destFile.exists() || (await destFile.length() != await file.length())) {
              await file.copy(destFile.path);
            }
            
            // The authority MUST match ${applicationId}.fileprovider in AndroidManifest.xml
            final String authority = '${_packageInfo?.packageName ?? 'com.qada.fard'}.fileprovider';
            final String contentUri = 'content://$authority/external_azan/$fileName';
            
            debugPrint('Using content URI for Azan: $contentUri (Authority: $authority)');
            return contentUri;
          }
        }
      } catch (e) {
        debugPrint('Error preparing sound URI: $e');
      }
      return Uri.file(sound).toString();
    }
    
    return null; // For raw resources
  }
}
