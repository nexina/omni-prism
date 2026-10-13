import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_prism/features/gallery/domain/usecases/get_default_image_folder.dart';
import 'package:omni_prism/features/gallery/domain/usecases/load_gallery_images.dart';
import 'package:omni_prism/features/gallery/domain/usecases/pick_custom_folder.dart';
import 'package:omni_prism/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:omni_prism/features/gallery/presentation/bloc/gallery_state.dart';
import 'package:omni_prism/core/router/app_router.dart';
import 'package:omni_prism/core/class/working_file.dart';

/// BLoC for managing gallery state
class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final GetDefaultImageFolderUseCase _getDefaultImageFolder;
  final LoadGalleryImagesUseCase _loadGalleryImages;
  final PickCustomFolderUseCase _pickCustomFolder;

  GalleryBloc({
    required GetDefaultImageFolderUseCase getDefaultImageFolder,
    required LoadGalleryImagesUseCase loadGalleryImages,
    required PickCustomFolderUseCase pickCustomFolder,
  })  : _getDefaultImageFolder = getDefaultImageFolder,
        _loadGalleryImages = loadGalleryImages,
        _pickCustomFolder = pickCustomFolder,
        super(const GalleryState.initial()) {
    on<LoadGallery>(_onLoadGallery);
    on<PickCustomFolder>(_onPickCustomFolder);
    on<SelectImage>(_onSelectImage);
    on<RefreshGallery>(_onRefreshGallery);
  }

  /// Loads gallery images from default or specified folder
  Future<void> _onLoadGallery(LoadGallery event, Emitter<GalleryState> emit) async {
    emit(state.copyWith(status: GalleryStatus.loading, isLoading: true));

    try {
      String folderPath;
      if (event.folderPath != null && event.folderPath!.isNotEmpty) {
        folderPath = event.folderPath!;
      } else {
        folderPath = await _getDefaultImageFolder();
      }

      final images = await _loadGalleryImages(folderPath);

      if (images.isEmpty) {
        emit(state.copyWith(
          status: GalleryStatus.empty,
          folderPath: folderPath,
          images: [],
          isLoading: false,
        ));
        return;
      }

      emit(state.copyWith(
        status: GalleryStatus.loaded,
        folderPath: folderPath,
        images: images,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GalleryStatus.error,
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Picks a custom folder and loads its images
  Future<void> _onPickCustomFolder(PickCustomFolder event, Emitter<GalleryState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final folderPath = await _pickCustomFolder();
      if (folderPath != null && folderPath.isNotEmpty) {
        add(LoadGallery(folderPath: folderPath));
      } else {
        emit(state.copyWith(isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to pick folder: $e',
      ));
    }
  }

  /// Selects an image, opens the viewer and refreshes on return
  /// (images may have been deleted while viewing)
  Future<void> _onSelectImage(SelectImage event, Emitter<GalleryState> emit) async {
    if (event.index < 0 || event.index >= state.images.length) return;

    final selectedImage = state.images[event.index];
    final workingFile = WorkingFile(
      path: selectedImage.path,
      workingPath: selectedImage.path,
      size: selectedImage.size,
    );

    await AppRouter.navigateToImageViewer(workingFile);
    if (!isClosed) add(const RefreshGallery());
  }

  /// Reloads the current folder without showing the loading state
  Future<void> _onRefreshGallery(RefreshGallery event, Emitter<GalleryState> emit) async {
    if (state.folderPath.isEmpty) {
      add(const LoadGallery());
      return;
    }

    try {
      final images = await _loadGalleryImages(state.folderPath);
      emit(state.copyWith(
        status: images.isEmpty ? GalleryStatus.empty : GalleryStatus.loaded,
        images: images,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: GalleryStatus.error,
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
