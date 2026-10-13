import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/file_type_utils.dart';
import 'file_icon.dart';

/// Renders an image file from disk, handling SVG separately and falling back
/// to a [FileIcon] for formats Flutter cannot decode.
class FileImageView extends StatelessWidget {
  final String path;
  final BoxFit fit;

  /// Decode width in physical pixels; set for thumbnails to save memory.
  final int? cacheWidth;
  final double placeholderSize;

  const FileImageView({
    super.key,
    required this.path,
    this.fit = BoxFit.contain,
    this.cacheWidth,
    this.placeholderSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    Widget placeholder(BuildContext context, Object error, StackTrace? stackTrace) {
      return Center(child: FileIcon(filePath: path, size: placeholderSize));
    }

    if (FileTypeUtils.getExtension(path) == 'svg') {
      return SvgPicture.file(File(path), fit: fit, errorBuilder: placeholder);
    }

    return Image.file(
      File(path),
      fit: fit,
      cacheWidth: cacheWidth,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      errorBuilder: placeholder,
    );
  }
}
