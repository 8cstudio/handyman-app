import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';
import 'package:my_bloc_app/presentation/screens/home/home_screen.dart';
import 'package:my_bloc_app/presentation/screens/profile/profile_screen.dart';

List<RouteBase> get appRouteModule => [
      GoRoute(
        name: AppRoute.home.name,
        path: AppRoute.home.path,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        name: AppRoute.profile.name,
        path: AppRoute.profile.path,
        builder: (context, state) => const ProfileScreen(),
      ),
    ];
