// このファイルは開発・テスト用のFirebase設定です
// 実際の本番環境では、Firebase Consoleから取得した設定を使用してください

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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web プラットフォーム設定
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForWebPlatform123456789',
    appId: '1:123456789:web:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'staff-finder-demo',
    authDomain: 'staff-finder-demo.firebaseapp.com',
    storageBucket: 'staff-finder-demo.appspot.com',
    measurementId: 'G-ABCDEFGHIJ',
  );

  // Android プラットフォーム設定
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForAndroidPlatform123456789',
    appId: '1:123456789:android:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'staff-finder-demo',
    storageBucket: 'staff-finder-demo.appspot.com',
  );

  // iOS プラットフォーム設定
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForiOSPlatform123456789',
    appId: '1:123456789:ios:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'staff-finder-demo',
    storageBucket: 'staff-finder-demo.appspot.com',
    iosClientId: '123456789-abcdefghijklmnop.apps.googleusercontent.com',
    iosBundleId: 'com.stafffinder.finder',
  );

  // macOS プラットフォーム設定
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDemoKeyForiOSPlatform123456789',
    appId: '1:123456789:ios:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'staff-finder-demo',
    storageBucket: 'staff-finder-demo.appspot.com',
    iosClientId: '123456789-abcdefghijklmnop.apps.googleusercontent.com',
    iosBundleId: 'com.stafffinder.finder',
  );
}
