import 'package:go_router/go_router.dart';
import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/features/main/presentation/page/mainpage.dart';
import 'package:omni_preview/features/main/presentation/page/settings.dart';
import 'package:omni_preview/features/viewer/presentation/page/archive.dart';
import 'package:omni_preview/features/viewer/presentation/page/audio.dart';
import 'package:omni_preview/features/viewer/presentation/page/document.dart';
import 'package:omni_preview/features/viewer/presentation/page/image.dart';
import 'package:omni_preview/features/viewer/presentation/page/text.dart';
import 'package:omni_preview/features/viewer/presentation/page/video.dart';

class AppRouter {
  static String textViewerRoute = '/textViewer';
  static String audioViewerRoute = '/audioViewer';
  static String videoViewerRoute = '/videoViewer';
  static String imageViewerRoute = '/imageViewer';
  static String archiveViewerRoute = '/archiveViewer';
  static String documentViewerRoute = '/documentViewer';

  static String setting = '/setting';

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final uri = state.uri;

      // Ignore external intents (Open With)
      if (uri.scheme == 'content' ||
          uri.scheme == 'file' ||
          uri.scheme == 'android.resource') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainPage()),
      GoRoute(
        name: setting,
        path: setting,
        pageBuilder: (context, state) {
          return NoTransitionPage(child: const SettingsView());
        },
      ),

      GoRoute(
        name: textViewerRoute,
        path: textViewerRoute,
        builder: (context, state) {
          return TextViewer(workingFile: state.extra as WorkingFile);
        },
      ),
      GoRoute(
        name: audioViewerRoute,
        path: audioViewerRoute,
        builder: (context, state) {
          return AudioViewer(workingFile: state.extra as WorkingFile);
        },
      ),
      GoRoute(
        name: videoViewerRoute,
        path: videoViewerRoute,
        builder: (context, state) {
          return VideoViewer(workingFile: state.extra as WorkingFile);
        },
      ),
      GoRoute(
        name: imageViewerRoute,
        path: imageViewerRoute,
        pageBuilder: (context, state) {
          return NoTransitionPage(
            child: ImageViewer(workingFile: state.extra as WorkingFile),
          );
        },
      ),
      GoRoute(
        name: archiveViewerRoute,
        path: archiveViewerRoute,
        builder: (context, state) {
          return ArchieveViewer(workingFile: state.extra as WorkingFile);
        },
      ),
      GoRoute(
        name: documentViewerRoute,
        path: documentViewerRoute,
        builder: (context, state) {
          return DocumentViewer(workingFile: state.extra as WorkingFile);
        },
      ),
    ],
  );
}
