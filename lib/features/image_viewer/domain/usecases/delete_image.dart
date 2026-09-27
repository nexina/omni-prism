import 'package:omni_prism/features/image_viewer/domain/repositories/image_repository.dart';

/// Use case for deleting an image
class DeleteImageUseCase {
  final ImageRepository _repository;

  DeleteImageUseCase(this._repository);

  /// Executes the use case
  Future<bool> call(String path) async {
    return _repository.deleteImage(path);
  }
}