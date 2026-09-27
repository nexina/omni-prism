import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:omni_prism/features/image_viewer/data/datasources/local/image_local_datasource.dart';
import 'package:omni_prism/features/image_viewer/data/repositories/image_repository.dart';
import 'package:omni_prism/features/image_viewer/domain/usecases/get_images_in_folder.dart';
import 'package:omni_prism/features/image_viewer/domain/usecases/delete_image.dart';
import 'package:omni_prism/features/image_viewer/domain/usecases/share_image.dart';
import 'package:omni_prism/features/image_viewer/domain/usecases/set_wallpaper.dart';
import 'package:omni_prism/features/image_viewer/presentation/bloc/image_viewer_bloc.dart';
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
  /// Feature: About
  /// ----------------------------------------------------------
  getIt.registerFactory(() => AboutBloc());

  /// ----------------------------------------------------------
  /// Feature: Gallery (TODO: implement)
  /// ----------------------------------------------------------
  // getIt.registerLazySingleton<GalleryLocalDataSource>(
  //   () => GalleryLocalDataSourceImpl(),
  // );
  // getIt.registerLazySingleton<GalleryRepository>(
  //   () => GalleryRepositoryImpl(localDataSource: getIt()),
  // );
  // getIt.registerFactory(() => GalleryBloc(
  //   pickFolder: getIt(),
  //   loadFolder: getIt(),
  // ));
}

/// Reset all registrations (useful for testing)
Future<void> reset() async {
  await getIt.reset();
}