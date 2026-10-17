import 'package:path/path.dart' as p;
import 'package:omni_prism/features/gallery/domain/repositories/gallery_repository.dart';

/// Use case for the list of folders the user added to the gallery
class ManageGalleryFoldersUseCase {
  final GalleryRepository _repository;

  ManageGalleryFoldersUseCase(this._repository);

  /// The saved folders. On first use these are the platform's image
  /// folders (e.g. DCIM on Android, Pictures on desktop), saved so that
  /// removing one sticks.
  Future<List<String>> getFolders() async {
    final saved = _repository.getSavedFolders();
    if (saved != null) return saved;

    final defaults = await _repository.getDefaultImageFolders();
    await _repository.saveFolders(defaults);
    return defaults;
  }

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
