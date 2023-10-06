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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAm0ceBqev4hL5Aa9QGhwASk3S2bLco_qM',
    appId: '1:526988021227:web:b04b011fffd3d658e21dae',
    messagingSenderId: '526988021227',
    projectId: 'lipi-b8642',
    authDomain: 'lipi-b8642.firebaseapp.com',
    databaseURL: 'https://lipi-b8642-default-rtdb.firebaseio.com',
    storageBucket: 'lipi-b8642.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCFm92Et17Bb8Qc_htK6ckxLIbD7PbeQmw',
    appId: '1:526988021227:android:027af163ee226296e21dae',
    messagingSenderId: '526988021227',
    projectId: 'lipi-b8642',
    databaseURL: 'https://lipi-b8642-default-rtdb.firebaseio.com',
    storageBucket: 'lipi-b8642.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCbjCdaPZQYvN3IQ2omJm568tOr8eF4cTs',
    appId: '1:526988021227:ios:ce6b5382caa98d75e21dae',
    messagingSenderId: '526988021227',
    projectId: 'lipi-b8642',
    databaseURL: 'https://lipi-b8642-default-rtdb.firebaseio.com',
    storageBucket: 'lipi-b8642.appspot.com',
    iosBundleId: 'com.example.frontend',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCbjCdaPZQYvN3IQ2omJm568tOr8eF4cTs',
    appId: '1:526988021227:ios:98e1859193b99be9e21dae',
    messagingSenderId: '526988021227',
    projectId: 'lipi-b8642',
    databaseURL: 'https://lipi-b8642-default-rtdb.firebaseio.com',
    storageBucket: 'lipi-b8642.appspot.com',
    iosBundleId: 'com.example.frontend.RunnerTests',
  );
}
