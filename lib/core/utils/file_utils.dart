import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';

/// File utility functions for file operations
class FileUtils {
  FileUtils._();

  /// Gets all files in a directory (non-recursive)
  static Future<List<FileSystemEntity>> getFilesInDirectory(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) return [];
    return directory.listSync();
  }

  /// Gets all files in a directory recursively
  static Future<List<FileSystemEntity>> getFilesRecursive(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) return [];
    return directory.listSync(recursive: true);
  }

  /// Checks if a file exists
  static Future<bool> fileExists(String path) async {
    final file = File(path);
    return file.exists();
  }

  /// Gets file size in bytes
  static Future<int> getFileSize(String path) async {
    final file = File(path);
    if (!await file.exists()) return 0;
    return await file.length();
  }

  /// Gets file modification time
  static Future<DateTime> getFileModifiedTime(String path) async {
    final file = File(path);
    if (!await file.exists()) return DateTime.fromMillisecondsSinceEpoch(0);
    return file.lastModifiedSync();
  }

  /// Formats bytes into human-readable string
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    double dBytes = bytes.toDouble();
    while (dBytes >= 1024 && i < suffixes.length - 1) {
      dBytes /= 1024;
      i++;
    }
    return '${dBytes.toStringAsFixed(2)} ${suffixes[i]}';
  }

  /// Formats duration into HH:MM:SS or MM:SS format
  static String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    return '${minutes}:${twoDigits(seconds)}';
  }

  /// Checks if a file is likely a text file by reading the first 1KB
  static Future<bool> isTextFile(String path) async {
    final file = File(path);
    if (!await file.exists()) return false;

    try {
      final bytes = await file.openRead(0, 1024).first;

      // Try to decode as UTF-8
      final text = utf8.decode(bytes, allowMalformed: true);

      // Heuristic: if too many null bytes or replacement chars → binary
      final nullCount = bytes.where((b) => b == 0).length;
      final ratio = nullCount / bytes.length;

      return ratio < 0.01 && text.trim().isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Deletes a file
  static Future<bool> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Reads a file as bytes
  static Future<Uint8List?> readFileAsBytes(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Reads a file as string
  static Future<String?> readFileAsString(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        return await file.readAsString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Writes bytes to a file
  static Future<bool> writeFileAsBytes(String path, Uint8List bytes) async {
    try {
      final file = File(path);
      await file.writeAsBytes(bytes);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Creates a directory if it doesn't exist
  static Future<void> createDirectoryIfNotExists(String path) async {
    final directory = Directory(path);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
  }

  /// Gets the temporary directory path
  static String getTemporaryDirectory() {
    return Directory.systemTemp.path;
  }

  /// Gets the application documents directory path
  static Future<String> getApplicationDocumentsDirectory() async {
    final directory = await Directory.current.path;
    return directory;
  }
}