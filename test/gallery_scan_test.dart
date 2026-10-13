import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omni_prism/features/gallery/data/datasources/local/gallery_local_datasource.dart';
import 'package:omni_prism/features/gallery/data/repositories/gallery_repository.dart';
import 'package:omni_prism/features/gallery/domain/usecases/manage_gallery_folders.dart';
import 'package:omni_prism/features/gallery/domain/usecases/pick_custom_folder.dart';
import 'package:omni_prism/features/gallery/domain/usecases/scan_gallery_images.dart';
import 'package:omni_prism/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:omni_prism/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:omni_prism/features/gallery/presentation/bloc/gallery_state.dart';

void main() {
  late Directory root;
  late SharedPreferences preferences;
  late GalleryLocalDataSourceImpl dataSource;

  void touch(String relative) {
    final file = File(p.join(root.path, relative));
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync([0]);
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    dataSource = GalleryLocalDataSourceImpl(preferences: preferences);
    root = Directory.systemTemp.createTempSync('omni_prism_scan');
    touch('b.png');
    touch('a.jpg');
    touch('notes.txt');
    touch('trip/day1/c.png');
    touch('trip/d.webp');
    touch('.cache/hidden.png');
  });

  tearDown(() => root.deleteSync(recursive: true));

  test('scans subfolders, skips hidden folders and non-images, root first', () async {
    final batches = await dataSource.scanImages(root.path).toList();
    final names = batches.expand((b) => b).map((e) => p.basename(e.path)).toList();

    expect(names, ['a.jpg', 'b.png', 'd.webp', 'c.png']);
    // The root folder's images arrive in their own first batch
    expect(batches.first.map((e) => p.basename(e.path)), ['a.jpg', 'b.png']);
  });

  test('a missing folder completes with no images', () async {
    final batches = await dataSource.scanImages(p.join(root.path, 'nope')).toList();
    expect(batches, isEmpty);
  });

  test('cancelling the subscription stops the scan', () async {
    final subscription = dataSource.scanImages(root.path).listen((_) {});
    await subscription.cancel();
  });

  test('findMissing reports deleted files', () async {
    final keep = p.join(root.path, 'a.jpg');
    final gone = p.join(root.path, 'gone.png');
    expect(await dataSource.findMissing([keep, gone]), {gone});
  });

  GalleryBloc createBloc() {
    final repository = GalleryRepositoryImpl(localDataSource: dataSource);
    return GalleryBloc(
      manageFolders: ManageGalleryFoldersUseCase(repository),
      scanGalleryImages: ScanGalleryImagesUseCase(repository),
      pickCustomFolder: PickCustomFolderUseCase(repository),
    );
  }

  Future<GalleryState> settled(GalleryBloc bloc) {
    return bloc.stream
        .firstWhere((s) => s.status != GalleryStatus.loading && !s.isLoading);
  }

  test('with no folders added nothing is scanned', () async {
    final bloc = createBloc()..add(const LoadGallery());
    final state = await settled(bloc);

    expect(state.status, GalleryStatus.empty);
    expect(state.hasFolders, isFalse);
    expect(state.images, isEmpty);
    await bloc.close();
  });

  test('bloc adds images while scanning and finishes not loading', () async {
    final bloc = createBloc();
    final states = <GalleryState>[];
    final sub = bloc.stream.listen(states.add);

    bloc.add(LoadGallery(folders: [root.path]));
    await settled(bloc);

    expect(states.first.status, GalleryStatus.loading);
    expect(states.where((s) => s.isLoading && s.hasImages), isNotEmpty);
    expect(bloc.state.imageCount, 4);
    expect(bloc.state.status, GalleryStatus.loaded);

    await sub.cancel();
    await bloc.close();
  });

  test('saved folders are scanned on load and removing one drops its images',
      () async {
    final trip = p.join(root.path, 'trip');
    await preferences.setStringList('gallery_folders', [trip]);

    final bloc = createBloc()..add(const LoadGallery());
    var state = await settled(bloc);
    expect(state.folders, [trip]);
    expect(state.images.map((e) => p.basename(e.path)), ['d.webp', 'c.png']);

    bloc.add(RemoveFolder(trip));
    state = await bloc.stream.firstWhere((s) => !s.hasFolders);
    expect(state.images, isEmpty);
    expect(preferences.getStringList('gallery_folders'), isEmpty);
    await bloc.close();
  });

  test('adding folders persists them and ignores ones already covered', () async {
    final manage = ManageGalleryFoldersUseCase(
      GalleryRepositoryImpl(localDataSource: dataSource),
    );
    final trip = p.join(root.path, 'trip');

    var folders = await manage.addFolder([], trip);
    expect(folders, [trip]);

    // A subfolder of an added folder is already scanned
    expect(await manage.addFolder(folders, p.join(trip, 'day1')), same(folders));

    // Adding the parent replaces its added subfolders
    folders = await manage.addFolder(folders, root.path);
    expect(folders, [root.path]);
    expect(manage.getFolders(), [root.path]);
  });
}
