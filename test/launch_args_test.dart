import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:omni_prism/core/utils/launch_args.dart';

void main() {
  late Directory dir;
  late File image;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('omni_prism_args');
    image = File(p.join(dir.path, 'my photo.png'))..writeAsBytesSync([1, 2, 3]);
  });

  tearDown(() => dir.delete(recursive: true));

  test('resolves a plain absolute path', () async {
    final file = await resolveLaunchFile([image.path]);
    expect(file?.workingPath, image.path);
    expect(file?.size, 3);
  });

  test('resolves a file:// URI with escaped characters', () async {
    final file = await resolveLaunchFile([Uri.file(image.path).toString()]);
    expect(file?.workingPath, image.path);
  });

  test('resolves a relative path to an absolute one', () async {
    final previous = Directory.current;
    Directory.current = dir;
    addTearDown(() => Directory.current = previous);

    final file = await resolveLaunchFile(['my photo.png']);
    expect(p.isAbsolute(file!.workingPath), isTrue);
    expect(p.basename(file.workingPath), 'my photo.png');
  });

  test('skips flags and missing files', () async {
    final file = await resolveLaunchFile(['--verbose', '/no/such.png', image.path]);
    expect(file?.workingPath, image.path);
  });

  test('returns null with no usable argument', () async {
    expect(await resolveLaunchFile([]), isNull);
    expect(await resolveLaunchFile(['/no/such.png']), isNull);
  });
}
