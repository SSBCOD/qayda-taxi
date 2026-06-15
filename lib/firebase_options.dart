// File generated manually from google-services.json for multi-platform support.
// Run `flutterfire configure` to regenerate with proper per-platform app IDs.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAC8DlZcgMf6X5WJePBfE5xSVw2NCjhWo',
    appId: '1:898588116588:android:0954cdb8dda34685d3fa49',
    messagingSenderId: '898588116588',
    projectId: 'qayda-taxi-app-c0404',
    storageBucket: 'qayda-taxi-app-c0404.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDAC8DlZcgMf6X5WJePBfE5xSVw2NCjhWo',
    appId: '1:898588116588:ios:0954cdb8dda34685d3fa49',
    messagingSenderId: '898588116588',
    projectId: 'qayda-taxi-app-c0404',
    storageBucket: 'qayda-taxi-app-c0404.firebasestorage.app',
    iosBundleId: 'com.example.qayda',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDAC8DlZcgMf6X5WJePBfE5xSVw2NCjhWo',
    appId: '1:898588116588:android:0954cdb8dda34685d3fa49',
    messagingSenderId: '898588116588',
    projectId: 'qayda-taxi-app-c0404',
    storageBucket: 'qayda-taxi-app-c0404.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDAC8DlZcgMf6X5WJePBfE5xSVw2NCjhWo',
    appId: '1:898588116588:android:0954cdb8dda34685d3fa49',
    messagingSenderId: '898588116588',
    projectId: 'qayda-taxi-app-c0404',
    storageBucket: 'qayda-taxi-app-c0404.firebasestorage.app',
  );
}
