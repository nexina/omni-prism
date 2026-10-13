import 'dart:ui';

import 'package:flutter/material.dart';
import '../config/constants.dart';

/// Blurred, darkened wallpaper background shared by every page
class BackgroundBuilder extends StatelessWidget {
  final Widget child;
  final double overlayOpacity;

  const BackgroundBuilder({
    super.key,
    required this.child,
    this.overlayOpacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Painted first so there is never a white frame
          const ColoredBox(color: Colors.black),
          Image.asset(
            AppConstants.defaultBackgroundPath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: const ColoredBox(color: Colors.transparent),
          ),
          SafeArea(
            child: ColoredBox(
              color: Colors.black.withValues(alpha: overlayOpacity),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
