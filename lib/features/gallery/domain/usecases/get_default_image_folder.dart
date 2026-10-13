import 'package:omni_prism/features/gallery/domain/repositories/gallery_repository.dart';

/// Use case for getting the default Pictures folder path
class GetDefaultImageFolderUseCase {
  final GalleryRepository _repository;

  GetDefaultImageFolderUseCase(this._repository);

  /// Executes the use case
  Future<String> call() async {
    return _repository.getDefaultPicturesFolder();
  }
}