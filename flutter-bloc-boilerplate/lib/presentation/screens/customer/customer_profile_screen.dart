import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/domain/repository_interfaces/handyman_repository.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_state.dart';
import 'package:my_bloc_app/presentation/blocs/theme/theme_cubit.dart';
import 'package:my_bloc_app/presentation/common/app_widgets.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      _name.text = auth.user.name;
      _phone.text = auth.user.phone ?? '';
    }
  }

  Future<void> _save() async {
    await getIt<HandymanRepository>().updateProfile(
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      defaultAddress: _address.text.trim(),
    );
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppText.profile)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppTextField(label: AppText.name, controller: _name),
            const SizedBox(height: 16),
            AppTextField(label: AppText.phone, controller: _phone),
            const SizedBox(height: 16),
            AppTextField(label: AppText.address, controller: _address),
            const SizedBox(height: 24),
            AppButton(label: AppText.save, onPressed: _save),
            const SizedBox(height: 24),
            Text(AppText.appearance, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, mode) => SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text(AppText.lightMode)),
                  ButtonSegment(value: ThemeMode.dark, label: Text(AppText.darkMode)),
                ],
                selected: {mode},
                onSelectionChanged: (s) => context.read<ThemeCubit>().setThemeMode(s.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
