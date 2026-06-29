import 'package:flutter/material.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/core/theme/theme_context.dart';
import 'package:my_bloc_app/presentation/common/app_drawer.dart';
import 'package:my_bloc_app/presentation/common/app_widgets.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';
import 'package:my_bloc_app/presentation/routes/route_extensions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: AppText.homeTitle,
      drawer: const AppDrawer(),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => context.goAppRoute(AppRoute.profile),
        ),
      ],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.dashboard_outlined,
                size: 64,
                color: context.colors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Dashboard',
                style: context.textTheme.headlineMedium?.copyWith(
                  color: context.appTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Clean Architecture + BLoC boilerplate is ready.',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.appTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Text(
                context.isDarkMode ? 'Dark mode active' : 'Light mode active',
                style: context.textTheme.labelLarge?.copyWith(
                  color: context.colors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
