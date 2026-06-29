import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory CategoryEntity.fromJson(Map<String, dynamic> json) => CategoryEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
      );

  @override
  List<Object?> get props => [id, name, description, imageUrl];
}

class ServiceEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double price;
  final int durationMinutes;
  final String? imageUrl;
  final String categoryId;
  final String? categoryName;

  const ServiceEntity({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.durationMinutes,
    this.imageUrl,
    required this.categoryId,
    this.categoryName,
  });

  factory ServiceEntity.fromJson(Map<String, dynamic> json) => ServiceEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        price: (json['price'] as num?)?.toDouble() ?? 0,
        durationMinutes: json['duration_minutes'] as int? ?? 60,
        imageUrl: json['image_url'] as String?,
        categoryId: json['category_id'] as String,
        categoryName: (json['categories'] as Map?)?['name'] as String?,
      );

  @override
  List<Object?> get props => [id, name, price, categoryId];
}
