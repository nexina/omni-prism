/// Events for GalleryBloc
sealed class GalleryEvent {
  const GalleryEvent();
}

/// Load gallery images from a folder (or default if null)
class LoadGallery extends GalleryEvent {
  final String? folderPath;

  const LoadGallery({this.folderPath});
}

/// Pick a custom folder
class PickCustomFolder extends GalleryEvent {
  const PickCustomFolder();
}

/// Select an image to open in viewer
class SelectImage extends GalleryEvent {
  final int index;

  const SelectImage(this.index);
}

/// Refresh the gallery
class RefreshGallery extends GalleryEvent {
  const RefreshGallery();
}