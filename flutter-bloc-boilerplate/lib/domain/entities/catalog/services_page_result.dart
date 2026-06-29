import 'package:my_bloc_app/domain/entities/catalog/catalog_entity.dart';

class ServicesPageResult {
  final List<ServiceEntity> services;
  final bool hasMore;

  const ServicesPageResult({
    required this.services,
    required this.hasMore,
  });
}
