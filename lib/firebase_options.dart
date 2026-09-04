import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return windows;

      case TargetPlatform.linux:
        throw UnsupportedError('Firebase is not configured for Linux.');

      default:
        throw UnsupportedError('Firebase is not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBFCnL3E9AfR-RFcV7Uj0ddjDmhw8nUSR8',
    appId: '1:439548860123:web:cf0c7c13df3eba17265efe',
    messagingSenderId: '439548860123',
    projectId: 'timetable-project-d7923',
    authDomain: 'timetable-project-d7923.firebaseapp.com',
    storageBucket: 'timetable-project-d7923.firebasestorage.app',
    measurementId: 'G-5EH4S4NESX',
  );

  // ============================================================
  // ANDROID
  // ============================================================

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: '439548860123',
    projectId: 'timetable-project-d7923',
    storageBucket: 'timetable-project-d7923.firebasestorage.app',
  );

  // ============================================================
  // IOS
  // ============================================================

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '439548860123',
    projectId: 'timetable-project-d7923',
    storageBucket: 'timetable-project-d7923.firebasestorage.app',
    iosBundleId: 'com.example.timetableProject',
  );

  // ============================================================
  // MACOS
  // ============================================================

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '439548860123',
    projectId: 'timetable-project-d7923',
    storageBucket: 'timetable-project-d7923.firebasestorage.app',
    iosBundleId: 'com.example.timetableProject',
  );

  // ============================================================
  // WINDOWS
  // ============================================================

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBFCnL3E9AfR-RFcV7Uj0ddjDmhw8nUSR8',
    appId: '1:439548860123:web:cf0c7c13df3eba17265efe',
    messagingSenderId: '439548860123',
    projectId: 'timetable-project-d7923',
    authDomain: 'timetable-project-d7923.firebaseapp.com',
    storageBucket: 'timetable-project-d7923.firebasestorage.app',
    measurementId: 'G-5EH4S4NESX',
  );
}
