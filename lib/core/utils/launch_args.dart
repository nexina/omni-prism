import 'dart:io';

import 'package:omni_prism/core/class/working_file.dart';

/// Resolves the file to open from the process arguments
/// (desktop "Open With", file associations, or the command line).
///
/// Accepts plain or relative paths and `file://` URIs, skips flags, and
/// returns the first argument that points at an existing file.
Future<WorkingFile?> resolveLaunchFile(List<String> args) async {
  for (final arg in args) {
    if (arg.isEmpty || arg.startsWith('-')) continue;

    String path = arg;
    if (arg.startsWith('file://')) {
      try {
        path = Uri.parse(arg).toFilePath();
      } catch (_) {
        continue;
      }
    }

    final file = File(path).absolute;
    if (await file.exists()) {
      return WorkingFile(
        path: file.path,
        workingPath: file.path,
        size: await file.length(),
      );
    }
  }
  return null;
}
