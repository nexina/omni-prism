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
  Future<List<String>> getDefaultImageFolders() {
    return _localDataSource.getDefaultImageFolders();
  }

  @override
  Future<List<ImageItem>> getImagesInFolder(String folderPath) async {
    return _localDataSource.getImagesInFolder(folderPath);
  }

  @override
  Stream<List<ImageItem>> scanImages(String folderPath) {
    return _localDataSource.scanImages(folderPath);
  }

  @override
  Future<Set<String>> findMissing(List<String> paths) {
    return _localDataSource.findMissing(paths);
  }

  @override
  Future<String?> pickCustomFolder() async {
    return _localDataSource.pickCustomFolder();
  }

  @override
  List<String>? getSavedFolders() => _localDataSource.getSavedFolders();

  @override
  Future<void> saveFolders(List<String> folders) {
    return _localDataSource.saveFolders(folders);
  }
}
