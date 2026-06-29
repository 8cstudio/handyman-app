import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/domain/repository_interfaces/auth_repository.dart';
import 'package:my_bloc_app/domain/usecases/auth/get_current_user_use_case.dart';
import 'package:my_bloc_app/domain/usecases/auth/sign_in_use_case.dart';
import 'package:my_bloc_app/domain/usecases/auth/sign_out_use_case.dart';
import 'package:my_bloc_app/domain/repository_interfaces/theme_repository.dart';
import 'package:my_bloc_app/domain/usecases/auth/sign_up_use_case.dart';
import 'package:my_bloc_app/domain/usecases/theme/get_theme_mode_use_case.dart';
import 'package:my_bloc_app/domain/usecases/theme/set_theme_mode_use_case.dart';

mixin DomainLayerInjection {
  static Future<void> configureDomainLayerInjection() async {
    getIt.registerLazySingleton(
      () => SignInUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton(
      () => SignUpUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton(
      () => SignOutUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetCurrentUserUseCase(getIt<AuthRepository>()),
    );
    getIt.registerLazySingleton(
      () => GetThemeModeUseCase(getIt<ThemeRepository>()),
    );
    getIt.registerLazySingleton(
      () => SetThemeModeUseCase(getIt<ThemeRepository>()),
    );
  }
}
