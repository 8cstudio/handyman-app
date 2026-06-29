import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';

extension AppRouteNavigation on BuildContext {
  void goAppRoute(AppRoute route, {Object? extra}) {
    goNamed(route.name, extra: extra);
  }

  void pushAppRoute(AppRoute route, {Object? extra}) {
    pushNamed(route.name, extra: extra);
  }
}
