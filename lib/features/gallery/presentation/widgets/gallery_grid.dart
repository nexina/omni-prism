import 'package:flutter/material.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/widgets/file_image.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Callback for when a gallery image is tapped
typedef OnImageTap = void Function(int index);

/// A responsive grid of gallery thumbnails
class GalleryGrid extends StatelessWidget {
  final List<ImageItem> images;
  final OnImageTap onImageTap;
  final double maxTileExtent;
  final double spacing;

  const GalleryGrid({
    super.key,
    required this.images,
    required this.onImageTap,
    this.maxTileExtent = 180,
    this.spacing = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    final cacheWidth =
        (maxTileExtent * MediaQuery.of(context).devicePixelRatio).round();

    return Theme(
      data: Theme.of(context).copyWith(
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(Colors.white),
          trackColor: WidgetStateProperty.all(Colors.white24),
          trackBorderColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      child: GridView.builder(
        padding: EdgeInsets.all(spacing),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxTileExtent,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: images.length,
        itemBuilder: (context, index) {
          return _GalleryGridItem(
            imageItem: images[index],
            cacheWidth: cacheWidth,
            onTap: () => onImageTap(index),
          );
        },
      ),
    );
  }
}

/// Individual gallery grid item with a hover highlight and name caption
class _GalleryGridItem extends StatefulWidget {
  final ImageItem imageItem;
  final int cacheWidth;
  final VoidCallback onTap;

  const _GalleryGridItem({
    required this.imageItem,
    required this.cacheWidth,
    required this.onTap,
  });

  @override
  State<_GalleryGridItem> createState() => _GalleryGridItemState();
}

class _GalleryGridItemState extends State<_GalleryGridItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: AppConstants.hoverAnimationDuration,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(23, 255, 255, 255),
            border: Border.all(
              color: _isHovering ? Colors.white : Colors.white24,
              width: _isHovering ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Stack(
              fit: StackFit.expand,
              children: [
                FileImageView(
                  path: widget.imageItem.path,
                  fit: BoxFit.cover,
                  cacheWidth: widget.cacheWidth,
                  placeholderSize: 48,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedOpacity(
                    opacity: _isHovering ? 1 : 0,
                    duration: const Duration(
                      milliseconds: AppConstants.hoverAnimationDuration,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      color: Colors.black.withValues(alpha: 0.6),
                      child: Text(
                        widget.imageItem.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: AppConstants.fontFamily,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty state widget for gallery
class GalleryEmptyState extends StatelessWidget {
  final String message;
  final VoidCallback? onPickFolder;

  const GalleryEmptyState({
    super.key,
    required this.message,
    this.onPickFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 72,
              color: Colors.white54,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (onPickFolder != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onPickFolder,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                icon: const Icon(Icons.folder_open),
                label: const Text('Add Folder'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading state widget for gallery
class GalleryLoadingState extends StatelessWidget {
  const GalleryLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }
}

/// Error state widget for gallery
class GalleryErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const GalleryErrorState({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading gallery',
              style: TextStyle(color: Colors.red[300], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
