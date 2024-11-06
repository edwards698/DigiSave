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
    apiKey: 'AIzaSyCnkDqjRK3RERg4RbOpGEY7JMDDTzqUHvw',
    appId: '1:336533887938:web:33bca50ccf6f487f00545b',
    messagingSenderId: '336533887938',
    projectId: 'update-a33ce',
    authDomain: 'update-a33ce.firebaseapp.com',
    storageBucket: 'update-a33ce.firebasestorage.app',
    measurementId: 'G-05MY53KG2S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBNOQUmuae90sBIyRs3byxp8ImEk1j04OI',
    appId: '1:336533887938:android:8f70622ccc9a3ab900545b',
    messagingSenderId: '336533887938',
    projectId: 'update-a33ce',
    storageBucket: 'update-a33ce.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD1UzpN2YIRYNmUD5lTpCdPNexaALgrJL0',
    appId: '1:336533887938:ios:71634ae51cb02b4300545b',
    messagingSenderId: '336533887938',
    projectId: 'update-a33ce',
    storageBucket: 'update-a33ce.firebasestorage.app',
    iosBundleId: 'com.example.digi',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD1UzpN2YIRYNmUD5lTpCdPNexaALgrJL0',
    appId: '1:336533887938:ios:71634ae51cb02b4300545b',
    messagingSenderId: '336533887938',
    projectId: 'update-a33ce',
    storageBucket: 'update-a33ce.firebasestorage.app',
    iosBundleId: 'com.example.digi',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCnkDqjRK3RERg4RbOpGEY7JMDDTzqUHvw',
    appId: '1:336533887938:web:1dbfc939422e581f00545b',
    messagingSenderId: '336533887938',
    projectId: 'update-a33ce',
    authDomain: 'update-a33ce.firebaseapp.com',
    storageBucket: 'update-a33ce.firebasestorage.app',
    measurementId: 'G-9PZEDWZSVB',
  );
}
