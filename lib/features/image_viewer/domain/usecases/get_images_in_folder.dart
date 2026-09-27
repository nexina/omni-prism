import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';
import 'package:omni_prism/features/image_viewer/domain/repositories/image_repository.dart';

/// Use case for getting all images in a folder
class GetImagesInFolderUseCase {
  final ImageRepository _repository;

  GetImagesInFolderUseCase(this._repository);

  /// Executes the use case
  Future<List<ImageItem>> call(String folderPath) async {
    return _repository.getImagesInFolder(folderPath);
  }
}