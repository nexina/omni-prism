import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omni_prism/features/image_viewer/data/datasources/local/image_local_datasource.dart';
import 'package:omni_prism/features/image_viewer/data/repositories/image_repository.dart';
import 'package:omni_prism/features/image_viewer/domain/repositories/image_repository.dart';
import 'package:omni_prism/features/image_viewer/domain/usecases/get_images_in_folder.dart';
import 'package:omni_prism/features/image_viewer/domain/usecases/delete_image.dart';
import 'package:omni_prism/features/image_viewer/domain/usecases/share_image.dart';
import 'package:omni_prism/features/image_viewer/domain/usecases/set_wallpaper.dart';
import 'package:omni_prism/features/image_viewer/presentation/bloc/image_viewer_bloc.dart';
import 'package:omni_prism/features/gallery/data/datasources/local/gallery_local_datasource.dart';
import 'package:omni_prism/features/gallery/data/repositories/gallery_repository.dart';
import 'package:omni_prism/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:omni_prism/features/gallery/domain/usecases/get_default_image_folder.dart';
import 'package:omni_prism/features/gallery/domain/usecases/load_gallery_images.dart';
import 'package:omni_prism/features/gallery/domain/usecases/pick_custom_folder.dart';
import 'package:omni_prism/features/gallery/presentation/bloc/gallery_bloc.dart';
import 'package:omni_prism/features/about/presentation/bloc/about_bloc.dart';

/// Dependency injection container using GetIt
final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> init() async {
  /// ----------------------------------------------------------
  /// External
  /// ----------------------------------------------------------
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  /// ----------------------------------------------------------
  /// Feature: Image Viewer
  /// ----------------------------------------------------------
  // Data Sources
  getIt.registerLazySingleton<ImageLocalDataSource>(
    () => ImageLocalDataSourceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<ImageRepository>(
    () => ImageRepositoryImpl(localDataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton(() => GetImagesInFolderUseCase(getIt()));
  getIt.registerLazySingleton(() => DeleteImageUseCase(getIt()));
  getIt.registerLazySingleton(() => ShareImageUseCase());
  getIt.registerLazySingleton(() => SetWallpaperUseCase());

  // BLoC
  getIt.registerFactory(() => ImageViewerBloc(
    getImagesInFolder: getIt(),
    deleteImage: getIt(),
    shareImage: getIt(),
    setWallpaper: getIt(),
  ));

  /// ----------------------------------------------------------
  /// Feature: Gallery
  /// ----------------------------------------------------------
  // Data Sources
  getIt.registerLazySingleton<GalleryLocalDataSource>(
    () => GalleryLocalDataSourceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<GalleryRepository>(
    () => GalleryRepositoryImpl(localDataSource: getIt()),
  );

  // Use Cases
  getIt.registerLazySingleton<GetDefaultImageFolderUseCase>(
    () => GetDefaultImageFolderUseCase(getIt<GalleryRepository>()),
  );
  getIt.registerLazySingleton<LoadGalleryImagesUseCase>(
    () => LoadGalleryImagesUseCase(getIt<GalleryRepository>()),
  );
  getIt.registerLazySingleton<PickCustomFolderUseCase>(
    () => PickCustomFolderUseCase(getIt<GalleryRepository>()),
  );

  // BLoC
  getIt.registerFactory<GalleryBloc>(() => GalleryBloc(
    getDefaultImageFolder: getIt<GetDefaultImageFolderUseCase>(),
    loadGalleryImages: getIt<LoadGalleryImagesUseCase>(),
    pickCustomFolder: getIt<PickCustomFolderUseCase>(),
  ));

  /// ----------------------------------------------------------
  /// Feature: About
  /// ----------------------------------------------------------
  getIt.registerFactory(() => AboutBloc());
}

/// Reset all registrations (useful for testing)
Future<void> reset() async {
  await getIt.reset();
}