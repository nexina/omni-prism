import 'dart:io';
import 'package:omni_prism/core/utils/file_utils.dart';
import 'package:omni_prism/core/utils/file_type_utils.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Interface for image local data source
abstract class ImageLocalDataSource {
  /// Gets all images in a folder
  Future<List<ImageItem>> getImagesInFolder(String folderPath);

  /// Deletes an image file
  Future<bool> deleteImage(String path);

  /// Gets image details (size, modified time)
  Future<ImageItem?> getImageDetails(String path);
}

/// Implementation of image local data source using file system
class ImageLocalDataSourceImpl implements ImageLocalDataSource {
  @override
  Future<List<ImageItem>> getImagesInFolder(String folderPath) async {
    final files = await FileUtils.getFilesInDirectory(folderPath);
    final imageItems = <ImageItem>[];

    for (final file in files) {
      if (file is File) {
        if (FileTypeUtils.isImageFile(file.path) ||
            AppConstants.supportedImageExtensions.any((ext) => file.path.toLowerCase().endsWith(ext))) {
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
    }

    // Sort by name
    imageItems.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

    return imageItems;
  }

  @override
  Future<bool> deleteImage(String path) async {
    return FileUtils.deleteFile(path);
  }

  @override
  Future<ImageItem?> getImageDetails(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;

    try {
      final stat = file.statSync();
      return ImageItem.fromFile(
        path,
        modified: stat.modified,
        size: stat.size,
      );
    } catch (_) {
      return null;
    }
  }
}