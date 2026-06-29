import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/core/utils/validation_utils.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/domain/repository_interfaces/auth_repository.dart';
import 'package:my_bloc_app/presentation/common/app_widgets.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    if (ValidationUtils.validateEmail(email) != null) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await getIt<AuthRepository>().forgotPassword(email);
      setState(() {
        _message =
            'If an account exists for this email, reset instructions have been sent.';
      });
    } catch (e) {
      setState(() {
        _message = e.toString();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter your email and we will send password reset instructions.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: AppText.email,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: ValidationUtils.validateEmail,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              child: Text(_loading ? AppText.loading : 'Send reset link'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(_message!, style: Theme.of(context).textTheme.bodyMedium),
            ],
            TextButton(
              onPressed: () => context.go(AppRoute.roleSelection.path),
              child: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
