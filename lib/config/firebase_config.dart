// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web is not supported for this configuration.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyEXAMPLE-123456',
    appId: '1:1234567890:android:abcdefg12345',
    messagingSenderId: '1234567890',
    projectId: 'todo-a7a92',
    storageBucket: 'todo-a7a92.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyEXAMPLE-098765',
    appId: '1:1234567890:ios:abcdefg98765',
    messagingSenderId: '1234567890',
    projectId: 'todo-a7a92',
    storageBucket: 'todo-a7a92.appspot.com',
    iosBundleId: 'com.aptyou.flutterApp',
  );
}
