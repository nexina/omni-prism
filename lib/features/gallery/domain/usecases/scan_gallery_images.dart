import 'package:omni_prism/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Use case for scanning a folder tree for images in the background
class ScanGalleryImagesUseCase {
  final GalleryRepository _repository;

  ScanGalleryImagesUseCase(this._repository);

  /// Emits batches of images as they are found
  Stream<List<ImageItem>> call(String folderPath) {
    return _repository.scanImages(folderPath);
  }

  /// Returns the paths among [paths] whose files no longer exist
  Future<Set<String>> findMissing(List<String> paths) {
    return _repository.findMissing(paths);
  }
}
