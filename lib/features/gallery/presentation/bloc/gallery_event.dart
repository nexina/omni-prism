/// Events for GalleryBloc
sealed class GalleryEvent {
  const GalleryEvent();
}

/// Scan the given folders, or the user's saved folders if null.
/// Nothing is scanned when no folder has been added.
class LoadGallery extends GalleryEvent {
  final List<String>? folders;

  const LoadGallery({this.folders});
}

/// Pick a folder and add it to the gallery
class PickCustomFolder extends GalleryEvent {
  const PickCustomFolder();
}

/// Remove a folder (and its images) from the gallery
class RemoveFolder extends GalleryEvent {
  final String folderPath;

  const RemoveFolder(this.folderPath);
}

/// Select an image to open in viewer
class SelectImage extends GalleryEvent {
  final int index;

  const SelectImage(this.index);
}

/// Drop images whose files were deleted (e.g. from the viewer)
class PruneMissingImages extends GalleryEvent {
  const PruneMissingImages();
}

/// Rescan the added folders
class RefreshGallery extends GalleryEvent {
  const RefreshGallery();
}
