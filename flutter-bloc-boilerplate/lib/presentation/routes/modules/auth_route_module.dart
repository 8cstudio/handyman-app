import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';
import 'package:my_bloc_app/presentation/screens/auth/role_selection_screen.dart';
import 'package:my_bloc_app/presentation/screens/auth/customer_sign_in_screen.dart';
import 'package:my_bloc_app/presentation/screens/auth/customer_sign_up_screen.dart';
import 'package:my_bloc_app/presentation/screens/auth/forgot_password_screen.dart';
import 'package:my_bloc_app/presentation/screens/auth/provider_sign_in_screen.dart';
import 'package:my_bloc_app/presentation/screens/splash/splash_screen.dart';

List<RouteBase> get authRouteModule => [
      GoRoute(
        name: AppRoute.splash.name,
        path: AppRoute.splash.path,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRoute.roleSelection.name,
        path: AppRoute.roleSelection.path,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        name: AppRoute.customerSignIn.name,
        path: AppRoute.customerSignIn.path,
        builder: (context, state) => const CustomerSignInScreen(),
      ),
      GoRoute(
        name: AppRoute.customerSignUp.name,
        path: AppRoute.customerSignUp.path,
        builder: (context, state) => const CustomerSignUpScreen(),
      ),
      GoRoute(
        name: AppRoute.providerSignIn.name,
        path: AppRoute.providerSignIn.path,
        builder: (context, state) => const ProviderSignInScreen(),
      ),
      GoRoute(
        name: AppRoute.forgotPassword.name,
        path: AppRoute.forgotPassword.path,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
    ];
