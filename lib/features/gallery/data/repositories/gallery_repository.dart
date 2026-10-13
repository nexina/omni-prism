import 'package:omni_prism/features/gallery/data/datasources/local/gallery_local_datasource.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';
import 'package:omni_prism/features/gallery/domain/repositories/gallery_repository.dart';

/// Implementation of gallery repository
class GalleryRepositoryImpl implements GalleryRepository {
  final GalleryLocalDataSource _localDataSource;

  GalleryRepositoryImpl({required GalleryLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<String> getDefaultPicturesFolder() async {
    return _localDataSource.getDefaultPicturesFolder();
  }

  @override
  Future<List<ImageItem>> getImagesInFolder(String folderPath) async {
    return _localDataSource.getImagesInFolder(folderPath);
  }

  @override
  Future<String?> pickCustomFolder() async {
    return _localDataSource.pickCustomFolder();
  }
}
