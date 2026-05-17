import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class BazaaroFirebaseBootstrap {
  const BazaaroFirebaseBootstrap._();

  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) return;
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'REPLACE_WITH_FIREBASE_WEB_API_KEY',
          authDomain: 'bazaaro.firebaseapp.com',
          projectId: 'bazaaro',
          storageBucket: 'bazaaro.appspot.com',
          messagingSenderId: '000000000000',
          appId: '1:000000000000:web:replace',
        ),
      );
      return;
    }
    await Firebase.initializeApp();
  }
}
