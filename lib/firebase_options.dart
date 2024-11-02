// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBWnczyyv1v9pV6DZcgjPCwisP9xBt3R6g',
    appId: '1:376065639878:web:1638ab6a4984fa404cdec7',
    messagingSenderId: '376065639878',
    projectId: 'talkloop-9f2ba',
    authDomain: 'talkloop-9f2ba.firebaseapp.com',
    storageBucket: 'talkloop-9f2ba.appspot.com',
    measurementId: 'G-6FZBMRMKES',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBjFl2SPu4s7r3d4jc943rzy8ckVzkkHso',
    appId: '1:376065639878:android:5f0b8bfe07b0d7404cdec7',
    messagingSenderId: '376065639878',
    projectId: 'talkloop-9f2ba',
    storageBucket: 'talkloop-9f2ba.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCZ8QbGxO8ddTGQL3RHt-V2RcU37I9LSIc',
    appId: '1:376065639878:ios:53b57a0eb6839fbe4cdec7',
    messagingSenderId: '376065639878',
    projectId: 'talkloop-9f2ba',
    storageBucket: 'talkloop-9f2ba.appspot.com',
    iosBundleId: 'com.example.talkloop',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCZ8QbGxO8ddTGQL3RHt-V2RcU37I9LSIc',
    appId: '1:376065639878:ios:53b57a0eb6839fbe4cdec7',
    messagingSenderId: '376065639878',
    projectId: 'talkloop-9f2ba',
    storageBucket: 'talkloop-9f2ba.appspot.com',
    iosBundleId: 'com.example.talkloop',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBWnczyyv1v9pV6DZcgjPCwisP9xBt3R6g',
    appId: '1:376065639878:web:1f5d755911c1c5f04cdec7',
    messagingSenderId: '376065639878',
    projectId: 'talkloop-9f2ba',
    authDomain: 'talkloop-9f2ba.firebaseapp.com',
    storageBucket: 'talkloop-9f2ba.appspot.com',
    measurementId: 'G-23H54LRZXD',
  );
}
