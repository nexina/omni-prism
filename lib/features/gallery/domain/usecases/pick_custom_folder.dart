import 'package:omni_prism/features/gallery/domain/repositories/gallery_repository.dart';

/// Use case for picking a custom folder
class PickCustomFolderUseCase {
  final GalleryRepository _repository;

  PickCustomFolderUseCase(this._repository);

  /// Executes the use case
  Future<String?> call() async {
    return _repository.pickCustomFolder();
  }
}