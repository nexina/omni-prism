import 'dart:io';

import 'package:flutter/services.dart';

/// Controls the native app window (implemented by Linux and Windows runners)
class WindowUtils {
  static const MethodChannel _channel = MethodChannel('omni_prism/window');

  /// Makes the window fullscreen, without title bar or border, or restores
  /// it. Does nothing on platforms whose runner doesn't support it.
  static Future<void> setFullScreen(bool fullScreen) async {
    try {
      await _channel.invokeMethod<void>('setFullScreen', fullScreen);
    } on MissingPluginException {
      // Not implemented by this platform's runner
    } on PlatformException {
      // Ignore; the viewer still hides its own chrome
    }
  }

  /// Closes the window, quitting the app
  static Future<void> close() async {
    try {
      await _channel.invokeMethod<void>('close');
    } on MissingPluginException {
      exit(0);
    }
  }
}
