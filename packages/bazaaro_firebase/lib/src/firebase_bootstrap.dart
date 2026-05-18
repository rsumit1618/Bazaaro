import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class BazaaroFirebaseBootstrap {
  const BazaaroFirebaseBootstrap._();

  static var _isInitializing = false;

  static bool get isReady => Firebase.apps.isNotEmpty;

  static Future<void> initialize() async {
    if (Firebase.apps.isNotEmpty) return;
    if (_isInitializing) return;
    _isInitializing = true;
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(options: _webOptions);
        return;
      }
      await Firebase.initializeApp(options: _androidFallbackOptions);
    } catch (_) {
      // Bazaaro can run from local catalog data when Firebase is not reachable.
    } finally {
      _isInitializing = false;
    }
  }

  static const _webOptions = FirebaseOptions(
    apiKey: 'AIzaSyCe482qkY-KtUh3kflvuYvJ9CRXzIc8S1c',
    appId: '1:395070756993:web:5383871bfc8888a323d580',
    authDomain: 'echo-me-fe509.firebaseapp.com',
    databaseURL: 'https://echo-me-fe509-default-rtdb.firebaseio.com',
    messagingSenderId: '395070756993',
    projectId: 'echo-me-fe509',
    storageBucket: 'echo-me-fe509.firebasestorage.app',
  );

  static const _androidFallbackOptions = FirebaseOptions(
    apiKey: 'AIzaSyA1RjspMP_yktpbQwPC80mKnVxKyjfOSO0',
    appId: '1:395070756993:android:9611971b824cac4b23d580',
    databaseURL: 'https://echo-me-fe509-default-rtdb.firebaseio.com',
    messagingSenderId: '395070756993',
    projectId: 'echo-me-fe509',
    storageBucket: 'echo-me-fe509.firebasestorage.app',
  );
}
