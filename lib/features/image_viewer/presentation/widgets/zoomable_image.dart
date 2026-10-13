import 'package:flutter/material.dart';
import 'package:omni_prism/core/config/constants.dart';
import 'package:omni_prism/core/widgets/file_image.dart';

/// A single image with pinch/scroll-wheel zoom, pan and double-tap zoom
class ZoomableImage extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onTap;

  /// Called when the image goes from fitted to zoomed in, and back
  final ValueChanged<bool>? onZoomChanged;

  const ZoomableImage({
    super.key,
    required this.imagePath,
    this.onTap,
    this.onZoomChanged,
  });

  @override
  State<ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<ZoomableImage> {
  final TransformationController _transformationController =
      TransformationController();
  Offset _doubleTapPosition = Offset.zero;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformationController
      ..removeListener(_onTransformChanged)
      ..dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final zoomed = _transformationController.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed != _isZoomed) {
      _isZoomed = zoomed;
      widget.onZoomChanged?.call(zoomed);
    }
  }

  void _handleDoubleTap() {
    if (_isZoomed) {
      _transformationController.value = Matrix4.identity();
      return;
    }
    const scale = AppConstants.doubleTapZoomFactor;
    final position = _doubleTapPosition;
    _transformationController.value = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(
        -position.dx * (scale - 1),
        -position.dy * (scale - 1),
        0,
      );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTapDown: (details) => _doubleTapPosition = details.localPosition,
      onDoubleTap: _handleDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 10.0,
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: FileImageView(
              path: widget.imagePath,
              fit: BoxFit.contain,
              placeholderSize: 120,
            ),
          ),
        ),
      ),
    );
  }
}
