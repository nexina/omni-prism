import 'package:flutter/material.dart';
import 'package:omni_prism/core/router/app_router.dart';
import 'package:omni_prism/core/config/theme.dart';

/// Main application widget
class OmniPrismApp extends StatelessWidget {
  const OmniPrismApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Omni Prism',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
    );
  }
}