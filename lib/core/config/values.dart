import 'package:flutter/services.dart';
import 'package:omni_prism/core/config/stored.dart';

class Values {
  static Uint8List? _cachedBackgroundImage;

  static Uint8List? get cachedBackgroundImage => _cachedBackgroundImage;

  static Future<Uint8List> get backgroundImage async {
    if (_cachedBackgroundImage != null) return _cachedBackgroundImage!;
    final ByteData data = await rootBundle.load(Stored.backgroundImagePath);
    _cachedBackgroundImage = data.buffer.asUint8List();
    return _cachedBackgroundImage!;
  }
}
