import 'package:omni_prism/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Use case for loading gallery images from a folder
class LoadGalleryImagesUseCase {
  final GalleryRepository _repository;

  LoadGalleryImagesUseCase(this._repository);

  /// Executes the use case
  Future<List<ImageItem>> call(String folderPath) async {
    return _repository.getImagesInFolder(folderPath);
  }
}