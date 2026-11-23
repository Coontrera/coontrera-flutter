import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuração do aplicativo Web registrado no projeto coontrera-app.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'Execute flutterfire configure para vincular esta plataforma ao Firebase.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAn9yy2XO2wuewGx6TLXbU7-l3Ao0DO3zs',
    authDomain: 'coontrera-app.firebaseapp.com',
    projectId: 'coontrera-app',
    storageBucket: 'coontrera-app.firebasestorage.app',
    messagingSenderId: '278060160759',
    appId: '1:278060160759:web:d6e5dde99e29535ceaa5f2',
    measurementId: 'G-L4GP18J8YK',
  );
}
