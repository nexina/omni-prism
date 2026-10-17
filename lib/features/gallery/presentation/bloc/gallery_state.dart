import 'package:omni_prism/features/gallery/domain/entities/gallery_section.dart';
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
  /// Images shown per page; more are shown as the user scrolls
  static const int pageSize = 120;

  final GalleryStatus status;
  final List<ImageItem> images;
  final List<String> folders;
  final GalleryGrouping grouping;

  /// The first [visibleCount] of [images], grouped by [grouping], in
  /// display order
  final List<GallerySection> sections;

  /// How many images are shown; grows a page at a time
  final int visibleCount;
  final bool isLoading;
  final String? error;

  const GalleryState({
    required this.status,
    this.images = const [],
    this.folders = const [],
    this.grouping = GalleryGrouping.folder,
    this.sections = const [],
    this.visibleCount = pageSize,
    this.isLoading = false,
    this.error,
  });

  /// Initial state
  const GalleryState.initial()
      : status = GalleryStatus.initial,
        images = const [],
        folders = const [],
        grouping = GalleryGrouping.folder,
        sections = const [],
        visibleCount = pageSize,
        isLoading = false,
        error = null;

  /// Creates a copy with updated fields
  GalleryState copyWith({
    GalleryStatus? status,
    List<ImageItem>? images,
    List<String>? folders,
    GalleryGrouping? grouping,
    List<GallerySection>? sections,
    int? visibleCount,
    bool? isLoading,
    String? error,
  }) {
    return GalleryState(
      status: status ?? this.status,
      images: images ?? this.images,
      folders: folders ?? this.folders,
      grouping: grouping ?? this.grouping,
      sections: sections ?? this.sections,
      visibleCount: visibleCount ?? this.visibleCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  /// Whether the user has added any folder
  bool get hasFolders => folders.isNotEmpty;

  /// Whether the gallery has images
  bool get hasImages => images.isNotEmpty;

  /// Whether more images exist than are shown
  bool get hasMore => images.length > visibleCount;

  /// Number of images in gallery
  int get imageCount => images.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GalleryState &&
        other.status == status &&
        other.images == images &&
        other.folders == folders &&
        other.grouping == grouping &&
        other.sections == sections &&
        other.visibleCount == visibleCount &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(
        status,
        images,
        folders,
        grouping,
        sections,
        visibleCount,
        isLoading,
        error,
      );

  @override
  String toString() => 'GalleryState(status: $status, folders: ${folders.length}, '
      'grouping: ${grouping.name}, '
      'images: ${images.length}, isLoading: $isLoading, error: $error)';
}