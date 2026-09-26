import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:omni_preview/core/class/working_file.dart';
import 'package:omni_preview/core/config/file-type.dart';
import 'dart:io';
import 'dart:convert';

import 'package:omni_preview/core/router/app_router.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_bloc.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_event.dart';
import 'package:path/path.dart' as p;
import 'package:uri_to_file/uri_to_file.dart';

String getFileName(String path) {
  return p.basename(path);
}

String getExtension(String path) {
  return p.extension(path).replaceFirst('.', '').toLowerCase();
}

String getFilePathWithoutFileName(String path) {
  return p.dirname(path);
}

String getFileType(String extension) {
  if (documentsExtensions.contains(extension)) {
    return "Document";
  } else if (imagesExtensions.contains(extension)) {
    return "Image";
  } else if (videosExtensions.contains(extension)) {
    return "Video";
  } else if (audiosExtensions.contains(extension)) {
    return "Audio";
  } else if (archivesExtensions.contains(extension)) {
    return "Archive";
  } else if (textExtensions.contains(extension)) {
    return "Text";
  } else {
    return "Other";
  }
}

Color setColorByExtension(String extension) {
  String fileType = getFileType(extension);
  if (fileType == "Document") {
    return const Color(0xFF4A90E2);
  } else if (fileType == "Image") {
    return const Color(0xFF50E3C2);
  } else if (fileType == "Video") {
    return const Color(0xFFFF5A5F);
  } else if (fileType == "Audio") {
    return const Color(0xFFFFC300);
  } else if (fileType == "Archive") {
    return const Color(0xFF9013FE);
  } else {
    return const Color(0xFF9B9B9B);
  }
}

Future<void> openScreenForFile(BuildContext context, WorkingFile file) async {
  context.read<RecentListBloc>().add(
    AddFileToRecentListEvent(workingFile: file),
  );
  String extension = getExtension(file.workingPath);
  String fileType = getFileType(extension);

  if (!context.mounted) return;
  if (fileType == "Image") {
    AppRouter.router.pushNamed(
      AppRouter.imageViewerRoute,
      extra: WorkingFile(
        path: file.path,
        workingPath: file.workingPath,
        size: file.size,
      ),
    );
  } else if (fileType == "Archive") {
    AppRouter.router.pushNamed(
      AppRouter.archiveViewerRoute,
      extra: WorkingFile(
        path: file.path,
        workingPath: file.workingPath,
        size: file.size,
      ),
    );
  } else if (fileType == "Video") {
    AppRouter.router.pushNamed(
      AppRouter.videoViewerRoute,
      extra: WorkingFile(
        path: file.path,
        workingPath: file.workingPath,
        size: file.size,
      ),
    );
  } else if (fileType == "Document") {
    AppRouter.router.pushNamed(
      AppRouter.documentViewerRoute,
      extra: WorkingFile(
        path: file.path,
        workingPath: file.workingPath,
        size: file.size,
      ),
    );
  } else if (fileType == "Audio") {
    AppRouter.router.pushNamed(
      AppRouter.audioViewerRoute,
      extra: WorkingFile(
        path: file.path,
        workingPath: file.workingPath,
        size: file.size,
      ),
    );
  } else if (fileType == "Text") {
    AppRouter.router.pushNamed(
      AppRouter.textViewerRoute,
      extra: WorkingFile(
        path: file.path,
        workingPath: file.workingPath,
        size: file.size,
      ),
    );
  } else {
    if (await isTextFile(file.path)) {
      if (!context.mounted) return;
      AppRouter.router.pushNamed(
        AppRouter.textViewerRoute,
        extra: WorkingFile(
          path: file.path,
          workingPath: file.workingPath,
          size: file.size,
        ),
      );
    } else {
      // Show unsupported file type message
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Unsupported file type")));
    }
  }
}

// Future<void> openScreenForUri(
//   BuildContext context,
//   String uri, {
//   String? mimeType,
// }) async {
//   if (!context.mounted) return;

//   // Encode the URI so GoRouter treats it as a parameter, not a route
//   final encodedUri = Uri.encodeComponent(uri);
//   // final encodedUri = uri;

//   // Detect MIME type
//   final mimev = mimeType ?? mime(uri) ?? '';

//   if (mimev.startsWith('image/')) {
//     context.pushNamed(
//       AppRouter.imageViewerRoute,
//       pathParameters: {'fileUri': encodedUri},
//     );
//   } else if (mimev.startsWith('video/')) {
//     context.pushNamed(
//       AppRouter.videoViewerRoute,
//       pathParameters: {'fileUri': encodedUri},
//     );
//   } else if (mimev.startsWith('audio/')) {
//     context.pushNamed(
//       AppRouter.audioViewerRoute,
//       pathParameters: {'fileUri': encodedUri},
//     );
//   } else if (mimev == 'application/pdf') {
//     context.pushNamed(
//       AppRouter.documentViewerRoute,
//       pathParameters: {'fileUri': encodedUri},
//     );
//   } else if (mimev == 'application/zip') {
//     context.pushNamed(
//       AppRouter.archiveViewerRoute,
//       pathParameters: {'fileUri': encodedUri},
//     );
//   } else if (mimev.startsWith('text/')) {
//     context.pushNamed(
//       AppRouter.textViewerRoute,
//       pathParameters: {'fileUri': encodedUri},
//     );
//   } else {
//     // Unsupported file type
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text("Unsupported file type")));
//   }
// }

Future<String> getFilePathFromUri(String uri) async {
  // On Android, convert content URI to file path
  if (Platform.isAndroid && uri.startsWith('content://')) {
    try {
      final file = await UriToFilePlatform.instance.toFile(uri);
      return file.path;
    } catch (e) {
      throw Exception('Error resolving content URI: $e');
    }
  } else {
    return uri;
  }
}

String formatBytes(int bytes) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB"];
  var i = 0;
  double dBytes = bytes.toDouble();
  while (dBytes >= 1024 && i < suffixes.length - 1) {
    dBytes /= 1024;
    i++;
  }
  return '${dBytes.toStringAsFixed(2)} ${suffixes[i]}';
}

Future<bool> isTextFile(String path) async {
  final file = File(path);

  if (!await file.exists()) return false;

  final bytes = await file.openRead(0, 1024).first; // read first 1KB

  try {
    final text = utf8.decode(bytes, allowMalformed: true);

    // Heuristic: if too many replacement chars or null bytes → binary
    final nullCount = bytes.where((b) => b == 0).length;
    final ratio = nullCount / bytes.length;

    return ratio < 0.01 && text.trim().isNotEmpty;
  } catch (_) {
    return false;
  }
}

String formatDuration(Duration d) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);
  if (hours > 0) return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
  return '${minutes}:${twoDigits(seconds)}';
}
