import 'dart:io';
import 'package:flutter/material.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/widgets/error_image.dart';

/// Callback for when an overview image is tapped
typedef OnImageTap = void Function(int index);

/// A widget that displays a horizontal scrollable list of image thumbnails
class ImageOverview extends StatefulWidget {
  final List<String> imagePaths;
  final int currentIndex;
  final ScrollController scrollController;
  final OnImageTap onImageTap;

  const ImageOverview({
    super.key,
    required this.imagePaths,
    required this.currentIndex,
    required this.scrollController,
    required this.onImageTap,
  });

  @override
  State<ImageOverview> createState() => _ImageOverviewState();
}

class _ImageOverviewState extends State<ImageOverview> {
  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        return SizedBox(
          height: 70,
          child: ListView.builder(
            controller: widget.scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: widget.imagePaths.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: _getItemPadding(index, screenWidth),
                child: _ImageOverviewItem(
                  imagePath: widget.imagePaths[index],
                  isSelected: index == widget.currentIndex,
                  onTap: () => widget.onImageTap(index),
                ),
              );
            },
          ),
        );
      },
    );
  }

  /// Calculates padding for first and last items to center them
  EdgeInsets _getItemPadding(int index, double screenWidth) {
    if (index == 0) {
      return EdgeInsets.only(left: (screenWidth / 2) - (AppConstants.overviewItemWidth / 2));
    } else if (index == widget.imagePaths.length - 1) {
      return EdgeInsets.only(right: (screenWidth / 2) - (AppConstants.overviewItemWidth / 2));
    } else {
      return const EdgeInsets.symmetric(horizontal: 5);
    }
  }
}

/// Individual thumbnail item in the overview
class _ImageOverviewItem extends StatefulWidget {
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const _ImageOverviewItem({
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ImageOverviewItem> createState() => _ImageOverviewItemState();
}

class _ImageOverviewItemState extends State<_ImageOverviewItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  static const double _initOpacity = 0.6;
  static const double _finalOpacity = 1.0;
  static const int _duration = 200;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: _duration),
      vsync: this,
    );
    _animation = Tween<double>(begin: _initOpacity, end: _finalOpacity).animate(_controller);

    // Start animation if selected
    if (widget.isSelected) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _ImageOverviewItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: widget.isSelected ? 1.0 : _animation.value,
              child: Container(
                width: AppConstants.overviewItemWidth,
                decoration: BoxDecoration(
                  border: widget.isSelected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    File(widget.imagePath),
                    width: AppConstants.overviewItemWidth,
                    height: AppConstants.overviewItemWidth,
                    cacheWidth: AppConstants.overviewItemWidth.toInt(),
                    cacheHeight: AppConstants.overviewItemWidth.toInt(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return SquareErrorImage(
                        errorMessage: 'NaN',
                        size: AppConstants.overviewItemWidth,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}