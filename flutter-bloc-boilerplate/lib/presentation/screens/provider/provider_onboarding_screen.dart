import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/core/supabase/supabase_service.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/domain/repository_interfaces/handyman_repository.dart';
import 'package:my_bloc_app/presentation/routes/app_routes.dart';

class ProviderOnboardingScreen extends StatefulWidget {
  const ProviderOnboardingScreen({super.key});

  @override
  State<ProviderOnboardingScreen> createState() => _ProviderOnboardingScreenState();
}

class _ProviderOnboardingScreenState extends State<ProviderOnboardingScreen> {
  bool _uploading = false;
  String? _message;

  Future<void> _uploadDocument(String type) async {
    setState(() { _uploading = true; _message = null; });
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final userId = SupabaseService.client.auth.currentUser!.id;
      final path = '$userId/${type}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final url = await getIt<HandymanRepository>().uploadFile(
        'provider-documents',
        path,
        bytes,
      );

      final providerId = await getIt<HandymanRepository>().getProviderId();
      if (providerId == null) throw Exception('Provider profile not found');

      await getIt<HandymanRepository>().uploadProviderDocument(
        providerId: providerId,
        documentType: type,
        fileUrl: url,
      );

      setState(() => _message = '$type uploaded successfully');
    } catch (e) {
      setState(() => _message = e.toString());
    } finally {
      setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppText.uploadDocuments)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Upload your ID card and license to complete registration.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _uploading ? null : () => _uploadDocument('id_card'),
              child: const Text('Upload ID Card'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _uploading ? null : () => _uploadDocument('license'),
              child: const Text('Upload License'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _uploading ? null : () => _uploadDocument('profile_picture'),
              child: const Text('Upload Profile Picture'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(_message!, textAlign: TextAlign.center),
            ],
            const Spacer(),
            OutlinedButton(
              onPressed: () => context.go(AppRoute.providerPending.path),
              child: const Text('Continue — Wait for Approval'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _skills = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _skills.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await getIt<HandymanRepository>().updateProfile(
      fullName: _name.text.trim(),
      phone: _phone.text.trim(),
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
            TextField(controller: _name, decoration: const InputDecoration(labelText: AppText.name)),
            const SizedBox(height: 16),
            TextField(controller: _phone, decoration: const InputDecoration(labelText: AppText.phone)),
            const SizedBox(height: 16),
            TextField(controller: _skills, decoration: const InputDecoration(labelText: AppText.skills)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text(AppText.save)),
          ],
        ),
      ),
    );
  }
}
