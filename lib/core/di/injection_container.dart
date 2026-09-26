import 'package:get_it/get_it.dart';
import 'package:omni_preview/features/main/data/datasource/local/recent_list_local_datasource.dart';
import 'package:omni_preview/features/main/data/repositories/recent_list_repository_impl.dart';
import 'package:omni_preview/features/main/domain/repositories/recent_list_repository.dart';
import 'package:omni_preview/features/main/domain/usecase/recent_list.dart';
import 'package:omni_preview/features/main/presentation/bloc/recent_list_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  /// ----------------------------------------------------------
  /// External
  /// ----------------------------------------------------------
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  /// ----------------------------------------------------------
  /// Data sources
  /// ----------------------------------------------------------
  getIt.registerLazySingleton<RecentListLocalDataSource>(
    () => RecentListLocalDataSourceImpl(prefs: getIt()),
  );

  /// ----------------------------------------------------------
  /// Repositories
  /// ----------------------------------------------------------
  getIt.registerLazySingleton<RecentListRepository>(
    () => RecentListRepositoryImpl(localDataSource: getIt()),
  );

  /// ----------------------------------------------------------
  /// Use cases
  /// ----------------------------------------------------------
  getIt.registerLazySingleton(() => GetRecentList(getIt()));

  getIt.registerLazySingleton(() => AddFileInRecent(getIt()));

  getIt.registerLazySingleton(() => RemoveFileFromRecentList(getIt()));

  getIt.registerLazySingleton(() => ClearRecentList(getIt()));

  /// ----------------------------------------------------------
  /// BLoC
  /// ----------------------------------------------------------
  getIt.registerFactory(
    () => RecentListBloc(
      getRecentFiles: getIt(),
      addRecentFile: getIt(),
      removeRecentFile: getIt(),
      clearRecentFiles: getIt(),
    ),
  );
}
