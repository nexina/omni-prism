import 'package:flutter/material.dart';
import '../config/file_types.dart';

/// File type utility functions for determining file types and associated colors
class FileTypeUtils {
  FileTypeUtils._();

  /// Gets the file type category from a file path
  static String getFileTypeFromPath(String path) {
    final extension = getExtension(path);
    return FileTypes.getFileType(extension);
  }

  /// Gets the file type category from an extension
  static String getFileType(String extension) {
    return FileTypes.getFileType(extension);
  }

  /// Gets the color associated with a file type from a file path
  static Color getColorFromPath(String path) {
    final extension = getExtension(path);
    return getColorFromExtension(extension);
  }

  /// Gets the color associated with a file type from an extension
  static Color getColorFromExtension(String extension) {
    final colorValue = FileTypes.getFileTypeColor(extension);
    return Color(colorValue);
  }

  /// Gets the extension from a file path (without leading dot)
  static String getExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '';
    return path.substring(lastDot + 1).toLowerCase();
  }

  /// Checks if a file is an image based on its path
  static bool isImageFile(String path) {
    final extension = getExtension(path);
    return FileTypes.isImage(extension);
  }

  /// Checks if a file is a video based on its path
  static bool isVideoFile(String path) {
    final extension = getExtension(path);
    return FileTypes.isVideo(extension);
  }

  /// Checks if a file is an audio based on its path
  static bool isAudioFile(String path) {
    final extension = getExtension(path);
    return FileTypes.isAudio(extension);
  }

  /// Checks if a file is a document based on its path
  static bool isDocumentFile(String path) {
    final extension = getExtension(path);
    return FileTypes.isDocument(extension);
  }

  /// Checks if a file is an archive based on its path
  static bool isArchiveFile(String path) {
    final extension = getExtension(path);
    return FileTypes.isArchive(extension);
  }

  /// Checks if a file is a text/code file based on its path
  static bool isTextFile(String path) {
    final extension = getExtension(path);
    return FileTypes.isText(extension);
  }

  /// Gets all supported image extensions with leading dot (for file pickers)
  static List<String> getSupportedImageExtensionsWithDot() {
    return FileTypes.images.map((e) => '.$e').toList();
  }

  /// Gets all supported extensions with leading dot (for file pickers)
  static List<String> getAllSupportedExtensionsWithDot() {
    return FileTypes.all.map((e) => '.$e').toList();
  }
}