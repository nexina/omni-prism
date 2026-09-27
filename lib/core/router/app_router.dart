import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:omni_prism/core/class/working_file.dart';

/// Application router using GoRouter
class AppRouter {
  // Route names
  static const String homeRoute = '/';
  static const String imageViewerRoute = '/imageViewer';
  static const String galleryRoute = '/gallery';
  static const String aboutRoute = '/about';
  static const String settingsRoute = '/settings';
  static const String editImageRoute = '/editImage';

  // Route paths (same as names for simplicity)
  static const String homePath = homeRoute;
  static const String imageViewerPath = imageViewerRoute;
  static const String galleryPath = galleryRoute;
  static const String aboutPath = aboutRoute;
  static const String settingsPath = settingsRoute;
  static const String editImagePath = editImageRoute;

  /// The GoRouter instance
  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    redirect: (context, state) {
      final uri = state.uri;

      // Ignore external intents (Open With) - let them be handled by the platform
      if (uri.scheme == 'content' ||
          uri.scheme == 'file' ||
          uri.scheme == 'android.resource') {
        return homePath;
      }

      return null;
    },
    routes: [
      // Home/Gallery route
      GoRoute(
        path: homePath,
        name: homeRoute,
        builder: (context, state) {
          // TODO: Replace with actual GalleryPage when implemented
          return const _PlaceholderPage(title: 'Gallery');
        },
      ),

      // Gallery route (explicit)
      GoRoute(
        path: galleryPath,
        name: galleryRoute,
        builder: (context, state) {
          // TODO: Replace with actual GalleryPage when implemented
          return const _PlaceholderPage(title: 'Gallery');
        },
      ),

      // Image Viewer route
      GoRoute(
        path: imageViewerPath,
        name: imageViewerRoute,
        pageBuilder: (context, state) {
          final workingFile = state.extra as WorkingFile?;
          // TODO: Replace with actual ImageViewerPage when implemented
          return NoTransitionPage(
            child: _PlaceholderPage(
              title: 'Image Viewer',
              subtitle: workingFile?.workingPath ?? 'No file',
            ),
          );
        },
      ),

      // About route
      GoRoute(
        path: aboutPath,
        name: aboutRoute,
        builder: (context, state) {
          // TODO: Replace with actual AboutPage when implemented
          return const _PlaceholderPage(title: 'About');
        },
      ),

      // Settings route
      GoRoute(
        path: settingsPath,
        name: settingsRoute,
        pageBuilder: (context, state) {
          return NoTransitionPage(
            child: const _PlaceholderPage(title: 'Settings'),
          );
        },
      ),

      // Edit Image route
      GoRoute(
        path: editImagePath,
        name: editImageRoute,
        builder: (context, state) {
          // TODO: Replace with actual EditImagePage when implemented
          return const _PlaceholderPage(title: 'Edit Image');
        },
      ),
    ],
  );

  /// Navigate to image viewer with a working file
  static void navigateToImageViewer(WorkingFile file) {
    router.pushNamed(imageViewerRoute, extra: file);
  }

  /// Navigate to gallery
  static void navigateToGallery() {
    router.pushNamed(galleryRoute);
  }

  /// Navigate to about
  static void navigateToAbout() {
    router.pushNamed(aboutRoute);
  }

  /// Navigate to settings
  static void navigateToSettings() {
    router.pushNamed(settingsRoute);
  }

  /// Navigate to edit image
  static void navigateToEditImage() {
    router.pushNamed(editImageRoute);
  }

  /// Go back
  static void goBack() {
    if (router.canPop()) {
      router.pop();
    }
  }
}

/// Placeholder page for routes not yet implemented
class _PlaceholderPage extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _PlaceholderPage({
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}