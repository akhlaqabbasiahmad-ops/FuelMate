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
    apiKey: 'AIzaSyBYE7DWhtRbXVqfFLu8emgQQfhdAqk-7v0',
    appId: '1:342717605808:android:48a03c910a8a1b2fedd875',
    messagingSenderId: '342717605808',
    projectId: 'fuelmate-73aaf',
    storageBucket: 'fuelmate-73aaf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBYE7DWhtRbXVqfFLu8emgQQfhdAqk-7v0',
    appId: '1:342717605808:ios:48a03c910a8a1b2fedd875',
    messagingSenderId: '342717605808',
    projectId: 'fuelmate-73aaf',
    storageBucket: 'fuelmate-73aaf.firebasestorage.app',
    iosBundleId: 'com.example.fuelmate-flutter',
  );
}

