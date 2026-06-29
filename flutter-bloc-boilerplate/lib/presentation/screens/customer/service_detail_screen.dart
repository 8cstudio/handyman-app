import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/constants/app_text.dart';
import 'package:my_bloc_app/di/service_locator.dart';
import 'package:my_bloc_app/domain/entities/catalog/catalog_entity.dart';
import 'package:my_bloc_app/domain/repository_interfaces/handyman_repository.dart';
import 'package:my_bloc_app/presentation/common/service_image.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  ServiceEntity? _service;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = await getIt<HandymanRepository>().getService(widget.serviceId);
    if (mounted) {
      setState(() {
        _service = service;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_service == null) return const Scaffold(body: Center(child: Text('Service not found')));

    final service = _service!;
    return Scaffold(
      appBar: AppBar(title: Text(service.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ServiceImage(
              imageUrl: service.imageUrl,
              width: double.infinity,
              height: 220,
              borderRadius: BorderRadius.zero,
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(service.description ?? '', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 16),
                  Text('\$${service.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
                  Text('${service.durationMinutes} minutes'),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.push('/customer/book/${service.id}'),
                      child: const Text(AppText.bookNow),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
