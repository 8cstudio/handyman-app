import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_bloc_app/domain/entities/catalog/catalog_entity.dart';
import 'package:my_bloc_app/presentation/common/service_image.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_container.dart';
import 'package:my_bloc_app/presentation/widgets/glass/glass_style.dart';

class ServiceListTile extends StatelessWidget {
  final ServiceEntity service;

  const ServiceListTile({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      onTap: () => context.push('/customer/service/${service.id}'),
      child: Row(
        children: [
          ServiceImage(
            imageUrl: service.imageUrl,
            width: 72,
            height: 72,
            borderRadius: BorderRadius.circular(GlassStyle.radiusSm),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                if (service.categoryName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    service.categoryName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  '\$${service.price.toStringAsFixed(2)} · ${service.durationMinutes} min',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
