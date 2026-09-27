import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omni_prism/core/widgets/error_image.dart';

/// A widget that displays a single image with zoom and pan capabilities
class ImageItem extends StatefulWidget {
  final String imagePath;
  final VoidCallback onDoubleTap;
  final VoidCallback onTap;

  const ImageItem({
    super.key,
    required this.imagePath,
    required this.onDoubleTap,
    required this.onTap,
  });

  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  bool _isImage = false;
  bool _isZoomed = false;
  final TransformationController _transformationController = TransformationController();
  static const double _minScale = 0.1;
  static const double _maxScale = 4.0;
  static const double _minScaleFactor = 0.1;
  static const double _doubleTapZoomFactor = 3.0;

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  void _scaleImage(double scaleFactor, Offset localPosition) {
    final currentScale = _transformationController.value.getMaxScaleOnAxis();
    double newScale = currentScale * scaleFactor;
    newScale = newScale < _minScaleFactor ? _minScaleFactor : newScale;

    final scaleAdjustmentFactor = newScale / currentScale;

    final zoomMatrix = Matrix4.identity()
      ..translate(localPosition.dx, localPosition.dy)
      ..scale(scaleAdjustmentFactor)
      ..translate(-localPosition.dx, -localPosition.dy);

    final newValue = _transformationController.value.multiplied(zoomMatrix);

    if (newValue.determinant() != 0.0) {
      _transformationController.value = newValue;
      _isZoomed = true;
    }
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_isImage) {
      if (_isZoomed) {
        _transformationController.value = Matrix4.identity();
        _isZoomed = false;
      } else {
        _scaleImage(_doubleTapZoomFactor, details.localPosition);
      }
    } else {
      widget.onDoubleTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.onTap,
          onDoubleTapDown: _handleDoubleTap,
          child: InteractiveViewer(
            boundaryMargin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width / 2,
              vertical: MediaQuery.of(context).size.height / 2,
            ),
            minScale: _minScale,
            maxScale: _maxScale,
            scaleFactor: 0.01,
            transformationController: _transformationController,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 90.0),
              child: FittedBox(
                fit: BoxFit.contain,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isImage = true),
                  onExit: (_) => setState(() => _isImage = false),
                  cursor: SystemMouseCursors.move,
                  child: Image.file(
                    File(widget.imagePath),
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return const SquareErrorImage(
                        errorMessage: 'Error loading image',
                        size: 200,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}