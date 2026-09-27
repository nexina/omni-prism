import 'package:path/path.dart' as p;

/// Path utility functions for file path manipulation
class PathUtils {
  PathUtils._();

  /// Extracts the file name from a path
  static String getFileName(String path) {
    return p.basename(path);
  }

  /// Extracts the file extension (without the leading dot) from a path
  static String getExtension(String path) {
    return p.extension(path).replaceFirst('.', '').toLowerCase();
  }

  /// Extracts the directory path without the file name
  static String getDirectoryPath(String path) {
    return p.dirname(path);
  }

  /// Gets the parent folder path from a file path
  /// Handles both Windows (backslash) and Unix (forward slash) separators
  static String getParentFolderPath(String path) {
    final normalizedPath = path.replaceAll('\\', '/');
    final parts = normalizedPath.split('/');
    if (parts.length <= 1) return '';
    return parts.sublist(0, parts.length - 1).join('/');
  }

  /// Joins path segments using the platform-appropriate separator
  static String join(String part1, String part2) {
    return p.join(part1, part2);
  }

  /// Normalizes a path (resolves ., .., and redundant separators)
  static String normalize(String path) {
    return p.normalize(path);
  }

  /// Checks if a path is absolute
  static bool isAbsolute(String path) {
    return p.isAbsolute(path);
  }

  /// Gets the relative path from [from] to [to]
  static String relative(String to, {String? from}) {
    return p.relative(to, from: from);
  }
}