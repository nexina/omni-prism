import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_prism/features/image_viewer/data/models/image_item.dart';
import 'package:omni_prism/features/image_viewer/domain/usecases/delete_image.dart';
import 'package:omni_prism/features/image_viewer/domain/usecases/get_images_in_folder.dart';
import 'package:omni_prism/features/image_viewer/domain/usecases/set_wallpaper.dart';
import 'package:omni_prism/features/image_viewer/domain/usecases/share_image.dart';
import 'image_viewer_event.dart';
import 'image_viewer_state.dart';

/// BLoC for managing image viewer state
class ImageViewerBloc extends Bloc<ImageViewerEvent, ImageViewerState> {
  final GetImagesInFolderUseCase _getImagesInFolder;
  final DeleteImageUseCase _deleteImage;
  final ShareImageUseCase _shareImage;
  final SetWallpaperUseCase _setWallpaper;

  ImageViewerBloc({
    required GetImagesInFolderUseCase getImagesInFolder,
    required DeleteImageUseCase deleteImage,
    required ShareImageUseCase shareImage,
    required SetWallpaperUseCase setWallpaper,
  })  : _getImagesInFolder = getImagesInFolder,
        _deleteImage = deleteImage,
        _shareImage = shareImage,
        _setWallpaper = setWallpaper,
        super(const ImageViewerState.initial()) {
    on<LoadImages>(_onLoadImages);
    on<NavigateNext>(_onNavigateNext);
    on<NavigatePrev>(_onNavigatePrev);
    on<GoToIndex>(_onGoToIndex);
    on<DeleteCurrent>(_onDeleteCurrent);
    on<ShareCurrent>(_onShareCurrent);
    on<ToggleFullscreen>(_onToggleFullscreen);
    on<ToggleVisibility>(_onToggleVisibility);
    on<SetFolderPath>(_onSetFolderPath);
  }

  /// Loads images from a folder
  Future<void> _onLoadImages(LoadImages event, Emitter<ImageViewerState> emit) async {
    emit(state.copyWith(status: ImageViewerStatus.loading));

    try {
      final images = await _getImagesInFolder(event.folderPath);
      if (images.isEmpty) {
        emit(state.copyWith(
          status: ImageViewerStatus.empty,
          folderPath: event.folderPath,
        ));
        return;
      }

      // Find initial index
      int initialIndex = event.initialIndex;
      if (initialIndex < 0 || initialIndex >= images.length) {
        initialIndex = 0;
      }

      emit(state.copyWith(
        status: ImageViewerStatus.loaded,
        folderPath: event.folderPath,
        images: images,
        currentIndex: initialIndex,
        currentImage: images[initialIndex],
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ImageViewerStatus.error,
        error: e.toString(),
      ));
    }
  }

  /// Navigates to next image
  void _onNavigateNext(NavigateNext event, Emitter<ImageViewerState> emit) {
    if (state.status != ImageViewerStatus.loaded) return;
    if (state.currentIndex < state.images.length - 1) {
      final newIndex = state.currentIndex + 1;
      emit(state.copyWith(
        currentIndex: newIndex,
        currentImage: state.images[newIndex],
      ));
    }
  }

  /// Navigates to previous image
  void _onNavigatePrev(NavigatePrev event, Emitter<ImageViewerState> emit) {
    if (state.status != ImageViewerStatus.loaded) return;
    if (state.currentIndex > 0) {
      final newIndex = state.currentIndex - 1;
      emit(state.copyWith(
        currentIndex: newIndex,
        currentImage: state.images[newIndex],
      ));
    }
  }

  /// Goes to a specific index
  void _onGoToIndex(GoToIndex event, Emitter<ImageViewerState> emit) {
    if (state.status != ImageViewerStatus.loaded) return;
    if (event.index >= 0 && event.index < state.images.length) {
      emit(state.copyWith(
        currentIndex: event.index,
        currentImage: state.images[event.index],
      ));
    }
  }

  /// Deletes the current image
  Future<void> _onDeleteCurrent(DeleteCurrent event, Emitter<ImageViewerState> emit) async {
    if (state.status != ImageViewerStatus.loaded || state.currentImage == null) return;

    try {
      final deleted = await _deleteImage(state.currentImage!.path);
      if (!deleted) {
        emit(state.copyWith(error: 'Failed to delete image'));
        return;
      }

      // Remove from list
      final newImages = List<ImageItem>.from(state.images);
      newImages.removeAt(state.currentIndex);

      if (newImages.isEmpty) {
        emit(state.copyWith(
          status: ImageViewerStatus.empty,
          images: [],
          currentIndex: -1,
          currentImage: null,
        ));
        return;
      }

      // Adjust index
      int newIndex = state.currentIndex;
      if (newIndex >= newImages.length) {
        newIndex = newImages.length - 1;
      }

      emit(state.copyWith(
        images: newImages,
        currentIndex: newIndex,
        currentImage: newImages[newIndex],
      ));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Shares the current image
  Future<void> _onShareCurrent(ShareCurrent event, Emitter<ImageViewerState> emit) async {
    if (state.currentImage == null) return;

    try {
      await _shareImage(state.currentImage!.path, text: 'Share image via -');
    } catch (e) {
      emit(state.copyWith(error: 'Failed to share image: $e'));
    }
  }

  /// Toggles fullscreen mode
  void _onToggleFullscreen(ToggleFullscreen event, Emitter<ImageViewerState> emit) {
    emit(state.copyWith(isFullscreen: !state.isFullscreen));
  }

  /// Toggles UI visibility
  void _onToggleVisibility(ToggleVisibility event, Emitter<ImageViewerState> emit) {
    emit(state.copyWith(isVisible: !state.isVisible));
  }

  /// Sets the folder path (for initial load from CLI args)
  void _onSetFolderPath(SetFolderPath event, Emitter<ImageViewerState> emit) {
    // This is handled by LoadImages event
  }
}