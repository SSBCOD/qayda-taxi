import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'app/bootstrap.dart';
import 'firebase_options.dart';
import 'services/firebase/firebase_connection_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  assert(() {
    debugPrint(const FirebaseConnectionService().currentStatus().toString());
    return true;
  }());

  final overrides = await bootstrap();
  runApp(
    ProviderScope(
      overrides: overrides,
      child: const QaydaApp(),
    ),
  );
}
