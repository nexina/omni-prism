import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Domain interface for gallery repository
abstract class GalleryRepository {
  /// Gets the default Pictures folder path for the current platform
  Future<String> getDefaultPicturesFolder();

  /// The platform's usual image folders that exist
  Future<List<String>> getDefaultImageFolders();

  /// Gets all images in a folder
  Future<List<ImageItem>> getImagesInFolder(String folderPath);

  /// Scans a folder recursively in the background, emitting image batches
  Stream<List<ImageItem>> scanImages(String folderPath);

  /// Returns the paths among [paths] whose files no longer exist
  Future<Set<String>> findMissing(List<String> paths);

  /// Picks a custom folder using platform file picker
  Future<String?> pickCustomFolder();

  /// Folders the user added to the gallery, or null if never saved
  List<String>? getSavedFolders();

  /// Persists the folders the user added to the gallery
  Future<void> saveFolders(List<String> folders);
}