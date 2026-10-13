import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omni_prism/core/di/injection_container.dart';
import 'package:omni_prism/core/router/app_router.dart';
import 'package:omni_prism/core/utils/launch_args.dart';
import 'package:omni_prism/features/image_viewer/presentation/pages/image_viewer_page.dart';
import 'package:omni_prism/omni_prism_app.dart';

// 1x1 transparent PNG
const _png = [
  137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, //
  0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 13, 73, 68, 65, 84,
  120, 156, 99, 0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78,
  68, 174, 66, 96, 130,
];

void main() {
  late Directory dir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await init();
    dir = await Directory.systemTemp.createTemp('omni_prism_launch');
    for (final name in ['a.png', 'b.png', 'c.png']) {
      File(p.join(dir.path, name)).writeAsBytesSync(_png);
    }
  });

  tearDown(() async {
    await reset();
    await dir.delete(recursive: true);
  });

  testWidgets('a file:// launch argument opens that image in the viewer',
      (tester) async {
    final arg = Uri.file(p.join(dir.path, 'b.png')).toString();

    // Same sequence as main(): resolve args, start app, navigate
    final launchFile = await tester.runAsync(() => resolveLaunchFile([arg]));
    expect(launchFile, isNotNull);

    await tester.pumpWidget(const OmniPrismApp());
    AppRouter.navigateToImageViewer(launchFile!);

    // Let the viewer bloc scan the folder (real file IO)
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
    }

    expect(find.byType(ImageViewerPage), findsOneWidget);
    expect(find.text('b.png'), findsOneWidget);
    expect(find.textContaining('2 / 3'), findsOneWidget);

    // Return to the gallery so the router is clean for other tests
    AppRouter.goBack();
    await tester.pump();
  });
}
