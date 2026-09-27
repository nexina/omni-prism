import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Domain interface for image repository
abstract class ImageRepository {
  /// Gets all images in a folder
  Future<List<ImageItem>> getImagesInFolder(String folderPath);

  /// Deletes an image file
  Future<bool> deleteImage(String path);

  /// Gets image details
  Future<ImageItem?> getImageDetails(String path);
}