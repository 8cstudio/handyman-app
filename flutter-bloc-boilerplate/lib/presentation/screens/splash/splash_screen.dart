import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_event.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_state.dart';
import 'package:my_bloc_app/presentation/common/app_widgets.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          if (user.isCustomer) {
            context.go(AppRoute.customerHome.path);
          } else if (user.isProvider) {
            if (user.isProviderPending) {
              context.go(AppRoute.providerPending.path);
            } else if (user.isProviderApproved) {
              context.go(AppRoute.providerHome.path);
            } else {
              context.go(AppRoute.providerOnboarding.path);
            }
          } else {
            context.go(AppRoute.roleSelection.path);
          }
        } else if (state is AuthUnauthenticated) {
          context.go(AppRoute.roleSelection.path);
        }
      },
      child: GlassShell(
        extendBody: false,
        body: const LoadingOverlay(message: AppText.loading),
      ),
    );
  }
}
