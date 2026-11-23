import 'package:firebase_core/firebase_core.dart';

/// O FlutterFire CLI substitui este arquivo ao executar `flutterfire configure`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Firebase ainda não configurado. Execute flutterfire configure para vincular seu projeto.',
  );
}
