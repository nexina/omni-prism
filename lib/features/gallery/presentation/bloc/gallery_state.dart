import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Status of the gallery
enum GalleryStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// State for the gallery
class GalleryState {
  final GalleryStatus status;
  final List<ImageItem> images;
  final String folderPath;
  final bool isLoading;
  final String? error;

  const GalleryState({
    required this.status,
    this.images = const [],
    this.folderPath = '',
    this.isLoading = false,
    this.error,
  });

  /// Initial state
  const GalleryState.initial()
      : status = GalleryStatus.initial,
        images = const [],
        folderPath = '',
        isLoading = false,
        error = null;

  /// Creates a copy with updated fields
  GalleryState copyWith({
    GalleryStatus? status,
    List<ImageItem>? images,
    String? folderPath,
    bool? isLoading,
    String? error,
  }) {
    return GalleryState(
      status: status ?? this.status,
      images: images ?? this.images,
      folderPath: folderPath ?? this.folderPath,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Whether the gallery has images
  bool get hasImages => images.isNotEmpty;

  /// Number of images in gallery
  int get imageCount => images.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GalleryState &&
        other.status == status &&
        other.images == images &&
        other.folderPath == folderPath &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        status,
        images,
        folderPath,
        isLoading,
        error,
      );

  @override
  String toString() => 'GalleryState(status: $status, folderPath: $folderPath, '
      'images: ${images.length}, isLoading: $isLoading, error: $error)';
}