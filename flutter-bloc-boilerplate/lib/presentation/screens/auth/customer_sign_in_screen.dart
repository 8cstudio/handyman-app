import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/core/utils/validation_utils.dart';
import 'package:my_bloc_app/domain/params/auth/sign_in_params.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_event.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_state.dart';
import 'package:my_bloc_app/presentation/common/app_widgets.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';
import 'package:my_bloc_app/presentation/screens/auth/role_selection_screen.dart';

class CustomerSignInScreen extends StatefulWidget {
  const CustomerSignInScreen({super.key});

  @override
  State<CustomerSignInScreen> createState() => _CustomerSignInScreenState();
}

class _CustomerSignInScreenState extends State<CustomerSignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          context.read<AuthBloc>().add(const AuthReset());
        }
        if (state is AuthAuthenticated) context.go(AppRoute.customerHome.path);
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return AuthFormScaffold(
            title: AppText.signIn,
            subtitle: '${AppText.welcome} (Customer)',
            isLoading: state is AuthLoading,
            fields: [
              AppTextField(label: AppText.email, controller: _email, keyboardType: TextInputType.emailAddress, validator: ValidationUtils.validateEmail),
              const SizedBox(height: 16),
              AppTextField(label: AppText.password, controller: _password, obscureText: true, validator: ValidationUtils.validatePassword),
            ],
            submitLabel: AppText.signIn,
            onSubmit: () => context.read<AuthBloc>().add(SignInRequested(SignInParams(email: _email.text.trim(), password: _password.text))),
            alternateLabel: "Don't have an account? Sign up",
            onAlternate: () => context.go(AppRoute.customerSignUp.path),
            forgotPasswordLabel: 'Forgot password?',
            onForgotPassword: () => context.go(AppRoute.forgotPassword.path),
          );
        },
      ),
    );
  }
}
