import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Status of the image viewer
enum ImageViewerStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// State for the image viewer
class ImageViewerState {
  final ImageViewerStatus status;
  final String folderPath;
  final List<ImageItem> images;
  final int currentIndex;
  final ImageItem? currentImage;
  final bool isFullscreen;
  final bool isVisible;
  final String? error;

  const ImageViewerState({
    required this.status,
    this.folderPath = '',
    this.images = const [],
    this.currentIndex = -1,
    this.currentImage,
    this.isFullscreen = false,
    this.isVisible = true,
    this.error,
  });

  /// Initial state
  const ImageViewerState.initial()
      : status = ImageViewerStatus.initial,
        folderPath = '',
        images = const [],
        currentIndex = -1,
        currentImage = null,
        isFullscreen = false,
        isVisible = true,
        error = null;

  /// Creates a copy with updated fields
  ImageViewerState copyWith({
    ImageViewerStatus? status,
    String? folderPath,
    List<ImageItem>? images,
    int? currentIndex,
    ImageItem? currentImage,
    bool? isFullscreen,
    bool? isVisible,
    String? error,
  }) {
    return ImageViewerState(
      status: status ?? this.status,
      folderPath: folderPath ?? this.folderPath,
      images: images ?? this.images,
      currentIndex: currentIndex ?? this.currentIndex,
      currentImage: currentImage ?? this.currentImage,
      isFullscreen: isFullscreen ?? this.isFullscreen,
      isVisible: isVisible ?? this.isVisible,
      error: error ?? this.error,
    );
  }

  /// Whether there is a next image
  bool get hasNext => currentIndex < images.length - 1;

  /// Whether there is a previous image
  bool get hasPrev => currentIndex > 0;

  /// Current position as 1-based index for display
  int get displayIndex => currentIndex + 1;

  /// Total number of images
  int get totalImages => images.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageViewerState &&
        other.status == status &&
        other.folderPath == folderPath &&
        other.images == images &&
        other.currentIndex == currentIndex &&
        other.currentImage == currentImage &&
        other.isFullscreen == isFullscreen &&
        other.isVisible == isVisible &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        status,
        folderPath,
        images,
        currentIndex,
        currentImage,
        isFullscreen,
        isVisible,
        error,
      );

  @override
  String toString() => 'ImageViewerState(status: $status, folderPath: $folderPath, '
      'images: ${images.length}, currentIndex: $currentIndex, '
      'isFullscreen: $isFullscreen, isVisible: $isVisible, error: $error)';
}