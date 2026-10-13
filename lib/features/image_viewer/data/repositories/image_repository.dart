import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';
import 'package:omni_prism/features/image_viewer/data/datasources/local/image_local_datasource.dart';
import 'package:omni_prism/features/image_viewer/domain/repositories/image_repository.dart';

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
