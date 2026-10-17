/// Base class for image viewer events
sealed class ImageViewerEvent {
  const ImageViewerEvent();
}

/// Load images from a folder
class LoadImages extends ImageViewerEvent {
  final String folderPath;
  final int initialIndex;

  /// Path of the image to open first; takes precedence over [initialIndex]
  final String? initialPath;

  const LoadImages({
    required this.folderPath,
    this.initialIndex = 0,
    this.initialPath,
  });
}

/// Navigate to next image
class NavigateNext extends ImageViewerEvent {
  const NavigateNext();
}

/// Navigate to previous image
class NavigatePrev extends ImageViewerEvent {
  const NavigatePrev();
}

/// Go to a specific image index
class GoToIndex extends ImageViewerEvent {
  final int index;

  const GoToIndex(this.index);
}

/// Delete the current image
class DeleteCurrent extends ImageViewerEvent {
  const DeleteCurrent();
}

/// Share the current image
class ShareCurrent extends ImageViewerEvent {
  const ShareCurrent();
}

/// Toggle fullscreen mode
class ToggleFullscreen extends ImageViewerEvent {
  const ToggleFullscreen();
}

/// Enter or leave fullscreen mode
class SetFullscreen extends ImageViewerEvent {
  final bool fullscreen;

  const SetFullscreen(this.fullscreen);
}

/// Toggle UI visibility
class ToggleVisibility extends ImageViewerEvent {
  const ToggleVisibility();
}

/// Set folder path (for CLI args)
class SetFolderPath extends ImageViewerEvent {
  final String folderPath;

  const SetFolderPath(this.folderPath);
}