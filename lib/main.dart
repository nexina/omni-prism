import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:omni_prism/core/di/injection_container.dart';
import 'package:omni_prism/core/config/constants.dart';
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
    await windowManager.waitUntilReadyToShow(windowOptions);
  }

  // Initialize dependency injection
  await init();

  // TODO: Handle CLI args for opening specific images
  // if (args.isNotEmpty) {
  //   final imagePath = args[0];
  //   // Navigate to image viewer with the image
  // }

  // Run the app
  runApp(const OmniPrismApp());
}