import 'package:path/path.dart' as p;
import 'package:omni_prism/features/gallery/domain/repositories/gallery_repository.dart';

/// Use case for the list of folders the user added to the gallery
class ManageGalleryFoldersUseCase {
  final GalleryRepository _repository;

  ManageGalleryFoldersUseCase(this._repository);

  /// The saved folders
  List<String> getFolders() => _repository.getSavedFolders();

  /// Adds [folder] to [folders] and saves the result. A folder already
  /// covered by an added parent is ignored; added subfolders of [folder]
  /// are replaced by it, since scans include subfolders.
  Future<List<String>> addFolder(List<String> folders, String folder) async {
    final normalized = p.normalize(folder);
    if (folders.any((f) => p.equals(f, normalized) || p.isWithin(f, normalized))) {
      return folders;
    }
    final updated = [
      ...folders.where((f) => !p.isWithin(normalized, f)),
      normalized,
    ];
    await _repository.saveFolders(updated);
    return updated;
  }

  /// Removes [folder] from [folders] and saves the result
  Future<List<String>> removeFolder(List<String> folders, String folder) async {
    final updated = folders.where((f) => !p.equals(f, folder)).toList();
    await _repository.saveFolders(updated);
    return updated;
  }
}
