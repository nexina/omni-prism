import 'package:flutter/material.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/widgets/file_image.dart';

/// Callback for when an overview image is tapped
typedef OnImageTap = void Function(int index);

/// A horizontal strip of thumbnails that keeps the current image centered
class ImageOverview extends StatefulWidget {
  final List<String> imagePaths;
  final int currentIndex;
  final OnImageTap onImageTap;

  const ImageOverview({
    super.key,
    required this.imagePaths,
    required this.currentIndex,
    required this.onImageTap,
  });

  static const double itemSize = 56.0;
  static const double itemSpacing = 8.0;
  static const double itemExtent = itemSize + itemSpacing;

  @override
  State<ImageOverview> createState() => _ImageOverviewState();
}

class _ImageOverviewState extends State<ImageOverview> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent(false));
  }

  @override
  void didUpdateWidget(covariant ImageOverview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _scrollToCurrent(true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// List padding lets every item be centered, so the offset is just index * extent
  void _scrollToCurrent(bool animate) {
    if (!mounted || !_scrollController.hasClients) return;
    final target = (widget.currentIndex * ImageOverview.itemExtent)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    if (animate) {
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: AppConstants.scrollAnimationDuration),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(target);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) return const SizedBox.shrink();

    final cacheWidth =
        (ImageOverview.itemSize * MediaQuery.of(context).devicePixelRatio).round();

    return SizedBox(
      height: ImageOverview.itemSize + 16,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sidePadding =
              (constraints.maxWidth - ImageOverview.itemExtent) / 2;
          return ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: sidePadding < 0 ? 0 : sidePadding,
              vertical: 8,
            ),
            itemExtent: ImageOverview.itemExtent,
            itemCount: widget.imagePaths.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: ImageOverview.itemSpacing / 2,
                ),
                child: _ImageOverviewItem(
                  imagePath: widget.imagePaths[index],
                  isSelected: index == widget.currentIndex,
                  cacheWidth: cacheWidth,
                  onTap: () => widget.onImageTap(index),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Individual thumbnail item in the overview
class _ImageOverviewItem extends StatefulWidget {
  final String imagePath;
  final bool isSelected;
  final int cacheWidth;
  final VoidCallback onTap;

  const _ImageOverviewItem({
    required this.imagePath,
    required this.isSelected,
    required this.cacheWidth,
    required this.onTap,
  });

  @override
  State<_ImageOverviewItem> createState() => _ImageOverviewItemState();
}

class _ImageOverviewItemState extends State<_ImageOverviewItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          opacity: widget.isSelected || _isHovering ? 1.0 : 0.6,
          duration: const Duration(
            milliseconds: AppConstants.hoverAnimationDuration,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(23, 255, 255, 255),
              border: Border.all(
                color: widget.isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: FileImageView(
                path: widget.imagePath,
                fit: BoxFit.cover,
                cacheWidth: widget.cacheWidth,
                placeholderSize: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
