import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:omni_prism/core/di/injection_container.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/utils/launch_args.dart';
import 'package:omni_prism/core/router/app_router.dart';
import 'package:omni_prism/omni_prism_app.dart';

/// Application entry point
void main(List<String> args) async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager
  await windowManager.ensureInitialized();

  // Configure window options for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    const windowOptions = WindowOptions(
      size: Size(AppConstants.defaultWindowWidth, AppConstants.defaultWindowHeight),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Initialize dependency injection
  await init();

  // Open the image passed via launch arguments, once the router is ready
  final launchFile = await resolveLaunchFile(args);
  if (launchFile != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.navigateToImageViewer(launchFile);
    });
  }

  // Run the app
  runApp(const OmniPrismApp());
}