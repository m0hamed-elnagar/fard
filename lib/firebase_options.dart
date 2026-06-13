// File configured for dynamic multi-flavor Android setup.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'core/utils/app_identifiers.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get android {
    final String currentPackageName = AppIdentifiers.packageName;
    
    // Choose appropriate App ID depending on the runtime package identifier.
    // NOTE: The 'benchmark' build type (com.khwarizmi.fard.benchmark) is NOT
    // registered in Firebase. It intentionally falls through to the release
    // App ID since benchmark builds mirror release behavior for profiling.
    final String appId = (currentPackageName == 'com.khwarizmi.fard.debug')
        ? '1:892116958938:android:ea45cdae9f040a2438efe3' // Fard Debug
        : '1:892116958938:android:a07b337d341a813e38efe3'; // Fard Release (+ Benchmark)

    return FirebaseOptions(
      apiKey: 'AIzaSyBD2Wly4VlTh73f6b8Vgzd_K6pEIuv5fO0',
      appId: appId,
      messagingSenderId: '892116958938',
      projectId: 'fard-6b8a0',
      storageBucket: 'fard-6b8a0.firebasestorage.app',
    );
  }
}
