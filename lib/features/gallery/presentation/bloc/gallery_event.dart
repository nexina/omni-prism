import 'package:omni_prism/features/gallery/domain/entities/gallery_section.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Events for GalleryBloc
sealed class GalleryEvent {
  const GalleryEvent();
}

/// Scan the given folders, or the user's saved folders if null (the
/// platform's image folders on first launch).
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
  final ImageItem image;

  const SelectImage(this.image);
}

/// Show the next page of images
class LoadMoreImages extends GalleryEvent {
  const LoadMoreImages();
}

/// Change how the gallery groups its images
class ChangeGrouping extends GalleryEvent {
  final GalleryGrouping grouping;

  const ChangeGrouping(this.grouping);
}

/// Drop images whose files were deleted (e.g. from the viewer)
class PruneMissingImages extends GalleryEvent {
  const PruneMissingImages();
}

/// Rescan the added folders
class RefreshGallery extends GalleryEvent {
  const RefreshGallery();
}
