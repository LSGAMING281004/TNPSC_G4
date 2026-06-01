// File generated manually from Firebase Console config.
// To regenerate, run: flutterfire configure
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return web; // Use web config for Windows
      case TargetPlatform.linux:
        return web; // Use web config for Linux
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ─── Web ───
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBfq7B0S1HweCvF3x67M9hjhzGTMRGoDEs',
    appId: '1:642882247014:web:5d7c2e56bd54e0819910a7',
    messagingSenderId: '642882247014',
    projectId: 'tnpsc-group-4-master-2026',
    authDomain: 'tnpsc-group-4-master-2026.firebaseapp.com',
    storageBucket: 'tnpsc-group-4-master-2026.firebasestorage.app',
    measurementId: 'G-5FWG4WSCG2',
  );

  // ─── Android ───
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyALRd_iT7jMOr3KN1nWXXTp4rhBy9Yb4rs',
    appId: '1:642882247014:android:b4fec287ff0d1fe29910a7',
    messagingSenderId: '642882247014',
    projectId: 'tnpsc-group-4-master-2026',
    storageBucket: 'tnpsc-group-4-master-2026.firebasestorage.app',
  );

  // ─── iOS ───
  // TODO: Replace with actual iOS config after running `flutterfire configure`
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBfq7B0S1HweCvF3x67M9hjhzGTMRGoDEs',
    appId: '1:642882247014:web:5d7c2e56bd54e0819910a7', // Replace with iOS appId
    messagingSenderId: '642882247014',
    projectId: 'tnpsc-group-4-master-2026',
    storageBucket: 'tnpsc-group-4-master-2026.firebasestorage.app',
    iosBundleId: 'com.tnpscmaster.tnpscGroup4Master',
  );

  // ─── macOS ───
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBfq7B0S1HweCvF3x67M9hjhzGTMRGoDEs',
    appId: '1:642882247014:web:5d7c2e56bd54e0819910a7',
    messagingSenderId: '642882247014',
    projectId: 'tnpsc-group-4-master-2026',
    storageBucket: 'tnpsc-group-4-master-2026.firebasestorage.app',
    iosBundleId: 'com.tnpscmaster.tnpscGroup4Master',
  );
}
