import 'dart:io';
import 'package:share_plus/share_plus.dart';

/// Use case for sharing an image
class ShareImageUseCase {
  /// Shares an image file
  Future<void> call(String path, {String? text}) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception('File not found: $path');
    }

    final xFile = XFile(path);
    await Share.shareXFiles([xFile], text: text ?? 'Share image via -');
  }
}