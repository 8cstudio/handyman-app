import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_bloc_app/core/config/flavors/flavors.dart';
import 'package:my_bloc_app/core/dio/configs/dio_configs.dart';
import 'package:my_bloc_app/core/dio/dio_client.dart';
import 'package:my_bloc_app/core/dio/interceptor/auth_interceptor.dart';
import 'package:my_bloc_app/data/data_sources/local/auth_local_data_source.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/auth/auth_api.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/auth/auth_api_impl.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/auth/auth_api_mock_impl.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/handyman/handyman_api.dart';
import 'package:my_bloc_app/data/data_sources/remote/apis/handyman/handyman_api_impl.dart';
import 'package:my_bloc_app/di/service_locator.dart';

mixin NetworkModule {
  static Future<void> configureNetworkModuleInjection() async {
    getIt.registerLazySingleton<AuthLocalDataSource>(
      AuthLocalDataSourceImpl.new,
    );

    getIt.registerLazySingleton<LoggingInterceptor>(LoggingInterceptor.new);

    getIt.registerLazySingleton<AuthInterceptor>(
      () => AuthInterceptor(getIt<AuthLocalDataSource>()),
    );

    getIt.registerLazySingleton<DioConfigs>(
      () => DioConfigs(
        baseUrl: FlavorConfig.instance.baseUrl,
        connectionTimeout: FlavorConfig.instance.connectionTimeout,
        receiveTimeout: FlavorConfig.instance.receiveTimeout,
      ),
    );

    getIt.registerLazySingleton<DioClient>(
      () => DioClient.basic(dioConfigs: getIt<DioConfigs>())
        ..addInterceptors([
          getIt<AuthInterceptor>(),
          getIt<LoggingInterceptor>(),
        ]),
    );

    getIt.registerLazySingleton<AuthApi>(() {
      if (FlavorConfig.instance.useMockAuth) {
        return AuthApiMockImpl();
      }
      return AuthApiImpl(getIt<DioClient>());
    });

    getIt.registerLazySingleton<HandymanApi>(
      () => HandymanApiImpl(getIt<DioClient>()),
    );
  }
}
