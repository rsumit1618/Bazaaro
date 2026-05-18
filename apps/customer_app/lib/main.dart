import 'dart:async';

import 'package:bazaaro_firebase/bazaaro_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(BazaaroFirebaseBootstrap.initialize());
  runApp(const ProviderScope(child: BazaaroCustomerApp()));
}
