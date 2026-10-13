import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_prism/features/gallery/domain/usecases/manage_gallery_folders.dart';
import 'package:omni_prism/features/gallery/domain/usecases/pick_custom_folder.dart';
import 'package:omni_prism/features/gallery/domain/usecases/scan_gallery_images.dart';
import 'package:omni_prism/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:omni_prism/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:omni_prism/core/router/app_router.dart';
import 'package:omni_prism/core/class/working_file.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';

/// BLoC for managing gallery state
class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final ManageGalleryFoldersUseCase _manageFolders;
  final ScanGalleryImagesUseCase _scanGalleryImages;
  final PickCustomFolderUseCase _pickCustomFolder;

  GalleryBloc({
    required ManageGalleryFoldersUseCase manageFolders,
    required ScanGalleryImagesUseCase scanGalleryImages,
    required PickCustomFolderUseCase pickCustomFolder,
  })  : _manageFolders = manageFolders,
        _scanGalleryImages = scanGalleryImages,
        _pickCustomFolder = pickCustomFolder,
        super(const GalleryState.initial()) {
    // A new load cancels the running scan (which kills its isolate)
    on<LoadGallery>(_onLoadGallery);
    on<PickCustomFolder>(_onPickCustomFolder);
    on<RemoveFolder>(_onRemoveFolder);
    on<SelectImage>(_onSelectImage);
    on<RefreshGallery>(_onRefreshGallery);
    on<PruneMissingImages>(_onPruneMissingImages);
  }

  /// Scans the added folders in the background, adding images to the
  /// gallery as each batch arrives. Does nothing until a folder is added.
  Future<void> _onLoadGallery(
      LoadGallery event, Emitter<GalleryState> emit) async {
    final folders = event.folders ?? _manageFolders.getFolders();

    if (folders.isEmpty) {
      emit(const GalleryState(status: GalleryStatus.empty));
      return;
    }

    emit(GalleryState(
      status: GalleryStatus.loading,
      folders: folders,
      isLoading: true,
    ));

    await emit.forEach<List<ImageItem>>(
      _scanFolders(folders),
      onData: (batch) => state.copyWith(
        status: GalleryStatus.loaded,
        images: [...state.images, ...batch],
      ),
      onError: (error, stackTrace) => state.copyWith(
        status: state.hasImages ? GalleryStatus.loaded : GalleryStatus.error,
        isLoading: false,
        error: error.toString(),
      ),
    );

    emit(state.copyWith(
      status: state.hasImages
          ? GalleryStatus.loaded
          : (state.status == GalleryStatus.error
              ? GalleryStatus.error
              : GalleryStatus.empty),
      isLoading: false,
    ));
  }

  /// Scans folders one after another
  Stream<List<ImageItem>> _scanFolders(List<String> folders) async* {
    for (final folder in folders) {
      yield* _scanGalleryImages(folder);
    }
  }

  /// Picks a folder, saves it and rescans
  Future<void> _onPickCustomFolder(
      PickCustomFolder event, Emitter<GalleryState> emit) async {
    try {
      final folderPath = await _pickCustomFolder();
      if (folderPath == null || folderPath.isEmpty) return;

      final folders = await _manageFolders.addFolder(state.folders, folderPath);
      if (!identical(folders, state.folders))
        add(LoadGallery(folders: folders));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to add folder: $e'));
    }
  }

  /// Removes a folder, saves the list and rescans the rest
  Future<void> _onRemoveFolder(
      RemoveFolder event, Emitter<GalleryState> emit) async {
    final folders =
        await _manageFolders.removeFolder(state.folders, event.folderPath);
    add(LoadGallery(folders: folders));
  }

  /// Selects an image, opens the viewer and drops deleted images on return
  Future<void> _onSelectImage(
      SelectImage event, Emitter<GalleryState> emit) async {
    if (event.index < 0 || event.index >= state.images.length) return;

    final selectedImage = state.images[event.index];
    final workingFile = WorkingFile(
      path: selectedImage.path,
      workingPath: selectedImage.path,
      size: selectedImage.size,
    );

    await AppRouter.navigateToImageViewer(workingFile);
    if (!isClosed) add(const PruneMissingImages());
  }

  /// Rescans the added folders
  void _onRefreshGallery(RefreshGallery event, Emitter<GalleryState> emit) {
    add(LoadGallery(folders: state.folders));
  }

  /// Removes images whose files no longer exist (checked off the UI thread).
  /// Filters the latest state so batches from a running scan are kept.
  Future<void> _onPruneMissingImages(
    PruneMissingImages event,
    Emitter<GalleryState> emit,
  ) async {
    if (!state.hasImages) return;
    final missing = await _scanGalleryImages
        .findMissing(state.images.map((e) => e.path).toList());
    if (missing.isEmpty) return;

    final images =
        state.images.where((e) => !missing.contains(e.path)).toList();
    emit(state.copyWith(
      status: images.isEmpty && !state.isLoading
          ? GalleryStatus.empty
          : state.status,
      images: images,
    ));
  }
}
