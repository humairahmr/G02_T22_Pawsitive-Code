import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
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
