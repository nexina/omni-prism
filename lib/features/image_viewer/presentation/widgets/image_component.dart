import 'package:flutter/material.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart' as model;
import 'package:omni_prism/features/image_viewer/presentation/widgets/image_item.dart';
import 'package:omni_prism/features/image_viewer/presentation/widgets/image_overview.dart';

/// A widget that displays a paginated list of images with lazy loading
class ImageComponent extends StatefulWidget {
  final List<model.ImageItem> imageList;
  final int initialIndex;
  final ValueChanged<model.ImageItem> onImageChanged;
  final VoidCallback onNextImage;
  final VoidCallback onPrevImage;
  final VoidCallback onDoubleTap;

  const ImageComponent({
    super.key,
    required this.imageList,
    required this.initialIndex,
    required this.onImageChanged,
    required this.onNextImage,
    required this.onPrevImage,
    required this.onDoubleTap,
  });

  @override
  State<ImageComponent> createState() => _ImageComponentState();
}

class _ImageComponentState extends State<ImageComponent> {
  late PageController _pageController;
  late ScrollController _scrollController;
  List<model.ImageItem> _cachedImages = [];
  int _cacheStartIndex = 0;
  int _cacheEndIndex = 0;
  int _currentCacheIndex = 0;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _scrollController = ScrollController();
    _loadCache(widget.initialIndex);
    _updateImage(widget.initialIndex);
  }

  @override
  void didUpdateWidget(covariant ImageComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageList != widget.imageList) {
      _loadCache(widget.initialIndex);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Loads a cache of images around the given index
  void _loadCache(int index) {
    final cacheSize = AppConstants.imageCacheSize;
    _cacheStartIndex = (index ~/ cacheSize) * cacheSize;
    _cacheEndIndex = (_cacheStartIndex + cacheSize - 1) < widget.imageList.length
        ? _cacheStartIndex + cacheSize - 1
        : widget.imageList.length - 1;

    _cachedImages = widget.imageList.sublist(_cacheStartIndex, _cacheEndIndex + 1);
    _currentCacheIndex = index - _cacheStartIndex;
  }

  /// Updates the current image and notifies listener
  void _updateImage(int index) {
    if (index >= 0 && index < _cachedImages.length) {
      widget.onImageChanged(_cachedImages[index]);
    }
  }

  /// Animates to a position in both page view and overview
  Future<void> _animateToPosition(int index) async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    if (_pageController.hasClients) {
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: AppConstants.pageTransitionDuration),
        curve: Curves.easeInOut,
      );
    }

    if (_scrollController.hasClients) {
      final currentImageIndex = _cacheStartIndex + index;
      await _scrollController.animateTo(
        currentImageIndex * 60.0,
        duration: const Duration(milliseconds: AppConstants.scrollAnimationDuration),
        curve: Curves.easeInOut,
      );
    }

    _isTransitioning = false;
  }

  /// Handles page change
  void _onPageChanged(int index) {
    if (_isTransitioning) return;

    // Check if we need to load next cache
    if (index >= _cachedImages.length - 1 && _cacheEndIndex < widget.imageList.length - 1) {
      _loadCache(_cacheEndIndex + 1);
      _currentCacheIndex = 0;
      _updateImage(0);
      _animateToPosition(0);
    } else if (index < 0 && _cacheStartIndex > 0) {
      _loadCache(_cacheStartIndex - 1);
      _currentCacheIndex = _cachedImages.length - 1;
      _updateImage(_currentCacheIndex);
      _animateToPosition(_currentCacheIndex);
    } else {
      _currentCacheIndex = index;
      _updateImage(index);
    }
  }

  /// Goes to next image
  void _handleNextImage() {
    if (_isTransitioning) return;
    if (_currentCacheIndex < _cachedImages.length - 1) {
      _currentCacheIndex++;
      _pageController.animateToPage(
        _currentCacheIndex,
        duration: const Duration(milliseconds: AppConstants.pageTransitionDuration),
        curve: Curves.easeInOut,
      );
      _updateImage(_currentCacheIndex);
    } else if (_cacheEndIndex < widget.imageList.length - 1) {
      _loadCache(_cacheEndIndex + 1);
      _currentCacheIndex = 0;
      _pageController.jumpToPage(0);
      _updateImage(0);
    }
    widget.onNextImage();
  }

  /// Goes to previous image
  void _handlePrevImage() {
    if (_isTransitioning) return;
    if (_currentCacheIndex > 0) {
      _currentCacheIndex--;
      _pageController.animateToPage(
        _currentCacheIndex,
        duration: const Duration(milliseconds: AppConstants.pageTransitionDuration),
        curve: Curves.easeInOut,
      );
      _updateImage(_currentCacheIndex);
    } else if (_cacheStartIndex > 0) {
      _loadCache(_cacheStartIndex - 1);
      _currentCacheIndex = _cachedImages.length - 1;
      _pageController.jumpToPage(_currentCacheIndex);
      _updateImage(_currentCacheIndex);
    }
    widget.onPrevImage();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main image viewer
        Expanded(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return ImageItem(
                    imagePath: _cachedImages[index].path,
                    onDoubleTap: widget.onDoubleTap,
                    onTap: () {
                      // Single tap - could be used for visibility toggle
                    },
                  );
                },
                itemCount: _cachedImages.length,
              ),
              // Navigation buttons
              if (widget.imageList.length > 1) ...[
                _NavigationButton(
                  icon: Icons.arrow_back,
                  alignment: Alignment.centerLeft,
                  onPressed: _handlePrevImage,
                ),
                _NavigationButton(
                  icon: Icons.arrow_forward,
                  alignment: Alignment.centerRight,
                  onPressed: _handleNextImage,
                ),
              ],
            ],
          ),
        ),
        // Image overview/thumbnails
        ImageOverview(
          imagePaths: widget.imageList.map((e) => e.path).toList(),
          currentIndex: _cacheStartIndex + _currentCacheIndex,
          scrollController: _scrollController,
          onImageTap: (index) {
            _loadCache(index);
            _currentCacheIndex = index - _cacheStartIndex;
            _pageController.jumpToPage(_currentCacheIndex);
            _updateImage(_currentCacheIndex);
          },
        ),
      ],
    );
  }
}

/// Navigation button for image component
class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final Alignment alignment;
  final VoidCallback onPressed;

  const _NavigationButton({
    required this.icon,
    required this.alignment,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: AppConstants.navButtonWidth,
        height: AppConstants.navButtonHeight,
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }
}