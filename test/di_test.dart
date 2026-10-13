import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omni_prism/core/di/injection_container.dart';
import 'package:omni_prism/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:omni_prism/features/image_viewer/presentation/bloc/image_viewer_bloc.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await init();
  });

  tearDown(reset);

  test('viewer and gallery blocs resolve from the container', () {
    expect(getIt<ImageViewerBloc>(), isA<ImageViewerBloc>());
    expect(getIt<GalleryBloc>(), isA<GalleryBloc>());
  });
}
