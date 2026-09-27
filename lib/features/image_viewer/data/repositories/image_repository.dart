import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';
import 'package:omni_prism/features/image_viewer/data/datasources/local/image_local_datasource.dart';

/// Interface for image repository
abstract class ImageRepository {
  /// Gets all images in a folder
  Future<List<ImageItem>> getImagesInFolder(String folderPath);

  /// Deletes an image file
  Future<bool> deleteImage(String path);

  /// Gets image details
  Future<ImageItem?> getImageDetails(String path);
}

/// Implementation of image repository
class ImageRepositoryImpl implements ImageRepository {
  final ImageLocalDataSource _localDataSource;

  ImageRepositoryImpl({required ImageLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<List<ImageItem>> getImagesInFolder(String folderPath) async {
    return _localDataSource.getImagesInFolder(folderPath);
  }

  @override
  Future<bool> deleteImage(String path) async {
    return _localDataSource.deleteImage(path);
  }

  @override
  Future<ImageItem?> getImageDetails(String path) async {
    return _localDataSource.getImageDetails(path);
  }
}