import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDS9FhBy87dcI1gtqU_BLPYH433QZrIelA',
    appId: '1:572087801666:android:0a5f1259945c5356f6dadb',
    messagingSenderId: '572087801666',
    projectId: 'fuelmate-a5d7a',
    storageBucket: 'fuelmate-a5d7a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDS9FhBy87dcI1gtqU_BLPYH433QZrIelA',
    appId: '1:572087801666:ios:0a5f1259945c5356f6dadb',
    messagingSenderId: '572087801666',
    projectId: 'fuelmate-a5d7a',
    storageBucket: 'fuelmate-a5d7a.firebasestorage.app',
    iosBundleId: 'com.asentyx.fuelmate',
  );
}

