// File generated from Firebase project services-provider-b9462.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCyfT1Jrb57QrENUEbzEQD9Pde1ilILYqM',
    appId: '1:138471737210:android:90d093d39bf5f34af1b8c3',
    messagingSenderId: '138471737210',
    projectId: 'services-provider-b9462',
    storageBucket: 'services-provider-b9462.appspot.com',
    databaseURL: 'https://services-provider-b9462-default-rtdb.firebaseio.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCyc52WNvBJMvtRK2hMqAHs_OW3l2uyeNU',
    appId: '1:138471737210:ios:30c53370e1a44fadf1b8c3',
    messagingSenderId: '138471737210',
    projectId: 'services-provider-b9462',
    storageBucket: 'services-provider-b9462.appspot.com',
    iosBundleId: 'com.example.flutterBloc',
    databaseURL: 'https://services-provider-b9462-default-rtdb.firebaseio.com',
  );
}
