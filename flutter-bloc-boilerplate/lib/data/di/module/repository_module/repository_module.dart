import 'package:my_bloc_app/core/config/flavors/flavors.dart';
import 'package:my_bloc_app/data/data_sources/local/auth_local_data_source.dart';
import 'package:my_bloc_app/data/data_sources/local/theme_local_data_source.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/auth/auth_api.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/handyman/handyman_api.dart';
import 'package:my_bloc_app/data/local/database/app_database.dart';
import 'package:my_bloc_app/data/local/local_cache_store.dart';
import 'package:my_bloc_app/data/repository/auth_repository_impl.dart';
import 'package:my_bloc_app/data/repository/handyman_repository_impl.dart';
import 'package:my_bloc_app/data/repository/handyman_repository_mock_impl.dart';
import 'package:my_bloc_app/data/repository/theme_config_repository_impl.dart';
import 'package:my_bloc_app/data/repository/theme_config_repository_mock_impl.dart';
import 'package:my_bloc_app/data/repository/theme_repository_impl.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/domain/repository_interfaces/auth_repository.dart';
import 'package:my_bloc_app/domain/repository_interfaces/handyman_repository.dart';
import 'package:my_bloc_app/domain/repository_interfaces/theme_config_repository.dart';
import 'package:my_bloc_app/domain/repository_interfaces/theme_repository.dart';

mixin RepositoryModule {
  static Future<void> configureRepositoryModuleInjection() async {
    getIt.registerLazySingleton<ThemeLocalDataSource>(
      ThemeLocalDataSourceImpl.new,
    );

    getIt.registerLazySingleton<ThemeRepository>(
      () => ThemeRepositoryImpl(getIt<ThemeLocalDataSource>()),
    );

    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        authApi: getIt<AuthApi>(),
        localDataSource: getIt<AuthLocalDataSource>(),
      ),
    );

    getIt.registerLazySingleton<ThemeConfigRepository>(() {
      if (FlavorConfig.instance.useMockAuth) {
        return ThemeConfigRepositoryMockImpl();
      }
      return ThemeConfigRepositoryImpl();
    });

    getIt.registerLazySingleton<AppDatabase>(AppDatabase.new);

    getIt.registerLazySingleton<LocalCacheStore>(
      () => LocalCacheStore(getIt<AppDatabase>()),
    );

    getIt.registerLazySingleton<HandymanRepository>(() {
      if (FlavorConfig.instance.useMockAuth) {
        return HandymanRepositoryMockImpl(getIt<AuthLocalDataSource>());
      }
      return HandymanRepositoryImpl(
        api: getIt<HandymanApi>(),
        cache: getIt<LocalCacheStore>(),
      );
    });
  }
}
