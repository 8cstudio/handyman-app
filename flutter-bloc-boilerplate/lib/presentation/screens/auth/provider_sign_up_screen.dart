import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/core/utils/validation_utils.dart';
import 'package:my_bloc_app/domain/entities/user/user_role.dart';
import 'package:my_bloc_app/domain/params/auth/sign_up_params.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_event.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_state.dart';
import 'package:my_bloc_app/presentation/common/app_widgets.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';
import 'package:my_bloc_app/presentation/screens/auth/role_selection_screen.dart';

class ProviderSignUpScreen extends StatefulWidget {
  const ProviderSignUpScreen({super.key});

  @override
  State<ProviderSignUpScreen> createState() => _ProviderSignUpScreenState();
}

class _ProviderSignUpScreenState extends State<ProviderSignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _skills = TextEditingController();
  final _experience = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _skills.dispose();
    _experience.dispose();
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
        if (state is AuthAuthenticated) context.go(AppRoute.providerPending.path);
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          return AuthFormScaffold(
            title: AppText.signUp,
            subtitle: 'Provider ${AppText.createAccount}',
            isLoading: state is AuthLoading,
            fields: [
              AppTextField(label: AppText.name, controller: _name, validator: (v) => v?.isEmpty == true ? 'Required' : null),
              const SizedBox(height: 16),
              AppTextField(label: AppText.email, controller: _email, keyboardType: TextInputType.emailAddress, validator: ValidationUtils.validateEmail),
              const SizedBox(height: 16),
              AppTextField(label: AppText.phone, controller: _phone),
              const SizedBox(height: 16),
              AppTextField(label: AppText.skills, controller: _skills),
              const SizedBox(height: 16),
              AppTextField(label: AppText.experience, controller: _experience, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              AppTextField(label: AppText.password, controller: _password, obscureText: true, validator: ValidationUtils.validatePassword),
            ],
            submitLabel: AppText.signUp,
            onSubmit: () => context.read<AuthBloc>().add(SignUpRequested(SignUpParams(
              email: _email.text.trim(),
              password: _password.text,
              name: _name.text.trim(),
              role: UserRole.provider,
              phone: _phone.text.trim(),
              skills: _skills.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
              experienceYears: int.tryParse(_experience.text) ?? 0,
            ))),
            alternateLabel: 'Already have an account? Sign in',
            onAlternate: () => context.go(AppRoute.providerSignIn.path),
          );
        },
      ),
    );
  }
}
