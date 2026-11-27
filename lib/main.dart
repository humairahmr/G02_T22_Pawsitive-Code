import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BlackboxStudioApp());
}

class BlackboxStudioApp extends StatelessWidget {
  const BlackboxStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Blackbox Studio',
      theme: AppTheme.dark,
      routerConfig: appRouter,
    );
  }
}
