import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/constants/app_theme_extension.dart';
import 'package:my_bloc_app/core/theme/theme_context.dart';
import 'package:my_bloc_app/presentation/blocs/theme/theme_cubit.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';
import 'package:my_bloc_app/presentation/routes/route_extensions.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(appTheme: appTheme),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text(AppText.profileTitle),
              onTap: () {
                Navigator.pop(context);
                context.goAppRoute(AppRoute.profile);
              },
            ),
            const Divider(height: 1),
            const _ThemeModeSelector(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppText.appName,
                textAlign: TextAlign.center,
                style: context.textTheme.bodySmall?.copyWith(
                  color: appTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final AppThemeExtension appTheme;

  const _DrawerHeader({required this.appTheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: context.colors.primary,
            child: const Icon(Icons.apps, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              AppText.appName,
              style: context.textTheme.titleMedium?.copyWith(
                color: appTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return DropdownMenu<ThemeMode>(
              key: ValueKey(themeMode),
              initialSelection: themeMode,
              label: const Text(AppText.appearance),
              leadingIcon: Icon(_themeModeIcon(themeMode)),
              menuStyle: MenuStyle(
                minimumSize: WidgetStateProperty.all(const Size(220, 0)),
                maximumSize: WidgetStateProperty.all(const Size(280, 400)),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: appTheme.surface.withValues(alpha: 0.6),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
              dropdownMenuEntries: const [
                DropdownMenuEntry(
                  value: ThemeMode.light,
                  label: AppText.lightMode,
                  leadingIcon: Icon(Icons.light_mode_outlined),
                ),
                DropdownMenuEntry(
                  value: ThemeMode.dark,
                  label: AppText.darkMode,
                  leadingIcon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              onSelected: (mode) {
                if (mode != null) {
                  context.read<ThemeCubit>().setThemeMode(mode);
                }
              },
            );
          },
        ),
      ),
    );
  }
}

IconData _themeModeIcon(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
    ThemeMode.system => Icons.brightness_auto_outlined,
  };
}

String _themeModeLabel(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => AppText.lightMode,
    ThemeMode.dark => AppText.darkMode,
    ThemeMode.system => AppText.systemMode,
  };
}
