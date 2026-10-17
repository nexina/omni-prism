import 'package:flutter/material.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/utils/format_utils.dart';
import 'package:omni_prism/core/widgets/file_image.dart';
import 'package:omni_prism/features/gallery/domain/entities/gallery_section.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// Callback for when a gallery image is tapped
typedef OnImageTap = void Function(ImageItem image);

/// A responsive grid of gallery thumbnails, split into titled sections.
///
/// Shows one page at a time: [onLoadMore] is called when the user scrolls
/// near the end (or the page doesn't fill the view) while [hasMore].
class GalleryGrid extends StatefulWidget {
  final List<GallerySection> sections;
  final OnImageTap onImageTap;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final double maxTileExtent;
  final double spacing;

  const GalleryGrid({
    super.key,
    required this.sections,
    required this.onImageTap,
    this.hasMore = false,
    this.onLoadMore,
    this.maxTileExtent = 180,
    this.spacing = 10.0,
  });

  @override
  State<GalleryGrid> createState() => _GalleryGridState();
}

class _GalleryGridState extends State<GalleryGrid> {
  final _scrollController = ScrollController();

  /// Set once a page is requested, cleared when the next one arrives
  bool _loadRequested = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_maybeLoadMore);
    _checkAfterLayout();
  }

  @override
  void didUpdateWidget(GalleryGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sections != oldWidget.sections) _loadRequested = false;
    _checkAfterLayout();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// A page may not fill a large window, leaving nothing to scroll
  void _checkAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeLoadMore();
    });
  }

  void _maybeLoadMore() {
    if (_loadRequested || !widget.hasMore || !_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    if (position.extentAfter < widget.maxTileExtent * 2) {
      _loadRequested = true;
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sections = widget.sections;
    final maxTileExtent = widget.maxTileExtent;
    final spacing = widget.spacing;
    final onImageTap = widget.onImageTap;
    if (sections.isEmpty) {
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
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          for (final section in sections) ...[
            SliverToBoxAdapter(
              child: _GallerySectionHeader(
                section: section,
                padding: EdgeInsets.fromLTRB(spacing + 2, spacing + 6, spacing, 2),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(spacing),
              sliver: SliverGrid.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: maxTileExtent,
                  crossAxisSpacing: spacing,
                  mainAxisSpacing: spacing,
                ),
                itemCount: section.images.length,
                itemBuilder: (context, index) {
                  final image = section.images[index];
                  return _GalleryGridItem(
                    imageItem: image,
                    cacheWidth: cacheWidth,
                    onTap: () => onImageTap(image),
                  );
                },
              ),
            ),
          ],
          if (widget.hasMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Section title with its image count
class _GallerySectionHeader extends StatelessWidget {
  final GallerySection section;
  final EdgeInsets padding;

  const _GallerySectionHeader({required this.section, required this.padding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: Text(
              section.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: AppConstants.fontFamily,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            FormatUtils.formatNumber(section.totalCount),
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
              fontFamily: AppConstants.fontFamily,
            ),
          ),
        ],
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
