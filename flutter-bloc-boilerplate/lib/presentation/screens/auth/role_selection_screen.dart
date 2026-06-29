import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/core/config/flavors/flavors.dart';
import 'package:my_bloc_app/core/theme/theme_context.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_app_bar.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_container.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_shell.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_style.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassShell(
      extendBody: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              GlassContainer(
                blur: true,
                elevated: true,
                borderRadius: GlassStyle.radiusXl,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    Text(
                      AppText.appName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: context.appTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppText.roleSelectionTitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: context.appTheme.textSecondary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (FlavorConfig.instance.useMockAuth)
                GlassContainer(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Mock mode — try customer@demo.com or provider@demo.com (any password)',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.appTheme.textSecondary,
                        ),
                  ),
                ),
              ElevatedButton(
                onPressed: () => context.go(AppRoute.customerSignIn.path),
                child: Text(AppText.continueAsCustomer),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go(AppRoute.providerSignIn.path),
                child: Text(AppText.continueAsProvider),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthFormScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> fields;
  final String submitLabel;
  final VoidCallback onSubmit;
  final String? alternateLabel;
  final VoidCallback? onAlternate;
  final String? forgotPasswordLabel;
  final VoidCallback? onForgotPassword;
  final bool isLoading;

  const AuthFormScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.submitLabel,
    required this.onSubmit,
    this.alternateLabel,
    this.onAlternate,
    this.forgotPasswordLabel,
    this.onForgotPassword,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlassShell(
      extendBody: false,
      appBar: GlassAppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: GlassContainer(
          blur: true,
          elevated: true,
          borderRadius: GlassStyle.radiusXl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(subtitle, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 24),
              ...fields,
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                child: Text(isLoading ? AppText.loading : submitLabel),
              ),
              if (forgotPasswordLabel != null && onForgotPassword != null)
                TextButton(
                  onPressed: onForgotPassword,
                  child: Text(forgotPasswordLabel!),
                ),
              if (alternateLabel != null && onAlternate != null)
                TextButton(onPressed: onAlternate, child: Text(alternateLabel!)),
            ],
          ),
        ),
      ),
    );
  }
}
