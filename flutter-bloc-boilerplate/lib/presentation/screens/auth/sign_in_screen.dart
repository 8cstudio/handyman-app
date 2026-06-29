import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/core/utils/validation_utils.dart';
import 'package:my_bloc_app/domain/params/auth/sign_in_params.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_event.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_state.dart';
import 'package:my_bloc_app/presentation/common/app_widgets.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';
import 'package:my_bloc_app/presentation/routes/route_extensions.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          SignInRequested(
            SignInParams(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.read<AuthBloc>().add(const AuthReset());
        }
        if (state is AuthAuthenticated) {
          context.goAppRoute(AppRoute.home);
        }
      },
      child: AppScaffold(
        title: AppText.signIn,
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => _buildBody(state),
        ),
      ),
    );
  }

  Widget _buildBody(AuthState state) {
    if (state is AuthLoading) {
      return const LoadingOverlay();
    }

    return _buildContent();
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppText.welcome,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: AppText.email,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: ValidationUtils.validateEmail,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: AppText.password,
              controller: _passwordController,
              obscureText: true,
              validator: ValidationUtils.validatePassword,
            ),
            const SizedBox(height: 24),
            AppButton(label: AppText.signIn, onPressed: _submit),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.goAppRoute(AppRoute.signUp),
              child: const Text(AppText.noAccount),
            ),
          ],
        ),
      ),
    );
  }
}
