import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/core/theme/theme_context.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/domain/repository_interfaces/handyman_repository.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:my_bloc_app/presentation/blocs/auth/auth_state.dart';
import 'package:my_bloc_app/presentation/blocs/theme/theme_cubit.dart';
import 'package:my_bloc_app/presentation/common/app_widgets.dart';
import 'package:my_bloc_app/presentation/common/role_shell_widgets.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_container.dart';
import 'package:my_bloc_app/presentation/widgets/glass/shell_tab_scroll_view.dart';

class ProfileHeaderCard extends StatelessWidget {
  final AppRole role;
  final String name;
  final String email;
  final String? subtitle;

  const ProfileHeaderCard({
    super.key,
    required this.role,
    required this.name,
    required this.email,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: context.colors.primary,
              child: Icon(
                role == AppRole.customer ? Icons.person : Icons.handyman,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.appTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.appTheme.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      subtitle ?? (role == AppRole.customer ? 'Customer' : 'Provider'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

class ProfileSectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.appTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class CustomerProfileTab extends StatefulWidget {
  const CustomerProfileTab({super.key});

  @override
  State<CustomerProfileTab> createState() => _CustomerProfileTabState();
}

class _CustomerProfileTabState extends State<CustomerProfileTab> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      _name.text = auth.user.name;
      _phone.text = auth.user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await getIt<HandymanRepository>().updateProfile(
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
      defaultAddress: _address.text.trim(),
    );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final user = auth is AuthAuthenticated ? auth.user : null;

    return ShellTabScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeaderCard(
            role: AppRole.customer,
            name: user?.name ?? AppText.appName,
            email: user?.email ?? '',
          ),
          const SizedBox(height: 16),
          ProfileSectionCard(
            title: 'Personal Information',
            children: [
              AppTextField(label: AppText.name, controller: _name),
              const SizedBox(height: 16),
              AppTextField(
                label: AppText.phone,
                controller: _phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(label: AppText.address, controller: _address),
            ],
          ),
          const SizedBox(height: 16),
          ProfileSectionCard(
            title: AppText.appearance,
            children: [
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) => SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(AppText.lightMode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(AppText.darkMode),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (s) =>
                      context.read<ThemeCubit>().setThemeMode(s.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppButton(
            label: _saving ? AppText.loading : AppText.save,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}

class ProviderProfileTab extends StatelessWidget {
  const ProviderProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final user = auth is AuthAuthenticated ? auth.user : null;
    final statusLabel = user?.providerStatus == 'approved'
        ? 'Approved Provider'
        : user?.providerStatus == 'pending'
            ? 'Pending Approval'
            : 'Provider';

    return ShellTabScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProfileHeaderCard(
            role: AppRole.provider,
            name: user?.name ?? AppText.appName,
            email: user?.email ?? '',
            subtitle: statusLabel,
          ),
          const SizedBox(height: 16),
          ProfileSectionCard(
            title: 'Professional Details',
            children: [
              _ReadOnlyField(label: AppText.name, value: user?.name ?? '—'),
              const SizedBox(height: 12),
              _ReadOnlyField(label: AppText.phone, value: user?.phone ?? '—'),
              const SizedBox(height: 12),
              _ReadOnlyField(
                label: AppText.skills,
                value: user?.providerSkills?.join(', ') ?? '—',
              ),
              const SizedBox(height: 12),
              _ReadOnlyField(
                label: 'Experience',
                value: user?.providerExperienceYears != null
                    ? '${user!.providerExperienceYears} years'
                    : '—',
              ),
              if ((user?.providerBio ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                _ReadOnlyField(label: 'Bio', value: user!.providerBio!),
              ],
            ],
          ),
          const SizedBox(height: 16),
          ProfileSectionCard(
            title: AppText.appearance,
            children: [
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) => SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(AppText.lightMode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(AppText.darkMode),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (s) =>
                      context.read<ThemeCubit>().setThemeMode(s.first),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Profile changes are managed by your company admin.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.appTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: context.appTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: context.appTheme.textPrimary,
              ),
        ),
      ],
    );
  }
}
