import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_state.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';
import 'package:my_bloc_app/presentation/routes/go_router_refresh_stream.dart';
import 'package:my_bloc_app/presentation/routes/modules/app_route_module.dart';
import 'package:my_bloc_app/presentation/routes/modules/auth_route_module.dart';
import 'package:my_bloc_app/presentation/routes/modules/customer_route_module.dart';
import 'package:my_bloc_app/presentation/routes/modules/provider_route_module.dart';

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    final refreshListenable = GoRouterRefreshStream(authBloc.stream);

    return GoRouter(
      initialLocation: AppRoute.splash.path,
      refreshListenable: refreshListenable,
      redirect: (context, state) {
        final authState = context.read<AuthBloc>().state;
        final location = state.matchedLocation;
        final currentRoute = AppRoute.fromPath(location);

        if (currentRoute == null) {
          return AppRoute.roleSelection.path;
        }

        if (authState is AuthAuthenticated) {
          final user = authState.user;
          if (currentRoute.isAuthRoute ||
              currentRoute == AppRoute.splash ||
              currentRoute == AppRoute.roleSelection) {
            if (user.isCustomer) return AppRoute.customerHome.path;
            if (user.isProvider) {
              if (user.isProviderPending) return AppRoute.providerPending.path;
              if (!user.isProviderApproved) return AppRoute.providerOnboarding.path;
              return AppRoute.providerHome.path;
            }
            return AppRoute.customerHome.path;
          }

          if (user.isCustomer && location.startsWith('/provider')) {
            return AppRoute.customerHome.path;
          }
          if (user.isProvider && location.startsWith('/customer')) {
            return AppRoute.providerHome.path;
          }
        }

        if (authState is AuthUnauthenticated && !currentRoute.isPublicRoute) {
          return AppRoute.roleSelection.path;
        }

        return null;
      },
      routes: [
        ...authRouteModule,
        ...customerRouteModule,
        ...providerRouteModule,
        ...appRouteModule,
      ],
    );
  }
}

late final GoRouter appRouter;

void initializeRouter(AuthBloc authBloc) {
  appRouter = AppRouter.createRouter(authBloc);
}
