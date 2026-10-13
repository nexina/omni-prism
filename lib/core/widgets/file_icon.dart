import 'package:flutter/material.dart';
import '../utils/file_type_utils.dart';

/// Generic file icon tinted by file type, with an extension badge.
/// Used as a placeholder for images Flutter cannot decode (RAW, PSD, ...).
class FileIcon extends StatelessWidget {
  final String filePath;
  final double size;

  const FileIcon({super.key, required this.filePath, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final extension = FileTypeUtils.getExtension(filePath);
    final color = FileTypeUtils.getColorFromExtension(extension);
    final label = extension.length > 5 ? extension.substring(0, 5) : extension;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color.fromARGB(23, 255, 255, 255),
        borderRadius: BorderRadius.circular(size / 5),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(Icons.insert_drive_file, color: color, size: size * 0.6),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: size / 5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
