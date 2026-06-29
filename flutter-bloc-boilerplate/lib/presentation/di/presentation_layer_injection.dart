import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/domain/usecases/auth/get_current_user_use_case.dart';
import 'package:my_bloc_app/domain/usecases/auth/sign_in_use_case.dart';
import 'package:my_bloc_app/domain/usecases/auth/sign_out_use_case.dart';
import 'package:my_bloc_app/domain/usecases/auth/sign_up_use_case.dart';
import 'package:my_bloc_app/domain/usecases/theme/get_theme_mode_use_case.dart';
import 'package:my_bloc_app/domain/usecases/theme/set_theme_mode_use_case.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:my_bloc_app/presentation/blocs/chat/chat_cubit.dart';
import 'package:my_bloc_app/presentation/blocs/handyman/handyman_cubit.dart';
import 'package:my_bloc_app/presentation/blocs/theme/theme_config_cubit.dart';
import 'package:my_bloc_app/presentation/blocs/theme/theme_cubit.dart';
import 'package:my_bloc_app/domain/repository_interfaces/handyman_repository.dart';
import 'package:my_bloc_app/domain/repository_interfaces/theme_config_repository.dart';

mixin PresentationLayerInjection {
  static Future<void> configurePresentationLayerInjection() async {
    getIt.registerLazySingleton<ThemeCubit>(
      () => ThemeCubit(
        getThemeModeUseCase: getIt<GetThemeModeUseCase>(),
        setThemeModeUseCase: getIt<SetThemeModeUseCase>(),
      ),
    );

    getIt.registerLazySingleton<ThemeConfigCubit>(
      () => ThemeConfigCubit(repository: getIt<ThemeConfigRepository>()),
    );

    getIt.registerFactory<HandymanCubit>(
      () => HandymanCubit(repository: getIt<HandymanRepository>()),
    );

    getIt.registerFactory<ChatCubit>(
      () => ChatCubit(repository: getIt<HandymanRepository>()),
    );

    getIt.registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        signInUseCase: getIt<SignInUseCase>(),
        signUpUseCase: getIt<SignUpUseCase>(),
        signOutUseCase: getIt<SignOutUseCase>(),
        getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
      ),
    );
  }
}
