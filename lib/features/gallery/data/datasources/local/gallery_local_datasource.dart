import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:omni_prism/core/utils/file_utils.dart';
import 'package:omni_prism/core/utils/file_type_utils.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Interface for gallery local data source
abstract class GalleryLocalDataSource {
  /// Gets the default Pictures folder path for the current platform
  Future<String> getDefaultPicturesFolder();

  /// Gets all images in a folder
  Future<List<ImageItem>> getImagesInFolder(String folderPath);

  /// Picks a custom folder using platform file picker
  Future<String?> pickCustomFolder();
}

/// Implementation of gallery local data source using file system
class GalleryLocalDataSourceImpl implements GalleryLocalDataSource {
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
  Future<String?> pickCustomFolder() async {
    return getDirectoryPath(confirmButtonText: 'Open Folder');
  }
}