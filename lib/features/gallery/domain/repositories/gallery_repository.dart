import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Domain interface for gallery repository
abstract class GalleryRepository {
  /// Gets the default Pictures folder path for the current platform
  Future<String> getDefaultPicturesFolder();

  /// Gets all images in a folder
  Future<List<ImageItem>> getImagesInFolder(String folderPath);

  /// Picks a custom folder using platform file picker
  Future<String?> pickCustomFolder();
}