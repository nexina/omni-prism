import 'package:flutter/material.dart';
import 'package:omni_prism/core/di/injection_container.dart';
import 'package:omni_prism/core/router/app_router.dart';
import 'package:omni_prism/core/utils/launch_args.dart';
import 'package:omni_prism/omni_prism_app.dart';

/// Application entry point
void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();

  // Show the gallery first; nothing else may delay the first frame
  runApp(const OmniPrismApp());

  // Then open the image passed via launch arguments, if any, in fullscreen
  final launchFile = await resolveLaunchFile(args);
  if (launchFile != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.navigateToImageViewer(launchFile, fullscreen: true);
    });
    WidgetsBinding.instance.scheduleFrame();
  }
}
