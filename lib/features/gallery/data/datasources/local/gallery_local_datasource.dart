import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omni_prism/core/utils/file_utils.dart';
import 'package:omni_prism/core/utils/file_type_utils.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Interface for gallery local data source
abstract class GalleryLocalDataSource {
  /// Gets the default Pictures folder path for the current platform
  Future<String> getDefaultPicturesFolder();

  /// Gets all images in a folder
  Future<List<ImageItem>> getImagesInFolder(String folderPath);

  /// Scans a folder and all its subfolders on a background isolate,
  /// emitting images in batches as they are found. Cancelling the
  /// subscription stops the scan.
  Stream<List<ImageItem>> scanImages(String folderPath);

  /// Returns the paths among [paths] whose files no longer exist
  Future<Set<String>> findMissing(List<String> paths);

  /// Picks a custom folder using platform file picker
  Future<String?> pickCustomFolder();

  /// Folders the user added to the gallery
  List<String> getSavedFolders();

  /// Persists the folders the user added to the gallery
  Future<void> saveFolders(List<String> folders);
}

/// Implementation of gallery local data source using file system
class GalleryLocalDataSourceImpl implements GalleryLocalDataSource {
  static const String _foldersKey = 'gallery_folders';

  final SharedPreferences _preferences;

  GalleryLocalDataSourceImpl({required SharedPreferences preferences})
      : _preferences = preferences;

  @override
  List<String> getSavedFolders() {
    return _preferences.getStringList(_foldersKey) ?? const [];
  }

  @override
  Future<void> saveFolders(List<String> folders) async {
    await _preferences.setStringList(_foldersKey, folders);
  }

  @override
  Future<String> getDefaultPicturesFolder() async {
    if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        return '$userProfile\\Pictures';
      }
    } else if (Platform.isLinux) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        // Try XDG_PICTURES_DIR first
        final xdgPictures = Platform.environment['XDG_PICTURES_DIR'];
        if (xdgPictures != null && xdgPictures.isNotEmpty) {
          return xdgPictures;
        }
        return '$home/Pictures';
      }
    } else if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null) {
        return '$home/Pictures';
      }
    } else if (Platform.isAndroid) {
      // On Android, use external storage Pictures directory
      try {
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          // Navigate to Pictures folder
          final picturesDir = Directory('${directory.path}/Pictures');
          if (await picturesDir.exists()) {
            return picturesDir.path;
          }
          // Fallback to DCIM
          final dcimDir = Directory('${directory.path}/DCIM');
          if (await dcimDir.exists()) {
            return dcimDir.path;
          }
        }
      } catch (_) {
        // Fall through to app documents
      }
    }

    // Fallback to application documents directory
    final appDir = await getApplicationDocumentsDirectory();
    return appDir.path;
  }

  @override
  Future<List<ImageItem>> getImagesInFolder(String folderPath) async {
    final files = await FileUtils.getFilesInDirectory(folderPath);
    final imageItems = <ImageItem>[];

    for (final file in files) {
      if (file is File && FileTypeUtils.isImageFile(file.path)) {
        try {
          final stat = file.statSync();
          final imageItem = ImageItem.fromFile(
            file.path,
            modified: stat.modified,
            size: stat.size,
          );
          imageItems.add(imageItem);
        } catch (_) {
          // Skip files that can't be read
        }
      }
    }

    // Sort by name
    imageItems.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    return imageItems;
  }

  @override
  Stream<List<ImageItem>> scanImages(String folderPath) {
    late final StreamController<List<ImageItem>> controller;
    final port = ReceivePort();
    Isolate? isolate;
    var cancelled = false;

    void finish() {
      port.close();
      if (!controller.isClosed) controller.close();
    }

    controller = StreamController<List<ImageItem>>(
      onListen: () async {
        port.listen((message) {
          if (message is _ScanBatch) {
            controller.add(message.items);
          } else if (message is List && message.length == 2) {
            // Uncaught error from the isolate: [error, stackTrace] as strings
            controller.addError(Exception(message[0]));
          } else if (message == null) {
            // Isolate exited
            finish();
          }
        });
        try {
          isolate = await Isolate.spawn(
            _scanFolder,
            _ScanRequest(folderPath, port.sendPort),
            onExit: port.sendPort,
            onError: port.sendPort,
            debugName: 'gallery-scan',
          );
          if (cancelled) isolate!.kill(priority: Isolate.immediate);
        } catch (e, s) {
          controller.addError(e, s);
          finish();
        }
      },
      onCancel: () {
        cancelled = true;
        isolate?.kill(priority: Isolate.immediate);
        port.close();
      },
    );
    return controller.stream;
  }

  @override
  Future<Set<String>> findMissing(List<String> paths) {
    return Isolate.run(
      () => paths.where((path) => !File(path).existsSync()).toSet(),
      debugName: 'gallery-prune',
    );
  }

  @override
  Future<String?> pickCustomFolder() async {
    // Only used as the picker's starting point; nothing is scanned here
    String? initialDirectory;
    try {
      initialDirectory = await getDefaultPicturesFolder();
    } catch (_) {}
    return getDirectoryPath(
      initialDirectory: initialDirectory,
      confirmButtonText: 'Add Folder',
    );
  }
}

/// Message sent to the scan isolate
class _ScanRequest {
  final String rootPath;
  final SendPort sendPort;

  const _ScanRequest(this.rootPath, this.sendPort);
}

/// Batch of images sent back from the scan isolate
class _ScanBatch {
  final List<ImageItem> items;

  const _ScanBatch(this.items);
}

/// Isolate entry point: breadth-first walk of [request.rootPath], so the
/// images directly in the chosen folder arrive first. Hidden folders and
/// symlinks are skipped; unreadable folders are ignored.
void _scanFolder(_ScanRequest request) {
  const maxBatchSize = 200;
  const maxBatchDelay = Duration(milliseconds: 150);

  final queue = Queue<Directory>()..add(Directory(request.rootPath));
  final sinceFlush = Stopwatch()..start();
  var batch = <ImageItem>[];

  void flush() {
    if (batch.isNotEmpty) {
      request.sendPort.send(_ScanBatch(batch));
      batch = <ImageItem>[];
    }
    sinceFlush.reset();
  }

  var isRoot = true;
  while (queue.isNotEmpty) {
    final directory = queue.removeFirst();
    final List<FileSystemEntity> entries;
    try {
      entries = directory.listSync(followLinks: false);
    } catch (_) {
      continue;
    }
    entries.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    for (final entry in entries) {
      if (p.basename(entry.path).startsWith('.')) continue;
      if (entry is Directory) {
        queue.add(entry);
      } else if (entry is File && FileTypeUtils.isImageFile(entry.path)) {
        try {
          final stat = entry.statSync();
          batch.add(ImageItem.fromFile(
            entry.path,
            modified: stat.modified,
            size: stat.size,
          ));
        } catch (_) {
          // Skip files that can't be read
        }
        if (batch.length >= maxBatchSize) flush();
      }
    }

    // Show the chosen folder's own images right away
    if (isRoot || sinceFlush.elapsed >= maxBatchDelay) flush();
    isRoot = false;
  }
  flush();
}
