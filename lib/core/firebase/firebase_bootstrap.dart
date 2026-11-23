import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

Future<void> initializeFirebaseIfConfigured() async {
  final FirebaseOptions options;
  try {
    options = DefaultFirebaseOptions.currentPlatform;
  } on UnsupportedError catch (error) {
    // O FlutterFire também usa UnsupportedError para plataformas não selecionadas.
    debugPrint('Usando o modo local. ${error.message}');
    return;
  }

  await Firebase.initializeApp(options: options);
}
