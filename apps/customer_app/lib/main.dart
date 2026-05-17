import 'package:bazaaro_firebase/bazaaro_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await BazaaroFirebaseBootstrap.initialize();
  } catch (_) {
    // Firebase not configured (or init failed). App will still work with local catalog data.
  }
  runApp(const ProviderScope(child: BazaaroCustomerApp()));
}
