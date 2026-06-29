import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_bloc_app/constants/app_theme.dart';
import 'package:my_bloc_app/core/config/api_base_url.dart';
import 'package:my_bloc_app/core/config/flavors/flavors.dart';
import 'package:my_bloc_app/core/supabase/supabase_service.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:my_bloc_app/domain/entities/theme/theme_config_entity.dart';
import 'package:my_bloc_app/presentation/blocs/theme/theme_config_cubit.dart';
import 'package:my_bloc_app/presentation/blocs/theme/theme_cubit.dart';
import 'package:my_bloc_app/presentation/routes/app_router.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) {
      debugPrint('[BLoC] ${bloc.runtimeType} $change');
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    if (kDebugMode) {
      debugPrint('[BLoC ERROR] ${bloc.runtimeType}: $error');
    }
    super.onError(bloc, error, stackTrace);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final apiBaseUrl = await resolveApiBaseUrl();
  if (kDebugMode) {
    debugPrint('[API] Using base URL: $apiBaseUrl');
  }

  FlavorConfig.initialize(
    flavor: _parseFlavor(dotenv.env['FLAVOR']),
    baseUrl: apiBaseUrl,
    connectionTimeout:
        int.tryParse(dotenv.env['API_CONNECTION_TIMEOUT'] ?? '') ?? 30000,
    receiveTimeout:
        int.tryParse(dotenv.env['API_RECEIVE_TIMEOUT'] ?? '') ?? 30000,
    useMockAuth: _parseBool(dotenv.env['USE_MOCK_AUTH'], defaultValue: false),
  );

  if (!FlavorConfig.instance.useMockAuth) {
    await SupabaseService.initialize();
  }
  await ServiceLocator.configureDependencies();
  await getIt<ThemeConfigCubit>().loadThemeConfig();
  Bloc.observer = AppBlocObserver();
  final authBloc = getIt<AuthBloc>();
  initializeRouter(authBloc);

  runApp(MyApp(authBloc: authBloc));
}

AppFlavor _parseFlavor(String? value) {
  switch (value) {
    case 'staging':
      return AppFlavor.staging;
    case 'prod':
      return AppFlavor.prod;
    default:
      return AppFlavor.dev;
  }
}

bool _parseBool(String? value, {required bool defaultValue}) {
  if (value == null) return defaultValue;
  switch (value.toLowerCase()) {
    case 'true':
    case '1':
    case 'yes':
      return true;
    case 'false':
    case '0':
    case 'no':
      return false;
    default:
      return defaultValue;
  }
}

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;

  const MyApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: authBloc),
            BlocProvider(
              create: (_) => getIt<ThemeCubit>()..loadSavedTheme(),
            ),
            BlocProvider(create: (_) => getIt<ThemeConfigCubit>()),
          ],
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return BlocBuilder<ThemeConfigCubit, ThemeConfigEntity>(
                builder: (context, themeState) {
                  final themeConfig = context.read<ThemeConfigCubit>();
                  return MaterialApp.router(
                    title: themeState.platformName,
                    theme: AppTheme.buildLight(
                      themeConfig.lightExtension(),
                      themeConfig.primaryColor(),
                    ),
                    darkTheme: AppTheme.buildDark(
                      themeConfig.darkExtension(),
                      themeConfig.primaryColor(),
                    ),
                    themeMode: themeMode,
                    routerConfig: appRouter,
                    debugShowCheckedModeBanner: false,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
